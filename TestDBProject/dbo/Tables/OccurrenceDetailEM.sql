CREATE TABLE [dbo].[OccurrenceDetailEM] (
    [OccurrenceDetailEMID]     INT           IDENTITY (1, 1) NOT NULL,
    [AdvertiserID]             INT           NULL,
    [MediaTypeID]              INT           NULL,
    [MarketID]                 INT           NULL,
    [AdvertiserEmailID]        INT           NULL,
    [SenderPersonaID]          INT           NULL,
    [ParentOccurrenceID]       INT           NULL,
    [EnvelopeID]               INT           NULL,
    [AdID]                     INT           NULL,
    [PatternID]                INT           NULL,
    [DistributionDT]           DATE          NULL,
    [AdDT]                     DATE          NULL,
    [Priority]                 INT           NULL,
    [SubjectLine]              VARCHAR (200) NULL,
    [LandingPageID]            INT           NULL,
    [PromotionalInd]           TINYINT       NULL,
    [AssignedtoOffice]         VARCHAR (200) NULL,
    [NoTakeReason]             VARCHAR (200) NULL,
    [Query]                    TINYINT       NULL,
    [MapStatusID]              INT           NULL,
    [IndexStatusID]            INT           NULL,
    [ScanStatusID]             INT           NULL,
    [QCStatusID]               INT           NULL,
    [RouteStatusID]            INT           NULL,
    [OccurrenceStatusID]       INT           NULL,
    [CreateFromAuditIndicator] TINYINT       NULL,
    [FlyerID]                  INT           NULL,
    [AuditedByID]              INT           NULL,
    [AuditedDT]                DATETIME      NULL,
    [CreatedDT]                DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedByID]              INT           NULL,
    [ModifiedDT]               DATETIME      NULL,
    [ModifiedByID]             INT           NULL,
    [CTLegacySeq]              INT           NULL,
    CONSTRAINT [PK_OccurrenceDetailsEM] PRIMARY KEY CLUSTERED ([OccurrenceDetailEMID] ASC),
    CONSTRAINT [FK_OccurrenceDetailEM_IndexStatus] FOREIGN KEY ([IndexStatusID]) REFERENCES [dbo].[IndexStatus] ([IndexStatusID]),
    CONSTRAINT [FK_OccurrenceDetailEM_LandingPage] FOREIGN KEY ([LandingPageID]) REFERENCES [dbo].[LandingPage] ([LandingPageID]),
    CONSTRAINT [FK_OccurrenceDetailEM_MapStatus] FOREIGN KEY ([MapStatusID]) REFERENCES [dbo].[MapStatus] ([MapStatusID]),
    CONSTRAINT [FK_OccurrenceDetailEM_OccurrenceStatus] FOREIGN KEY ([OccurrenceStatusID]) REFERENCES [dbo].[OccurrenceStatus] ([OccurrenceStatusID]),
    CONSTRAINT [FK_OccurrenceDetailEM_QCStatus] FOREIGN KEY ([QCStatusID]) REFERENCES [dbo].[QCStatus] ([QCStatusID]),
    CONSTRAINT [FK_OccurrenceDetailEM_RouteStatus] FOREIGN KEY ([RouteStatusID]) REFERENCES [dbo].[RouteStatus] ([RouteStatusID]),
    CONSTRAINT [FK_OccurrenceDetailEM_ScanStatus] FOREIGN KEY ([ScanStatusID]) REFERENCES [dbo].[ScanStatus] ([ScanStatusID])
);


GO
CREATE NONCLUSTERED INDEX [IX_OccurrenceDetailEM_AssignedtoOffice]
    ON [dbo].[OccurrenceDetailEM]([ParentOccurrenceID] ASC, [AssignedtoOffice] ASC, [Query] ASC)
    INCLUDE([OccurrenceDetailEMID], [AdvertiserID], [MarketID], [SenderPersonaID], [AdDT], [SubjectLine], [CreatedByID]);


GO
CREATE NONCLUSTERED INDEX [IX_OccurrenceDetailEM_ParentOccurrenceID]
    ON [dbo].[OccurrenceDetailEM]([ParentOccurrenceID] ASC, [AdID] ASC, [Query] ASC, [CreatedDT] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OccurrenceDetailEM_OccurrenceStatusID]
    ON [dbo].[OccurrenceDetailEM]([ParentOccurrenceID] ASC, [OccurrenceStatusID] ASC, [Query] ASC)
    INCLUDE([OccurrenceDetailEMID], [AdvertiserID], [MarketID], [AdvertiserEmailID], [SenderPersonaID], [AdID], [PatternID], [AdDT], [Priority], [SubjectLine], [AssignedtoOffice], [MapStatusID], [IndexStatusID], [ScanStatusID], [RouteStatusID], [CreatedDT], [CreatedByID]);


