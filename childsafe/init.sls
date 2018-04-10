childsafe:
  group:
    - name: childsafe
    - present
  user.present:
    - fullname: childsafe
    - gid_from_name: True
    - shell: /sbin/nologin
    - createhome: False
    - require:
      - group: childsafe
      - pkg: nginx
      - pkg: postgres
      - pip: supervisor
      - pkg: rabbitmq
  git.latest:
    - name: git://github.com/RobSpectre/childsafe.io
    - target: /opt/childsafe.io
    - rev: master 
    - submodules: True
    - force_checkout: True
    - user: childsafe
    - require:
      - file: childsafe-app-directory
  virtualenv.managed:
    - name: /opt/childsafe.io/venv
    - system_site_packages: False
    - python: python3.4 
    - requirements: /opt/childsafe.io/requirements.txt
    - user: childsafe
    - require:
      - git: childsafe

childsafe-app-conf:
  file.managed:
    - name: /opt/childsafe.io/childsafe/childsafe/local.py
    - source: salt://childsafe/app.py
    - mode: 600
    - user: childsafe
    - group: childsafe
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
      tellfinder:
        api_key: {{ pillar['tellfinder']['api_key'] }}
      clarifai:
        api_key: {{ pillar['clarifai']['api_key'] }}
    - require:
      - git: childsafe 

childsafe-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/childsafe
    - source: salt://childsafe/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: nginx

childsafe-app-directory:
  file.directory:
    - name: /opt/childsafe.io
    - mode: 755 
    - user: childsafe
    - group: childsafe
    - require:
      - user: childsafe 

childsafe-server-cert:
  file.managed:
    - name: /etc/nginx/childsafe.crt
    - contents: |
        {{ pillar['sslcerts']['server-cert'] | indent(8) }}
    - mode: 600
    - user: root
    - group: root
    - require:
      - pkg: nginx

childsafe-server-key:
  file.managed:
    - name: /etc/nginx/childsafe.key
    - contents: |
        {{ pillar['sslcerts']['server-key'] | indent(8) }}
    - mode: 600
    - user: root
    - group: root
    - require:
      - pkg: nginx

childsafe-gunicorn-conf:
  file.managed:
    - name: /opt/childsafe.io/gunicorn.conf.py
    - source: salt://childsafe/gunicorn.conf.py
    - mode: 644
    - user: childsafe
    - group: childsafe
    - require:
      - git: childsafe 

childsafe-gunicorn-log:
  file.directory:
    - name: /opt/childsafe.io/log
    - mode: 755 
    - user: childsafe 
    - group: childsafe 
    - require:
      - git: childsafe 

childsafe-postgres-user:
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

childsafe-postgres-database:
  postgres_database.present:
    - name: {{ pillar['database']['user']['name'] }}
    - owner: {{ pillar['database']['user']['name'] }}
    - encoding: UTF8
    - lc_ctype: en_US.UTF8
    - lc_collate: en_US.UTF8
    - template: template0
    - require:
      - service: postgres
      - postgres_user: childsafe-postgres-user

childsafe-gunicorn:
  pip.installed:
    - name: gunicorn
    - upgrade: True
    - bin_env: /opt/childsafe.io/venv
    - require:
      - virtualenv: childsafe 

childsafe-psycopg2:
  pip.installed:
    - name: psycopg2 
    - upgrade: True
    - bin_env: /opt/childsafe.io/venv
    - require:
      - virtualenv: childsafe 

childsafe-supervisord-config:
  file.managed:
    - name: /etc/supervisor/conf.d/childsafe.conf
    - source: salt://childsafe/supervisor.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pip: supervisor

childsafe-supervisord:
  supervisord.running:
    - name: gunicorn_childsafe.io
    - update: True
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - require:
      - pip: supervisor
      - file: childsafe-supervisord-config
      - git: childsafe 
      - virtualenv: childsafe 
      - service: postgres
      - file: childsafe-app-conf
      - file: childsafe-gunicorn-conf
    - watch:
      - pip: supervisor
      - git: childsafe 
      - file: childsafe-supervisord-config
      - file: childsafe-app-conf

childsafe-celery-supervisord:
  supervisord.running:
    - name: celery_childsafe.io
    - update: True
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - require:
      - pip: supervisor
      - file: childsafe-supervisord-config
      - git: childsafe 
      - virtualenv: childsafe 
      - service: postgres
      - file: childsafe-app-conf
      - file: childsafe-gunicorn-conf
    - watch:
      - pip: supervisor
      - git: childsafe 
      - file: childsafe-supervisord-config
      - file: childsafe-app-conf

childsafe-migrate:
  cmd.run:
    - user: childsafe
    - cwd: /opt/childsafe.io/childsafe
    - name: /opt/childsafe.io/venv/bin/python manage.py migrate
    - require:
      - git: childsafe 
      - postgres_database: childsafe-postgres-database 
      - service: postgres 
      - pip: childsafe-psycopg2
      - virtualenv: childsafe 
      - file: childsafe-app-conf
    - watch:
      - git: childsafe 

childsafe-staticdir:
  file.directory:
    - name: /opt/childsafe.io/childsafe/static
    - user: childsafe
    - group: childsafe
    - mode: 755 
    - require:
      - git: childsafe 

childsafe-adminstaticdir:
  file.directory:
    - name: /opt/childsafe.io/static/admin
    - user: childsafe
    - group: childsafe
    - mode: 755 
    - makedirs: True
    - require:
      - user: childsafe 
      - git: childsafe 

childsafe-collectstatic:
  cmd.run:
    - user: childsafe
    - cwd: /opt/childsafe.io
    - name: /opt/childsafe.io/venv/bin/python childsafe/manage.py collectstatic --noinput
    - require:
      - git: childsafe 
      - file: childsafe-staticdir
      - file: childsafe-adminstaticdir
      - file: childsafe-app-conf
    - watch:
      - git: childsafe 

childsafe-live:
  file.symlink:
    - name: /etc/nginx/sites-enabled/childsafe
    - target: /etc/nginx/sites-available/childsafe
    - require:
      - service: postgres
      - supervisord: childsafe-supervisord
      - git: childsafe 
      - pip: childsafe-psycopg2
      - pip: childsafe-gunicorn
      - file: childsafe-app-conf
