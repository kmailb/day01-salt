install zabbix-related packages:
  pkg.installed:
    - pkgs:
      - zabbix22-server-mysql
      - zabbix22-web-mysql

#mysql -uroot
#mysql> create database zabbix character set utf8 collate utf8_bin;
#mysql> grant all privileges on zabbix.* to zabbix@localhost identified by 'negCiUkcivHut9';
#mysql> exit

# mysql -uroot zabbix < /usr/share/zabbix-mysql/schema.sql
# mysql -uroot zabbix < /usr/share/zabbix-mysql/images.sql
# mysql -uroot zabbix < /usr/share/zabbix-mysql/data.sql

# vi /etc/zabbix/zabbix_server.conf
#DBHost=localhost
#DBName=zabbix
#DBUser=zabbix
#DBPassword=zabbix

#php_value max_execution_time 300
#php_value memory_limit 128M
#php_value post_max_size 16M
#php_value upload_max_filesize 2M
#php_value max_input_time 300
## php_value date.timezone Europe/Riga

#"/etc/zabbix/web/zabbix.conf.php"

configure zabbix server:
  file.managed:
    - name: /etc/zabbix_server.conf
    - source: salt://zabbix/files/zabbix_server.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    
configure web server:
  file.managed:
    - name: /etc/httpd/conf.d/zabbix.conf
    - source: salt://zabbix/files/zabbix_server_apache.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    
configure zabbix web interface:
  file.managed:
    - name: /etc/zabbix/web/zabbix.conf.php
    - source: salt://zabbix/files/zabbix.conf.php
    - user: apache
    - group: apache
    - mode: 640
    - template: jinja

create zabbix user:
  mysql_user.present:
    - name: {{ pillar['zabbix-mysql-username'] }}
    - host: localhost
    - password: {{ pillar['zabbix-mysql-pwd'] }}
    
create zabbix database:
  mysql_database.present:
    - name: {{ pillar['zabbix-mysql-database'] }}
    - character_set: utf8
    - collate: utf8_bin
    
grant rights to zabbix user:
  mysql_grants.present:
    - grant: all
    - database: {{ pillar['zabbix-mysql-database'] }}.*
    - user: {{ pillar['zabbix-mysql-username'] }}
    - host: localhost

populate zabbix database:
  file.managed:
    - name: /tmp/zabbix.dump.1.sql
    - source: salt://zabbix/files/zabbix.dump.1.sql
    - user: root
    - group: root
    - mode: 600
  cmd.run:
    - name: /usr/bin/mysql -u {{ pillar['zabbix-mysql-username'] }} -h localhost --password={{ pillar['zabbix-mysql-pwd'] }} {{ pillar['zabbix-mysql-database'] }} < /tmp/zabbix.dump.1.sql && touch /tmp/zabbix.dump.1.sql.applied
    - unless: test -f /tmp/zabbix.dump.1.sql.applied
    
run zabbix instance:
  service.running:
    - name: zabbix-server
    - enable: True

run httpd instance:
  service.running:
    - name: httpd
    - enable: True
