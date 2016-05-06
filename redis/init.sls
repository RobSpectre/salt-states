redis:
  pkg.latest:
    - names:
      - redis-server
  service.running:
    - name: redis-server
    - require:
      - pkg: redis
