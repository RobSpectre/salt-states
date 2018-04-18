swig:
  pkg.installed:
    - require_in:
      - service: salt-minion

/etc/salt/minion:
  file.managed:
    - source: salt://salt/minion
    - mode: 644
    - user: root
    - group: root

/etc/salt/minion.d/empty:
  file.managed:
    - source: salt://salt/empty
    - mode: 600
    - user: root
    - group: root

salt-minion:
  service.running:
    - enable: True
    - watch:
      - file: /etc/salt/minion
      - file: /etc/salt/minion.d/*
    - require:
      - file: /etc/salt/minion
      - file: pip-10.0.0-fix-pip
      - file: pip-10.0.0-fix-pip_state
      - file: pip-10.0.0-fix-virtualenv_mod

pip-10.0.0-fix-pip:
  file.patch:
    - name: /usr/lib/python2.7/dist-packages/salt/modules/pip.py
    - source: salt://salt/pip-10.0.0-fix-pip.patch
    - hash: md5:0631af395d562b1208bb6e8b12cf8408

pip-10.0.0-fix-pip_state:
  file.patch:
    - name: /usr/lib/python2.7/dist-packages/salt/states/pip_state.py
    - source: salt://salt/pip-10.0.0-fix-pip_state.patch
    - hash: md5:0dbe25eb146ba82453a1dfd76bc47b95

pip-10.0.0-fix-virtualenv_mod:
  file.patch:
    - name: /usr/lib/python2.7/dist-packages/salt/states/virtualenv_mod.py
    - source: salt://salt/pip-10.0.0-fix-virtualenv_mod.patch
    - hash: md5:1843b5352566009ba705776581aaae1c
