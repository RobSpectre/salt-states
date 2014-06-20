/etc/apt/apt.conf.d/10periodic:
  file.managed:
    - source: salt://apt/10periodic
    - mode: 644
    - user: root
    - group: root

/etc/apt/sources.list
  file.managed:
    - source: salt://apt/sources.list
    - mode: 644
    - user: root
    - group: root
