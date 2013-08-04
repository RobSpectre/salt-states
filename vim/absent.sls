vim:
  pkg:
    {% if grains['os'] == 'CentOS' or grains['os'] == 'Fedora' %}
    - name: vim-enhanced
    {% elif grains['os'] == 'Debian' %}
    - name: vim-runtime
    {% endif %}
    - purged
