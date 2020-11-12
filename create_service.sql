DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_service`(date_time datetime(6), theme varchar(40), songleader varchar(36), out result varchar(100))
    DETERMINISTIC
BEGIN
	set result = "Your service has been created";
    if (select Svc_DateTime from service where Svc_DateTime = date_time) is not null then set result = "A service already exists at that time";
    else insert into service (Service_ID, Svc_DateTime, Theme_Event)
		values ((select Max(service_ID) from service)+1 , date_time, theme);
        insert into service_item (Service_Item_ID, Service_ID, Seq_Num, Event_Type)
			values (1, (select Max(service_ID) from service), 1, 1);
	end if;
END$$