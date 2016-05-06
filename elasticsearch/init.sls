include:
  - java

elasticsearch-repo:
  pkgrepo.managed:
    - humanname: ElasticSearch Repo
    - name: deb http://packages.elastic.co/elasticsearch/1.7/debian stable main
    - file: /etc/apt/sources.list.d/elasticsearch-1.7.list
    - key_url: https://packages.elastic.co/GPG-KEY-elasticsearch 

elasticsearch:
  pkg.latest:
    - require:
      - pkgrepo: elasticsearch-repo
  service.running:
    - require:
      - pkg: elasticsearch

/etc/elasticsearch/elasticsearch.yml:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: salt://elasticsearch/elasticsearch.yml
