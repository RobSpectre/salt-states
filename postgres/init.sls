postgres:
  pkg.latest:
    - names:
      - postgresql
      - postgresql-server-dev-all
  service.running:
    - name: postgresql
    - require:
      - pkg: postgresql
    - watch:
      - pkg: postgresql

psycopg2:
  pip.installed:
    - upgrade: True
    - require: 
      - pkg: postgres
