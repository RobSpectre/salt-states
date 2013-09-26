twilio-demo-docroot:
  file.directory:
    - name: /home/rspectre/demo01.brooklynhacker.com
    - file_mode: 644
    - dir_mode: 755
    - user: rspectre 
    - group: rspectre
    - makedirs: True
    - require:
      - user.present: rspectre
      - group.present: rspectre
    - recurse:
      - user
      - group
      - mode

twilio-demo-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/twilio-demo.conf
    - source: salt://demo/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
    - context:
      server_name: demo01.brooklynhacker.com
    - require:
      - pkg.latest: nginx

twilio-demo-log-directory:
    file.directory:
      - name: /var/log/nginx/demo01.brooklynhacker.com
      - mode: 644
      - user: www-data
      - group: www-data
      - require:
        - file.managed: twilio-demo-nginx-conf

twilio-demo-nginx-enable:
  file.symlink:
    - name: /etc/nginx/sites-enabled/twilio-demo.conf
    - target: /etc/nginx/sites-available/twilio-demo.conf
    - force: false
    - require:
      - file.managed: twilio-demo-log-directory
