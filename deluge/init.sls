{% for user in pillar.get('users', []) %}
{% if user.derp_password %}
transmission:
  pkg.removed

deluge-ppa:
  pkgrepo.managed:
    - ppa: deluge-team/ppa

deluge-daemon:
  pkg.latest:
    - names:
      - deluged
      - deluge-webui
      - deluge-console
    - require:
      - pkgrepo: deluge-ppa
  service.running:
    - enable: True
    - require:
      - file: /etc/init.d/deluge-daemon

/home/{{ user.username }}/.config:
  file.directory:
    - mode: 755 
    - user: {{ user.username }}
    - group: {{ user.username }}

/home/{{ user.username }}/.config/deluge-daemon:
  file.directory:
    - mode: 755 
    - user: {{ user.username }}
    - group: {{ user.username }}
    - recurse:
      - user
      - group
      - mode
    - require:
      - file: /home/{{ user.username }}/.config

/etc/init.d/deluge-daemon:
  file.managed:
    - source: salt://deluge/init_script
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - context:
      username: {{ user.username }}
{% endif %}
{% endfor %}
