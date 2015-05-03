kodi_repository:
  pkgrepo.managed:
    - ppa: team-xbmc/ppa

kodi:
  pkg.latest:
    - require:
      - pkgrepo: kodi_repository

{% for user in pillar.get('users', []) %}
/home/{{ user.username }}/.kodi/userdata/guisettings.xml:
  file.managed:
    - source: salt://kodi/guisettings.xml
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - makedirs: True
    - context:
        derp_username: {{ user.derp_username }}
        derp_password: {{ user.derp_password }}
        username: {{ user.username }}
    - require:
      - pkg: kodi 

/home/{{ user.username }}/.kodi/userdata/RssFeeds.xml:
  file.managed:
    - source: salt://kodi/RssFeeds.xml
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - makedirs: True
    - require:
      - pkg: kodi
    

/home/{{ user.username }}/.kodi/userdata/sources.xml:
  file.managed:
    - source: salt://kodi/sources.xml
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - makedirs: True
    - template: jinja
    - context:
        username: {{ user.username }}
    - require:
      - pkg: kodi
{% endfor %}
