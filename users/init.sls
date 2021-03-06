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
    - user: {{ user.username }}
    - group: {{ user.username }}
    - makedirs: True
    - require:
      - user: {{ user.username }}
      - group: {{ user.username }}

/home/{{ user.username }}/.bash_profile:
  file.managed:
    - source: salt://users/.bash_profile
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}

/home/{{ user.username }}/.bashrc:
  file.managed:
    - source: salt://users/.bash_profile
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}

{% if user.get('environment_variables', None) %}
/home/{{ user.username }}/.bash_environment:
  file.managed:
    - source: salt://users/.bash_environment
    - mode: 600
    - user: {{ user.username }}
    - group: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/.bash_profile
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
