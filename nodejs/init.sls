nodejs:
  pkgrepo.managed:
    - ppa: chris-lea/node.js
  pkg:
    - latest
    - require:
      - pkgrepo: nodejs
