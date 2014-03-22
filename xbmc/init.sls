xbmc_repository:
  pkgrepo.managed:
    - ppa: team-xbmc/ppa
    - require_in:
      - pkg: xbmc

xbmc:
  pkg.latest:
    - require:
      - pkgrepo: xbmc_repository

{% for user in pillar.get('users', []) %}
/home/{{ user.username }}/.xbmc/userdata/guisettings.xml:
  file.managed:
    - source: salt://xbmc/guisettings.xml
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - context:
        derp_username: {{ user.derp_username }}
        derp_password: {{ user.derp_password }}
        username: {{ user.username }}
    - require:
      - pkg: xbmc

/home/{{ user.username }}/.xbmc/userdata/sources.xml:
  file.managed:
    - source: salt://xbmc/sources.xml
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - context:
        username: {{ user.username }}
    - require:
      - pkg: xbmc
{% endfor %}
