jockey-gtk:
  pkg.removed

jockey-common:
  pkg.removed

jockey-text:
  pkg.removed

nvidia-current:
  pkg.latest

lightdm:
  service:
    - running
    - watch:
      - pkg: nvidia-current

/etc/X11/xorg.conf:
  file.managed:
    - source: salt://nvidia/xorg.conf
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg.installed: nvidia-current
