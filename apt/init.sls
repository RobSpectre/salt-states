/etc/apt/apt.conf.d/10periodic:
  file.managed:
    - source: salt://apt/10periodic
    - mode: 644
    - user: root
    - group: root
