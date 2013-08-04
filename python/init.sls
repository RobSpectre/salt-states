packages:
  pkg.installed:
    - names:
      - python
      - python-dev
      - python-pip
      - build-essential

Check pip version:
  cmd.run:
    - name: python check_pip_version.py
    - cwd: /srv/salt/python
    - stateful: True
    - require:
      - pkg.installed: python-pip

Upgrade pip:
  cmd.wait:
    - name: pip install --upgrade pip
    - cwd: /srv/salt/python
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
