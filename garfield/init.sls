garfield:
  group:
    - present
  user.present:
    - fullname: garfield 
    - gid_from_name: True
    - shell: /sbin/nologin
    - createhome: False
    - require:
      - group: garfield 
      - pkg: nginx
      - pkg: postgres
      - pkg: supervisor
      - pkg: rabbitmq
  git.latest:
    - name: git://github.com/RobSpectre/garfield
    - target: /opt/garfield
    - rev: master 
    - submodules: True
    - force_checkout: True
    - user: garfield 
    - require:
      - file: garfield-app-directory
  virtualenv.managed:
    - name: /opt/garfield/venv
    - system_site_packages: False
    - python: python3.5 
    - requirements: /opt/garfield/requirements.txt
    - user: garfield 
    - require:
      - git: garfield 

garfield-app-conf:
  file.managed:
    - name: /opt/garfield/garfield/garfield/local.py
    - source: salt://garfield/app.py
    - mode: 600
    - user: garfield 
    - group: garfield 
    - template: jinja
    - context:
      {% if pillar['admins'] %}
      admins: {{ pillar['admins'] }}
      {% else %}
      admins: None
      {% endif %}
      db_name: {{ pillar['database']['user']['name'] }}
      db_password: {{ pillar['database']['user']['password'] }}
      db_user: {{ pillar['database']['user']['name'] }}
      cookie_key: {{ pillar['cookie_key'] }}
      never_cache_key: {{ pillar['never_cache_key'] }}
      email_user: {{ pillar['email']['user'] }}
      email_host: {{ pillar['email']['host'] }}
      email_password: {{ pillar['email']['password'] }}
      twilio:
        account_sid: {{ pillar['twilio']['account_sid'] }}
        auth_token: {{ pillar['twilio']['auth_token'] }}
        phone_number: {{ pillar['twilio']['phone_number'] }}
        app_sid: {{ pillar['twilio']['app_sid'] }}
      tellfinder:
        api_key: {{ pillar['tellfinder']['api_key'] }}
    - require:
      - git: garfield 

hostname-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/{{ grains['fqdn'] }}
    - source: salt://garfield/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
      fqdn: {{ grains['fqdn'] }}
    - require:
      - pkg: nginx
      - cmd: letsencrypt-{{ grains['fqdn'] }}

garfield-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/garfield
    - source: salt://garfield/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
      fqdn: garfield.humantrafficking.tips 
    - require:
      - pkg: nginx
      - cmd: letsencrypt-garfield.humantrafficking.tips

garfield-app-directory:
  file.directory:
    - name: /opt/garfield
    - mode: 755 
    - user: garfield 
    - group: garfield 
    - require:
      - user: garfield 

garfield-gunicorn-conf:
  file.managed:
    - name: /opt/garfield/gunicorn.conf.py
    - source: salt://garfield/gunicorn.conf.py
    - mode: 644
    - user: garfield 
    - group: garfield 
    - require:
      - git: garfield 

garfield-gunicorn-log:
  file.directory:
    - name: /opt/garfield/log
    - mode: 755 
    - user: garfield 
    - group: garfield 
    - recurse:
      - user
      - group
      - mode
    - require:
      - git: garfield 

garfield-postgres-user:
  postgres_user.present:
    - name: {{ pillar['database']['user']['name'] }}
    - password: {{ pillar['database']['user']['password'] }}
    - createdb: True
    - createroles: False
    - login: True
    - inherit: True
    - superuser: False
    - replication: True
    - require:
      - service: postgres

garfield-postgres-database:
  postgres_database.present:
    - name: {{ pillar['database']['user']['name'] }}
    - owner: {{ pillar['database']['user']['name'] }}
    - encoding: UTF8
    - require:
      - service: postgres
      - postgres_user: garfield-postgres-user

garfield-gunicorn:
  pip.installed:
    - name: gunicorn
    - bin_env: /opt/garfield/venv
    - require:
      - virtualenv: garfield 

garfield-psycopg2:
  pip.installed:
    - name: psycopg2-binary
    - upgrade: True
    - bin_env: /opt/garfield/venv
    - require:
      - virtualenv: garfield 

garfield-supervisord-config:
  file.managed:
    - name: /etc/supervisor/conf.d/garfield.conf
    - source: salt://garfield/supervisor.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: supervisor

garfield-supervisord:
  supervisord.running:
    - name: gunicorn_garfield
    - update: True
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - require:
      - pkg: supervisor
      - file: garfield-supervisord-config
      - git: garfield 
      - virtualenv: garfield 
      - service: postgres
      - file: garfield-app-conf
      - file: garfield-gunicorn-conf
      - postgres_database: garfield-postgres-database
    - watch:
      - pkg: supervisor
      - git: garfield 
      - file: garfield-supervisord-config
      - file: garfield-app-conf

