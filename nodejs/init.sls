nodejs:
  pkgrepo.managed:
    - humanname: Nodesource Repo
    - name: deb https://deb.nodesource.com/node_6.x {{ grains['lsb_distrib_codename'] }} main
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
  pkg:
    - latest
    - require:
      - pkgrepo: nodejs
