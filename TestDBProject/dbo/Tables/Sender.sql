CREATE TABLE [dbo].[Sender] (
    [SenderID]                       INT           IDENTITY (1, 1) NOT NULL,
    [Name]                           VARCHAR (200) NULL,
    [Address]                        VARCHAR (200) NULL,
    [Address2]                       VARCHAR (50)  NULL,
    [City]                           VARCHAR (50)  NULL,
    [State]                          VARCHAR (50)  NULL,
    [ZipCode]                        VARCHAR (50)  NULL,
    [Country]                        VARCHAR (50)  NULL,
    [Phone]                          VARCHAR (50)  NULL,
    [StartDT]                        DATETIME      NULL,
    [EndDT]                          DATETIME      NULL,
    [Priority]                       INT           NULL,
    [FrequencyID]                    INT           NULL,
    [ExpectedReceiveDT]              INT           NULL,
    [TypeID]                         INT           NULL,
    [LocationID]                     INT           NULL,
    [IndNoShipping]                  TINYINT       NULL,
    [IndNoPublications]              TINYINT       NULL,
    [Comments]                       VARCHAR (250) NULL,
    [DefaultPkgAssignee]             INT           NULL,
    [DefaultRetID]                   INT           NULL,
    [DefaultMktID]                   INT           NULL,
    [Gender]                         VARCHAR (50)  NULL,
    [DoB]                            DATETIME      NULL,
    [AgeBracket]                     VARCHAR (50)  NULL,
    [Company]                        VARCHAR (200) NULL,
    [ContactName]                    VARCHAR (200) NULL,
    [MailingAddress]                 VARCHAR (500) NULL,
    [Cell]                           VARCHAR (100) NULL,
    [Work]                           VARCHAR (100) NULL,
    [Phone2]                         VARCHAR (100) NULL,
    [Email]                          VARCHAR (100) NULL,
    [ShippingTypeID]                 INT           NULL,
    [BulkLabelInd]                   TINYINT       NULL,
    [LabelQty]                       VARCHAR (100) NULL,
    [PackageWeight]                  VARCHAR (100) NULL,
    [LabelNote]                      VARCHAR (500) NULL,
    [SubPayment]                     INT           NULL,
    [InStoreNotes]                   VARCHAR (500) NULL,
    [SendingInstructions]            VARCHAR (500) NULL,
    [CCNotes]                        VARCHAR (500) NULL,
    [EarlySender]                    INT           NULL,
    [SourceID]                       INT           NULL,
    [DigitalOnlyIndicator]           TINYINT       NULL,
    [CreatedDT]                      DATETIME      NOT NULL,
    [CreatedByID]                    INT           NOT NULL,
    [ModifiedDT]                     DATETIME      NULL,
    [ModifiedByID]                   INT           NULL,
    [MTLegacyDefaultRetID]           INT           NULL,
    [MTLegacyDefaultMarketID]        INT           NULL,
    [TypeDescrip]                    VARCHAR (255) NULL,
    [LocationDescrip]                VARCHAR (255) NULL,
    [ShippingTypeDescrip]            VARCHAR (255) NULL,
    [RetailerDescription]            VARCHAR (255) NULL,
    [SIMRInd]                        TINYINT       NULL,
    [ReadyForCompare]                TINYINT       NULL,
    [DMAID]                          INT           NULL,
    [MTLegacySenderID]               INT           NULL,
    [MTLegacyDefaultPkgAssigneeCODE] VARCHAR (50)  NULL,
    [AssigneeName]                   VARCHAR (100) NULL,
    [AdvertiserID]                   INT           NULL,
    [MarketID]                       INT           NULL,
    [MarketDescrip]                  VARCHAR (255) NULL,
    [SourceDescrip]                  VARCHAR (255) NULL,
    [FrequencyDescrip]               VARCHAR (255) NULL,
    CONSTRAINT [PK_Sender] PRIMARY KEY CLUSTERED ([SenderID] ASC)
);


GO
CREATE TRIGGER [dbo].[Sender_AuditTrail] ON [dbo].[Sender] 
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

SET @TableName = 'Sender'

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