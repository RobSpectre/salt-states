{% if pillar.get('supervisor', None) %}
supervisor:
  pkg.latest:
    - require:
      - pip: virtualenv

supervisord:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/supervisor/supervisord.conf
      - file: /etc/supervisor/conf.d/*
    - require:
      - pkg: supervisor
      - file: /etc/init.d/supervisord

/etc/supervisor:
  file.directory:
    - mode: 644
    - user: root
    - group: root
    - makedirs: True
    - require:
      - pkg: supervisor

/etc/supervisor/supervisord.conf:
  file.managed:
    - source: salt://supervisor/supervisord.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
      service_user: {{ pillar['supervisor']['service_user'] }}
      service_password: {{ pillar['supervisor']['service_password'] }}
    - require:
      - file: /etc/supervisor


/etc/supervisor/conf.d:
  file.directory:
    - mode: 644
    - user: root
    - group: root
    - makedirs: True
    - require:
      - file: /etc/supervisor/supervisord.conf

/etc/init.d/supervisord:
  file.managed:
    - source: salt://supervisor/init_script
    - mode: 755
    - user: root
    - group: root
    - require:
      - file: /etc/supervisor/supervisord.conf
{% endif %}
