install mysql-related packages:
  pkg.installed:
    - pkgs:
      - python-devel
      - mysql-server
      - mysql-devel
      - mysql-libs
      - MySQL-python
    - reload_modules: True
    
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
