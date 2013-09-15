mysql-server:
  pkg:
    - latest
    - pkgs:
      - mysql-server
      - mysql-client
      - libmysqlclient18
      - libmysqlclient-dev
  service:
    - running
    - name: mysql
    - enable: True
    - require:
      - pkg.latest: mysql-server

distribute:
  pip.installed:
    - upgrade: True
    - require:
      - pkg.latest: mysql-server

python-mysql:
  pip.installed:
    - name: MySQL-python
    - upgrade: True
    - require:
      - pip.installed: distribute

{% if pillar.get('mysql', None) %}
root-mysql-user:
  cmd.wait:
    - name: mysqladmin -u root password "{{ pillar['mysql']['root_password'] }}" && echo "changed=True comment='MySQL root password reset.'"
    - stateful: True
    - cwd: /var/run/mysqld
    - require:
      - pkg.latest: mysql-server
      - service.running: mysql
      - service.running: salt-minion
    - watch:
      - pkg: mysql-server

mysql-minion-file:
  file.managed:
    - name: /etc/salt/minion.d/mysql.conf
    - source: salt://mysql/minion.conf
    - mode: 600
    - user: root
    - group: root
    - template: jinja
    - context:
      root_password: '{{ pillar['mysql']['root_password'] }}'
    - require:
      - pkg.latest: mysql-server
{% endif %}
