install monitoring-related packages:
  pkg.installed:
    - pkgs:
      - python-devel
      - mysql-server
      - mysql-devel
      - mysql-libs
      - MySQL-python
      - zabbix22-server-mysql
      - zabbix22-web-mysql
      - zabbix22-agent
    - reload_modules: True

#do mysql tasks
python-pip:
  pkg:
    - installed
    - refresh: True

install salt-related mysql pip:
  pip.installed:
    - name: mysql-python
    - require:
      - pkg: python-pip

run mysql instance:
  service.running:
    - name: mysqld
    - enable: True

#zabbix-related operations

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
    - source: salt://etc/zabbix_server.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    
configure web server:
  file.managed:
    - name: /etc/httpd/conf.d/zabbix.conf
    - source: salt://etc/zabbix_server_apache.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    
configure zabbix web interface:
  file.managed:
    - name: /etc/zabbix/web/zabbix.conf.php
    - source: salt://etc/zabbix.conf.php
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
    - source: salt://sql/zabbix.dump.1.sql
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

run zabbix agent instance:
  service.running:
    - name: zabbix-agent
    - enable: True
    
#mmonit-related operations
#I know that is not fully correct because there is much more OSes, but I assume we will use only those
untar mmonit package:
  archive.extracted:
    - name: {{ pillar['mmonit-prefix'] }}
    {% if grains['osarch'] == 'x86_64' %}
    - source: salt://tars/{{ pillar['mmonit-version'] }}-linux-x64.tar.gz
    {% else %}
    - source: salt://tars/{{ pillar['mmonit-version'] }}-linux-x86.tar.gz
    {% endif %}
    - archive_format: tar
    - if_missing: {{ pillar['mmonit-prefix'] }}/{{ pillar['mmonit-version'] }}
    - user: root
    - group: root
    
configure mmonit server:
  file.managed:
    - name: {{ pillar['mmonit-prefix'] }}/{{ pillar['mmonit-version'] }}/conf/server.xml
    - source: salt://etc/mmonit-server.xml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    
create mmonit user:
  mysql_user.present:
    - name: {{ pillar['mmonit-mysql-username'] }}
    - host: localhost
    - password: {{ pillar['mmonit-mysql-pwd'] }}
    
create mmonit database:
  mysql_database.present:
    - name: {{ pillar['mmonit-mysql-database'] }}
    - character_set: utf8
    - collate: utf8_bin
    
grant rights to mmonit user:
  mysql_grants.present:
    - grant: all
    - database: {{ pillar['mmonit-mysql-database'] }}.*
    - user: {{ pillar['mmonit-mysql-username'] }}
    - host: localhost

populate mmonit database:
  file.managed:
    - name: /tmp/mmonit-schema.mysql
    - source: salt://sql/mmonit-schema.mysql
    - user: root
    - group: root
    - mode: 600
  cmd.run:
    - name: /usr/bin/mysql -u {{ pillar['mmonit-mysql-username'] }} -h localhost --password={{ pillar['mmonit-mysql-pwd'] }} {{ pillar['mmonit-mysql-database'] }} < /tmp/mmonit-schema.mysql && touch /tmp/mmonit-schema.mysql.applied
    - unless: test -f /tmp/mmonit-schema.mysql.applied

run mmonit server:
  file.managed:
    - name: /etc/init.d/mmonit
    - source: salt://etc/init.d/mmonit
    - user: root
    - group: root
    - mode: 755
    - template: jinja
  service.running:
    - name: mmonit
    - enable: True

run httpd instance:
  service.running:
    - name: httpd
    - enable: True
