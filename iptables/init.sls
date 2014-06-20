/etc/iptables.save:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://iptables/iptables.save
    - template: jinja
    - context:
      roles: {{ salt['grains.get']('roles', None) }}
      network: {{ pillar.get('network', None) }}

Reload iptables:
  cmd.wait:
    - name: iptables-restore < /etc/iptables.save
    - watch:
      - file: /etc/iptables.save
