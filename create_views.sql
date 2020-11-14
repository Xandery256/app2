USE `wsoapp2`;
DROP VIEW IF EXISTS organist;

CREATE VIEW `organist` AS
    SELECT 
        `fills_role`.`Service_ID` AS `service_id`,
        CONCAT(`person`.`First_Name`,
                ' ',
                `person`.`Last_Name`) AS `organist_name`
    FROM
        (`fills_role`
        JOIN `person` ON ((`fills_role`.`Person_ID` = `person`.`Person_ID`)))
    WHERE
        (`fills_role`.`Role_Type` = 'O');


DROP VIEW IF EXISTS pianist;

CREATE VIEW `pianist` AS
    SELECT 
        `fills_role`.`Service_ID` AS `service_id`,
        CONCAT(`person`.`First_Name`,
                ' ',
                `person`.`Last_Name`) AS `pianist_name`
    FROM
        (`fills_role`
        JOIN `person` ON ((`fills_role`.`Person_ID` = `person`.`Person_ID`)))
    WHERE
        (`fills_role`.`Role_Type` = 'P');

DROP VIEW IF EXISTS songleader;

CREATE VIEW `songleader` AS
    SELECT 
        `fills_role`.`Service_ID` AS `service_id`,
        `person`.`Person_ID`,
        CONCAT(`person`.`First_Name`,
                ' ',
                `person`.`Last_Name`) AS `songleader_name`
    FROM
        (`fills_role`
        JOIN `person` ON ((`fills_role`.`Person_ID` = `person`.`Person_ID`)))
    WHERE
        (`fills_role`.`Role_Type` = 'S');


DROP VIEW IF EXISTS song_name;

CREATE VIEW `song_name` AS
    SELECT 
        `song`.`Song_ID` AS `song_id`,
        (CASE
            WHEN
                (`song`.`Song_Type` = 'C')
            THEN
                CONCAT(`song`.`Hymnbook_Num`,
                        ' - ',
                        `song`.`Title`)
            WHEN (`song`.`Song_Type` = 'A') THEN `song`.`Title`
        END) AS `name`
    FROM
        `song`;


DROP VIEW IF EXISTS service_view;

CREATE VIEW `service_view` AS
    SELECT 
        `service`.`Service_ID` AS `service_id`,
        `service`.`Svc_DateTime` AS `svc_datetime`,
        `service`.`Theme_Event` AS `theme`,
        `songleader`.`songleader_name` AS `songleader`,
        `organist`.`organist_name` AS `organist`,
        `pianist`.`pianist_name` AS `pianist`,
        `service_item`.`Seq_Num` AS `seq_num`,
        (SELECT 
                `event_type`.`Description`
            FROM
                `event_type`
            WHERE
                (`event_type`.`Event_Type_ID` = `service_item`.`Event_Type_ID`)) AS `event`,
        (CASE
            WHEN
                (`service_item`.`Song_ID` IS NOT NULL)
            THEN
                (SELECT 
                        `song_name`.`name`
                    FROM
                        `song_name`
                    WHERE
                        (`song_name`.`song_id` = `service_item`.`Song_ID`))
            ELSE `service_item`.`Title`
        END) AS `title`,
        (CASE
            WHEN
                (`service_item`.`Ensemble_ID` IS NOT NULL)
            THEN
                (SELECT 
                        `ensemble`.`Name`
                    FROM
                        `ensemble`
                    WHERE
                        (`ensemble`.`Ensemble_ID` = `service_item`.`Ensemble_ID`))
            WHEN
                (`service_item`.`Person_ID` IS NOT NULL)
            THEN
                (SELECT 
                        CONCAT(`person`.`First_Name`,
                                    ' ',
                                    `person`.`Last_Name`)
                    FROM
                        `person`
                    WHERE
                        (`person`.`Person_ID` = `service_item`.`Person_ID`))
            ELSE NULL
        END) AS `name`,
        `service_item`.`Notes` AS `notes`
    FROM
        ((((`service`
        LEFT JOIN `organist` ON ((`service`.`Service_ID` = `organist`.`service_id`)))
        LEFT JOIN `songleader` ON ((`songleader`.`service_id` = `service`.`Service_ID`)))
        LEFT JOIN `pianist` ON ((`pianist`.`service_id` = `service`.`Service_ID`)))
        LEFT JOIN `service_item` ON ((`service_item`.`Service_ID` = `service`.`Service_ID`)))
    ORDER BY `service`.`Service_ID` , `service_item`.`Seq_Num`;

DROP VIEW IF EXISTS songusageview;

CREATE VIEW `songusageview` AS
    SELECT 
        `song`.`Song_ID` AS `Song_ID`,
        `song`.`Song_Type` AS `Song_Type`,
        `song`.`Title` AS `Title`,
        `song`.`Hymnbook_Num` AS `Hymnbook_Num`,
        `song`.`Arranger` AS `Arranger`,
        MAX(`service`.`Svc_DateTime`) AS `LastUsedDate`
    FROM
        ((`song`
        LEFT JOIN `service_item` ON ((`song`.`Song_ID` = `service_item`.`Song_ID`)))
        LEFT JOIN `service` ON ((`service`.`Service_ID` = `service_item`.`Service_ID`)))
    WHERE
        ((`song`.`Song_Type` <> 'C')
            OR (`service`.`Svc_DateTime` IS NULL))
    GROUP BY `song`.`Song_ID`
    ORDER BY `LastUsedDate`;
