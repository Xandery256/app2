Drop if exists organist;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `wsoapp`.`organist` AS
    SELECT 
        `wsoapp`.`fills_role`.`Service_ID` AS `service_id`,
        CONCAT(`wsoapp`.`person`.`First_Name`,
                ' ',
                `wsoapp`.`person`.`Last_Name`) AS `organist_name`
    FROM
        (`wsoapp`.`fills_role`
        JOIN `wsoapp`.`person` ON ((`wsoapp`.`fills_role`.`Person_ID` = `wsoapp`.`person`.`Person_ID`)))
    WHERE
        (`wsoapp`.`fills_role`.`Role_Type` = 'O');

Drop if exists pianist;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `wsoapp`.`pianist` AS
    SELECT 
        `wsoapp`.`fills_role`.`Service_ID` AS `service_id`,
        CONCAT(`wsoapp`.`person`.`First_Name`,
                ' ',
                `wsoapp`.`person`.`Last_Name`) AS `pianist_name`
    FROM
        (`wsoapp`.`fills_role`
        JOIN `wsoapp`.`person` ON ((`wsoapp`.`fills_role`.`Person_ID` = `wsoapp`.`person`.`Person_ID`)))
    WHERE
        (`wsoapp`.`fills_role`.`Role_Type` = 'P');

Drop if exists songleader;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `wsoapp`.`songleader` AS
    SELECT 
        `wsoapp`.`fills_role`.`Service_ID` AS `service_id`,
        CONCAT(`wsoapp`.`person`.`First_Name`,
                ' ',
                `wsoapp`.`person`.`Last_Name`) AS `songleader_name`
    FROM
        (`wsoapp`.`fills_role`
        JOIN `wsoapp`.`person` ON ((`wsoapp`.`fills_role`.`Person_ID` = `wsoapp`.`person`.`Person_ID`)))
    WHERE
        (`wsoapp`.`fills_role`.`Role_Type` = 'S');


Drop if exists song_name;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `wsoapp`.`song_name` AS
    SELECT 
        `wsoapp`.`song`.`Song_ID` AS `song_id`,
        (CASE
            WHEN
                (`wsoapp`.`song`.`Song_Type` = 'C')
            THEN
                CONCAT(`wsoapp`.`song`.`Hymnbook_Num`,
                        ' - ',
                        `wsoapp`.`song`.`Title`)
            WHEN (`wsoapp`.`song`.`Song_Type` = 'A') THEN `wsoapp`.`song`.`Title`
        END) AS `name`
    FROM
        `wsoapp`.`song`;


Drop if exists service_view;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `wsoapp`.`service_view` AS
    SELECT 
        `wsoapp`.`service`.`Service_ID` AS `service_id`,
        `wsoapp`.`service`.`Svc_DateTime` AS `svc_datetime`,
        `wsoapp`.`service`.`Theme_Event` AS `theme`,
        `songleader`.`songleader_name` AS `songleader`,
        `organist`.`organist_name` AS `organist`,
        `pianist`.`pianist_name` AS `pianist`,
        `wsoapp`.`service_item`.`Seq_Num` AS `seq_num`,
        (SELECT 
                `wsoapp`.`event_type`.`Description`
            FROM
                `wsoapp`.`event_type`
            WHERE
                (`wsoapp`.`event_type`.`Event_Type_ID` = `wsoapp`.`service_item`.`Event_Type_ID`)) AS `event`,
        (CASE
            WHEN
                (`wsoapp`.`service_item`.`Song_ID` IS NOT NULL)
            THEN
                (SELECT 
                        `song_name`.`name`
                    FROM
                        `wsoapp`.`song_name`
                    WHERE
                        (`song_name`.`song_id` = `wsoapp`.`service_item`.`Song_ID`))
            ELSE `wsoapp`.`service_item`.`Title`
        END) AS `title`,
        (CASE
            WHEN
                (`wsoapp`.`service_item`.`Ensemble_ID` IS NOT NULL)
            THEN
                (SELECT 
                        `wsoapp`.`ensemble`.`Name`
                    FROM
                        `wsoapp`.`ensemble`
                    WHERE
                        (`wsoapp`.`ensemble`.`Ensemble_ID` = `wsoapp`.`service_item`.`Ensemble_ID`))
            WHEN
                (`wsoapp`.`service_item`.`Person_ID` IS NOT NULL)
            THEN
                (SELECT 
                        CONCAT(`wsoapp`.`person`.`First_Name`,
                                    ' ',
                                    `wsoapp`.`person`.`Last_Name`)
                    FROM
                        `wsoapp`.`person`
                    WHERE
                        (`wsoapp`.`person`.`Person_ID` = `wsoapp`.`service_item`.`Person_ID`))
            ELSE NULL
        END) AS `name`,
        `wsoapp`.`service_item`.`Notes` AS `notes`
    FROM
        ((((`wsoapp`.`service`
        LEFT JOIN `wsoapp`.`organist` ON ((`wsoapp`.`service`.`Service_ID` = `organist`.`service_id`)))
        LEFT JOIN `wsoapp`.`songleader` ON ((`songleader`.`service_id` = `wsoapp`.`service`.`Service_ID`)))
        LEFT JOIN `wsoapp`.`pianist` ON ((`pianist`.`service_id` = `wsoapp`.`service`.`Service_ID`)))
        LEFT JOIN `wsoapp`.`service_item` ON ((`wsoapp`.`service_item`.`Service_ID` = `wsoapp`.`service`.`Service_ID`)))
    ORDER BY `wsoapp`.`service`.`Service_ID` , `wsoapp`.`service_item`.`Seq_Num`







