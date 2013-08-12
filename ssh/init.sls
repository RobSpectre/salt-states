openssh-client:
  pkg.latest

/etc/ssh/ssh_config:
  file.managed:
    - user: root
    - user: root
    - mode: 644
    - source: salt://ssh/ssh_config
    - require:
      - pkg: openssh-client
