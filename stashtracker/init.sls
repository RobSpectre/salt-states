stashtracker:
  group:
    - present
  user.present:
    - fullname: Stash Tracker 
    - gid_from_name: True
    - shell: /sbin/nologin
    - createhome: True
    - require:
      - group: stashtracker 
      - pkg: nginx

stashtracker-supervisord-conf:
  file.managed:
    - name: /etc/supervisor/conf.d/stashtracker.conf
    - source: salt://stashtracker/supervisor.conf
    - mode: 600
    - user: root
    - group: root
    - template: jinja
    - context:
      account_sid: {{ pillar['twilio']['account_sid'] }} 
      auth_token: {{ pillar['twilio']['auth_token'] }}
      caller_id: {{ pillar['stashtracker']['caller_id'] }}
    - require:
      - pip: supervisor

stashtracker-supervisord:
  supervisord.running:
    - name: stashtracker
    - update: True 
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - bin_env: /usr/local/bin/supervisorctl
    - require:
      - pip: supervisor
      - file: stashtracker-supervisord-conf
      - user: stashtracker
    - watch:
      - pip: supervisor
      - file: stashtracker-supervisord-conf 

stashtracker-code:
  git.latest:
    - name: git://github.com/RobSpectre/Realtime-MMS-Photostream
    - target: /home/stashtracker/stashtracker
    - rev: master
    - user: stashtracker
    - force_checkout: True
    - require:
      - user: stashtracker

stashtracker-npm:
  npm.bootstrap:
    - name: /home/stashtracker/stashtracker
    - user: stashtracker 
    - require:
      - git: stashtracker-code      

stashtracker-nginx:
  file.managed:
    - name: /etc/nginx/sites-available/stashtracker
    - source: salt://stashtracker/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - user: stashtracker
      - git: stashtracker-code

stashtracker-nginx-enabled:
  file.symlink:
    - name: /etc/nginx/sites-enabled/stashtracker
    - target: /etc/nginx/sites-available/stashtracker
    - require:
      - file: stashtracker-nginx 
