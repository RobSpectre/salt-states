base:
  '*':
    - git
    - users
    - vim
    - ssh
    - python
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
