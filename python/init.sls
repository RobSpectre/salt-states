build-essential:
  pkg.latest

packages:
  pkg.latest:
    - names:
      - python
      - python-dev
      - python-pip
    - require:
      - pkg.installed: build-essential

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
      - pkg.installed: python-pip
      - file.managed: /opt/salt-utils/check_pip_version.py

Upgrade pip:
  cmd.wait:
    - name: pip install --upgrade pip
    - cwd: /opt/salt-utils
    - watch:
      - cmd: Check pip version

virtualenv:
  pip.installed:
    - require:
      - pkg: python-pip

virtualenvwrapper:
  pip.installed:
    - require:
      - pip.installed: virtualenv 

pyflakes:
  pip.installed:
    - require:
      - pip.installed: virtualenv

pep8:
  pip.installed:
    - require:
      - pip.installed: virtualenv

requests:
  pip.installed:
    - require:
      - pip.installed: virtualenv

simplejson:
  pip.installed:
    - require:
      - pip.installed: virtualenv

twilio:
  pip.installed:
    - require:
      - pip.installed: virtualenv

GitPython:
  pip.installed:
    - require:
      - pip.installed: virtualenv
