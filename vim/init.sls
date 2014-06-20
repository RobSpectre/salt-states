vim-deps:
  pkg.latest:
    - names:
      - exuberant-ctags
    - require_in:
      - pkg: vim

{% for user in pillar.get('users', []) %}
vim-vundle:
  git.latest:
    - name: git://github.com/gmarik/vundle.git
    - rev: master
    - target: /home/{{ user.username }}/.vim/bundle/vundle
    - submodules: true
    - runas: {{ user.username }} 
{% endfor %}

vim:
  pkg.latest:
  - require:
    - pkg: vim-deps
    
/etc/vimrc:
  file.managed:
    - source: salt://vim/vimrc
    - mode: 644
    - user: root
    - group: root

{% for user in pillar.get('users', []) %}
/home/{{ user.username }}/.vimrc:
  file.managed:
    - source: salt://vim/vimrc
    - mode: 644
    - user: {{ user.username }}
    - group: {{ user.username }}
{% endfor %}
