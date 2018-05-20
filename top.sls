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
    - letsencrypt
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
    - gimp
    - ffmpeg
    - vlc
    - python-dev
    - robrepos
    - ruby
    - nodejs
    - ssh.server
    - gnome-terminal-colors-solarized
    - ngrok
  'roles:domaincontroller':
    - match: grain
    - named
    - dhcpd
  'roles:backup_sync*':
    - match: grain
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
  'apps:humantrafficking.tips':
    - match: grain
    - python
    - supervisor
    - nginx
    - postgres
    - rabbitmq
    - humantrafficking
  'apps:garfield':
    - match: grain
    - python
    - python-dev
    - supervisor
    - nginx
    - postgres
    - rabbitmq
    - garfield
  'apps:childsafe.io':
    - match: grain
    - python
    - supervisor
    - nginx
    - postgres
    - rabbitmq
    - childsafe
