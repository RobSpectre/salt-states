btsync:
  service.running:
    - enable: True
    - watch:
      - archive: btsync-download
    - require:
      - file: /etc/init.d/btsync
      - user: btsync
      - group: btsync
      - archive: btsync-download
      - file: /home/btsync/Sync
      - file: /home/btsync/.sync
      - file: btsync-log
  user.present:
    - fullname: Bittorrent Sync
    - gid_from_name: True 
    - shell: /sbin/nologin
    - createhome: True 
    - require:
      - group: btsync
  group:
    - present

btsync-download:
  archive.extracted:
    - name: /opt/
    - source: http://download.getsyncapp.com/endpoint/btsync/os/linux-x64/track/stable
    - tar_options: x
    - archive_format: tar
    - source_hash: md5=11df67e44eea7b127b8d5a3d9501c07d
    - if_missing: /opt/btsync

/etc/init.d/btsync:
  file.managed:
    - source: salt://btsync/init_script
    - mode: 755
    - user: root
    - group: root

btsync-log:
  file.managed:
    - name: /var/log/btsync.log
    - mode: 644 
    - user: btsync 
    - group: btsync
    - require:
      - user: btsync
      - group: btsync
      - archive: btsync-download

/home/btsync/Sync:
  file.directory:
    - mode: 755 
    - user: btsync
    - group: btsync

/home/btsync/.sync:
  file.directory:
    - mode: 755 
    - user: btsync
    - group: btsync

/home/btsync/.sync/config.json:
  file.managed:
    - source: salt://btsync/config.json
    - mode: 600
    - user: btsync
    - group: btsync
    - template: jinja
      hostname: {{ grains.id }}
      username: {{ pillar['users'][0].username }}
      password_hash: {{ pillar['users'][0].crypt3_hash }}
    {% if pillar.get('shared_folders', None) %}
      shared_folders: {{ pillar.get('shared_folders', None) }}
    {% else %}
      shared_folders: None
    {% endif %}
    - require:
      - user: btsync
      - group: btsync
      - file: /home/btsync/.sync

{% if pillar.get('shared_folders', None) %}
{% for shared_folder in pillar['shared_folders'] %}
/home/btsync/Sync/{{ shared_folder.path }}:
  file.directory:
    - mode: 755 
    - user: btsync
    - group: btsync
    - require_in:
      - service: btsync
{% endfor %}
{% endif %}
