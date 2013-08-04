include:
  - ssh

openssh-server:
  pkg.installed

ssh:
  service.running:
    - watch:
      - file: /etc/ssh/sshd_config
    - require:
      - pkg: openssh-client
      - pkg: openssh-server
      - file: /etc/issue.net
      - file: /etc/motd

/etc/ssh/sshd_config:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://ssh/sshd_config
    - require:
      - pkg: openssh-server

/etc/issue.net:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://ssh/issue.net
    - require:
      - pkg: openssh-server

/etc/motd:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://ssh/motd
    - require:
      - pkg: openssh-server
