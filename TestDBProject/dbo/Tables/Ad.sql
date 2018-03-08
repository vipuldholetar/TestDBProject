CREATE TABLE [dbo].[Ad] (
    [AdID]                  INT           IDENTITY (1, 1) NOT NULL,
    [OriginalAdID]          INT           NULL,
    [PrimaryOccurrenceID]   INT           NULL,
    [AdvertiserID]          INT           NOT NULL,
    [BreakDT]               DATETIME      NULL,
    [StartDT]               DATETIME      NULL,
    [EndDT]                 DATETIME      NULL,
    [LanguageID]            INT           NULL,
    [FamilyID]              INT           NULL,
    [CommonAdDT]            DATETIME      NULL,
    [NoTakeAdReason]        INT           NULL,
    [FirstRunMarketID]      INT           NULL,
    [FirstRunDate]          DATETIME      NULL,
    [LastRunDate]           DATETIME      NULL,
    [AdName]                VARCHAR (MAX) NULL,
    [AdVisual]              VARCHAR (MAX) NULL,
    [AdInfo]                VARCHAR (MAX) NULL,
    [Coop1AdvId]            VARCHAR (MAX) NULL,
    [Coop2AdvId]            VARCHAR (MAX) NULL,
    [Coop3AdvId]            VARCHAR (MAX) NULL,
    [Comp1AdvId]            VARCHAR (MAX) NULL,
    [Comp2AdvId]            VARCHAR (MAX) NULL,
    [TaglineId]             INT           NULL,
    [LeadText]              VARCHAR (MAX) NULL,
    [LeadAvHeadline]        VARCHAR (MAX) NULL,
    [RecutDetail]           VARCHAR (MAX) NULL,
    [RecutAdId]             INT           NULL,
    [EthnicFlag]            VARCHAR (MAX) NULL,
    [AddlInfo]              VARCHAR (MAX) NULL,
    [AdLength]              INT           NULL,
    [InternalNotes]         VARCHAR (MAX) NULL,
    [ProductId]             INT           NULL,
    [Description]           VARCHAR (MAX) NULL,
    [SessionDate]           DATETIME      NULL,
    [Unclassified]          BIT           NULL,
    [CreateDate]            DATETIME      DEFAULT (getdate()) NULL,
    [CreatedBy]             INT           NULL,
    [ModifiedDate]          DATETIME      NULL,
    [ModifiedBy]            INT           NULL,
    [Campaign]              VARCHAR (MAX) NULL,
    [KeyVisualElement]      VARCHAR (MAX) NULL,
    [EntryEligible]         VARCHAR (MAX) NULL,
    [AdType]                VARCHAR (MAX) NULL,
    [AdDistribution]        VARCHAR (MAX) NULL,
    [CelebrityID]           INT           NULL,
    [ClassificationGroupID] INT           NULL,
    [ClassifiedBy]          VARCHAR (MAX) NULL,
    [ClassifiedDT]          DATETIME      NULL,
    [TargetMarketId]        INT           NULL,
    [Query]                 INT           NULL,
    [AuditedByID]           VARCHAR (MAX) NULL,
    [AuditDT]               DATE          NULL,
    [CTLegacySEQ]           INT           NULL,
    [CTLegacyAdCode]        VARCHAR (12)  NULL,
    [Valid]                 BIT           DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Ad] PRIMARY KEY CLUSTERED ([AdID] ASC),
    CONSTRAINT [FK_Ad_To_Ad] FOREIGN KEY ([OriginalAdID]) REFERENCES [dbo].[Ad] ([AdID]),
    CONSTRAINT [FK_Ad_To_Advertiser] FOREIGN KEY ([AdvertiserID]) REFERENCES [dbo].[Advertiser] ([AdvertiserID]),
    CONSTRAINT [FK_Ad_To_Market] FOREIGN KEY ([FirstRunMarketID]) REFERENCES [dbo].[Market] ([MarketID]),
    CONSTRAINT [FK_Ad_To_RefClassificationGroup] FOREIGN KEY ([ClassificationGroupID]) REFERENCES [dbo].[RefClassificationGroup] ([RefClassificationGroupID]),
    CONSTRAINT [FK_Ad_To_RefTagline] FOREIGN KEY ([TaglineId]) REFERENCES [dbo].[RefTagline] ([RefTaglineID]),
    CONSTRAINT [FK_Ad_To_RefTargetMarket] FOREIGN KEY ([TargetMarketId]) REFERENCES [dbo].[RefTargetMarket] ([RefTargetMarketID])
);


GO
CREATE NONCLUSTERED INDEX [IX_Ad_AdvertiserId]
    ON [dbo].[Ad]([AdvertiserID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AD_AdId]
    ON [dbo].[Ad]([AdID] ASC, [Valid] ASC, [Unclassified] ASC, [NoTakeAdReason] ASC)
    INCLUDE([OriginalAdID], [PrimaryOccurrenceID], [Description], [CreateDate], [CreatedBy], [LeadText], [LeadAvHeadline], [RecutDetail], [RecutAdId], [AdLength], [ProductId], [Coop1AdvId], [Coop2AdvId], [Coop3AdvId], [Comp1AdvId], [Comp2AdvId], [TaglineId], [AdvertiserID], [LanguageID], [FirstRunMarketID], [FirstRunDate], [LastRunDate], [AdVisual]);


GO
CREATE NONCLUSTERED INDEX [IX_Ad_CTLegacyAdCode]
    ON [dbo].[Ad]([CTLegacyAdCode] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Ad_PrimaryOccurrenceId]
    ON [dbo].[Ad]([PrimaryOccurrenceID] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_AdvertiserIDLanguageID]
    ON [dbo].[Ad]([AdvertiserID] ASC, [LanguageID] ASC);


GO
CREATE TRIGGER [dbo].[Ad_AuditTrail] ON dbo.Ad 
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

SET @TableName = 'Ad'

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
