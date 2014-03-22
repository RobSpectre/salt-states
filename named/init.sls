named:
  pkg.latest:
    - pkgs:
      - bind9
      - dnsutils
    - require:
      - file: named-conf-primary
      - file: named-conf-options
      - file: named-conf-defaultzones
  service.running:
    - name: bind9
    - enable: True
    - require:
      - pkg: named 
      - file: named-conf-primary
      - file: named-conf-options
      - file: named-conf-defaultzones
    - watch:
      - file: named-conf-primary
      - file: named-conf-options
      - file: named-conf-defaultzones
      - pkg: named 

named-conf-primary:
  file.managed:
    - name: /etc/bind/named.conf
    - source: salt://named/named.conf
    - mode: 644
    - user: bind 
    - group: bind

named-conf-options:
  file.managed:
    - name: /etc/bind/named.conf.options
    - source: salt://named/named.conf.options
    - mode: 644
    - user: bind
    - group: bind
{% if pillar.get('network', None) %}    
    - template: jinja
    - context:
      network: {{ pillar['network'] }}
{% endif %}

named-conf-defaultzones:
  file.managed:
    - name: /etc/bind/named.conf.default-zones
    - source: salt://named/named.conf.default-zones
    - mode: 644
    - user: bind
    - group: bind

db.root:
  file.managed:
    - name: /etc/bind/db.root
    - source: salt://named/db.root
    - mode: 644
    - user: bind
    - group: bind

db.0:
  file.managed:
    - name: /etc/bind/db.0
    - source: salt://named/db.0
    - mode: 644
    - user: bind
    - group: bind

db.127:
  file.managed:
    - name: /etc/bind/db.127
    - source: salt://named/db.127
    - mode: 644
    - user: bind
    - group: bind

db.local:
  file.managed:
    - name: /etc/bind/db.local
    - source: salt://named/db.local
    - mode: 644
    - user: bind
    - group: bind

db.255:
  file.managed:
    - name: /etc/bind/db.255
    - source: salt://named/db.255
    - mode: 644
    - user: bind
    - group: bind
