

CREATE VIEW [dbo].[WhatIsLocked]
AS
SELECT * FROM 
(SELECT
Locks.request_session_id AS SessionID,
Obj.Name AS LockedObjectName,
DATEDIFF(second,ActTra.Transaction_begin_time, GETDATE()) AS Duration,
ActTra.Transaction_begin_time,
COUNT(*) AS Locks
FROM    sys.dm_tran_locks Locks
JOIN sys.partitions Parti ON Parti.hobt_id = Locks.resource_associated_entity_id
JOIN sys.objects Obj ON Obj.object_id = Parti.object_id

JOIN sys.dm_exec_sessions ExeSess ON ExeSess.session_id = Locks.request_session_id
JOIN sys.dm_tran_session_transactions TranSess ON ExeSess.session_id = TranSess.session_id
JOIN sys.dm_tran_active_transactions ActTra ON TranSess.transaction_id = ActTra.transaction_id
WHERE   resource_database_id = db_id() AND Obj.Type = 'U'
GROUP BY ActTra.Transaction_begin_time,Locks.request_session_id, Obj.Name ) a

join (SELECT  des.login_name AS [Login],
        der.command AS [Command],
        dest.text AS [Command Text] ,
        des.login_time AS [Login Time],
        des.[host_name] AS [Hostname],
        des.[program_name] AS [Program],
        der.session_id AS [Session ID],
       dec.client_net_address [Client Net Address],
        der.status AS [Status],
        DB_NAME(der.database_id) AS [Database Name]
FROM    sys.dm_exec_requests der
        INNER JOIN sys.dm_exec_connections dec
                       ON der.session_id = dec.session_id
        INNER JOIN sys.dm_exec_sessions des
                       ON des.session_id = der.session_id
        CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS dest
) b on b.[Session ID]=a.SessionID

