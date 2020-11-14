DROP procedure IF EXISTS `create_service`;

DELIMITER $$
USE `wsoapp2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_service`(service_template integer, date_time datetime(6), theme varchar(40), songleader integer, out result varchar(100))
    DETERMINISTIC
BEGIN
	set result = "Your service has been created";
    if (select Svc_DateTime from service where Svc_DateTime = date_time) is not null then set result = "A service already exists at that time";
    else 
		insert into service (Svc_DateTime, Theme_Event) values (date_time, theme);
		insert into fills_role values(songleader, (select service_ID from service where Svc_DateTime = date_time), 'S', 'N');
        -- insert into service_item (Service_ID, Seq_Num, Event_Type_ID, Title, Notes, Confirmed, Person_ID, Ensemble_ID, Song_ID)
			-- values ((select service_ID from service where Svc_DateTime = date_time), (select Seq_Num from service_item where service_ID = service_template), (select Event_Type_ID from service_item where service_ID = service_template),null,null,null,null,null,null);
	end if;
END$$

DELIMITER ;

