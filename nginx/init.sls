nginx-repo:
  pkgrepo.managed:
    - ppa: nginx/stable

nginx:
  pkg.latest:
    - name: nginx
    - require:
      - pkgrepo: nginx-repo
  service.running:
    - enable: True
    - require:
      - pkg: nginx
      - file: nginx-conf
      - file: nginx-empty
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
      - pkg: nginx

nginx-empty:
  file.managed:
    - name: /etc/nginx/sites-available/empty
    - source: salt://nginx/empty
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: nginx