celery-supervisord:
  supervisord.running:
    - name: celery_garfield
    - update: True
    - restart: True
    - config_file: /etc/supervisor/supervisord.conf
    - require:
      - pkg: supervisor
      - file: garfield-supervisord-config
      - git: garfield 
      - virtualenv: garfield 
      - service: postgres
      - supervisord: garfield-supervisord
      - file: garfield-app-conf
      - file: garfield-gunicorn-conf
      - postgres_database: garfield-postgres-database
    - watch:
      - pkg: supervisor
      - git: garfield 
      - file: garfield-supervisord-config
      - file: garfield-app-conf
    

garfield-migrate:
  cmd.run:
    - user: garfield 
    - cwd: /opt/garfield/garfield
    - name: /opt/garfield/venv/bin/python manage.py migrate
    - require:
      - git: garfield 
      - postgres_database: garfield-postgres-database 
      - service: postgres 
      - pip: garfield-psycopg2
      - virtualenv: garfield 
      - file: garfield-app-conf
    - watch:
      - git: garfield 

garfield-staticdir:
  file.directory:
    - name: /opt/garfield/garfield/static
    - user: garfield 
    - group: garfield 
    - mode: 755 
    - require:
      - git: garfield 

garfield-adminstaticdir:
  file.directory:
    - name: /opt/garfield/static/admin
    - user: garfield 
    - group: garfield 
    - mode: 755 
    - makedirs: True
    - require:
      - user: garfield 
      - git: garfield 

garfield-collectstatic:
  cmd.run:
    - user: garfield 
    - cwd: /opt/garfield
    - name: /opt/garfield/venv/bin/python garfield/manage.py collectstatic --noinput
    - require:
      - git: garfield 
      - file: garfield-staticdir
      - file: garfield-adminstaticdir
      - file: garfield-app-conf
    - watch:
      - git: garfield 

garfield-live:
  file.symlink:
    - name: /etc/nginx/sites-enabled/garfield
    - target: /etc/nginx/sites-available/garfield
    - require:
      - service: postgres
      - supervisord: garfield-supervisord
      - git: garfield 
      - pip: garfield-psycopg2
      - pip: garfield-gunicorn
      - file: garfield-app-conf
      - cmd: letsencrypt-garfield.humantrafficking.tips

hostname-live:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ grains['fqdn'] }}
    - target: /etc/nginx/sites-available/{{ grains['fqdn'] }}
    - require:
      - service: postgres
      - supervisord: garfield-supervisord
      - git: garfield 
      - pip: garfield-psycopg2
      - pip: garfield-gunicorn
      - file: garfield-app-conf
      - cmd: letsencrypt-{{ grains['fqdn'] }}

letsencrypt-{{ grains['fqdn'] }}:
  cmd.run:
    - name: >
             /opt/letsencrypt/bin/letsencrypt certonly --renew-by-default --standalone -d {{ grains['fqdn'] }} --non-interactive --agree-tos -m {{ pillar['email']['user'] }}
    - creates: /etc/letsencrypt/live/{{ grains['fqdn'] }}/fullchain.pem
    - require:
      - pip: letsencrypt

renew-cert-for-{{ grains['fqdn'] }}:
  cron.present:
    - name: >
         /opt/letsencrypt/bin/letsencrypt certonly --webroot -w /opt/garfield/static -d {{ grains['fqdn'] }} --non-interactive --agree-tos -m {{ pillar['email']['user'] }} 
    - identifier: renew-cert-for-{{ grains['fqdn'] }}
    - daymonth: 1
    - hour: 10
    - minute: 0
    - require:
      - cmd: letsencrypt-{{ grains['fqdn'] }}

letsencrypt-garfield.humantrafficking.tips:
  cmd.run:
    - name: >
             /opt/letsencrypt/bin/letsencrypt certonly --renew-by-default --standalone -d garfield.humantrafficking.tips --non-interactive --agree-tos -m {{ pillar['email']['user'] }}
    - creates: /etc/letsencrypt/live/garfield.humantrafficking.tips/fullchain.pem
    - require:
      - pip: letsencrypt
      - cmd: letsencrypt-{{ grains['fqdn'] }}

renew-cert-for-garfield.humantrafficking.tips:
  cron.present:
    - name: >
         /opt/letsencrypt/bin/letsencrypt certonly --webroot -w /opt/garfield/static -d garfield.humantrafficking.tips --non-interactive --agree-tos -m {{ pillar['email']['user'] }} 
    - identifier: renew-cert-for-garfield.humantrafficking.tips
    - daymonth: 1
    - hour: 10
    - minute: 0
    - require:
      - cmd: letsencrypt-garfield.humantrafficking.tips
