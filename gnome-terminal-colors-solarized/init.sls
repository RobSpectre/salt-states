dconf-cli:
  pkg.latest

{% for user in pillar.get('users', []) %} 
gnome-terminal-colors-solarized:
  git.latest:
    - name: git://github.com/Anthony25/gnome-terminal-colors-solarized.git
    - target: /home/{{ user.username }}/gnome-terminal-colors-solarized
    - user: {{ user.username }}
    - require:
      - pkg: dconf-cli
{% endfor %}
