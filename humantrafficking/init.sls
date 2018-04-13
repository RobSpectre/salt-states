humantrafficking:
  group:
    - present
  user.present:
    - fullname: humantrafficking.tips 
    - gid_from_name: True
    - shell: /sbin/nologin
    - createhome: False
    - require:
      - group: humantrafficking 
      - pkg: nginx
      - pkg: postgres
      - pip: supervisor
      - pkg: rabbitmq
  git.latest:
    - name: git://github.com/RobSpectre/humantrafficking.tips
    - target: /opt/humantrafficking.tips
    - rev: master 
    - submodules: True
    - force_checkout: True
    - user: humantrafficking 
    - require:
      - file: humantrafficking-app-directory
  virtualenv.managed:
    - name: /opt/humantrafficking.tips/venv
    - system_site_packages: False
    - python: python3.5 
    - requirements: /opt/humantrafficking.tips/requirements.txt
    - user: humantrafficking 
    - require:
      - git: humantrafficking 

humantrafficking-app-conf:
  file.managed:
    - name: /opt/humantrafficking.tips/humantrafficking_tips/humantrafficking_tips/local.py
    - source: salt://humantrafficking/app.py
    - mode: 600
    - user: humantrafficking 
    - group: humantrafficking 
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
    - require:
      - git: humantrafficking 

humantrafficking-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/humantrafficking.tips
    - source: salt://humantrafficking/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: nginx

humantrafficking-app-directory:
  file.directory:
    - name: /opt/humantrafficking.tips
    - mode: 755 
    - user: humantrafficking 
    - group: humantrafficking 
    - require:
      - user: humantrafficking 

humantrafficking-server-cert:
  file.managed:
    - name: /etc/nginx/humantrafficking.tips.crt
    - contents: |
        {{ pillar['sslcerts']['server-cert'] | indent(8) }}
    - mode: 600
    - user: root
    - group: root
    - require:
      - pkg: nginx

humantrafficking-server-key:
  file.managed:
    - name: /etc/nginx/humantrafficking.tips.key
    - contents: |
        {{ pillar['sslcerts']['server-key'] | indent(8) }}
    - mode: 600
    - user: root
    - group: root
    - require:
      - pkg: nginx

gunicorn-conf:
  file.managed:
    - name: /opt/humantrafficking.tips/gunicorn.conf.py
    - source: salt://humantrafficking/gunicorn.conf.py
    - mode: 644
    - user: humantrafficking
    - group: humantrafficking 
    - require:
      - git: humantrafficking 

gunicorn-log:
  file.directory:
    - name: /opt/humantrafficking.tips/log
    - mode: 755 
    - user: humantrafficking 
    - group: humantrafficking 
    - require:
      - git: humantrafficking 

humantrafficking-postgres-user:
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

humantrafficking-postgres-database:
  postgres_database.present:
    - name: {{ pillar['database']['user']['name'] }}
    - owner: {{ pillar['database']['user']['name'] }}
    - encoding: UTF8
    - lc_ctype: en_US.UTF8
    - lc_collate: en_US.UTF8
    - template: template0
    - require:
      - service: postgres
      - postgres_user: humantrafficking-postgres-user

humantrafficking-gunicorn:
  pip.installed:
    - name: gunicorn
    - upgrade: True
    - bin_env: /opt/humantrafficking.tips/venv
    - require:
      - virtualenv: humantrafficking 

humantrafficking-psycopg2:
  pip.installed:
    - name: psycopg2 
    - upgrade: True
    - bin_env: /opt/humantrafficking.tips/venv
    - require:
      - virtualenv: humantrafficking 

humantrafficking-supervisord-config:
  file.managed:
    - name: /etc/supervisor/conf.d/humantrafficking.tips.conf
    - source: salt://humantrafficking/supervisor.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pip: supervisor

humantrafficking-supervisord:
  supervisord.running:
    - name: gunicorn_humantrafficking.tips
    - update: True
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - require:
      - pip: supervisor
      - file: humantrafficking-supervisord-config
      - git: humantrafficking 
      - virtualenv: humantrafficking 
      - service: postgres
      - file: humantrafficking-app-conf
      - file: gunicorn-conf
    - watch:
      - pip: supervisor
      - git: humantrafficking 
      - file: humantrafficking-supervisord-config
      - file: humantrafficking-app-conf

humantrafficking-migrate:
  cmd.run:
    - user: humantrafficking 
    - cwd: /opt/humantrafficking.tips/humantrafficking_tips
    - name: /opt/humantrafficking.tips/venv/bin/python manage.py migrate
    - require:
      - git: humantrafficking 
      - postgres_database: humantrafficking-postgres-database 
      - service: postgres 
      - pip: humantrafficking-psycopg2
      - virtualenv: humantrafficking
      - file: humantrafficking-app-conf
    - watch:
      - git: humantrafficking 

humantrafficking-staticdir:
  file.directory:
    - name: /opt/humantrafficking.tips/humantrafficking_tips/static
    - user: humantrafficking 
    - group: humantrafficking 
    - mode: 755 
    - require:
      - git: humantrafficking 

humantrafficking-adminstaticdir:
  file.directory:
    - name: /opt/humantrafficking.tips/static/admin
    - user: humantrafficking 
    - group: humantrafficking 
    - mode: 755 
    - makedirs: True
    - require:
      - user: humantrafficking
      - git: humantrafficking 

humantrafficking-collectstatic:
  cmd.run:
    - user: humantrafficking 
    - cwd: /opt/humantrafficking.tips
    - name: /opt/humantrafficking.tips/venv/bin/python humantrafficking_tips/manage.py collectstatic --noinput
    - require:
      - git: humantrafficking 
      - file: humantrafficking-staticdir
      - file: humantrafficking-adminstaticdir
      - file: humantrafficking-app-conf
    - watch:
      - git: humantrafficking 

humantrafficking-live:
  file.symlink:
    - name: /etc/nginx/sites-enabled/humantrafficking.tips
    - target: /etc/nginx/sites-available/humantrafficking.tips
    - require:
      - service: postgres
      - supervisord: humantrafficking-supervisord
      - git: humantrafficking 
      - pip: humantrafficking-psycopg2
      - pip: humantrafficking-gunicorn
      - file: humantrafficking-app-conf
