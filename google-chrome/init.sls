google-chrome:
  pkgrepo.managed:
    - humanname: Google Chrome PPA 
    - name: deb http://dl.google.com/linux/chrome/deb/ stable main 
    - file: /etc/apt/sources.list.d/google-chrome.list
    - key_url: https://dl-ssl.google.com/linux/linux_signing_key.pub

google-chrome-stable:
  pkg.latest:
    - require:
      - pkgrepo: google-chrome
