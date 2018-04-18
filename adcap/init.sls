adcap-deps:
  pkg.latest:
    - names:
      - libjpeg62 
      - libjpeg62-dev 
      - libfreetype6
      - libfreetype6-dev
      - zlib1g-dev
adcap:
  group:
    - present
  user.present:
    - fullname: AdCap Website
    - gid_from_name: True
    - shell: /sbin/nologin
    - createhome: False
    - require:
      - group: adcap
      - pkg: nginx
      - pkg: postgres
      - pkg: redis
      - pkg: elasticsearch
      - pkg: supervisor
      - pkg: adcap-deps
  git.latest:
    - name: git://github.com/AdventureCapitalists/website
    - target: /opt/adcap.biz
    - rev: master 
    - submodules: True
    - user: adcap
    - require:
      - file: adcap-app-directory
  virtualenv.managed:
    - name: /opt/adcap.biz/venv
    - system_site_packages: False
    - python: python3.5 
    - requirements: /opt/adcap.biz/requirements.txt
    - user: adcap
    - require:
      - git: adcap

adcap-app-conf:
  file.managed:
    - name: /opt/adcap.biz/adcap_website/adcap_website/settings/local.py
    - source: salt://adcap/app.py
    - mode: 600
    - user: adcap
    - group: adcap
    - template: jinja
    - context:
      db_name: {{ pillar['database']['user']['name'] }}
      db_password: {{ pillar['database']['user']['password'] }}
      db_user: {{ pillar['database']['user']['name'] }}
      cookie_key: {{ pillar['cookie_key'] }}
      never_cache_key: {{ pillar['never_cache_key'] }}
      email_user: {{ pillar['email']['user'] }}
      email_host: {{ pillar['email']['host'] }}
      email_password: {{ pillar['email']['password'] }}
    - require:
      - git: adcap

adcap-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/adcap.biz
    - source: salt://adcap/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: nginx

adcap-app-directory:
  file.directory:
    - name: /opt/adcap.biz
    - mode: 755 
    - user: adcap
    - group: adcap
    - require:
      - user: adcap

adcap-server-cert:
  file.managed:
    - name: /etc/nginx/adcap.biz.crt
    - contents: |
        {{ pillar['sslcerts']['server-cert'] | indent(8) }}
    - mode: 600
    - user: root
    - group: root
    - require:
      - pkg: nginx

adcap-server-key:
  file.managed:
    - name: /etc/nginx/adcap.biz.key
    - contents: |
        {{ pillar['sslcerts']['server-key'] | indent(8) }}
    - mode: 600
    - user: root
    - group: root
    - require:
      - pkg: nginx

gunicorn-conf:
  file.managed:
    - name: /opt/adcap.biz/gunicorn.conf.py
    - source: salt://adcap/gunicorn.conf.py
    - mode: 644
    - user: adcap
    - group: adcap
    - require:
      - git: adcap

gunicorn-log:
  file.directory:
    - name: /opt/adcap.biz/log
    - mode: 755 
    - user: adcap
    - group: adcap
    - require:
      - git: adcap

adcap-postgres-user:
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

adcap-postgres-database:
  postgres_database.present:
    - name: {{ pillar['database']['user']['name'] }}
    - owner: {{ pillar['database']['user']['name'] }}
    - encoding: UTF8
    - lc_ctype: en_US.UTF8
    - lc_collate: en_US.UTF8
    - template: template0
    - require:
      - service: postgres
      - postgres_user: adcap-postgres-user

adcap-gunicorn:
  pip.installed:
    - name: gunicorn
    - upgrade: True
    - bin_env: /opt/adcap.biz/venv
    - require:
      - virtualenv: adcap

adcap-psycopg2:
  pip.installed:
    - name: psycopg2 
    - upgrade: True
    - bin_env: /opt/adcap.biz/venv
    - require:
      - virtualenv: adcap

adcap-django-redis:
  pip.installed:
    - name: django-redis 
    - upgrade: True
    - bin_env: /opt/adcap.biz/venv
    - require:
      - virtualenv: adcap

adcap-elasticsearch:
  pip.installed:
    - name: elasticsearch 
    - upgrade: True
    - bin_env: /opt/adcap.biz/venv
    - require:
      - virtualenv: adcap

adcap-supervisord-config:
  file.managed:
    - name: /etc/supervisor/conf.d/adcap.biz.conf
    - source: salt://adcap/supervisor.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: supervisor

adcap-supervisord:
  supervisord.running:
    - name: gunicorn_adcap.biz
    - update: True
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - require:
      - pkg: supervisor
      - file: adcap-supervisord-config
      - git: adcap
      - virtualenv: adcap
      - service: postgres
      - service: elasticsearch
      - service: redis
      - file: adcap-app-conf
    - watch:
      - pkg: supervisor
      - git: adcap
      - file: adcap-supervisord-config
      - file: adcap-app-conf

adcap-migrate:
  cmd.run:
    - user: adcap
    - cwd: /opt/adcap.biz/adcap_website
    - name: /opt/adcap.biz/venv/bin/python manage.py migrate
    - require:
      - git: adcap
      - postgres_database: adcap-postgres-database 
      - service: postgres 
      - pip: adcap-psycopg2
    - watch:
      - git: adcap

adcap-update-index:
  cmd.run:
    - user: adcap
    - cwd: /opt/adcap.biz/adcap_website
    - name: /opt/adcap.biz/venv/bin/python manage.py update_index 
    - require:
      - git: adcap
      - service: elasticsearch 
      - pip: adcap-elasticsearch
    - watch:
      - git: adcap

adcap-staticdir:
  file.directory:
    - name: /opt/adcap.biz/adcap_website/adcap_website/static
    - user: adcap
    - group: adcap
    - mode: 644
    - require:
      - git: adcap

adcap-collectstatic:
  cmd.run:
    - user: adcap
    - cwd: /opt/adcap.biz/adcap_website
    - name: /opt/adcap.biz/venv/bin/python manage.py collectstatic --noinput
    - require:
      - git: adcap
      - file: adcap-staticdir
    - watch:
      - git: adcap

adcap-live:
  file.symlink:
    - name: /etc/nginx/sites-enabled/adcap.biz
    - target: /etc/nginx/sites-available/adcap.biz
    - require:
      - service: postgres
      - service: redis
      - service: elasticsearch
      - supervisord: adcap-supervisord
      - git: adcap
      - pip: adcap-psycopg2
      - pip: adcap-gunicorn
      - pip: adcap-django-redis 
      - pip: adcap-elasticsearch
      - file: adcap-app-conf
