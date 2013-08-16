sabnzbdplus:
  pkg:
    - latest
  service:
    - running
    - enable: True
    - watch:
      - pkg: sabnzbdplus
      - file: /etc/default/sabnzbdplus
    - require:
      - pkg.latest: sabnzbdplus 
      - file.managed: /etc/default/sabnzbdplus

{% for user in pillar.get('users', []) %}
{% if user.derp_password %}
/home/{{ user.username }}/.sabnzbd/sabnzbd.ini:
  file.managed:
    - source: salt://sabnzbd/sabnzbd.ini
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - context:
      sabnzbd_apikey: {{ user.sabnzbd_apikey }}
      sabnzbd_password: {{ user.sabnzbd_password }}
      sabnzbd_username: {{ user.sabnzbd_username }}
      nzb_key: {{ user.nzb_key }}
      nzbmatrix_username: {{ user.nzbmatrix_username }}
      nzbmatrix_password: {{ user.nzbmatrix_password }}
      username: {{ user.username }}
      astraweb_username: {{ user.astraweb_username }}
      astraweb_password: {{ user.astraweb_password }}
      nzbmatrix_apikey: {{ user.nzbmatrix_apikey }}
      nzbmatrix_userid: {{ user.nzbmatrix_userid }}
    - require:
      - pkg.latest: sabnzbdplus
{% endif %}
{% endfor %}

/etc/default/sabnzbdplus:
  file.managed:
    - source: salt://sabnzbd/default
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
      {% if pillar.get('users', None) %}
      username: {{ pillar['users'][0].username }}
      {% else %}
      username: root
      {% endif %}
    - require:
      - pkg.latest: sabnzbdplus
