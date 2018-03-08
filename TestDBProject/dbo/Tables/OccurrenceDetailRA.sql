CREATE TABLE [dbo].[OccurrenceDetailRA] (
    [OccurrenceDetailRAID] INT          IDENTITY (1, 1) NOT NULL,
    [PatternID]            INT          NULL,
    [AdID]                 VARCHAR (50) NULL,
    [RCSAcIdID]            VARCHAR (50) NOT NULL,
    [AirDT]                DATETIME     NOT NULL,
    [RCSStationID]         INT          NOT NULL,
    [LiveRead]             TINYINT      NULL,
    [RCSSequenceID]        BIGINT       NOT NULL,
    [AirStartDT]           DATETIME     NOT NULL,
    [AirEndDT]             DATETIME     NOT NULL,
    [Deleted]              TINYINT      NOT NULL,
    [CreatedDT]            DATETIME     NOT NULL,
    [CreatedByID]          INT          NOT NULL,
    [ModifiedDT]           DATETIME     NULL,
    [ModifiedByID]         INT          NULL,
    [CTLegacySeq]          INT          NULL,
    CONSTRAINT [PK_OccrncDetailsRA] PRIMARY KEY CLUSTERED ([OccurrenceDetailRAID] ASC),
    CONSTRAINT [FK_OccurrenceDetailRA_To_Pattern] FOREIGN KEY ([PatternID]) REFERENCES [dbo].[Pattern] ([PatternID])
);


GO
CREATE NONCLUSTERED INDEX [IX_OccurrenceDetailRA_PatternAdID]
    ON [dbo].[OccurrenceDetailRA]([PatternID] ASC, [AdID] ASC)
    INCLUDE([RCSAcIdID], [AirDT], [RCSStationID]);


GO
CREATE NONCLUSTERED INDEX [IX_OccurrenceDetailRA_Station_StartDT_EndDT]
    ON [dbo].[OccurrenceDetailRA]([RCSStationID] ASC, [AirStartDT] ASC, [AirEndDT] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OccurrenceDetailRA_OccurencesBySessionDate]
    ON [dbo].[OccurrenceDetailRA]([PatternID] ASC, [AdID] ASC, [RCSAcIdID] ASC, [AirDT] ASC, [RCSStationID] ASC)
    INCLUDE([OccurrenceDetailRAID], [AirStartDT], [AirEndDT], [CreatedDT]);


GO
CREATE TRIGGER [dbo].[OccurrenceDetailRA_AuditTrail] ON [dbo].[OccurrenceDetailRA] 
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

SET @TableName = 'OccurrenceDetailRA'

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