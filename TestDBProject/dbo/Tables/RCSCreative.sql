CREATE TABLE [dbo].[RCSCreative] (
    [RCSCreativeID]     VARCHAR (50) NOT NULL,
    [RCSAcctID]         INT          NOT NULL,
    [RCSAdvID]          INT          NOT NULL,
    [RCSClassID]        INT          NOT NULL,
    [CreativeLength]    INT          NULL,
    [Priority]          INT          NULL,
    [Deleted]           TINYINT      NOT NULL,
    [RCSSeqForCreation] BIGINT       NOT NULL,
    [CreatedDT]         DATETIME     DEFAULT (getdate()) NOT NULL,
    [CreatedByID]       INT          DEFAULT ((-1)) NOT NULL,
    [RCSSeqForUpdate]   BIGINT       NULL,
    [ModifiedDT]        DATETIME     NULL,
    [ModifiedByID]      INT          NULL,
    [CTLegacyID]        INT          NULL,
    CONSTRAINT [PK_RCSCreatives_1] PRIMARY KEY CLUSTERED ([RCSCreativeID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_RCSCreative_ClassAccountAdvertiser]
    ON [dbo].[RCSCreative]([RCSClassID] ASC, [RCSAcctID] ASC, [RCSAdvID] ASC);


GO
CREATE TRIGGER mt_trInsertTriggerToLogOnRCSCreative ON RCSCreative
	FOR INSERT AS 
SET NOCOUNT ON
insert into RCSCreativeLog(LogTimeStamp, LogDMLOperation, LoginUser, [RCSCreativeID], [RCSAcctID], [RCSAdvID], [RCSClassID], [CreativeLength], [Priority], [Deleted], [RCSSeqForCreation], [CreatedDT], [CreatedByID], [RCSSeqForUpdate], [ModifiedDT], [ModifiedByID], [CTLegacyID])
SELECT GETDATE(),'I', SYSTEM_USER,  I.[RCSCreativeID],  I.[RCSAcctID],  I.[RCSAdvID],  I.[RCSClassID],  I.[CreativeLength],  I.[Priority],  I.[Deleted],  I.[RCSSeqForCreation],  I.[CreatedDT],  I.[CreatedByID],  I.[RCSSeqForUpdate],  I.[ModifiedDT],  I.[ModifiedByID],  I.[CTLegacyID]
 FROM INSERTED I 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into RCSCreativeLog for 
any record insert into RCSCreative*/
GO

 CREATE TRIGGER mt_trUpdateTriggerToLogOnRCSCreative ON RCSCreative
	FOR UPDATE AS 
SET NOCOUNT ON
insert into RCSCreativeLog(LogTimeStamp, LogDMLOperation, LoginUser, [RCSCreativeID],[OldValue_RCSCreativeID], [RCSAcctID],[OldValue_RCSAcctID], [RCSAdvID],[OldValue_RCSAdvID], [RCSClassID],[OldValue_RCSClassID], [CreativeLength],[OldValue_CreativeLength], [Priority],[OldValue_Priority], [Deleted],[OldValue_Deleted], [RCSSeqForCreation],[OldValue_RCSSeqForCreation], [CreatedDT],[OldValue_CreatedDT], [CreatedByID],[OldValue_CreatedByID], [RCSSeqForUpdate],[OldValue_RCSSeqForUpdate], [ModifiedDT],[OldValue_ModifiedDT], [ModifiedByID],[OldValue_ModifiedByID], [CTLegacyID],[OldValue_CTLegacyID])
SELECT GETDATE(),'U', SYSTEM_USER,  I.[RCSCreativeID], D.[RCSCreativeID],  I.[RCSAcctID], D.[RCSAcctID],  I.[RCSAdvID], D.[RCSAdvID],  I.[RCSClassID], D.[RCSClassID],  I.[CreativeLength], D.[CreativeLength],  I.[Priority], D.[Priority],  I.[Deleted], D.[Deleted],  I.[RCSSeqForCreation], D.[RCSSeqForCreation],  I.[CreatedDT], D.[CreatedDT],  I.[CreatedByID], D.[CreatedByID],  I.[RCSSeqForUpdate], D.[RCSSeqForUpdate],  I.[ModifiedDT], D.[ModifiedDT],  I.[ModifiedByID], D.[ModifiedByID],  I.[CTLegacyID], D.[CTLegacyID]
 FROM INSERTED I 
join DELETED D on
 I.[RCSCreativeID]= D.[RCSCreativeID]
 where  ( (I.[RCSAcctID]<> D.[RCSAcctID] or (I.[RCSAcctID] is null and D.[RCSAcctID] is not null) or  (I.[RCSAcctID] is not null and D.[RCSAcctID] is null)) or  (I.[RCSAdvID]<> D.[RCSAdvID] or (I.[RCSAdvID] is null and D.[RCSAdvID] is not null) or  (I.[RCSAdvID] is not null and D.[RCSAdvID] is null)) or  (I.[RCSClassID]<> D.[RCSClassID] or (I.[RCSClassID] is null and D.[RCSClassID] is not null) or  (I.[RCSClassID] is not null and D.[RCSClassID] is null)) or  (I.[CreativeLength]<> D.[CreativeLength] or (I.[CreativeLength] is null and D.[CreativeLength] is not null) or  (I.[CreativeLength] is not null and D.[CreativeLength] is null)) or  (I.[Priority]<> D.[Priority] or (I.[Priority] is null and D.[Priority] is not null) or  (I.[Priority] is not null and D.[Priority] is null)) or  (I.[Deleted]<> D.[Deleted] or (I.[Deleted] is null and D.[Deleted] is not null) or  (I.[Deleted] is not null and D.[Deleted] is null)) or  (I.[RCSSeqForCreation]<> D.[RCSSeqForCreation] or (I.[RCSSeqForCreation] is null and D.[RCSSeqForCreation] is not null) or  (I.[RCSSeqForCreation] is not null and D.[RCSSeqForCreation] is null)) or  (I.[CreatedDT]<> D.[CreatedDT] or (I.[CreatedDT] is null and D.[CreatedDT] is not null) or  (I.[CreatedDT] is not null and D.[CreatedDT] is null)) or  (I.[CreatedByID]<> D.[CreatedByID] or (I.[CreatedByID] is null and D.[CreatedByID] is not null) or  (I.[CreatedByID] is not null and D.[CreatedByID] is null)) or  (I.[RCSSeqForUpdate]<> D.[RCSSeqForUpdate] or (I.[RCSSeqForUpdate] is null and D.[RCSSeqForUpdate] is not null) or  (I.[RCSSeqForUpdate] is not null and D.[RCSSeqForUpdate] is null)) or  (I.[ModifiedDT]<> D.[ModifiedDT] or (I.[ModifiedDT] is null and D.[ModifiedDT] is not null) or  (I.[ModifiedDT] is not null and D.[ModifiedDT] is null)) or  (I.[ModifiedByID]<> D.[ModifiedByID] or (I.[ModifiedByID] is null and D.[ModifiedByID] is not null) or  (I.[ModifiedByID] is not null and D.[ModifiedByID] is null)) or  (I.[CTLegacyID]<> D.[CTLegacyID] or (I.[CTLegacyID] is null and D.[CTLegacyID] is not null) or  (I.[CTLegacyID] is not null and D.[CTLegacyID] is null)))

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into RCSCreativeLog for any record UPDATED in RCSCreative.
The inserted row will contain the particular field value updated and the previous value
from that field(OldValue_) */
GO

 CREATE TRIGGER mt_trDeleteTriggerToLogOnRCSCreative ON RCSCreative
	FOR DELETE AS 
SET NOCOUNT ON
insert into RCSCreativeLog(LogTimeStamp, LogDMLOperation, LoginUser, [RCSCreativeID], [RCSAcctID], [RCSAdvID], [RCSClassID], [CreativeLength], [Priority], [Deleted], [RCSSeqForCreation], [CreatedDT], [CreatedByID], [RCSSeqForUpdate], [ModifiedDT], [ModifiedByID], [CTLegacyID])
SELECT GETDATE(),'D', SYSTEM_USER,  D.[RCSCreativeID],  D.[RCSAcctID],  D.[RCSAdvID],  D.[RCSClassID],  D.[CreativeLength],  D.[Priority],  D.[Deleted],  D.[RCSSeqForCreation],  D.[CreatedDT],  D.[CreatedByID],  D.[RCSSeqForUpdate],  D.[ModifiedDT],  D.[ModifiedByID],  D.[CTLegacyID]
 FROM DELETED D 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into RCSCreativeLog for any record DELETED in RCSCreative.
The inserted row will contain the record that was deleted from the original table */