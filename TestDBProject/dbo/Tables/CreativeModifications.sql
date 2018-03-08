CREATE TABLE [dbo].[CreativeModifications] (
    [CreativeModificationId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [AdId]                   BIGINT        NULL,
    [CreativeId]             BIGINT        NULL,
    [OccurrenceId]           BIGINT        NULL,
    [CreativeSignature]      VARCHAR (200) NULL,
    [CreativePath]           VARCHAR (200) NOT NULL,
    [ModifiedById]           INT           NOT NULL,
    [ModifiedDT]             DATETIME      CONSTRAINT [DF_CreativeModifications_ModifiedDT] DEFAULT (getdate()) NOT NULL,
    [MediaStreamId]          INT           NULL,
    [LocationId]             INT           NULL,
    [Synced]                 BIT           NULL,
    [SyncDT]                 DATETIME      NULL,
    CONSTRAINT [PK_CreativeModificationsID] PRIMARY KEY CLUSTERED ([CreativeModificationId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idxOccurrenceIdModifiedDT]
    ON [dbo].[CreativeModifications]([OccurrenceId] ASC, [ModifiedDT] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CreativePath]
    ON [dbo].[CreativeModifications]([CreativePath] ASC)
    INCLUDE([CreativeModificationId], [AdId], [CreativeId]);


GO
CREATE TRIGGER [dbo].[mt_trInsertTriggerToLogOnCreativeModifications] ON [dbo].[CreativeModifications]
	FOR INSERT AS 
SET NOCOUNT ON
INSERT INTO OneMT..CreativeModificationsLog(LogTimeStamp, LogDMLOperation, LoginUser, [CreativeModificationId], [AdId], [CreativeId], [OccurrenceId], [CreativeSignature], [CreativePath], [ModifiedById], [ModifiedDT], [MediaStreamId], [LocationId], [Synced], [SyncDt])
SELECT GETDATE(),'I', SYSTEM_USER,  I.[CreativeModificationId],  I.[AdId],  I.[CreativeId],  I.[OccurrenceId],  I.[CreativeSignature],  I.[CreativePath],  I.[ModifiedById],  I.[ModifiedDT],  I.[MediaStreamId],  I.[LocationId],  I.[Synced], I.[SyncDt]
 FROM INSERTED I 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into CreativeModificationsLog for 
any record insert into CreativeModifications*/
GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[mt_trInsertTriggerToLogOnCreativeModifications]', @order = N'last', @stmttype = N'insert';


GO
CREATE TRIGGER [dbo].[mt_trDeleteTriggerToLogOnCreativeModifications] ON [dbo].[CreativeModifications]
	FOR DELETE AS 
SET NOCOUNT ON
INSERT INTO OneMT..CreativeModificationsLog(LogTimeStamp, LogDMLOperation, LoginUser, [CreativeModificationId], [AdId], [CreativeId], [OccurrenceId], [CreativeSignature], [CreativePath], [ModifiedById], [ModifiedDT], [MediaStreamId], [LocationId], [Synced], [SyncDt])
SELECT GETDATE(),'D', SYSTEM_USER,  D.[CreativeModificationId],  D.[AdId],  D.[CreativeId],  D.[OccurrenceId],  D.[CreativeSignature],  D.[CreativePath],  D.[ModifiedById],  D.[ModifiedDT],  D.[MediaStreamId],  D.[LocationId],  D.[Synced], D.[SyncDt]
 FROM DELETED D 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into CreativeModificationsLog for any record DELETED in CreativeModifications.
The inserted row will contain the record that was deleted from the original table */
GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[mt_trDeleteTriggerToLogOnCreativeModifications]', @order = N'last', @stmttype = N'delete';


GO
CREATE TRIGGER [dbo].[mt_trUpdateTriggerToLogOnCreativeModifications] ON [dbo].[CreativeModifications]
	FOR UPDATE AS 
SET NOCOUNT ON
INSERT INTO OneMT..CreativeModificationsLog(LogTimeStamp, LogDMLOperation, LoginUser, [CreativeModificationId],[OldValue_CreativeModificationId], [AdId],[OldValue_AdId], [CreativeId],[OldValue_CreativeId], [OccurrenceId],[OldValue_OccurrenceId], [CreativeSignature],[OldValue_CreativeSignature], [CreativePath],[OldValue_CreativePath], [ModifiedById],[OldValue_ModifiedById], [ModifiedDT],[OldValue_ModifiedDT], [MediaStreamId],[OldValue_MediaStreamId], [LocationId],[OldValue_LocationId], [Synced],[OldValue_Synced],[SyncDt],[OldValue_SyncDt])
SELECT GETDATE(),'U', SYSTEM_USER,  I.[CreativeModificationId], D.[CreativeModificationId],  I.[AdId], D.[AdId],  I.[CreativeId], D.[CreativeId],  I.[OccurrenceId], D.[OccurrenceId],  I.[CreativeSignature], D.[CreativeSignature],  I.[CreativePath], D.[CreativePath],  I.[ModifiedById], D.[ModifiedById],  I.[ModifiedDT], D.[ModifiedDT],  I.[MediaStreamId], D.[MediaStreamId],  I.[LocationId], D.[LocationId],  I.[Synced], D.[Synced], I.[SyncDt], D.[SyncDt]
 FROM INSERTED I 
join DELETED D on
 I.[CreativeModificationId]= D.[CreativeModificationId]
 where  ( (I.[AdId]<> D.[AdId] or (I.[AdId] is null and D.[AdId] is not null) or  (I.[AdId] is not null and D.[AdId] is null)) or  (I.[CreativeId]<> D.[CreativeId] or (I.[CreativeId] is null and D.[CreativeId] is not null) or  (I.[CreativeId] is not null and D.[CreativeId] is null)) or  (I.[OccurrenceId]<> D.[OccurrenceId] or (I.[OccurrenceId] is null and D.[OccurrenceId] is not null) or  (I.[OccurrenceId] is not null and D.[OccurrenceId] is null)) or  (I.[CreativeSignature]<> D.[CreativeSignature] or (I.[CreativeSignature] is null and D.[CreativeSignature] is not null) or  (I.[CreativeSignature] is not null and D.[CreativeSignature] is null)) or  (I.[CreativePath]<> D.[CreativePath] or (I.[CreativePath] is null and D.[CreativePath] is not null) or  (I.[CreativePath] is not null and D.[CreativePath] is null)) or  (I.[ModifiedById]<> D.[ModifiedById] or (I.[ModifiedById] is null and D.[ModifiedById] is not null) or  (I.[ModifiedById] is not null and D.[ModifiedById] is null)) or  (I.[ModifiedDT]<> D.[ModifiedDT] or (I.[ModifiedDT] is null and D.[ModifiedDT] is not null) or  (I.[ModifiedDT] is not null and D.[ModifiedDT] is null)) or  (I.[MediaStreamId]<> D.[MediaStreamId] or (I.[MediaStreamId] is null and D.[MediaStreamId] is not null) or  (I.[MediaStreamId] is not null and D.[MediaStreamId] is null)) or  (I.[LocationId]<> D.[LocationId] or (I.[LocationId] is null and D.[LocationId] is not null) or  (I.[LocationId] is not null and D.[LocationId] is null)) or  (I.[Synced]<> D.[Synced] or (I.[Synced] is null and D.[Synced] is not null) or  (I.[Synced] is not null and D.[Synced] is null)) or  (I.[SyncDt]<> D.[SyncDt] or (I.[SyncDt] is null and D.[SyncDt] is not null) or  (I.[SyncDt] is not null and D.[SyncDt] is null)))

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into CreativeModificationsLog for any record UPDATED in CreativeModifications.
The inserted row will contain the particular field value updated and the previous value
from that field(OldValue_) */
GO
EXECUTE sp_settriggerorder @triggername = N'[dbo].[mt_trUpdateTriggerToLogOnCreativeModifications]', @order = N'last', @stmttype = N'update';

