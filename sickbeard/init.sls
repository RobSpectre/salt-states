cheetah:
  pip.installed:
    - require:
      - pip.installed: virtualenv

{% for user in pillar.get('users', []) %}
{% if user.derp_password %}
sickbeard:
  git.latest:
    - name: git://github.com/midgetspy/Sick-Beard.git
    - target: /home/{{ user.username }}/sickbeard
    - submodules: true
    - runas: {{ user.username }}
    - require:
      - pip.installed: cheetah

/home/{{ user.username }}/sickbeard/config.ini:
  file.managed:
    - source: salt://sickbeard/config.ini
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - context:
      derp_username: {{ user.derp_username }}
      derp_password: {{ user.derp_password }}
      sickbeard_apikey: {{ user.sickbeard_apikey }}
      username: {{ user.username }}
      nzbmatrix_username: {{ user.nzbmatrix_username }}
      nzbmatrix_apikey: {{ user.nzbmatrix_apikey }}
      sabnzbd_username: {{ user.sabnzbd_username }}
      sabnzbd_password: {{ user.sabnzbd_password }}
      sabnzbd_apikey: {{ user.sabnzbd_apikey }}
    - require:
      - git.latest: sickbeard
{% endif %}
{% endfor %}
