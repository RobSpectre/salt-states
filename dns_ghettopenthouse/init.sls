{% if pillar.get('network', None) %}
named-conf-local:
  file.managed:
    - name: /etc/bind/named.conf.local
    - source: salt://dns_ghettopenthouse/named.conf.local
    - mode: 644
    - user: bind 
    - group: bind
    - require_in:
      - pkg: named
    - template: jinja
    - context:
      network: {{ pillar['network'] }}
    - watch_in:
      - service: named

{{ pillar['network']['domain_zone'] }}:
  file.managed:
    - name: /var/lib/bind/zone.{{ pillar['network']['domain_zone'] }}
    - source: salt://dns_ghettopenthouse/zone.{{ pillar['network']['domain_zone'] }}
    - mode: 644
    - user: bind
    - group: bind
    - require_in:
      - pkg: named
    - template: jinja
    - context:
      network: {{ pillar['network'] }}
    - watch_in:
      - service: named

revp.{{ pillar['network']['range_zone'] }}.in-addr.arpa:
  file.managed:
    - name: /var/lib/bind/revp.{{ pillar['network']['range_zone'] }}.in-addr.arpa
    - source: salt://dns_ghettopenthouse/revp.{{ pillar['network']['range_zone'] }}.in-addr.arpa
    - mode: 644
    - user: bind
    - group: bind
    - require_in:
      - pkg: named
    - template: jinja
    - context:
      network: {{ pillar['network'] }}
    - watch_in:
      - service: named
{% endif %}

usr.sbin.dhcpd:
  file.managed:
    - name: /etc/apparmor.d/local/usr.sbin.dhcpd
    - source: salt://dns_ghettopenthouse/usr.sbin.dhcpd
    - mode: 644
    - user: root 
    - group: root
    - require_in:
      - pkg: dhcpd 
