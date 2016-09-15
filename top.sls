base:
  '*':
    - git
    - users
    - vim
    - ssh
    - python
    - salt
    - archive
    - vulnerable_packages
  'os:Ubuntu':
    - match: grain
    - apt
  'environment:production':
    - match: grain
    - ssh.server
    - iptables
    - supervisor
  'roles:mediastreamer':
    - match: grain
    - ffmpeg
    - vlc
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
    - kodi 
    - sabnzbd
    - couchpotato
    - sharedesktop
    - sickbeard
    - deluge
  'roles:desktop':
    - match: grain
    - pidgin
    - handbrake
    - shutter 
    - audacity
    - openshot
    - heroku
    - synergy
    - gimp
    - ffmpeg
    - vlc
    - btsync-gui
    - python-dev
    - robrepos
    - ruby
    - nodejs
    - ssh.server
    - google-chrome
    - btsync-gui
    - gnome-terminal-colors-solarized
    - ngrok
  'roles:domaincontroller':
    - match: grain
    - named
    - dhcpd
  'roles:backup_sync*':
    - match: grain
    - btsync
  'roles:web':
    - match: grain
    - nginx
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
  'apps:slackbot':
    - match: grain
    - supervisor
    - nginx
    - slackbot
  'domaincontroller01':
    - dns_ghettopenthouse
  'apps:adcap.biz':
    - match: grain
    - python
    - supervisor
    - nginx 
    - postgres
    - redis
    - elasticsearch
    - adcap
