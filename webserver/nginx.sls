nginx:
  pkg.installed
       
provision html sources:
  file.recurse:
    - name: /var/www
    - source: salt://webserver/files/www
    - user: nginx
    - group: nginx
    - dir_mode: 755
    - file_mode: 644
    - clean: True

configure and run nginx instance:
  file.managed:
    - name: /etc/nginx/conf.d/default.conf
    - source: salt://webserver/files/nginx.conf
    - user: root
    - group: root
    - mode: 644
  service.running:
    - name: nginx
    - enable: True
