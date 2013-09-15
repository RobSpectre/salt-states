sentry-deps:
  pkg:
    - installed
    - latest
    - names:
      - nginx
      - postgresql
    - require_in:
      - virtualenv.installed: sentry
      - file.managed: /home/sentry/.sentry/sentry.conf.py
      - file.directory: /home/sentry
      - user.present: sentry
      - group.present: sentry

sentry:
  user.present:
    - shell: /usr/sbin/nologin
  group:
    - present
  require:
    - pkg.installed: sentry-deps

/home/sentry:
  file.directory:
    - file_mode: 644
    - dir_mode: 755
    - user: sentry
    - group: sentry
    - makedirs: True
    - require:
      - user.present: sentry 
      - group.present: sentry
    - recurse:
      - user
      - group
      - mode
  require:
    - pkg.installed: sentry-deps

/home/sentry/.sentry/sentry.conf.py:
  file.managed:
    - source: salt://sentry/sentry.conf.py
    - mode: 600
    - user: sentry
    - group: sentry
    - template: jinja
  require:
    - pkg.installed: sentry-deps

/home/sentry/virtualenv:
  virtualenv.managed:
    - no_site_packages: True
    - requirements: salt://sentry/requirements.txt
    - runas: sentry
  require:
    - pkg.installed: sentry-deps

sentry-service:
  service:
    - name: sentry
    - running
    - enable: True
    - reload: True
    - runas: sentry
    - watch:
      - virtualenv.managed: /home/sentry/virtualenv
      - file.managed: /home/sentry/.sentry/sentry.conf.py
  require:
    - pkg.installed: sentry-deps
    - virtualenv.managed: /home/sentry/virtualenv
