include:
  - ssh

openssh-server:
  pkg.latest

ssh:
  service.running:
    - watch:
      - file: /etc/ssh/sshd_config
    - require:
      - pkg: openssh-client
      - pkg: openssh-server

/etc/ssh/sshd_config:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://ssh/sshd_config
    - require:
      - pkg: openssh-server

/etc/update-motd.d/10-help-text:
  file:
    - absent

/etc/update-motd.d/00-header:
  file.managed:
    - user: root
    - group: root
    - mode: 755 
    - source: salt://ssh/header
    - require:
      - pkg: openssh-server

/etc/motd.tail:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://ssh/motd.tail
    - require:
      - pkg: openssh-server
