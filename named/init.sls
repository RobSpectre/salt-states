named:
  pkg.latest:
    - name: bind9
    - name: dnsutils
  service.running:
    - enable: True
    - require:
      - pkg.latest: bind9
      - file.managed: named-conf
    - watch:
      - file: named-conf-primary
      - file: named-conf-local
      - file: named-conf-options
      - file: named-conf-defaultzones
      - pkg: bind9

named-conf-primary:
  file.managed:
    - name: /etc/bind/named.conf
    - source: salt://named/named.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg.latest: bind9

named-conf-local:
  file.managed:
    - name: /etc/bind/named.conf.local
    - source: salt://named/named.conf.local
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg.latest: bind9

named-conf-options:
  file.managed:
    - name: /etc/bind/named.conf.options
    - source: salt://named/named.conf.options
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg.latest: bind9

named-conf-defaultzones:
  file.managed:
    - name: /etc/bind/named.conf.default-zones
    - source: salt://named/named.conf.default-zones
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg.latest: bind9
