{% if pillar.get('openvbx', None) %}
{{ pillar['openvbx']['user'] }}:
  group:
    - present
  user.present:
    - fullname: OpenVBX
    - gid_from_name: True
    - shell: /sbin/nologin
    - createhome: True
    - require:
      - pkg.latest: nginx
      - pkg.latest: mysql-server
      - pkg.latest: php

/home/{{ pillar['openvbx']['user'] }}:
  file.directory:
    - file_mode: 644
    - dir_mode: 755
    - user: www-data 
    - group: www-data
    - makedirs: True
    - require:
      - user.present: {{ pillar['openvbx']['user'] }}
      - group.present: {{ pillar['openvbx']['user'] }}
    - recurse:
      - user
      - group
      - mode

{{ pillar['openvbx']['user'] }}-source:
  git.latest:
    - name: git://github.com/twilio/OpenVBX.git
    - target: /home/{{ pillar['openvbx']['user'] }}/{{ pillar['openvbx']['server_name'] }}
    - runas: www-data
    - require: 
      - group: {{ pillar['openvbx']['user'] }}

{{ pillar['openvbx']['user'] }}-index-override:
  file.managed:
    - name: /home/{{ pillar['openvbx']['user'] }}/{{ pillar['openvbx']['server_name'] }}/OpenVBX/config/config-local.php
    - source: salt://openvbx/config-local.php
    - user: www-data
    - group: www-data
    - require:
      - git.latest: {{ pillar['openvbx']['user'] }}-source

{{ pillar['openvbx']['user'] }}-mysql-user:
  mysql_user.present:
    - name: {{ pillar['openvbx']['user'] }}
    - host: {{ pillar['openvbx']['mysql_host'] }}
    - password: {{ pillar['openvbx']['mysql_password'] }}
    - require:
      - service.running: mysql
      - service.running: salt-minion
  mysql_grants.present:
    - grant: all privileges
    - database: {{ pillar['openvbx']['user'] }}.*
    - user: {{ pillar['openvbx']['user'] }}
    - require:
      - mysql_user.present: {{ pillar['openvbx']['user'] }}

{{ pillar['openvbx']['user'] }}-mysql-database:
  mysql_database.present:
    - name: {{ pillar['openvbx']['user'] }}
    - require:
      - service.running: mysql
      - service.running: salt-minion

{{ pillar['openvbx']['user'] }}-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/{{ pillar['openvbx']['user'] }}.conf
    - source: salt://openvbx/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
      server_name: {{ pillar['openvbx']['server_name'] }}
    - require:
      - pkg.latest: nginx

{{ pillar['openvbx']['user'] }}-log-directory:
    file.directory:
      - name: /var/log/nginx/{{ pillar['openvbx']['server_name'] }}
      - mode: 644
      - user: www-data
      - group: www-data
      - require:
        - file.managed: {{ pillar['openvbx']['user'] }}-nginx-conf

{{ pillar['openvbx']['user'] }}-nginx-enable:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ pillar['openvbx']['user'] }}.conf
    - target: /etc/nginx/sites-available/{{ pillar['openvbx']['user'] }}.conf
    - force: false
    - require:
      - file.managed: {{ pillar['openvbx']['user'] }}-log-directory
{% endif %}
