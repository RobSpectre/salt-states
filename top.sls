base:
  '*':
    - git
    - users
    - vim
    - ssh
    - python
    - apt
    - salt
  'environment:production':
    - match: grain
    - ssh.server
    - iptables
    - supervisor
  'roles:mediastreamer':
    - match: grain
    - ffmpeg
    - vlc
  'apps:chickcam':
    - match: grain
    - chickcam
    - nginx
  'apps:openvbx':
    - match: grain
    - nginx
    - mysql
    - php
    - openvbx
  'apps:twilio_demo':
    - match: grain
    - nginx
    - php
    - demo
  'roles:mediacenter':
    - match: grain
    - ssh.server
    - xbmc
    - sabnzbd
    - couchpotato
    - sharedesktop
    - sickbeard
    - nvidia
  'roles:desktop':
    - match: grain
    - pidgin
    - handbrake
    - screencloud
    - flash
    - audacity
    - openshot
    - dropbox
    - heroku
    - synergy
    - gimp
    - gmtp
    - ffmpeg
    - vlc
    - dataanalysis
    - robrepos
