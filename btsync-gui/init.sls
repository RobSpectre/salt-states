btsync-gui:
  pkgrepo.managed:
    - ppa: tuxpoldo/btsync
  pkg.latest:
    - require:
      - pkgrepo: btsync-gui
