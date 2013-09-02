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
    - supervisor
  'mediacenter*':
    - ssh.server
    - xbmc
    - sabnzbd
    - sickbeard
    - couchpotato
    - sharedesktop
    - nvidia
  'mediastreamer*':
    - ffmpeg
    - vlc
  'mediastreamer01.brooklynhacker.com':
    - chickcam
    - nginx
