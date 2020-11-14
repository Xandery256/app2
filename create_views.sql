DROP VIEW IF EXISTS organist;

CREATE VIEW `wsoapp2`.`organist` AS
    SELECT 
        `wsoapp2`.`fills_role`.`Service_ID` AS `service_id`,
        CONCAT(`wsoapp2`.`person`.`First_Name`,
                ' ',
                `wsoapp2`.`person`.`Last_Name`) AS `organist_name`
    FROM
        (`wsoapp2`.`fills_role`
        JOIN `wsoapp2`.`person` ON ((`wsoapp2`.`fills_role`.`Person_ID` = `wsoapp2`.`person`.`Person_ID`)))
    WHERE
        (`wsoapp2`.`fills_role`.`Role_Type` = 'O');


DROP VIEW IF EXISTS pianist;

CREATE VIEW `wsoapp2`.`pianist` AS
    SELECT 
        `wsoapp2`.`fills_role`.`Service_ID` AS `service_id`,
        CONCAT(`wsoapp2`.`person`.`First_Name`,
                ' ',
                `wsoapp2`.`person`.`Last_Name`) AS `pianist_name`
    FROM
        (`wsoapp2`.`fills_role`
        JOIN `wsoapp2`.`person` ON ((`wsoapp2`.`fills_role`.`Person_ID` = `wsoapp2`.`person`.`Person_ID`)))
    WHERE
        (`wsoapp2`.`fills_role`.`Role_Type` = 'P');

DROP VIEW IF EXISTS songleader;

CREATE VIEW `wsoapp2`.`songleader` AS
    SELECT 
        `wsoapp2`.`fills_role`.`Service_ID` AS `service_id`,
        `wsoapp2`.`person`.`Person_ID`,
        CONCAT(`wsoapp2`.`person`.`First_Name`,
                ' ',
                `wsoapp2`.`person`.`Last_Name`) AS `songleader_name`
    FROM
        (`wsoapp2`.`fills_role`
        JOIN `wsoapp2`.`person` ON ((`wsoapp2`.`fills_role`.`Person_ID` = `wsoapp2`.`person`.`Person_ID`)))
    WHERE
        (`wsoapp2`.`fills_role`.`Role_Type` = 'S');


DROP VIEW IF EXISTS song_name;

CREATE VIEW `wsoapp2`.`song_name` AS
    SELECT 
        `wsoapp2`.`song`.`Song_ID` AS `song_id`,
        (CASE
            WHEN
                (`wsoapp2`.`song`.`Song_Type` = 'C')
            THEN
                CONCAT(`wsoapp2`.`song`.`Hymnbook_Num`,
                        ' - ',
                        `wsoapp2`.`song`.`Title`)
            WHEN (`wsoapp2`.`song`.`Song_Type` = 'A') THEN `wsoapp2`.`song`.`Title`
        END) AS `name`
    FROM
        `wsoapp2`.`song`;


DROP VIEW IF EXISTS service_view;

CREATE VIEW `wsoapp2`.`service_view` AS
    SELECT 
        `wsoapp2`.`service`.`Service_ID` AS `service_id`,
        `wsoapp2`.`service`.`Svc_DateTime` AS `svc_datetime`,
        `wsoapp2`.`service`.`Theme_Event` AS `theme`,
        `songleader`.`songleader_name` AS `songleader`,
        `organist`.`organist_name` AS `organist`,
        `pianist`.`pianist_name` AS `pianist`,
        `wsoapp2`.`service_item`.`Seq_Num` AS `seq_num`,
        (SELECT 
                `wsoapp2`.`event_type`.`Description`
            FROM
                `wsoapp2`.`event_type`
            WHERE
                (`wsoapp2`.`event_type`.`Event_Type_ID` = `wsoapp2`.`service_item`.`Event_Type_ID`)) AS `event`,
        (CASE
            WHEN
                (`wsoapp2`.`service_item`.`Song_ID` IS NOT NULL)
            THEN
                (SELECT 
                        `song_name`.`name`
                    FROM
                        `wsoapp2`.`song_name`
                    WHERE
                        (`song_name`.`song_id` = `wsoapp2`.`service_item`.`Song_ID`))
            ELSE `wsoapp2`.`service_item`.`Title`
        END) AS `title`,
        (CASE
            WHEN
                (`wsoapp2`.`service_item`.`Ensemble_ID` IS NOT NULL)
            THEN
                (SELECT 
                        `wsoapp2`.`ensemble`.`Name`
                    FROM
                        `wsoapp2`.`ensemble`
                    WHERE
                        (`wsoapp2`.`ensemble`.`Ensemble_ID` = `wsoapp2`.`service_item`.`Ensemble_ID`))
            WHEN
                (`wsoapp2`.`service_item`.`Person_ID` IS NOT NULL)
            THEN
                (SELECT 
                        CONCAT(`wsoapp2`.`person`.`First_Name`,
                                    ' ',
                                    `wsoapp2`.`person`.`Last_Name`)
                    FROM
                        `wsoapp2`.`person`
                    WHERE
                        (`wsoapp2`.`person`.`Person_ID` = `wsoapp2`.`service_item`.`Person_ID`))
            ELSE NULL
        END) AS `name`,
        `wsoapp2`.`service_item`.`Notes` AS `notes`
    FROM
        ((((`wsoapp2`.`service`
        LEFT JOIN `wsoapp2`.`organist` ON ((`wsoapp2`.`service`.`Service_ID` = `organist`.`service_id`)))
        LEFT JOIN `wsoapp2`.`songleader` ON ((`songleader`.`service_id` = `wsoapp2`.`service`.`Service_ID`)))
        LEFT JOIN `wsoapp2`.`pianist` ON ((`pianist`.`service_id` = `wsoapp2`.`service`.`Service_ID`)))
        LEFT JOIN `wsoapp2`.`service_item` ON ((`wsoapp2`.`service_item`.`Service_ID` = `wsoapp2`.`service`.`Service_ID`)))
    ORDER BY `wsoapp2`.`service`.`Service_ID` , `wsoapp2`.`service_item`.`Seq_Num`

