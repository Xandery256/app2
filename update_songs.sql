USE `wsoapp2`;
DROP procedure IF EXISTS `Update_songs`;

DELIMITER $$
USE `wsoapp2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `Update_songs`(service_time datetime(6), sequence integer, song_id integer, out result integer)
BEGIN
    set result = 1;
	update service_item set service_item.song_id = song_id where service_item.seq_num = sequence and service_id = (select service_id from service where svc_datetime = service_time);
    set result = 0;
END$$

DELIMITER ;

