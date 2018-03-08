
/*-------------------------------------------------------------------------------- 
Stored Procedure/Trigger: mt_proc_BuildLogTableAutoCreateTriggers

Creation Date: 06-25-03						

Written by: Todd Hoffman and Tony Quirke	
			
Purpose: To create a log table for any required table and also 	
	automatically create the insert, update and delete triggers on the 	
	original table that will insert the relevant data into this 		
	newly created log table						

The source table MUST have a Primary Key for this procedure to run successfully

 Dependent upon initial creation of UDF's and LogPurgeFreq table	

 Input Parameters: @sTableName varchar(128),				
 @sLogTableName varchar(128), @nDaysPurgeFreq int,@bExecute bit	
									
 Output Parameters:							
									
 Modified by: 
	Todd Hoffman 7/19/03 - Don't log changes on updates without column value changes
 Modified by: 
	Jay Heter 4/24/08 - For MCAP - write to a different DB
	Update of name
----------------------------------------------------------------------------------*/


CREATE PROC  [dbo].[mt_proc_BuildLogTableAutoCreateTriggers]
	@sTableName varchar(32),
	@sLogTableName varchar(64),
	@sLogDatabaseName varchar(64),
	@nDaysToPurge int,
	@bExecute bit = 0
	
--@bExecute lets the user print out the code before executing for viewing
AS

DECLARE	@sLogTableText varchar(max),
	@sDropInsertTriggerText varchar(max),
	@sInsertTriggerTextFirst varchar(max),
	@sInsertTriggerTextLast  varchar(max),
	@sInsertTriggerCommentTag  varchar(350),
	@sUpdateTriggerCommentTag  varchar(350),
	@sDeleteTriggerCommentTag  varchar(350),
	@sInsertTriggerName varchar(128),
	@sDropUpdateTriggerText varchar(max),
	@sUpdateTriggerTextFirst varchar(max),
	@sUpdateTriggerTextLast  varchar(max),
	@sUpdateTriggerName varchar(128),
	@sUpdateNonPKColumns varchar (max),
	@sDropDeleteTriggerText varchar(max),
	@sDeleteTriggerTextFirst varchar(max),
	@sDeleteTriggerTextLast varchar(max),
	@sDeleteTriggerName varchar(128),
	@sColumnName varchar(128),
	@nColumnID smallint,
	@bPrimaryKeyColumn bit,
	@nAlternateType int,
	@nColumnLength int,
	@nColumnPrecision int,
	@nColumnScale int,
	@IsNullable bit, 
	@IsIdentity int,
	@sTypeName varchar(128),
	@sDefaultValue varchar(max),
	@sCRLF char(2),
	@sTAB char(1),
	@sDeletedInsertedJoin varchar(max),
	@sPreviousValueColumnPrefix varchar(128),
	@NonPrimaryKeyColumns int

SET 	@sCRLF = char(13) + char(10)
--Insert into LogPurgeFreq table the number of days where
--any log records older than this number of days will automatically 
--be purged from this particular log table.

