salt-call state.highstate -l debug:
  cron.present:
    - user: root
    - minute: random

/etc/salt/minion:
  file.managed:
    - source: salt://salt/minion
    - mode: 644
    - user: root
    - group: root

/etc/salt/minion.d/empty:
  file.managed:
    - source: salt://salt/empty
    - mode: 600
    - user: root
    - group: root

salt-minion:
  service.running:
    - enable: True
    - watch:
      - file: /etc/salt/minion
      - file: /etc/salt/minion.d/*
    - require:
      - file.managed: /etc/salt/minion
