build-essential:
  pkg.latest

packages:
  pkg.latest:
    - names:
      - python
      - python-dev
      - python-pip
    - require:
      - pkg: build-essential

/opt/salt-utils/check_pip_version.py:
  file.managed:
    - source: salt://python/check_pip_version.py
    - mode: 644
    - user: root
    - group: root

Check pip version:
  cmd.run:
    - name: python check_pip_version.py
    - cwd: /opt/salt-utils
    - stateful: True
    - require:
      - pkg: python-pip
      - file: /opt/salt-utils/check_pip_version.py

Upgrade pip:
  cmd.wait:
    - name: pip install --upgrade pip
    - cwd: /opt/salt-utils
    - watch:
      - cmd: Check pip version

virtualenv:
  pip.installed:
    - upgrade: True
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
