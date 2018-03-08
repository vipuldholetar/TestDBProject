CREATE TABLE [dbo].[CreativePreSync] (
    [id]                   BIGINT           IDENTITY (1, 1) NOT NULL,
    [creativedetailsid]    BIGINT           NULL,
    [mediatypeid]          VARCHAR (10)     NULL,
    [creativesyncstatusid] INT              NULL,
    [locationid]           INT              NULL,
    [threadguid]           UNIQUEIDENTIFIER NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE TRIGGER mt_trUpdateTriggerToLogOnCreativePreSync ON CreativePreSync
	FOR UPDATE AS 
SET NOCOUNT ON
INSERT INTO OneMTLog..CreativePreSyncLog(LogTimeStamp, LogDMLOperation, LoginUser, [id],[OldValue_id], [creativedetailsid],[OldValue_creativedetailsid], [mediatypeid],[OldValue_mediatypeid], [creativesyncstatusid],[OldValue_creativesyncstatusid], [locationid],[OldValue_locationid], [threadguid],[OldValue_threadguid])
SELECT GETDATE(),'U', SYSTEM_USER,  I.[id], D.[id],  I.[creativedetailsid], D.[creativedetailsid],  I.[mediatypeid], D.[mediatypeid],  I.[creativesyncstatusid], D.[creativesyncstatusid],  I.[locationid], D.[locationid],  I.[threadguid], D.[threadguid]
 FROM INSERTED I 
join DELETED D on
 I.[id]= D.[id]
 where  ( (I.[creativedetailsid]<> D.[creativedetailsid] or (I.[creativedetailsid] is null and D.[creativedetailsid] is not null) or  (I.[creativedetailsid] is not null and D.[creativedetailsid] is null)) or  (I.[mediatypeid]<> D.[mediatypeid] or (I.[mediatypeid] is null and D.[mediatypeid] is not null) or  (I.[mediatypeid] is not null and D.[mediatypeid] is null)) or  (I.[creativesyncstatusid]<> D.[creativesyncstatusid] or (I.[creativesyncstatusid] is null and D.[creativesyncstatusid] is not null) or  (I.[creativesyncstatusid] is not null and D.[creativesyncstatusid] is null)) or  (I.[locationid]<> D.[locationid] or (I.[locationid] is null and D.[locationid] is not null) or  (I.[locationid] is not null and D.[locationid] is null)) or  (I.[threadguid]<> D.[threadguid] or (I.[threadguid] is null and D.[threadguid] is not null) or  (I.[threadguid] is not null and D.[threadguid] is null)))

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into CreativePreSyncLog for any record UPDATED in CreativePreSync.
The inserted row will contain the particular field value updated and the previous value
from that field(OldValue_) */

GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[mt_trUpdateTriggerToLogOnCreativePreSync]', @order = N'last', @stmttype = N'update';


GO
CREATE TRIGGER mt_trDeleteTriggerToLogOnCreativePreSync ON CreativePreSync
	FOR DELETE AS 
SET NOCOUNT ON
INSERT INTO OneMTLog..CreativePreSyncLog(LogTimeStamp, LogDMLOperation, LoginUser, [id], [creativedetailsid], [mediatypeid], [creativesyncstatusid], [locationid], [threadguid])
SELECT GETDATE(),'D', SYSTEM_USER,  D.[id],  D.[creativedetailsid],  D.[mediatypeid],  D.[creativesyncstatusid],  D.[locationid],  D.[threadguid]
 FROM DELETED D 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into CreativePreSyncLog for any record DELETED in CreativePreSync.
The inserted row will contain the record that was deleted from the original table */

GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[mt_trDeleteTriggerToLogOnCreativePreSync]', @order = N'last', @stmttype = N'delete';


GO
CREATE TRIGGER mt_trInsertTriggerToLogOnCreativePreSync ON CreativePreSync
	FOR INSERT AS 
SET NOCOUNT ON
INSERT INTO OneMTLog..CreativePreSyncLog(LogTimeStamp, LogDMLOperation, LoginUser, [id], [creativedetailsid], [mediatypeid], [creativesyncstatusid], [locationid], [threadguid])
SELECT GETDATE(),'I', SYSTEM_USER,  I.[id],  I.[creativedetailsid],  I.[mediatypeid],  I.[creativesyncstatusid],  I.[locationid],  I.[threadguid]
 FROM INSERTED I 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into CreativePreSyncLog for 
any record insert into CreativePreSync*/

GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[mt_trInsertTriggerToLogOnCreativePreSync]', @order = N'last', @stmttype = N'insert';

