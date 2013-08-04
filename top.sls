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
