git:
  pkg.latest

{% for user in pillar.get('users', []) %}
/home/{{ user.username }}/.gitconfig:
  file.managed:
    - source: salt://git/gitconfig
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - context:
      fullname: {{ user.fullname }}
      email_address: {{ user.email_address }}
    - require:
      - pkg: git
{% endfor %}
