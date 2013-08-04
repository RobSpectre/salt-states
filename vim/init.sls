vim-deps:
   pkg.installed:
     - names:
       - exuberant-ctags
     - require_in:
       - pkg: vim

vim-vundle:
   git.latest:
     - name: git://github.com/gmarik/vundle.git
     - target: /home/rspectre/.vim/bundle/vundle
     - submodules: true
     - runas: rspectre

vim:
    require:
      - pkg: vim-deps
    pkg:
      - installed
    
/etc/vimrc:
  file.managed:
    - source: salt://vim/vimrc
    - mode: 644
    - user: root
    - group: root

/home/rspectre/.vimrc:
  file.managed:
    - source: salt://vim/vimrc
    - mode: 644
    - user: rspectre
    - group: rspectre
