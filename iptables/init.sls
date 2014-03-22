/etc/sysconfig/iptables.save:
  file:
    - managed
    - user: root
    - group: root
    - mode: 644
    - source: salt://iptables/iptables.save
    - template: jinja
{% if salt['grains.get']('roles', []) %}
    - context:
      roles: {{ salt['grains.get']('roles', []) }}
      network: {{ pillar.get('network', None) }}
{% endif %}

Reload iptables:
  cmd.wait:
    - name: iptables-restore < /etc/sysconfig/iptables.save
    - watch:
      - file: /etc/sysconfig/iptables.save
