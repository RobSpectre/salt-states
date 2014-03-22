{% if pillar.get('chickcam', None) %}
{{ pillar['chickcam']['user'] }}:
  group:
    - present
  user.present:
    - fullname: Chickcam
    - gid_from_name: True
    - shell: /sbin/nologin
    - createhome: True
    - require:
      - group: {{ pillar['chickcam']['user'] }}
      - pkg: nginx

{{ pillar['chickcam']['user'] }}-hls-supervisord-conf:
  file.managed:
    - name: /etc/supervisor/conf.d/{{ pillar['chickcam']['user'] }}.conf
    - source: salt://{{ pillar['chickcam']['user'] }}/hls-supervisor.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
      cam_user: {{ pillar['chickcam']['cam']['user'] }}
      cam_password: {{ pillar['chickcam']['cam']['password'] }}
      cam_uri: {{ pillar['chickcam']['cam']['uri'] }}
      linux_user: {{ pillar['chickcam']['user'] }}
      server_name: {{ pillar['chickcam']['server_name'] }}
    - context:
    - require:
      - pip: supervisor

/home/{{ pillar['chickcam']['user'] }}/{{ pillar['chickcam']['server_name'] }}/hls:
    file.directory:
      - file_mode: 755 
      - dir_mode: 755
      - makedirs: True
      - user: {{ pillar['chickcam']['user'] }} 
      - group: {{ pillar['chickcam']['user'] }}
      - recurse:
        - user
        - group
        - mode
      - require:
        - pkg: nginx
        - file: {{ pillar['chickcam']['user'] }}-hls-supervisord-conf 

chickcam-hls:
  supervisord.running:
    - update: True 
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - bin_env: /usr/local/bin/supervisorctl
    - require:
      - pip: supervisor
      - file: {{ pillar['chickcam']['user'] }}-hls-supervisord-conf
      - file: ffmpeg-stream-preset 
    - watch:
      - pip: supervisor
      - file: {{ pillar['chickcam']['user'] }}-hls-supervisord-conf 

ffmpeg-stream-preset:
  file.managed:
    - name: /home/{{ pillar['chickcam']['user'] }}/.ffmpeg/libx264-livestream.ffpreset
    - source: salt://{{ pillar['chickcam']['user'] }}/stream.preset
    - mode: 644 
    - user: {{ pillar['chickcam']['user'] }}
    - group: {{ pillar['chickcam']['user'] }}
    - require:
      - cmd: ffmpeg-clean

{{ pillar['chickcam']['user'] }}-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/{{ pillar['chickcam']['server_name'] }}.conf
    - source: salt://chickcam/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
      linux_user: {{ pillar['chickcam']['user'] }}
      server_name: {{ pillar['chickcam']['server_name'] }}
    - require:
      - pkg: nginx

{{ pillar['chickcam']['user'] }}-log-directory:
    file.directory:
      - name: /var/log/nginx/{{ pillar['chickcam']['server_name'] }}
      - mode: 644
      - user: www-data
      - group: www-data
      - require:
        - pkg: nginx
        - file.managed: {{ pillar['chickcam']['user'] }}-nginx-conf

enable-nginx-site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ pillar['chickcam']['server_name'] }}.conf
    - target: /etc/nginx/sites-available/{{ pillar['chickcam']['server_name'] }}.conf
    - force: false
    - require:
      - file: {{ pillar['chickcam']['user'] }}-nginx-conf 
{% endif %}
