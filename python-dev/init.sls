{% if grains['lsb_distrib_codename'] != 'disco' %}
deadsnakes-ppa:
  pkgrepo.managed:
    - ppa: deadsnakes/ppa 
{% endif %}

ipython-dependencies:
  pkg.latest:
    - names:
      - libfreetype6-dev
      {% if grains['lsb_distrib_codename'] == 'disco' %}
      - libpng-dev
      {% elif grains['lsb_distrib_codename'] == 'bionic' %}
      - libpng-dev
      {% else %}
      - libpng12-dev
      {% endif %}
      - libblas-dev
      - liblapack-dev
      - gfortran
      - python3.7-dev
      - g++
      - postgresql-client
      - libpq-dev
      - libhdf5-dev
      - python2.7
      - python3.7
      - python3.8
      - libhdf5-dev
      - hdf5-tools
      - hdf5-helpers
      - h5utils
      - libffi6
      - libffi-dev
      - libssl-dev
      - libfreetype6-dev
      {% if grains['lsb_distrib_codename'] == 'xenial' %} 
      - libhdf5-10
      {% elif grains['lsb_distrib_codename'] == 'bionic' %}
      - libhdf5-100
      {% elif grains['lsb_distrib_codename'] == 'disco' %}
      - libhdf5-103
      {% else %}
      - libhdf5-7
      {% endif %}
    {% if grains['lsb_distrib_codename'] != 'disco' %}
    - require:
      - pkgrepo: deadsnakes-ppa
    {% endif %}


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
      - pkg: ipython-dependencies 
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/authy:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://python-dev/authy.txt
    - user: {{ user.username }}
    - require:
      - pkg: ipython-dependencies 
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/django:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://python-dev/django.txt
    - user: {{ user.username }}
    - require:
      - pkg: ipython-dependencies 
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/djangorestframework:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://python-dev/djangorestframework.txt
    - user: {{ user.username }}
    - require:
      - pkg: ipython-dependencies 
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/nlp:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: salt://python-dev/nlp.txt
    - user: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/.virtualenvs

/home/{{ user.username }}/.virtualenvs/ipython:
  virtualenv.managed:
    - system_site_packages: False
    - python: /usr/bin/python3.7
    - user: {{ user.username }}
    - requirements: salt://python-dev/ipython-deps.txt
    - require:
      - pkg: ipython-dependencies
      - file: /home/{{ user.username }}/.virtualenvs

statsmodel-deps:
  pip.installed:
    - names:
      - numexpr
      - Cython
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
