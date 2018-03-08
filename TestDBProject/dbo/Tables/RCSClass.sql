CREATE TABLE [dbo].[RCSClass] (
    [RCSClassID]        INT          IDENTITY (2001082, 1) NOT NULL,
    [Name]              VARCHAR (50) NOT NULL,
    [Deleted]           TINYINT      NOT NULL,
    [RCSSeqForCreation] BIGINT       NOT NULL,
    [CreatedDT]         DATETIME     NOT NULL,
    [CreatedByID]       INT          NOT NULL,
    [RCSSeqForUpdate]   BIGINT       NULL,
    [ModifiedDT]        DATETIME     NULL,
    [ModifiedByID]      INT          NULL,
    [CTLegacyID]        INT          NULL,
    CONSTRAINT [PK_RCSClassMaster_1] PRIMARY KEY CLUSTERED ([RCSClassID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IIX_RCSClass_Name]
    ON [dbo].[RCSClass]([Name] ASC);


GO

CREATE TRIGGER mt_trUpdateTriggerToLogOnRCSClass ON RCSClass
	FOR UPDATE AS 
SET NOCOUNT ON
insert into RCSClassLog(LogTimeStamp, LogDMLOperation, LoginUser, [RCSClassID],[OldValue_RCSClassID], [Name],[OldValue_Name], [Deleted],[OldValue_Deleted], [RCSSeqForCreation],[OldValue_RCSSeqForCreation], [CreatedDT],[OldValue_CreatedDT], [CreatedByID],[OldValue_CreatedByID], [RCSSeqForUpdate],[OldValue_RCSSeqForUpdate], [ModifiedDT],[OldValue_ModifiedDT], [ModifiedByID],[OldValue_ModifiedByID], [CTLegacyID],[OldValue_CTLegacyID])
SELECT GETDATE(),'U', SYSTEM_USER,  I.[RCSClassID], D.[RCSClassID],  I.[Name], D.[Name],  I.[Deleted], D.[Deleted],  I.[RCSSeqForCreation], D.[RCSSeqForCreation],  I.[CreatedDT], D.[CreatedDT],  I.[CreatedByID], D.[CreatedByID],  I.[RCSSeqForUpdate], D.[RCSSeqForUpdate],  I.[ModifiedDT], D.[ModifiedDT],  I.[ModifiedByID], D.[ModifiedByID],  I.[CTLegacyID], D.[CTLegacyID]
 FROM INSERTED I 
join DELETED D on
 I.[RCSClassID]= D.[RCSClassID]
 where  ( (I.[Name]<> D.[Name] or (I.[Name] is null and D.[Name] is not null) or  (I.[Name] is not null and D.[Name] is null)) or  (I.[Deleted]<> D.[Deleted] or (I.[Deleted] is null and D.[Deleted] is not null) or  (I.[Deleted] is not null and D.[Deleted] is null)) or  (I.[RCSSeqForCreation]<> D.[RCSSeqForCreation] or (I.[RCSSeqForCreation] is null and D.[RCSSeqForCreation] is not null) or  (I.[RCSSeqForCreation] is not null and D.[RCSSeqForCreation] is null)) or  (I.[CreatedDT]<> D.[CreatedDT] or (I.[CreatedDT] is null and D.[CreatedDT] is not null) or  (I.[CreatedDT] is not null and D.[CreatedDT] is null)) or  (I.[CreatedByID]<> D.[CreatedByID] or (I.[CreatedByID] is null and D.[CreatedByID] is not null) or  (I.[CreatedByID] is not null and D.[CreatedByID] is null)) or  (I.[RCSSeqForUpdate]<> D.[RCSSeqForUpdate] or (I.[RCSSeqForUpdate] is null and D.[RCSSeqForUpdate] is not null) or  (I.[RCSSeqForUpdate] is not null and D.[RCSSeqForUpdate] is null)) or  (I.[ModifiedDT]<> D.[ModifiedDT] or (I.[ModifiedDT] is null and D.[ModifiedDT] is not null) or  (I.[ModifiedDT] is not null and D.[ModifiedDT] is null)) or  (I.[ModifiedByID]<> D.[ModifiedByID] or (I.[ModifiedByID] is null and D.[ModifiedByID] is not null) or  (I.[ModifiedByID] is not null and D.[ModifiedByID] is null)) or  (I.[CTLegacyID]<> D.[CTLegacyID] or (I.[CTLegacyID] is null and D.[CTLegacyID] is not null) or  (I.[CTLegacyID] is not null and D.[CTLegacyID] is null)))

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into RCSClassLog for any record UPDATED in RCSClass.
The inserted row will contain the particular field value updated and the previous value
from that field(OldValue_) */
GO

CREATE TRIGGER mt_trDeleteTriggerToLogOnRCSClass ON RCSClass
	FOR DELETE AS 
SET NOCOUNT ON
insert into RCSClassLog(LogTimeStamp, LogDMLOperation, LoginUser, [RCSClassID], [Name], [Deleted], [RCSSeqForCreation], [CreatedDT], [CreatedByID], [RCSSeqForUpdate], [ModifiedDT], [ModifiedByID], [CTLegacyID])
SELECT GETDATE(),'D', SYSTEM_USER,  D.[RCSClassID],  D.[Name],  D.[Deleted],  D.[RCSSeqForCreation],  D.[CreatedDT],  D.[CreatedByID],  D.[RCSSeqForUpdate],  D.[ModifiedDT],  D.[ModifiedByID],  D.[CTLegacyID]
 FROM DELETED D 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into RCSClassLog for any record DELETED in RCSClass.
The inserted row will contain the record that was deleted from the original table */
GO
CREATE TRIGGER mt_trInsertTriggerToLogOnRCSClass ON RCSClass
	FOR INSERT AS 
SET NOCOUNT ON
insert into RCSClassLog(LogTimeStamp, LogDMLOperation, LoginUser, [RCSClassID], [Name], [Deleted], [RCSSeqForCreation], [CreatedDT], [CreatedByID], [RCSSeqForUpdate], [ModifiedDT], [ModifiedByID], [CTLegacyID])
SELECT GETDATE(),'I', SYSTEM_USER,  I.[RCSClassID],  I.[Name],  I.[Deleted],  I.[RCSSeqForCreation],  I.[CreatedDT],  I.[CreatedByID],  I.[RCSSeqForUpdate],  I.[ModifiedDT],  I.[ModifiedByID],  I.[CTLegacyID]
 FROM INSERTED I 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into RCSClassLog for 
any record insert into RCSClass*/