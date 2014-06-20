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
      - service: salt-minion

/usr/local/bin/check_pip_version.py:
  file.managed:
    - source: salt://python/check_pip_version.py
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: python-pip

Check pip version:
  cmd.run:
    - name: python check_pip_version.py
    - cwd: /usr/local/bin
    - stateful: True
    - require:
      - pkg: python-pip

Upgrade pip:
  cmd.wait:
    - name: pip install --upgrade pip
    - cwd: /tmp
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
