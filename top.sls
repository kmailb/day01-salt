base:
  '*':
    - common.packages
  'web':
    - webserver.nginx
    - zabbix.agent
    - monit.client
  'monitoring':
    - mysql.server
    - zabbix.server
    - monit.server