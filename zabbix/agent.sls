zabbix-agent:
   pkg.installed

/etc/zabbix_agentd.conf:
  file.managed:
    - name: 
    - source: salt://zabbix/files/zabbix_agentd.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja

run zabbix agent service:
  service.running:
    - name: zabbix-agent
    - enable: True