GO
CREATE NONCLUSTERED INDEX [idx_AdID]
    ON [dbo].[OccurrenceDetailEM]([AdID] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_PatternID]
    ON [dbo].[OccurrenceDetailEM]([PatternID] ASC)
    INCLUDE([MarketID], [AdDT]);


GO
CREATE NONCLUSTERED INDEX [idx_SenderPersonaIDPatternIDSubjectLine]
    ON [dbo].[OccurrenceDetailEM]([SenderPersonaID] ASC, [PatternID] ASC, [SubjectLine] ASC, [CreatedDT] ASC);


GO
CREATE TRIGGER [dbo].[OccurrenceDetailEM_AuditTrail] ON [dbo].[OccurrenceDetailEM] 
FOR INSERT, UPDATE, DELETE
AS
BEGIN
DECLARE @TableNameParm varchar(250)
DECLARE @TableName varchar (250)
DECLARE @LogDMLOperation varchar (250)
DECLARE @KeyName varchar (250)
DECLARE @FieldName varchar (250)
DECLARE @field int
DECLARE @maxfield int 
DECLARE @bit int

DECLARE @sql varchar (max)
DECLARE @sql1 varchar (max)
DECLARE @sql2 varchar (max)
DECLARE @sql3 varchar (max)

SET NOCOUNT ON; 

SET @TableName = 'OccurrenceDetailEM'

SELECT @KeyName = COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS a, INFORMATION_SCHEMA.KEY_COLUMN_USAGE b
WHERE a.TABLE_NAME = @TableName
AND a.CONSTRAINT_TYPE = 'PRIMARY KEY'
AND b.TABLE_NAME = a.TABLE_NAME
AND b.CONSTRAINT_NAME = a.CONSTRAINT_NAME
 
SELECT * INTO #ins FROM INSERTED
SELECT * INTO #del FROM DELETED

IF EXISTS (SELECT * FROM INSERTED) AND
   EXISTS (SELECT * FROM DELETED)
   BEGIN
       SET @LogDMLOperation = 'U' --/ for UPDATEs
       SET @SQL3 = ' FROM #ins i LEFT JOIN #del d ON i.' + @KeyName + '=d.' + @KeyName
   END
--/ Devs, please account later for tables with NO PK
ELSE
IF EXISTS (SELECT * FROM INSERTED)
BEGIN
       SET @LogDMLOperation = 'I' --/ for INSERTs
       SET @SQL3 = ' FROM #ins i'
END
ELSE
BEGIN
       SET @LogDMLOperation = 'D' --/ for DELETEs
       SET @SQL3 = ' FROM #del i'
END
--ENDIF
 
--SELECT @LogDMLOperation
 
SET @SQL1 = 'INSERT INTO ' + @TableName + 'Log' + ' ('
SET @SQL1 = @SQL1 +  '            LogTimeStamp, LogDMLOperation, LoginUser'
 
SET @SQL2 = ') SELECT CURRENT_TIMESTAMP, ''' + @LogDMLOperation + ''', ''' + CURRENT_USER + ''''

SELECT @field = 1,
       @maxfield = MAX(ORDINAL_POSITION)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @TableName
 
WHILE @field <= @maxfield
BEGIN
     SET @bit = ((@field - 1) %  8) + 1
     SET @bit = POWER(2, @bit - 1)
 
     SELECT @fieldname = COLUMN_NAME
     FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_NAME = @TableName
     AND ORDINAL_POSITION = @field
 
     SET @SQL1 = @SQL1 + ',' + @fieldname 
     IF @fieldname <> @KeyName AND @LogDMLOperation = 'U' --THEN           --/ non PK
              SET @SQL1 = @SQL1 + ', OldVal_' + @fieldname 
            --ENDIF
 
     SET @SQL2 = @SQL2 + ',i.' + @fieldname  --/ assumption here that if no update, the value is both in INSERT and DELETE.
     --IF SUBSTRING(COLUMNS_UPDATED(),@field, 1) > 0 AND @bit > 0 AND @LogDMLOperation = 'U'
     IF  @LogDMLOperation = 'U'
              IF @fieldname <> @KeyName         --/ non PK
                     SET @SQL2 = @SQL2 + ',d.' + @fieldname 
       --ENDIF
             --ENDIF
 
     SET @field = @field + 1
END
 
SET @SQL = @SQL1 + @SQL2 + @SQL3
EXEC (@SQL)

END