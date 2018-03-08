CREATE TABLE [dbo].[LandingPage] (
    [LandingPageID] INT            IDENTITY (1, 1) NOT NULL,
    [LandingURL]    VARCHAR (3000) NOT NULL,
    [HashURL]       AS             (CONVERT([char],hashbytes('SHA1',[LandingURL]),(2))) PERSISTED,
    [CreatedDT]     DATETIME       DEFAULT (getdate()) NULL,
    [CTLegacySeq]   INT            NULL,
    CONSTRAINT [PK_LandingPage] PRIMARY KEY CLUSTERED ([LandingPageID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_LandingPage_CTLegacySeq]
    ON [dbo].[LandingPage]([CTLegacySeq] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_LandingPage_HashURL]
    ON [dbo].[LandingPage]([HashURL] ASC);


GO
CREATE TRIGGER mt_trDeleteTriggerToLogOnLandingPage ON LandingPage
	FOR DELETE AS 
SET NOCOUNT ON
INSERT INTO LandingPageLog(LogTimeStamp, LogDMLOperation, LoginUser, [LandingPageID], [LandingURL], [HashURL], [CreatedDT], [CTLegacySeq])
SELECT GETDATE(),'D', SYSTEM_USER,  D.[LandingPageID],  D.[LandingURL],  D.[HashURL],  D.[CreatedDT],  D.[CTLegacySeq]
 FROM DELETED D 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into LandingPageLog for any record DELETED in LandingPage.
The inserted row will contain the record that was deleted from the original table */
GO
CREATE TRIGGER mt_trInsertTriggerToLogOnLandingPage ON LandingPage
	FOR INSERT AS 
SET NOCOUNT ON
INSERT INTO LandingPageLog(LogTimeStamp, LogDMLOperation, LoginUser, [LandingPageID], [LandingURL], [HashURL], [CreatedDT], [CTLegacySeq])
SELECT GETDATE(),'I', SYSTEM_USER,  I.[LandingPageID],  I.[LandingURL],  I.[HashURL],  I.[CreatedDT],  I.[CTLegacySeq]
 FROM INSERTED I 

/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into LandingPageLog for 
any record insert into LandingPage*/
GO

 CREATE TRIGGER mt_trUpdateTriggerToLogOnLandingPage ON LandingPage
	FOR UPDATE AS 
SET NOCOUNT ON
INSERT INTO LandingPageLog(LogTimeStamp, LogDMLOperation, LoginUser, [LandingPageID], [LandingURL],[oldval_LandingURL], [HashURL],[oldval_HashURL], [CreatedDT],[oldval_CreatedDT], [CTLegacySeq],[oldval_CTLegacySeq])
SELECT GETDATE(),'U', SYSTEM_USER,  I.[LandingPageID], D.[LandingPageID],  I.[LandingURL], I.[HashURL], D.[HashURL],  I.[CreatedDT], D.[CreatedDT],  I.[CTLegacySeq], D.[CTLegacySeq]
 FROM INSERTED I 
join DELETED D on
 I.[LandingPageID]= D.[LandingPageID]
 where  ( (I.[LandingURL]<> D.[LandingURL] or (I.[LandingURL] is null and D.[LandingURL] is not null) or  (I.[LandingURL] is not null and D.[LandingURL] is null)) or  (I.[HashURL]<> D.[HashURL] or (I.[HashURL] is null and D.[HashURL] is not null) or  (I.[HashURL] is not null and D.[HashURL] is null)) or  (I.[CreatedDT]<> D.[CreatedDT] or (I.[CreatedDT] is null and D.[CreatedDT] is not null) or  (I.[CreatedDT] is not null and D.[CreatedDT] is null)) or  (I.[CTLegacySeq]<> D.[CTLegacySeq] or (I.[CTLegacySeq] is null and D.[CTLegacySeq] is not null) or  (I.[CTLegacySeq] is not null and D.[CTLegacySeq] is null)))
/*Automatically created by mt_proc_BuildLogTableAutoCreateTriggers Version 1.0.1
 Trigger created to auto-insert row into LandingPageLog for any record UPDATED in LandingPage.
The inserted row will contain the particular field value updated and the previous value
from that field(oldval_) */