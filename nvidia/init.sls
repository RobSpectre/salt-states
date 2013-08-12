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
