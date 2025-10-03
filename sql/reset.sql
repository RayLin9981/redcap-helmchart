-- #語法:
SELECT  
CONCAT('TRUNCATE TABLE ',TABLE_NAME,';') AS truncateCommand
FROM information_schema.TABLES  
WHERE TABLE_SCHEMA = 'redcapdata';
-- # 語法2:(可正常刪除，資料不存在)
USE redcapdata;
SHOW TABLES;  
SET FOREIGN_KEY_CHECKS = 0;
SET GROUP_CONCAT_MAX_LEN=32768;  
SELECT GROUP_CONCAT(table_name) INTO @tables FROM information_schema.tables WHERE table_schema = (SELECT DATABASE());
SET @tables = CONCAT('DROP TABLE IF EXISTS ', @tables);
PREPARE stmt FROM @tables;
EXECUTE stmt;
SET FOREIGN_KEY_CHECKS = 1;
default-character-set=utf8 redcapdata < F:\redcapdata20210506.sql
