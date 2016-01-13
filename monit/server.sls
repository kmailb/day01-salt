untar mmonit package:
  #I know that is not fully correct because there is much more OSes, but I assume we will use only those
  archive.extracted:
    - name: {{ pillar['mmonit-prefix'] }}
    {% if grains['osarch'] == 'x86_64' %}
    - source: salt://monit/files/tars/{{ pillar['mmonit-version'] }}-linux-x64.tar.gz
    {% else %}
    - source: salt://monit/files/tars/{{ pillar['mmonit-version'] }}-linux-x86.tar.gz
    {% endif %}
    - archive_format: tar
    - if_missing: {{ pillar['mmonit-prefix'] }}/{{ pillar['mmonit-version'] }}
    - user: root
    - group: root
    
configure mmonit server:
  file.managed:
    - name: {{ pillar['mmonit-prefix'] }}/{{ pillar['mmonit-version'] }}/conf/server.xml
    - source: salt://monit/files/mmonit-server.xml
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
    - source: salt://monit/files/mmonit-schema.mysql
    - user: root
    - group: root
    - mode: 600
  cmd.run:
    - name: /usr/bin/mysql -u {{ pillar['mmonit-mysql-username'] }} -h localhost --password={{ pillar['mmonit-mysql-pwd'] }} {{ pillar['mmonit-mysql-database'] }} < /tmp/mmonit-schema.mysql && touch /tmp/mmonit-schema.mysql.applied
    - unless: test -f /tmp/mmonit-schema.mysql.applied

run mmonit server:
  file.managed:
    - name: /etc/init.d/mmonit
    - source: salt://monit/files/mmonit-init
    - user: root
    - group: root
    - mode: 755
    - template: jinja
  service.running:
    - name: mmonit
    - enable: True
