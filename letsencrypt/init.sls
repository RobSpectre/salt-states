letsencrypt:
  virtualenv.managed:
    - name: /opt/letsencrypt
    - require:
      - pkg: python
  pip.installed:
    - bin_env: /opt/letsencrypt
    - require:
      - virtualenv: letsencrypt
