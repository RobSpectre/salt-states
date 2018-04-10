swig:
  pkg.installed:
    - require_in:
      - service: salt-minion

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
  pkg.installed:
    - version: 2016.11.5
  service.running:
    - enable: True
    - watch:
      - file: /etc/salt/minion
      - file: /etc/salt/minion.d/*
    - require:
      - file: /etc/salt/minion
