DELIMITER $$
DROP PROCEDURE IF EXISTS __count_unused_items $$
CREATE PROCEDURE __count_unused_items(
    tableName VARCHAR(32)
)
BEGIN

    SET @qry = concat('
    	DROP TEMPORARY TABLE IF EXISTS __uitems_', tableName ,'
    ');
    PREPARE `qry` FROM @qry; EXECUTE `qry`; DEALLOCATE PREPARE `qry`;

    SET @qry = concat('
    	CREATE TEMPORARY TABLE __uitems_', tableName ,' (
    	    itemid BIGINT UNSIGNED PRIMARY KEY
    	) ENGINE=MEMORY
                SELECT DISTINCT `itemid` FROM ', tableName ,'
    ');
    PREPARE `qry` FROM @qry; EXECUTE `qry`; DEALLOCATE PREPARE `qry`;

    SET @qry = concat('
        DELETE FROM __uitems_', tableName ,' WHERE itemid IN (SELECT itemid FROM __good_items);
    ');
    PREPARE `qry` FROM @qry; EXECUTE `qry`; DEALLOCATE PREPARE `qry`;

    SET @qry = concat('
    	SELECT count(i.itemid) AS ', tableName ,' FROM ', tableName ,' INNER JOIN __uitems_', tableName ,' i USING (itemid)
    ');
    PREPARE `qry` FROM @qry; EXECUTE `qry`; DEALLOCATE PREPARE `qry`;

END
$$

delimiter ;

DROP TEMPORARY TABLE IF EXISTS __good_items;
CREATE TEMPORARY TABLE __good_items ENGINE=MEMORY
        SELECT itemid FROM items WHERE status='0'
;
ALTER TABLE __good_items ADD PRIMARY KEY (itemid);

CALL __count_unused_items('history');
CALL __count_unused_items('__history_uitems');
CALL __count_unused_items('history_str');
CALL __count_unused_items('history_text');
CALL __count_unused_items('history_log');

CALL __count_unused_items('trends');
CALL __count_unused_items('trends_uint');

DROP PROCEDURE IF EXISTS __count_unused_items;
