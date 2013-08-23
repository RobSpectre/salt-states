/etc/apt/apt.conf.d/10periodic:
  file.managed:
    - source: salt://apt/10periodic
    - mode: 644
    - user: root
    - group: root

apt-get update:
  cron.present:
    - user: root
    - minute: random
    - hour: random

apt-get upgrade:
  cmd.wait:
    - name: apt-get upgrade -y
    - user: root
    - cwd: /
    - watch:
      - cron: apt-get update