BEGIN
declare @sql nvarchar(max)
	set @sql ='DELETE ' + @sLogDatabaseName + '.. LogPurgeDays Where LogTableName = '''+@sLogTableName+''''
	exec sp_executesql @sql

	set @sql ='  Insert ' + @sLogDatabaseName + '.. LogPurgeDays
	(logtablename, DaysToPurge)
	values ('''+@sLogTableName+''',	'+cast(@nDaysToPurge as varchar)+')'

	exec sp_executesql @sql
END

Print '-- ' + cast(@nDaysToPurge as char(3)) + 'entered into ' + @sLogDatabaseName + '..LogPurgeDays table for ' + @sLogTableName


--Insert Trigger Comment
--CHANGE THIS FOR EVERY VERSION***********************************************
SET 	@sInsertTriggerCommentTag = '/*Automatically created by ' + IsNull(OBJECT_NAME (@@PROCID),'Query Analyzer') +
 ' Version 1.0.1' + @sCRLF + ' Trigger created to auto-insert row into ' + @sLogTableName + ' for 
any record insert into ' + @sTableName + '*/'

--****************************************************************************

--Update Trigger Comment
--CHANGE THIS FOR EVERY VERSION***********************************************
SET 	@sUpdateTriggerCommentTag = '/*Automatically created by ' + IsNull(OBJECT_NAME (@@PROCID),'Query Analyzer') +
 ' Version 1.0.1' + @sCRLF + ' Trigger created to auto-insert row into ' + @sLogTableName + 
' for any record UPDATED in ' + @sTableName  + '.' + @sCRLF +
'The inserted row will contain the particular field value updated and the previous value
from that field(OldValue_) */'

--****************************************************************************

--Delete Trigger Comment
--CHANGE THIS FOR EVERY VERSION***********************************************
SET 	@sDeleteTriggerCommentTag = '/*Automatically created by ' + IsNull(OBJECT_NAME (@@PROCID),'Query Analyzer') +
 ' Version 1.0.1' + @sCRLF + ' Trigger created to auto-insert row into ' + @sLogTableName + 
' for any record DELETED in ' + @sTableName  + '.' + @sCRLF +
'The inserted row will contain the record that was deleted from the original table */'

--****************************************************************************


SET	@sTAB = char(9)
SET 	@sCRLF = char(13) + char(10)

SET 	@sLogTableText = ''

if @sTableName=@sLogTableName 
begin
	--print 'The target table and the log table can not be the same.'
	raiserror ('The target table, ''%s'' and the log table,''%s'' can not be the same.',16,1,@sTableName,@sLogTableName )
	return
end
--'use '+ @sLogDatabaseName + @sCRLF + 
	SET 	@sLogTableText = 'if exists (select * from '+@sLogDatabaseName+'.dbo.sysobjects where id = object_id(N'''+@sLogDatabaseName + '..'+ @sLogTableName +'''))' + @sCRLF
	SET 	@sLogTableText = @sLogTableText  + @sCRLF + 'BEGIN ' + @sCRLF +  @sTAB + 'DROP TABLE ' + @sLogDatabaseName + '..' + @sLogTableName + @sCRLF +'END'
	SET @sLogTableText = @sLogTableText + @sCRLF + 'if @@error =0' 
	SET @sLogTableText = @sLogTableText + @sCRLF + @sTAB +'PRINT ''Table: ' + @sLogDatabaseName + '..'+ @sLogTableName +' dropped'''+ @sCRLF 
	SET @sLogTableText = @sLogTableText + 'ELSE' + @sCRLF + @sTAB +'PRINT ''Error dropping Table: ' + @sLogDatabaseName + '..'+ @sLogTableName + ''''+ @sCRLF  + @sCRLF

IF @bExecute = 0
	PRINT @sLogTableText + @sCRLF + ' GO ' + @sCRLF
else
	exec (@sLogTableText)

SET 	@sLogTableText = 'CREATE TABLE '+ @sLogDatabaseName + '.dbo.' + @sLogTableName + 
	'(' + @sCRLF + @sTAB + 'LogTimeStamp datetime,' + 
	@sCRLF + @sTAB + 'LogDMLOperation char(1) CHECK (LogDMLOperation in (''D'',''I'',''U'')),' +
	@sCRLF + @sTAB + 'LoginUser varchar(32), ' +@sCRLF


--Prepare Insert Trigger Text
SET @sInsertTriggerName ='mt_trInsertTriggerToLogOn' + @sTableName

SET @sDropInsertTriggerText = 'if exists (select * from dbo.sysobjects where id = object_id(N''' + @sInsertTriggerName + ''') and OBJECTPROPERTY(id, N''IsTrigger'') = 1)' + @sCRLF +
	'DROP TRIGGER ' + @sInsertTriggerName + @sCRLF + 'GO' + @sCRLF


SET @sInsertTriggerTextFirst= 'CREATE TRIGGER '+@sInsertTriggerName +' ON '  + @sTableName + @sCRLF + @sTAB + 
	'FOR INSERT AS ' + @sCRLF + 'SET NOCOUNT ON' +  @sCRLF +'INSERT INTO ' + @sLogDatabaseName + '..' + @sLogTableName + '(LogTimeStamp, LogDMLOperation, LoginUser, '

SET @sInsertTriggerTextLast= 'SELECT GETDATE(),''I'', SYSTEM_USER, '

--Prepare Update Trigger
SET @sUpdateTriggerName ='mt_trUpdateTriggerToLogOn' + @sTableName

SET @sDropUpdateTriggerText = 'if exists (select * from dbo.sysobjects where id = object_id(N''' + @sUpdateTriggerName + ''') and OBJECTPROPERTY(id, N''IsTrigger'') = 1)' + @sCRLF +
	'DROP TRIGGER ' + @sUpdateTriggerName + @sCRLF  + 'GO' + @sCRLF


SET @sUpdateTriggerTextFirst= 'CREATE TRIGGER '+@sUpdateTriggerName +' ON ' + @sTableName + @sCRLF + @sTAB + 
	'FOR UPDATE AS ' +  @sCRLF + 'SET NOCOUNT ON' + @sCRLF +'INSERT INTO ' + @sLogDatabaseName + '..' + @sLogTableName + '(LogTimeStamp, LogDMLOperation, LoginUser, '

SET @sUpdateTriggerTextLast= 'SELECT GETDATE(),''U'', SYSTEM_USER, '

SET @sUpdateNonPKColumns =''

--Prepare Delete Trigger Text
SET @sDeleteTriggerName ='mt_trDeleteTriggerToLogOn' + @sTableName

SET @sDropDeleteTriggerText = 'if exists (select * from dbo.sysobjects where id = object_id(N''' + @sDeleteTriggerName + ''') and OBJECTPROPERTY(id, N''IsTrigger'') = 1)' + @sCRLF +
	'DROP TRIGGER ' + @sDeleteTriggerName + @sCRLF  + 'GO' + @sCRLF


SET @sDeleteTriggerTextFirst= 'CREATE TRIGGER '+@sDeleteTriggerName +' ON ' + @sTableName + @sCRLF + @sTAB + 
	'FOR DELETE AS ' +  @sCRLF + 'SET NOCOUNT ON' + @sCRLF +'INSERT INTO ' + @sLogDatabaseName + '..' + @sLogTableName + '(LogTimeStamp, LogDMLOperation, LoginUser, '

SET @sDeleteTriggerTextLast= 'SELECT GETDATE(),''D'', SYSTEM_USER, '

--Get fields in table from cursor
DECLARE crFields cursor for
	SELECT	*
	FROM dbo.fnTableColumnInfo(@sTableName)
	ORDER BY 2

SET @NonPrimaryKeyColumns=0
SET @sDeletedInsertedJoin = ''
SET @sPreviousValueColumnPrefix = 'OldValue_'
OPEN crFields

FETCH 	NEXT 
FROM 	crFields 
INTO 	@sColumnName, @nColumnID, @bPrimaryKeyColumn, @nAlternateType, 
	@nColumnLength, @nColumnPrecision, @nColumnScale, @IsNullable, 
	@IsIdentity, @sTypeName, @sDefaultValue
				
WHILE (@@FETCH_STATUS = 0)
 BEGIN
		--Insert Trigger Text
		SET @sInsertTriggerTextFirst= @sInsertTriggerTextFirst + '[' + @sColumnName + ']'
		SET @sInsertTriggerTextLast= @sInsertTriggerTextLast +' I.[' + @sColumnName + ']'

		
		--Update Trigger Text
		SET @sUpdateTriggerTextFirst= @sUpdateTriggerTextFirst + '[' + @sColumnName + '],[' + @sPreviousValueColumnPrefix + @sColumnName + ']'
		SET @sUpdateTriggerTextLast= @sUpdateTriggerTextLast +' I.[' + @sColumnName + '], D.[' +  @sColumnName + ']'
		
		--Delete Trigger Text
		SET @sDeleteTriggerTextFirst= @sDeleteTriggerTextFirst + '[' + @sColumnName + ']'
		SET @sDeleteTriggerTextLast= @sDeleteTriggerTextLast +' D.[' + @sColumnName + ']'
		
		IF @bPrimaryKeyColumn =1 
		BEGIN
			if @sDeletedInsertedJoin <> ''
				
				BEGIN
					SET @sDeletedInsertedJoin = @sDeletedInsertedJoin + ' and '
				END

			SET @sDeletedInsertedJoin = @sDeletedInsertedJoin + ' I.[' + @sColumnName + ']= D.[' + @sColumnName + ']'
		END
		ELSE
		BEGIN
			SET @NonPrimaryKeyColumns=@NonPrimaryKeyColumns+1
			if @sUpdateNonPKColumns <>''
			BEGIN
				SET @sUpdateNonPKColumns 	 = @sUpdateNonPKColumns + ' or '
			END
			SET @sUpdateNonPKColumns 	 = @sUpdateNonPKColumns + ' (I.[' + @sColumnName + ']<> D.[' + @sColumnName +'] or (I.[' + @sColumnName + '] is null and D.[' + @sColumnName +'] is not null)' +' or  (I.[' + @sColumnName + '] is not null and D.[' + @sColumnName +'] is null))'
		END
		
		--Create Log Table Columns
		SET @sLogTableText=@sLogTableText +  @sTAB + '[' + @sColumnName + '] ' + @sTypeName 
		
		IF (@nAlternateType = 2) --decimal, numeric
			SET @sLogTableText=@sLogTableText + '(' + CAST(@nColumnPrecision AS varchar(3)) + ', ' 
					+ CAST(@nColumnScale AS varchar(3)) + ')'
	
		ELSE IF (@nAlternateType = 1) --character and binary
			SET @sLogTableText=@sLogTableText +  '(' + CAST(@nColumnLength AS varchar(4)) +  ')'

		--Create Log Table Columns Prev Value Column
		
		SET @sLogTableText=@sLogTableText +  ', ' + @sCRLF
		SET @sLogTableText=@sLogTableText +  @sTAB + '[' + @sPreviousValueColumnPrefix + @sColumnName + '] ' + @sTypeName 
		
		IF (@nAlternateType = 2) --decimal, numeric
			SET @sLogTableText=@sLogTableText + '(' + CAST(@nColumnPrecision AS varchar(3)) + ', ' 
					+ CAST(@nColumnScale AS varchar(3)) + ')'
	
		ELSE IF (@nAlternateType = 1) --character and binary
			SET @sLogTableText=@sLogTableText +  '(' + CAST(@nColumnLength AS varchar(4)) +  ')'

		
	FETCH 	NEXT 
	FROM 	crFields 
	INTO 	@sColumnName, @nColumnID, @bPrimaryKeyColumn, @nAlternateType, 
		@nColumnLength, @nColumnPrecision, @nColumnScale, @IsNullable, 
		@IsIdentity, @sTypeName, @sDefaultValue
	if (@@FETCH_STATUS = 0)
	BEGIN
		SET @sLogTableText=@sLogTableText +  ', ' + @sCRLF
		SET @sInsertTriggerTextFirst= @sInsertTriggerTextFirst + ', '  
		SET @sInsertTriggerTextLast= @sInsertTriggerTextLast + ', ' 
		SET @sUpdateTriggerTextFirst= @sUpdateTriggerTextFirst + ', '  
		SET @sUpdateTriggerTextLast= @sUpdateTriggerTextLast + ', '
		SET @sDeleteTriggerTextFirst= @sDeleteTriggerTextFirst + ', '  
		SET @sDeleteTriggerTextLast= @sDeleteTriggerTextLast + ', '
	END
 END

CLOSE crFields
DEALLOCATE crFields

SET @sLogTableText=@sLogTableText + @sCRLF +  ') ' + @sCRLF
SET @sInsertTriggerTextFirst= @sInsertTriggerTextFirst + ')' + @sCRLF + @sInsertTriggerTextLast  + @sCRLF + ' FROM INSERTED I '  
+@sCRLF +@sCRLF + @sInsertTriggerCommentTag

SET @sUpdateTriggerTextFirst= @sUpdateTriggerTextFirst + ')' + @sCRLF + @sUpdateTriggerTextLast  + @sCRLF + ' FROM INSERTED I '  +@sCRLF 
+ 'join DELETED D on' +  @sCRLF + @sDeletedInsertedJoin +  @sCRLF + ' where  (' +@sUpdateNonPKColumns +')'
+ @sCRLF + @sCRLF + @sUpdateTriggerCommentTag

SET @sDeleteTriggerTextFirst= @sDeleteTriggerTextFirst + ')' + @sCRLF + @sDeleteTriggerTextLast  + @sCRLF + ' FROM DELETED D '  +@sCRLF 
+ @sCRLF + @sDeleteTriggerCommentTag

SET @sLogTableText= @sLogTableText + @sCRLF +  'PRINT ''Table: ' + @sLogDatabaseName + '..' + @sLogTableName +' created.''' +  @sCRLF 

