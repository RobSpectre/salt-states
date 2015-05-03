ngrok:
  archive.extracted:
    - archive_format: zip
    - name: /usr/local/bin/
    - source: https://dl.ngrok.com/ngrok_2.0.17_linux_amd64.zip
    - source_hash: md5=fcf800f4a6ef8b9042adf77c669976c5
    - if_missing: /usr/local/bin/ngrok 

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
