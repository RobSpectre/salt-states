nvm:
  git.latest:
    - name: https://github.com/creationix/nvm.git
    - target: /usr/local/nvm
    - rev: master
    - submodules: True
    - require:
      - pkg: nodejs

grunt-cli:
  npm.installed:
    - require:
      - pkg: npm

bower:
  npm.installed:
    - require:
      - pkg: npm
