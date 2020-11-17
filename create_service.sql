DROP procedure IF EXISTS `create_service`;

DELIMITER $$
USE `wsoapp2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_service`(template_time datetime(6), date_time datetime(6), theme varchar(40), songleader integer, out code integer)
    DETERMINISTIC
BEGIN
	declare template integer;
    declare new_service_id integer;
	set code = 1;
    if (select Svc_DateTime from Service where Svc_DateTime = date_time) is not null then set code = 1;
    else 
		insert into Service (Svc_DateTime, Theme_Event) values (date_time, theme);
        select Service_ID into template from Service where Svc_DateTime = template_time;
		select Service_ID into new_service_id from Service where Svc_DateTime = date_time;
		if songleader is not null then insert into fills_role values(songleader, new_service_id, 'S', 'N'); end if;
        insert into service_item (Service_ID, Seq_Num, Event_Type_ID, Confirmed)
			select new_service_id, Seq_Num, Event_Type_ID, 'N' from service_item where service_ID = template;
		set code = 0;
	end if;
END$$

DELIMITER ;

