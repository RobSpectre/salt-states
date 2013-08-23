vino:
  pkg.latest

{% for user in pillar.get('users', []) %}
{% if user.vnc_hash %}
/home/{{ user.username }}/.gconf/desktop/gnome/remote_access/%gconf.xml:
  file.managed:
    - source: salt://sharedesktop/%gconf.xml
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
    - template: jinja
    - context:
      vnc_hash: {{ user.vnc_hash }}
    - require:
      - pkg.installed: vino

Turn off confirmation prompt:
  cmd.run:
    - name: gconftool-2 -s -t bool /desktop/gnome/remote_access/prompt_enabled false
    - cwd: /home/{{ user.username }}
    - watch:
      - file: /home/{{ user.username }}/.gconf/desktop/gnome/remote_access/%gconf.xml

Turn off view only:
  cmd.run:
    - name: gconftool-2 -s -t bool /desktop/gnome/remote_access/view_only false
    - cwd: /home/{{ user.username }}
    - watch:
      - file: /home/{{ user.username }}/.gconf/desktop/gnome/remote_access/%gconf.xml

{% endif %}
{% endfor %}
