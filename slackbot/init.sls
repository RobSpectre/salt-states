slackbot-deps:
  pkg.latest:
    - pkgs:
      - libffi-dev 
      - python3.4
      - python3.4-dev

slackbot:
  user.present:
    - fullname: Slack Bot 
    - gid_from_name: True 
    - shell: /sbin/nologin
    - createhome: True 
    - require:
      - group: slackbot 
  group:
    - present

/opt/slackbot:
  file.directory: 
    - user: slackbot
    - group: slackbot
    - mode: 755
    - makedirs: True
    - require:
      - user: slackbot
      - group: slackbot

/opt/slackbot/venv:
  virtualenv.managed:
    - system_site_packages: False
    - python: /usr/bin/python3.4
    - requirements: salt://slackbot/requirements.txt

/opt/slackbot/config.py:
  file.managed:
    - source: salt://slackbot/config.py
    - user: slackbot
    - group: slackbot
    - mode: 755
    - makedirs: True
    - require:
      - virtualenv: /opt/slackbot/venv
      - file: /opt/slackbot
      - user: slackbot
    - template: jinja
    - context:
      token: {{ grains.get('token', None) }}
      botname: {{ grains.get('botname', None) }}
      admins: {{ grains.get('admins', None) }}
      rooms: {{ grains.get('rooms', None) }}

slackbot-supervisord-conf:
  file.managed:
    - name: /etc/supervisor/conf.d/slackbot.conf
    - source: salt://slackbot/supervisor.conf
    - mode: 600
    - user: root
    - group: root
    - require:
      - pip: supervisor

slackbot-supervisord:
  supervisord.running:
    - name: slackbot
    - update: True
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - bin_env: /usr/local/bin/supervisorctl
    - require:
      - pip: supervisor
      - file: slackbot-supervisord-conf
      - user: slackbot
    - watch:
      - virtualenv: /opt/slackbot/venv 
      - file: slackbot-supervisord-conf 
