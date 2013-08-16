{% for user in pillar.get('users', []) %}
{% if user.derp_password %}
couchpotato:
  git.latest:
    - name: git://github.com/RuudBurger/CouchPotatoServer.git
    - target: /home/{{ user.username }}/couchpotato
    - submodules: true
    - runas: {{ user.username }}
  service:
    - running
    - enable: True
    - watch:
      - git: couchpotato
      - file: /etc/init.d/couchpotato
    - require:
      - git.latest: couchpotato
      - file.managed: /etc/init.d/couchpotato

/home/{{ user.username }}/.couchpotato/settings.conf:
  file.managed:
    - source: salt://couchpotato/settings.conf
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - context:
      couchpotato_password: {{ user.couchpotato_password }}
      derp_username: {{ user.derp_username }}
      derp_password: {{ user.derp_password }}
      couchpotato_apikey: {{ user.couchpotato_apikey }}
      themoviedb_apikey: {{ user.themoviedb_apikey }}
      newznab_apikey: {{ user.newznab_apikey }}
      nzbmatrix_username: {{ user.nzbmatrix_username }}
      nzbmatrix_apikey: {{ user.nzbmatrix_apikey }}
      username: {{ user.username }}
      sabnzbd_apikey: {{ user.sabnzbd_apikey }}
    - require:
      - git.latest: couchpotato
{% endif %}
{% endfor %}

/etc/init.d/couchpotato:
  file.managed:
    - source: salt://couchpotato/init_script
    - mode: 755 
    - user: root
    - group: root
    - template: jinja
    - context:
      {% if pillar.get('users', None) %}
      username: {{ pillar['users'][0].username }}
      couchpotato_path: /home/{{ pillar['users'][0].username }}/couchpotato
      {% else %}
      username: root
      couchpotato_path: /usr/local/sbin/CouchPotatoServer/
      {% endif %}
    - require:
      - git.latest: couchpotato
