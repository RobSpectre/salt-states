hipchat:
  pkgrepo.managed:
    - humanname: Hipchat Repo
    - name: deb http://downloads.hipchat.com/linux/apt stable main
    - file: /etc/apt/sources.list.d/hipchat.list
    - key_url: https://www.hipchat.com/keys/hipchat-linux.key 
  pkg.latest:
    - require:
      - pkgrepo: hipchat
