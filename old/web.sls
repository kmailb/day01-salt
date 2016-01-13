install web-related packages:
  pkg.installed:
    - pkgs:
       - nginx
       - zabbix-agent
       - monit
       
provision html sources:
  file.recurse:
    - name: /var/www
    - source: salt://www
    - user: nginx
    - group: nginx
    - dir_mode: 755
    - file_mode: 644
    - clean: True

configure and run nginx instance:
  file.managed:
    - name: /etc/nginx/conf.d/default.conf
    - source: salt://etc/nginx.conf
    - user: root
    - group: root
    - mode: 644
  service.running:
    - name: nginx
    - enable: True

run nginx instance:
  service.running:
    - name: nginx
    - enable: True

configure and run zabbix agent:
  file.managed:
    - name: /etc/zabbix_agentd.conf
    - source: salt://etc/zabbix_agentd.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  service.running:
    - name: zabbix-agent
    - enable: True

configure and run monit client:
  file.managed:
    - name: /etc/monit.conf
    - source: salt://etc/monit-client.conf
    - user: root
    - group: root
    - mode: 600
    - template: jinja
  service.running:
    - name: monit
    - enable: True
