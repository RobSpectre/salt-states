dhcpd:
  pkg.latest:
    - name: isc-dhcp-server
  service.running:
    - name: isc-dhcp-server
    - enable: True
    - require:
      - pkg: dhcpd
      - file: dhcpd-conf
    - watch:
      - file: dhcpd-conf
      - pkg: dhcpd
  user.present:
    - groups:
      - dhcpd
      - bind

{% if pillar.get('network', None) %}
dhcpd-conf:
  file.managed:
    - name: /etc/dhcp/dhcpd.conf
    - source: salt://dhcpd/dhcpd.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: dhcpd
    - template: jinja
    - context:
      network: {{ pillar['network'] }}
{% endif %}
