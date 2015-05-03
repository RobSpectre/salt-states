empathy:
  pkg.removed

pidgin:
  pkg.latest

{% for user in pillar.get('users', []) %}
{% if user.im_users %}
/home/{{user.username}}/.purple/accounts.xml:
  file.managed:
    - source: salt://pidgin/accounts.xml
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - makedirs: True
    - template: jinja
    - context:
      im_users: {{ user.im_users }}
    - require:
      - pkg: pidgin
{% endif %}
{% endfor %}
