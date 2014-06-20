votr:
  group:
    - present
  user.present:
    - fullname: Votr App
    - gid_from_name: True
    - shell: /sbin/nologin
    - createhome: True
    - require:
      - group: votr
      - pkg: nginx

votr-supervisord-conf:
  file.managed:
    - name: /etc/supervisor/conf.d/votr.conf
    - source: salt://votr/supervisor.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pip: supervisor

votr-supervisord:
  supervisord.running:
    - name: votr
    - update: True 
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - bin_env: /usr/local/bin/supervisorctl
    - require:
      - pip: supervisor
      - file: votr-supervisord-conf
      - archive: votr-zip
      - user: votr
      - cmd: votr-initialize-db
    - watch:
      - pip: supervisor
      - file: votr-supervisord-conf 
      - file: votr-conf

votr-zip:
  archive.extracted:
    - name: /home/votr/votr
    - user: votr
    - source: salt://votr/votr.zip
    - archive_format: zip
    - require:
      - user: votr

votr-npm:
  npm.bootstrap:
    - name: /home/votr/votr
    - user: root 
    - require:
      - archive: votr-zip      

votr-conf:
  file.managed:
    - name: /home/votr/votr/config.js 
    - source: salt://votr/config.js
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
      twilio_account_sid: {{ pillar['twilio']['account_sid'] }} 
      twilio_auth_token: {{ pillar['twilio']['auth_token'] }}
      username: {{ pillar['votr']['derp_username'] }}
      password: {{ pillar['votr']['derp_password'] }}
    - require:
      - pip: supervisor

votr-nginx:
  file.managed:
    - name: /etc/nginx/sites-available/votr
    - source: salt://votr/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - user: votr
      - archive: votr-zip

votr-nginx-enabled:
  file.symlink:
    - name: /etc/nginx/sites-enabled/votr
    - target: /etc/nginx/sites-available/votr
    - require:
      - file: votr-nginx 

votr-initialize-db-script:
  file.managed:
    - name: /home/votr/initialize_votr_database.py
    - source: salt://votr/initialize_votr_database.py
    - mode: 600
    - user: root 
    - group: root 
    - require:
      - pkg: python-pip
      - service: couchdb

votr-initialize-db:
  cmd.run:
    - name: python initialize_votr_database.py --username={{
            pillar['votr']['derp_username'] }} --password={{
            pillar['votr']['derp_password'] }} http://localhost:5984
    - cwd: /home/votr/
    - stateful: True
    - require:
      - file: votr-initialize-db-script
