install packages:
    pkg.installed:
    - name: monit

copy config file:
  file.managed:
    - name: /etc/monit.conf
    - source: salt://monit/files/monit-client.conf
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    
run service:
  service.running:
    - name: monit
    - enable: True
