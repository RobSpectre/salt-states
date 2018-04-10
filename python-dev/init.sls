deadsnakes-ppa:
  pkgrepo.managed:
    - ppa: fkrull/deadsnakes

ipython-dependencies:
  pkg.latest:
    - names:
      - libfreetype6-dev
      - libpng-dev
      - libblas-dev
      - liblapack-dev
      - gfortran
      - python-dev
      - g++
      - postgresql-client
      - libpq-dev
      - libhdf5-dev
      - python2.7
      - python3.4
      - python3.5
      - libhdf5-dev
      - hdf5-tools
      - hdf5-helpers
      - h5utils
      - libffi6
      - libffi-dev
      - libssl-dev
      {% if grains['lsb_distrib_codename'] == 'xenial' %} 
      - libhdf5-10
      {% else %}
      - libhdf5-7
      {% endif %}
    - require:
      - pkgrepo: deadsnakes-ppa


{% for user in pillar.get('users', []) %}
/home/{{ user.username }}/.virtualenvs:
  file.directory:
    - user: {{ user.username }}
    - group: {{ user.username }}

/home/{{ user.username }}/.virtualenvs/flask:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://python-dev/flask.txt
    - user: {{ user.username }}
    - require:
      - pkgrepo: deadsnakes-ppa
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/authy:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://python-dev/authy.txt
    - user: {{ user.username }}
    - require:
      - pkgrepo: deadsnakes-ppa
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/django:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://python-dev/django.txt
    - user: {{ user.username }}
    - require:
      - pkgrepo: deadsnakes-ppa
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/djangorestframework:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://python-dev/djangorestframework.txt
    - user: {{ user.username }}
    - require:
      - pkgrepo: deadsnakes-ppa
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/nlp:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://python-dev/nlp.txt
    - user: {{ user.username }}
    - require:
      - pkgrepo: deadsnakes-ppa
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/ipython:
  virtualenv.managed:
    - system_site_packages: False
    - python: /usr/bin/python2.7
    - user: {{ user.username }}
    - requirements: salt://python-dev/ipython-deps.txt
    - require:
      - pkgrepo: deadsnakes-ppa
      - pkg: ipython-dependencies
      - file: /home/{{ user.username }}/.virtualenvs

statsmodel-deps:
  pip.installed:
    - names:
      - numexpr
      - cython
    - bin_env: /home/{{ user.username }}/.virtualenvs/ipython
    - user: {{ user.username }}
    - require:
      - virtualenv: /home/{{ user.username }}/.virtualenvs/ipython
      - file: /home/{{ user.username }}/.virtualenvs

ipython-packages:
  pip.installed:
    - requirements: salt://python-dev/ipython.txt
    - bin_env: /home/{{ user.username }}/.virtualenvs/ipython
    - user: {{ user.username }}
    - require:
      - pip: statsmodel-deps 
      - file: /home/{{ user.username }}/.virtualenvs
{% endfor %}
