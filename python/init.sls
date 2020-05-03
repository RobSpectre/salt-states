build-essential:
  pkg.latest

packages:
  pkg.latest:
    - names:
      - python
      - python-dev
      - python-venv
      {% if grains['lsb_distrib_codename'] == 'disco' %}
      - python3.7
      - python3.7-dev
      - python3.7-venv
      - python3-pip
      {% else %}
      - python3.5
      - python3.5-dev
      - python3.7-venv
      - python3-pip
      {% endif %}
      - python-pip
      - python-pycurl
    - require:
      - pkg: build-essential
      - service: salt-minion

#/usr/local/bin/check_pip_version.py:
#  file.managed:
#    - source: salt://python/check_pip_version.py
#    - mode: 644
#    - user: root
#    - group: root
#    - require:
#      - pkg: python-pip

#Check pip version:
#  cmd.run:
#    - name: python check_pip_version.py
#    - cwd: /usr/local/bin
#    - stateful: True
#    - require:
#      - pkg: python-pip

#Upgrade pip:
#  cmd.wait:
#    - name: pip install --upgrade pip
#    - cwd: /tmp
#    - watch:
#      - cmd: Check pip version

pip:
  pip.installed:
    - upgrade: True
    - require:
      - pkg: python-pip

virtualenv:
  pip.installed:
    - name: virtualenv == 16.7.9
    - require:
      - pkg: python-pip

virtualenvwrapper:
  pip.installed:
    - upgrade: True
    - require:
      - pip: virtualenv 

pyflakes:
  pip.installed:
    - upgrade: True
    - require:
      - pip: virtualenv

pep8:
  pip.installed:
    - upgrade: True
    - require:
      - pip: virtualenv

flake8:
  pip.installed:
    - upgrade: True
    - require:
      - pip: virtualenv

requests:
  pip.installed:
    - upgrade: True
    - require:
      - pip: virtualenv

simplejson:
  pip.installed:
    - upgrade: True
    - require:
      - pip: virtualenv

twilio:
  pip.installed:
    - upgrade: True
    - require:
      - pip: virtualenv

GitPython:
  pip.installed:
    - upgrade: True
    - require:
      - pip: virtualenv

pytest:
  pip.installed:
    - upgrade: True
    - require:
      - pip: virtualenv
