salt-call state.highstate:
  cron.present:
    - user: root
    - minute: random

/etc/salt/minion:
  file.managed:
    - source: salt://salt/minion
    - mode: 644
    - user: root
    - group: root

salt-minion:
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/salt/minion
    - require:
      - file.managed: /etc/salt/minion
