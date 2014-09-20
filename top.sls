base:
  '*':
    - git
    - users
    - vim
    - ssh
    - python
    - apt
    - salt
    - archive
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
  'apps:snowcam':
    - match: grain
    - snowcam
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
    - transmission
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
  'roles:domaincontroller':
    - match: grain
    - named
    - dhcpd
  'roles:backup_sync*':
    - match: grain
    - btsync
  'apps:votr':
    - match: grain
    - nginx
    - nodejs
    - couchdb
    - votr
  'apps:stashtracker':
    - match: grain
    - nginx
    - nodejs
    - stashtracker
  'domaincontroller01.ghettopenthouse.pvt':
    - dns_ghettopenthouse