IF @bExecute = 0
	PRINT @sLogTableText 
else
BEGIN
	exec (@sLogTableText)
END

--Create the INSERT trigger
--set the insert trigger as last
IF @bExecute = 0
BEGIN
	print '-- insert trigger'
	PRINT @sDropInsertTriggerText
	PRINT @sInsertTriggerTextFirst + @sCRLF + ' GO ' + @sCRLF
	SET @sInsertTriggerTextFirst='sp_settriggerorder @triggername = ''' + @sInsertTriggerName +''', @order = ''last'', @stmttype = ''INSERT'''
	print @sInsertTriggerTextFirst
END
else
BEGIN
	set @sDropInsertTriggerText = Replace(@sDropInsertTriggerText,@sCRLF+'GO'+@sCRLF,'')
	exec (@sDropInsertTriggerText)
	set @sInsertTriggerTextFirst = Replace(@sInsertTriggerTextFirst,@sCRLF+'GO'+@sCRLF,'')
	exec (@sInsertTriggerTextFirst)
	SET @sInsertTriggerTextFirst='exec sp_settriggerorder @triggername = ''' + @sInsertTriggerName +''', @order = ''last'', @stmttype = ''INSERT'''
	exec (@sInsertTriggerTextFirst)
END
 
--Create the Update trigger
--set the update trigger as last
IF @bExecute = 0 
BEGIN
	print '-- update trigger'
	if @NonPrimaryKeyColumns>0 
	BEGIN
		PRINT @sDropUpdateTriggerText
		PRINT @sUpdateTriggerTextFirst + @sCRLF + ' GO ' + @sCRLF
		SET @sUpdateTriggerTextFirst='sp_settriggerorder @triggername = ''' + @sUpdateTriggerName +''', @order = ''last'', @stmttype = ''UPDATE'''
		print @sUpdateTriggerTextFirst
	END
	else
	print 'no NonPrimaryKey'
