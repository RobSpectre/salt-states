couchdb:
  pkg.latest:
    - name: couchdb
  service.running:
    - enable: True
    - require:
      - pkg: couchdb
