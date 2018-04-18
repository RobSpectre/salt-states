{% if pillar.get('snowcam', None) %}
{{ pillar['snowcam']['user'] }}:
  group:
    - present
  user.present:
    - fullname: Chickcam
    - gid_from_name: True
    - shell: /sbin/nologin
    - createhome: True
    - require:
      - group: {{ pillar['snowcam']['user'] }}
      - pkg: nginx

{{ pillar['snowcam']['user'] }}-hls-supervisord-conf:
  file.managed:
    - name: /etc/supervisor/conf.d/{{ pillar['snowcam']['user'] }}.conf
    - source: salt://{{ pillar['snowcam']['user'] }}/hls-supervisor.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
      cam_user: {{ pillar['snowcam']['cam']['user'] }}
      cam_password: {{ pillar['snowcam']['cam']['password'] }}
      cam_uri: {{ pillar['snowcam']['cam']['uri'] }}
      linux_user: {{ pillar['snowcam']['user'] }}
      server_name: {{ pillar['snowcam']['server_name'] }}
    - context:
    - require:
      - pkg: supervisor

/home/{{ pillar['snowcam']['user'] }}/{{ pillar['snowcam']['server_name'] }}/hls:
    file.directory:
      - file_mode: 755 
      - dir_mode: 755
      - makedirs: True
      - user: {{ pillar['snowcam']['user'] }} 
      - group: {{ pillar['snowcam']['user'] }}
      - recurse:
        - user
        - group
        - mode
      - require:
        - pkg: nginx
        - file: {{ pillar['snowcam']['user'] }}-hls-supervisord-conf 

snowcam-hls:
  supervisord.running:
    - update: True 
    - restart: True
    - conf_file: /etc/supervisor/supervisord.conf
    - bin_env: /usr/local/bin/supervisorctl
    - require:
      - pkg: supervisor
      - file: {{ pillar['snowcam']['user'] }}-hls-supervisord-conf
      - file: ffmpeg-stream-preset 
    - watch:
      - pkg: supervisor
      - file: {{ pillar['snowcam']['user'] }}-hls-supervisord-conf 

ffmpeg-stream-preset:
  file.managed:
    - name: /home/{{ pillar['snowcam']['user'] }}/.ffmpeg/libx264-livestream.ffpreset
    - source: salt://{{ pillar['snowcam']['user'] }}/stream.preset
    - mode: 644 
    - user: {{ pillar['snowcam']['user'] }}
    - group: {{ pillar['snowcam']['user'] }}
    - require:
      - cmd: ffmpeg-clean

{{ pillar['snowcam']['user'] }}-nginx-conf:
  file.managed:
    - name: /etc/nginx/sites-available/{{ pillar['snowcam']['server_name'] }}.conf
    - source: salt://snowcam/nginx.conf
    - mode: 644
    - user: root
    - group: root
    - template: jinja
      linux_user: {{ pillar['snowcam']['user'] }}
      server_name: {{ pillar['snowcam']['server_name'] }}
    - require:
      - pkg: nginx

{{ pillar['snowcam']['user'] }}-log-directory:
    file.directory:
      - name: /var/log/nginx/{{ pillar['snowcam']['server_name'] }}
      - mode: 644
      - user: www-data
      - group: www-data
      - require:
        - pkg: nginx
        - file: {{ pillar['snowcam']['user'] }}-nginx-conf

enable-nginx-site:
  file.symlink:
    - name: /etc/nginx/sites-enabled/{{ pillar['snowcam']['server_name'] }}.conf
    - target: /etc/nginx/sites-available/{{ pillar['snowcam']['server_name'] }}.conf
    - force: false
    - require:
      - file: {{ pillar['snowcam']['user'] }}-nginx-conf 
{% endif %}
