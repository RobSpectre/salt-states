{% for user in pillar.get('users', []) %}
{{ user.username }}:
  user.present:
    - fullname: {{ user.fullname }} 
    - shell: /bin/bash
    - password: {{ user.password }}
    - home: /home/{{ user.username }}
    - groups:
      {% for group in user.groups %}
      - {{ group }}
      {% endfor %}
      - {{ user.username }}
    - require:
      - group: {{ user.username }}
  group:
    - present

/home/{{ user.username }}:
  file.directory:
    - file_mode: 644
    - dir_mode: 755
    - user: {{ user.username }}
    - group: {{ user.username }}
    - makedirs: True
    - require:
      - user.present: {{ user.username }}
      - group.present: {{ user.username }}
    - recurse:
      - user
      - group
      - mode

/home/{{ user.username }}/.bash_profile:
  file.managed:
    - source: salt://users/.bash_profile
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - require:
      - file.directory: /home/{{ user.username }}

{% if user.get('environment_variables', None) %}
/home/{{ user.username }}/.bash_environment:
  file.managed:
    - source: salt://users/.bash_environment
    - mode: 600
    - user: {{ user.username }}
    - group: {{ user.username }}
    - require:
      - file.managed: /home/{{ user.username }}/.bash_profile
    - template: jinja
    - context:
      environment_variables: {{ user.environment_variables }} 
{% endif %}
{% endfor %}

{% if pillar.get('root', None) %}
root:
  user.present:
    - password: {{ pillar['root']['password'] }}
{% endif %}
