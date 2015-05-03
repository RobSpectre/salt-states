{% for user in pillar.get('users', []) %}
{% if user.derp_password %}
transmission:
  pkg.removed

transmission-daemon:
  pkg.latest:
    - require:
      - git: couchpotato
  service:
    - running
    - enable: True
    - require:
      - file: /etc/init.d/transmission-daemon
      - file: /home/{{ user.username }}/.config/transmission-daemon/settings.json

/home/{{ user.username }}/.config/transmission-daemon/settings.json:
  file.managed:
    - source: salt://transmission/settings.json
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - context:
      username: {{ user.username}}
      derp_username: {{ user.derp_username }} 
      derp_password: {{ user.derp_password }}
    - require:
      - file: /home/{{ user.username }}/.config

/home/{{ user.username }}/torrents:
  file.directory:
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}

/home/{{ user.username }}/.config:
  file.directory:
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}

/home/{{ user.username }}/.config/transmission-daemon:
  file.directory:
    - mode: 755 
    - user: {{ user.username }}
    - group: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/.config

/etc/init.d/transmission-daemon:
  file.managed:
    - source: salt://transmission/init_script
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - context:
      username: {{ user.username }}
{% endif %}
{% endfor %}
