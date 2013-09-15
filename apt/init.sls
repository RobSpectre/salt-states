/etc/apt/apt.conf.d/10periodic:
  file.managed:
    - source: salt://apt/10periodic
    - mode: 644
    - user: root
    - group: root

daily-upgrade:
  cron.present:
    - name: apt-get update && apt-get -o Dpkg::Options::="--force-confdef" upgrade -y
    - user: root
    - minute: random
    - hour: random
