<?php
// Zabbix GUI configuration file
global $DB;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = 'localhost';
$DB['PORT']     = '0';
$DB['DATABASE'] = '{{ pillar['zabbix-mysql-database'] }}';
$DB['USER']     = '{{ pillar['zabbix-mysql-username'] }}';
$DB['PASSWORD'] = '{{ pillar['zabbix-mysql-pwd'] }}';

// SCHEMA is relevant only for IBM_DB2 database
$DB['SCHEMA'] = '';

$ZBX_SERVER      = '{{ pillar['zabbix-server-ip'] }}';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = '';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>
