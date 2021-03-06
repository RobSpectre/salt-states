cheetah:
  pip.installed:
    - require:
      - pip: virtualenv

{% for user in pillar.get('users', []) %}
{% if user.derp_password %}
sickbeard:
  git.latest:
    - name: git://github.com/midgetspy/Sick-Beard.git
    - target: /home/{{ user.username }}/sickbeard
    - rev: master
    - submodules: true
    - user: {{ user.username }}
    - force: True
    - require:
      - pip: cheetah
  service:
    - running
    - enable: True
    - watch:
      - git: sickbeard 
      - file: /etc/init.d/sickbeard
      - file: /home/{{ user.username }}/.sickbeard/config.ini
    - require:
      - git: sickbeard 
      - file: /etc/init.d/sickbeard

/home/{{ user.username }}/.sickbeard:
  file.directory:
    - file_mode: 755
    - dir_mode: 755
    - user: {{ user.username }}
    - group: {{ user.username }}
    - require:
      - git: sickbeard

/home/{{ user.username }}/.sickbeard/config.ini:
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
      oznzb_apikey: {{ user.oznzb_apikey }}
      nzbsu_apikey: {{ user.nzbsu_apikey }}
    - require:
      - git: sickbeard
      - file: /home/{{ user.username }}/.sickbeard

/home/{{ user.username }}/sickbeard/autoProcessTV/autoProcessTV.cfg:
  file.managed:
    - source: salt://sickbeard/autoProcessTV.cfg
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - context:
      derp_username: {{ user.derp_username }}
      derp_password: {{ user.derp_password }}
    - require:
      - git: sickbeard
      - pkg: sabnzbdplus

/home/{{ user.username }}/TV:
  file.directory:
    - file_mode: 644
    - dir_mode: 755
    - user: {{ user.username }}
    - group: {{ user.username }}
    - makedirs: True
    - require:
      - user: {{ user.username }}
      - group: {{ user.username }}
    - recurse:
      - user
      - group
      - mode

/home/{{ user.username }}/TV_Download:
  file.directory:
    - file_mode: 644
    - dir_mode: 755
    - user: {{ user.username }}
    - group: {{ user.username }}
    - makedirs: True
    - require:
      - user: {{ user.username }}
      - group: {{ user.username }}
    - recurse:
      - user
      - group
      - mode

/home/{{ user.username }}/sickbeard/autoProcessTV:
  file.directory:
    - file_mode: 755
    - dir_mode: 755
    - user: {{ user.username }}
    - group: {{ user.username }}
    - require:
      - git: sickbeard
    - watch:
      - git: sickbeard
    - recurse:
      - user
      - group
      - mode
{% endif %}
{% endfor %}

/etc/init.d/sickbeard:
  file.managed:
    - source: salt://sickbeard/init_script
    - mode: 755 
    - user: root
    - group: root
    - template: jinja
    - context:
      {% if pillar.get('users', None) %}
      username: {{ pillar['users'][0].username }}
      derp_username: {{ pillar['users'][0].derp_username }}
      derp_password: {{ pillar['users'][0].derp_password }}
      {% else %}
      username: root
      derp_username: derp
      derp_password: derp
      {% endif %}
    - require:
      - git: sickbeard
