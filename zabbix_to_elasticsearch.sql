CREATE TABLE `zabbix_to_elasticsearch` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `eventid` bigint(12) NOT NULL DEFAULT '0',
  `eventrecoveryid` bigint(12) DEFAULT NULL,
  `triggerid` bigint(12) NOT NULL DEFAULT '0',
  `hostname` varchar(64) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `triggerdescription` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `started` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `finished` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `severity` enum('Information','Warning','Average','High','Disaster') COLLATE utf8_unicode_ci DEFAULT NULL,
  `nseverity` tinyint(1) NOT NULL DEFAULT '0',
  `is_e_done` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'flag shows is eventid processed or not',
  `is_er_done` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'flag shows is eventrecoveryid processed or not',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ts_triggerid_host` (`started`,`triggerid`,`hostname`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
