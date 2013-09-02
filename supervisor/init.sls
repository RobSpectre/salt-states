{% if pillar.get('supervisor', None) %}
supervisor:
  pip.installed:
    - require:
      - pip.installed: virtualenv

supervisord:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file.managed: /etc/supervisor/supervisord.conf
      - file.managed: /etc/supervisor/conf.d/*
    - require:
      - pip.installed: supervisor
      - file.managed: /etc/init.d/supervisord

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
      - pip.installed: supervisor

/etc/supervisor/conf.d:
  file.directory:
    - mode: 644
    - user: root
    - group: root
    - makedirs: True
    - require:
      - file.managed: /etc/supervisor/supervisord.conf

/etc/init.d/supervisord:
  file.managed:
    - source: salt://supervisor/init_script
    - mode: 755
    - user: root
    - group: root
    - require:
      - file.managed: /etc/supervisor/supervisord.conf
{% endif %}
