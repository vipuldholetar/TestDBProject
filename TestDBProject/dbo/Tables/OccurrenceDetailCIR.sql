CREATE TABLE [dbo].[OccurrenceDetailCIR] (
    [OccurrenceDetailCIRID]    BIGINT        IDENTITY (1, 1) NOT NULL,
    [AdID]                     INT           NULL,
    [AdvertiserID]             INT           NOT NULL,
    [MediaTypeID]              INT           NOT NULL,
    [MarketID]                 INT           NOT NULL,
    [PubEditionID]             INT           NULL,
    [LanguageID]               INT           NULL,
    [EnvelopeID]               INT           NULL,
    [PatternID]                INT           NULL,
    [SubSourceID]              INT           NULL,
    [DistributionDate]         DATE          NULL,
    [AdDate]                   DATE          NULL,
    [Priority]                 INT           NULL,
    [InternalRefenceNotes]     VARCHAR (MAX) NULL,
    [Color]                    VARCHAR (MAX) NULL,
    [SizingMethod]             VARCHAR (MAX) NULL,
    [PubPageNumber]            VARCHAR (MAX) NULL,
    [PageCount]                INT           NULL,
    [NoTakeReason]             VARCHAR (MAX) NULL,
    [Query]                    TINYINT       NULL,
    [QueryCategory]            VARCHAR (MAX) NULL,
    [QueryText]                VARCHAR (MAX) NULL,
    [QryRaisedBy]              VARCHAR (MAX) NULL,
    [QryRaisedDT]              DATETIME      NULL,
    [QueryAnswer]              VARCHAR (MAX) NULL,
    [QryAnsweredBy]            VARCHAR (MAX) NULL,
    [QryAnsweredDT]            DATETIME      NULL,
    [MapStatusID]              INT           NULL,
    [IndexStatusID]            INT           NULL,
    [ScanStatusID]             INT           NULL,
    [QCStatusID]               INT           NULL,
    [RouteStatusID]            INT           NULL,
    [OccurrenceStatusID]       INT           NULL,
    [CreateFromAuditIndicator] TINYINT       NULL,
    [FlyerID]                  INT           NULL,
    [AuditBy]                  VARCHAR (MAX) NULL,
    [AuditDTM]                 VARCHAR (MAX) NULL,
    [CreatedDT]                DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedByID]              INT           DEFAULT ((-1)) NOT NULL,
    [ModifiedDT]               DATETIME      NULL,
    [ModifiedByID]             INT           NULL,
    CONSTRAINT [PK_OccurrenceDetailsCIR] PRIMARY KEY CLUSTERED ([OccurrenceDetailCIRID] ASC),
    CONSTRAINT [FK_OccurrenceDetailCIR_IndexStatus] FOREIGN KEY ([IndexStatusID]) REFERENCES [dbo].[IndexStatus] ([IndexStatusID]),
    CONSTRAINT [FK_OccurrenceDetailCIR_MapStatus] FOREIGN KEY ([MapStatusID]) REFERENCES [dbo].[MapStatus] ([MapStatusID]),
    CONSTRAINT [FK_OccurrenceDetailCIR_OccurrenceStatus] FOREIGN KEY ([OccurrenceStatusID]) REFERENCES [dbo].[OccurrenceStatus] ([OccurrenceStatusID]),
    CONSTRAINT [FK_OccurrenceDetailCIR_QCStatus] FOREIGN KEY ([QCStatusID]) REFERENCES [dbo].[QCStatus] ([QCStatusID]),
    CONSTRAINT [FK_OccurrenceDetailCIR_RouteStatus] FOREIGN KEY ([RouteStatusID]) REFERENCES [dbo].[RouteStatus] ([RouteStatusID]),
    CONSTRAINT [FK_OccurrenceDetailCIR_ScanStatus] FOREIGN KEY ([ScanStatusID]) REFERENCES [dbo].[ScanStatus] ([ScanStatusID]),
    CONSTRAINT [FK_OccurrenceDetailsCIR_ADVERTISERMASTER] FOREIGN KEY ([AdvertiserID]) REFERENCES [dbo].[Advertiser] ([AdvertiserID]),
    CONSTRAINT [FK_OccurrenceDetailsCIR_ENVELOPE] FOREIGN KEY ([EnvelopeID]) REFERENCES [dbo].[Envelope] ([EnvelopeID]),
    CONSTRAINT [FK_OccurrenceDetailsCIR_LANGUAGEMASTER] FOREIGN KEY ([LanguageID]) REFERENCES [dbo].[Language] ([LanguageID]),
    CONSTRAINT [FK_OccurrenceDetailsCIR_MediaType] FOREIGN KEY ([MediaTypeID]) REFERENCES [dbo].[MediaType] ([MediaTypeID]),
    CONSTRAINT [FK_OccurrenceDetailsCIR_PubEdition] FOREIGN KEY ([PubEditionID]) REFERENCES [dbo].[PubEdition] ([PubEditionID]),
    CONSTRAINT [FK_OccurrenceDetailsCIR_SubSource] FOREIGN KEY ([SubSourceID]) REFERENCES [dbo].[SubSource] ([SubSourceID])
);


GO
ALTER TABLE [dbo].[OccurrenceDetailCIR] NOCHECK CONSTRAINT [FK_OccurrenceDetailsCIR_ADVERTISERMASTER];


GO
CREATE NONCLUSTERED INDEX [idx_PatternID]
    ON [dbo].[OccurrenceDetailCIR]([PatternID] ASC)
    INCLUDE([OccurrenceDetailCIRID]);


GO
CREATE TRIGGER [dbo].[OccurrenceDetailCIR_AuditTrail] ON [dbo].[OccurrenceDetailCIR] 
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

SET @TableName = 'OccurrenceDetailCIR'

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
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key OccurrenceDetailsCIR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OccurrenceDetailCIR', @level2type = N'COLUMN', @level2name = N'OccurrenceDetailCIRID';

