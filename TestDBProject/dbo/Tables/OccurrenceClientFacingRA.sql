CREATE TABLE [dbo].[OccurrenceClientFacingRA] (
    [OccurrenceClientFacingRAId] INT      IDENTITY (1, 1) NOT NULL,
    [OccurrenceDetailRAId]       INT      NOT NULL,
    [AdID]                       INT      NULL,
    [OccurrenceClearanceRAId]    INT      NOT NULL,
    [ProgramFormatMasterId]      INT      NULL,
    [Valid]                      BIT      NULL,
    [AirDate]                    DATETIME NOT NULL,
    [AirStartTime]               DATETIME NOT NULL,
    [AirEndTime]                 DATETIME NOT NULL,
    [CreateDTM]                  DATETIME NOT NULL,
    [CreateBy]                   INT      NOT NULL,
    [ModifiedDTM]                DATETIME NULL,
    [ModifiedBy]                 INT      NULL,
    CONSTRAINT [PK_OCCURRENCECLIENTFACINGRA] PRIMARY KEY CLUSTERED ([OccurrenceClientFacingRAId] ASC),
    CONSTRAINT [FK_OCCURRENCECLIENTFACINGRA_OCCURRENCECLEARANCERA] FOREIGN KEY ([OccurrenceClearanceRAId]) REFERENCES [dbo].[OccurrenceClearanceRA] ([OccurrenceClearanceRAID])
);


GO


CREATE TRIGGER [dbo].[TRGAFTERUPDATEOCCURRENCECLIENTFACINGRA] ON [dbo].[OccurrenceClientFacingRA] 
FOR UPDATE
AS
IF NOT EXISTS (SELECT * FROM inserted)
   RETURN
IF NOT EXISTS (SELECT * FROM deleted)
   RETURN

       
	
       INSERT INTO [RadioClearanceLog] 
	  SELECT ins.OccurrenceClientFacingRAId,
      del.AdID,
       del.ProgramFormatMasterId,
      del.Valid,
      del.AirDate,
		del.AirStartTime,
      ins.AdID,
       ins.ProgramFormatMasterId,
      ins.Valid,
      ins.AirDate,
       ins.AirStartTime,
       getdate()
	    FROM inserted ins inner join deleted del on ins.OccurrenceClientFacingRAId=del.OccurrenceClientFacingRAId

GO
CREATE TRIGGER [dbo].[TRGAFTERINSERTOCCURRENCECLIENTFACINGRA] ON [dbo].[OccurrenceClientFacingRA] 
FOR INSERT
AS
IF NOT EXISTS (SELECT * FROM inserted)
   RETURN

	

       INSERT INTO [RadioClearanceLog]
          SELECT OccurrenceClientFacingRAId,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  AdID,
		  ProgramFormatMasterId,
		  Valid,
		  AirDate,
		  AirStartTime,
		  getdate()
		  FROM inserted
       
	   UPDATE [OccurrenceChangeLogRA] SET [EditedDT]=getdate() WHERE AdID IN (SELECT AdID FROM inserted)
	   
       INSERT INTO [OccurrenceChangeLogRA]
         SELECT DISTINCT AdID,'Creative',getdate() 
       FROM inserted ins  where not exists (SELECT AdID FROM [OccurrenceChangeLogRA] WHERE AdID=ins.AdID)

GO
CREATE TRIGGER [dbo].[OccurrenceClientFacingRA_AuditTrail] ON [dbo].[OccurrenceClientFacingRA] 
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

SET @TableName = 'OccurrenceClientFacingRA'

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