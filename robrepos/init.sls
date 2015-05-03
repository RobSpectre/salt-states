{% for user in pillar.get('users', []) %}
{% if user.username == 'rspectre' %}
/home/{{ user.username }}/workspace:
  file.directory:
    - file_mode: 644
    - dir_mode: 755
    - user: {{ user.username }}
    - group: {{ user.username }}
    - makedirs: True
    - require:
      - user: {{ user.username }}
      - group: {{ user.username }}

repo_talks:
  git.latest:
    - name: git://github.com/RobSpectre/Talks.git
    - target: /home/{{ user.username }}/workspace/Talks
    - rev: master
    - submodules: True
    - runas: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/workspace

repo_reveal_template:
  git.latest:
    - name: git://github.com/RobSpectre/Twilio-Reveal-Template.git
    - target: /home/{{ user.username }}/workspace/Twilio Reveal Template
    - rev: master
    - submodules: True
    - runas: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/workspace

repo_stash_tracker:
  git.latest:
    - name: git://github.com/RobSpectre/Stash-Tracker.git
    - target: /home/{{ user.username }}/workspace/Stash Tracker
    - rev: master
    - submodules: True
    - runas: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/workspace

repo_hackpack:
  git.latest:
    - name: git://github.com/RobSpectre/Twilio-Hackpack-for-Heroku-and-Flask.git
    - target: /home/{{ user.username }}/workspace/hackpack
    - rev: master
    - submodules: True
    - runas: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/workspace

repo_motionalert:
  git.latest:
    - name: git://github.com/RobSpectre/motionalert.git
    - target: /home/{{ user.username }}/workspace/motionalert
    - rev: master
    - submodules: True
    - runas: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/workspace

repo_mustacher:
  git.latest:
    - name: git://github.com/RobSpectre/Mustached-Message-Service.git
    - target: /home/{{ user.username }}/workspace/Mustached Message Service
    - rev: master
    - submodules: True
    - runas: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/workspace

repo_caesar_cipher:
  git.latest:
    - name: git://github.com/RobSpectre/Caesar-Cipher.git
    - target: /home/{{ user.username }}/workspace/caesarcipher
    - rev: master
    - submodules: True
    - runas: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/workspace

repo_ratmap:
  git.latest:
    - name: git://github.com/RobSpectre/NYC-Rat-Heat-Map.git
    - target: /home/{{ user.username }}/workspace/NYC Rat Heat Map
    - rev: master
    - submodules: True
    - runas: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/workspace

repo_jeterfilter:
  git.latest:
    - name: git://github.com/RobSpectre/Jeter-Filter.git
    - target: /home/{{ user.username }}/workspace/Jeter Filter
    - rev: master
    - submodules: True
    - runas: {{ user.username }}
    - require:
      - file: /home/{{ user.username }}/workspace
{% endif %}
{% endfor %}
