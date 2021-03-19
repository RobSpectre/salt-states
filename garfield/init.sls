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
    - python: python3.8 
    - requirements: /opt/garfield/requirements.txt
    - no_chace_dir: True
    - user: garfield 
    - require:
      - git: garfield 

arbuckle-key-dir:
  file.directory:
    - name: /opt/.ssh
    - mode: 700 
    - user: garfield 
    - group: garfield 
    - require:
      - user: garfield 

arbuckle-public-key:
  file.managed:
    - name: /opt/.ssh/id_rsa.pub
    - contents_pillar: ssh_keys:public
    - mode: 700 
    - user: garfield 
    - group: garfield 
    - require:
      - user: garfield 
      - file: arbuckle-key-dir

arbuckle-private-key:
  file.managed:
    - name: /opt/.ssh/id_rsa
    - contents_pillar: ssh_keys:private
    - mode: 700 
    - user: garfield 
    - group: garfield 
    - require:
      - user: garfield 
      - file: arbuckle-key-dir

arbuckle-app-directory:
  file.directory:
    - name: /opt/arbuckle
    - mode: 755 
    - user: garfield 
    - group: garfield 
    - require:
      - user: garfield 

arbuckle:
  git.latest:
    - name: git@github.com:RobSpectre/arbuckle.git 
    - target: /opt/arbuckle
    - rev: master 
    - submodules: True
    - force_checkout: True
    - identity: /opt/.ssh/id_rsa
    - user: garfield 
    - require:
      - file: arbuckle-app-directory


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
      {% if grains.get('garfield', None) %}
      twilio:
        account_sid: {{ grains['garfield']['twilio_account_sid'] }}
        auth_token: {{ grains['garfield']['twilio_auth_token'] }}
        phone_number: {{ grains['garfield']['twilio_phone_number'] }}
        app_sid: {{ grains['garfield']['twilio_app_sid'] }}
      tellfinder:
        api_key: {{ pillar['tellfinder']['api_key'] }}
      garfield:
        garfield_number_of_deterrents: {{ grains['garfield']['garfield_number_of_deterrents'] }}
        garfield_deterrent_interval: {{ grains['garfield']['garfield_deterrent_interval'] }}
        arbuckle_dir: "/opt/arbuckle"
        garfield_jurisdiction: {{ grains['garfield']['garfield_jurisdiction'] }}
      {% endif %}
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
    - name: gunicorn==19.7.1
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
      - pip: garfield-flower
    - template: jinja
    - context:
      user: {{ pillar['flower']['user']['name'] }}
      password: {{ pillar['flower']['user']['password'] }}

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
      - cmd: garfield-migrate
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
             /opt/letsencrypt/bin/letsencrypt certonly --standalone -d {{ grains['fqdn'] }} --non-interactive --agree-tos -m {{ pillar['email']['user'] }}
    - creates: /etc/letsencrypt/live/{{ grains['fqdn'] }}/fullchain.pem
    - require:
      - pip: letsencrypt

renew-cert-for-{{ grains['fqdn'] }}:
  cron.present:
    - name: >
         /opt/letsencrypt/bin/letsencrypt renew --nginx --cert-name {{ grains['fqdn'] }} --non-interactive --agree-tos -m {{ pillar['email']['user'] }} 
    - identifier: renew-cert-for-{{ grains['fqdn'] }}
    - special: '@daily'
    - require:
      - cmd: letsencrypt-{{ grains['fqdn'] }}

garfield-flower:
  pip.installed:
    - name: flower
    - upgrade: True
    - bin_env: /opt/garfield/venv
    - require:
      - virtualenv: garfield

flower-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/flower.{{ grains['fqdn'] }}
    - source: salt://garfield/nginx_flower.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
      fqdn: {{ grains['fqdn'] }}
    - require:
      - pkg: nginx
      - cmd: letsencrypt-flower.{{ grains['fqdn'] }}

flower-nginx-live:
  file.symlink:
    - name: /etc/nginx/sites-enabled/flower.{{ grains['fqdn'] }}
    - target: /etc/nginx/sites-available/flower.{{ grains['fqdn'] }}
    - require:
      - service: postgres
      - supervisord: garfield-supervisord
      - git: garfield 
      - pip: garfield-psycopg2
      - pip: garfield-gunicorn
      - file: garfield-app-conf
      - cmd: letsencrypt-flower.{{ grains['fqdn'] }}

letsencrypt-flower.{{ grains['fqdn'] }}:
  cmd.run:
    - name: >
             /opt/letsencrypt/bin/letsencrypt certonly --standalone -d flower.{{ grains['fqdn'] }} --non-interactive --agree-tos -m {{ pillar['email']['user'] }}
    - creates: /etc/letsencrypt/live/flower.{{ grains['fqdn'] }}/fullchain.pem
    - require:
      - pip: letsencrypt

renew-cert-for-flower.{{ grains['fqdn'] }}:
  cron.present:
    - name: >
         /opt/letsencrypt/bin/letsencrypt renew --nginx --cert-name flower.{{ grains['fqdn'] }} --non-interactive --agree-tos -m {{ pillar['email']['user'] }} 
    - identifier: renew-cert-for-flower.{{ grains['fqdn'] }}
    - special: '@daily'
    - require:
      - cmd: letsencrypt-flower.{{ grains['fqdn'] }}

restart-garfield-app:
  cron.present:
    - name: supervisorctl restart gunicorn_garfield
    - identifier: restart-garfield-app
    - special: '@daily'
    - require:
      - supervisord: garfield-supervisord 
