base:
  '*':
    - git
    - users
    - vim
    - ssh
    - python
    - apt
    - salt
  '*.brooklynhacker.com':
    - ssh.server
    - iptables
  'mediacenter*':
    - ssh.server
    - xbmc
    - sabnzbd
    - sickbeard
    - couchpotato
    - sharedesktop
    - nvidia
