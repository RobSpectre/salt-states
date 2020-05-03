ngrok:
  archive.extracted:
    - archive_format: zip
    - name: /usr/local/bin/
    - source: https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip 
    - source_hash: md5=a9aed972a34bdec5968398077e27b540
    - if_missing: /usr/local/bin/ngrok 
    - enforce_toplevel: False

{% for user in pillar.get('users', []) %}
{% if user.get('ngrok_key', None) %}
/home/{{ user.username }}/.ngrok2/ngrok.yml:
  file.managed:
    - source: salt://ngrok/ngrok.yml
    - user: {{ user.username }}
    - group: {{ user.username }}
    - mode: 644
    - makedirs: True
    - template: jinja
    - context:
      token: {{ user.ngrok_key }}
{% endif %}
{% endfor %}
