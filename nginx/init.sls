nginx:
  pkg.latest:
    - name: nginx
  service.running:
    - enable: True
    - require:
      - pkg.latest: nginx
      - file.managed: nginx-conf
      - file.managed: nginx-empty
    - watch:
      - file: nginx-conf 
      - file: /etc/nginx/sites-enabled/*
      - file: /etc/nginx/sites-available/*
      - pkg: nginx

default-nginx:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

nginx-conf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg.latest: nginx

nginx-empty:
  file.managed:
    - name: /etc/nginx/sites-available/empty
    - source: salt://nginx/empty
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg.latest: nginx
