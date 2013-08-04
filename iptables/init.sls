/etc/sysconfig/iptables.save:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://iptables/iptables.save

Reload iptables:
  cmd.wait:
    - name: iptables-restore < /etc/sysconfig/iptables.save
    - watch:
      - file: /etc/sysconfig/iptables.save