END
else
BEGIN
	if @NonPrimaryKeyColumns>0
	BEGIN
		set @sDropUpdateTriggerText = Replace(@sDropUpdateTriggerText,@sCRLF+'GO'+@sCRLF,'')
		exec (@sDropUpdateTriggerText)
		set @sUpdateTriggerTextFirst = Replace(@sUpdateTriggerTextFirst,@sCRLF+'GO'+@sCRLF,'')
		exec (@sUpdateTriggerTextFirst)
		SET @sUpdateTriggerTextFirst='exec sp_settriggerorder @triggername = ''' + @sUpdateTriggerName +''', @order = ''last'', @stmttype = ''UPDATE'''
		exec (@sUpdateTriggerTextFirst)
	END
	else
	print 'no NonPrimaryKey'
END

--Create the Delete trigger
--set the insert trigger as last
IF @bExecute = 0
BEGIN
	print '-- delete trigger'
	PRINT @sDropDeleteTriggerText
	PRINT @sDeleteTriggerTextFirst + @sCRLF + ' GO ' + @sCRLF
	SET @sDeleteTriggerTextFirst='sp_settriggerorder @triggername = ''' + @sDeleteTriggerName +''', @order = ''last'', @stmttype = ''DELETE'''
	print @sDeleteTriggerTextFirst
END
else
BEGIN
	set @sDropDeleteTriggerText = Replace(@sDropDeleteTriggerText,@sCRLF+'GO'+@sCRLF,'')
	exec (@sDropDeleteTriggerText)
	set @sDeleteTriggerTextFirst = Replace(@sDeleteTriggerTextFirst,@sCRLF+'GO'+@sCRLF,'')
	exec (@sDeleteTriggerTextFirst)
	SET @sDeleteTriggerTextFirst='exec sp_settriggerorder @triggername = ''' + @sDeleteTriggerName +''', @order = ''last'', @stmttype = ''DELETE'''
	exec (@sDeleteTriggerTextFirst)
END



