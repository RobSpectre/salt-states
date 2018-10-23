iptables-persistent:
  pkg.latest:
    - require:
      - file: /etc/iptables/rules.v4

/etc/iptables:
  file.directory:
    - user: root
    - group: root
    - mode: 644
    

/etc/iptables/rules.v4:
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
    - require:
      - file: /etc/iptables

Reload iptables:
  cmd.wait:
    - name: iptables-restore < /etc/iptables/rules.v4
    - watch:
      - file: /etc/iptables/rules.v4
