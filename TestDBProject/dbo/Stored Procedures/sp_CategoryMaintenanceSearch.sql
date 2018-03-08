
CREATE PROCEDURE [dbo].[sp_CategoryMaintenanceSearch] 
 @SeachXML AS XML

AS 
  BEGIN 
      SET NOCOUNT ON ;
      BEGIN TRY 

		  DECLARE @CategoryID AS INT
		  DECLARE @Code AS NVARCHAR(10)
		  DECLARE @CategoryName AS NVARCHAR(50)='' 
		  DECLARE @CategoryShortName AS NVARCHAR(50)=''
		  DECLARE @Definition1 AS VARCHAR(1000) = ''
		  DECLARE @Definition2 AS VARCHAR(1000) = ''
		  DECLARE @IncludeRetired AS INT
		  DECLARE @CreateDT AS DateTime
		  DECLARE @CreatedByID AS INT
		  DECLARE @ModifiedDT AS DateTime
		  DECLARE @ModifiedByID AS INT
		  DECLARE @EndDT AS DateTime
		  DECLARE @SelectStmnt AS NVARCHAR(MAX)=''
		  DECLARE @Where AS NVARCHAR(MAX)
		  DECLARE @OrderBy AS NVARCHAR(250)='' 

		  SET @Where = ''
		  SET @OrderBy = ' ORDER BY CategoryName ASC'

		  SELECT Categorysearchdetails.value('(CategoryID)[1]','INT') AS 'CategoryID', 
				Categorysearchdetails.value('(Code)[1]','NVARCHAR(10)') AS 'Code', 
				Categorysearchdetails.value('(CategoryName)[1]', 'NVARCHAR(50)') AS 'CategoryName',
				Categorysearchdetails.value('(CategoryShortName)[1]', 'NVARCHAR(50)') AS 'CategoryShortName',
				Categorysearchdetails.value('(Definition1)[1]', 'NVARCHAR(1000)') AS 'Definition1',
				Categorysearchdetails.value('(Definition2)[1]', 'NVARCHAR(1000)') AS 'Definition2',
				Categorysearchdetails.value('(IncludeRetired)[1]', 'INT') AS 'IncludeRetired'

		  INTO   #searchtempval
		  FROM   @SeachXML.nodes('CategoryMaintenanceSearch') AS CategorySearchProc(Categorysearchdetails) 

		  SELECT @CategoryID = CategoryID, 
				@Code = Code,
				@CategoryName = CategoryName,
				@CategoryShortName = CategoryShortName,
				@IncludeRetired = IncludeRetired,
				@Definition1 = Definition1,
				@Definition2 = Definition2
		  FROM   #searchtempval 

		  SET @SelectStmnt=' SELECT RefCategoryID,CategoryName,CategoryShortName,CTLegacyPCATCODE as Code,CTLegacyPSUPCODE as SuperCat,CreateDT
						  ,CreatedByID,ModifiedDT,ModifiedByID, isnull(Definition1,'''') AS Definition1 , isnull(Definition2,'''') AS Definition2 
						  ,endDT, c.RetiredByID, u.username as RetiredByUsername
						  FROM RefCategory c LEFT JOIN [user] u on c.RetiredByID = u.UserID
						  WHERE 1=1 '

		  IF( @CategoryName <> '' ) 
		  BEGIN 
			 SET @SelectStmnt=@SelectStmnt + ' AND CategoryName like ''%' + REPLACE(@CategoryName,'''','''''') + '%''' 
		  END 
		  IF( @CategoryShortName <> '' ) 
		  BEGIN 
			 SET @SelectStmnt=@SelectStmnt + ' AND CategoryShortName like  ''%'+ REPLACE(@CategoryShortName,'''','''''') + '%''' 
		  END 
		  IF(@Code <> '')
		  BEGIN 	
			 SET @SelectStmnt=@SelectStmnt   + '  AND CTLegacyPCATCODE = '''  + @Code +  '''' 
		  END 
		  IF(@Definition1 <> '')
		  BEGIN 	
			 SET @SelectStmnt=@SelectStmnt   + '  AND Definition1 like ''%'  + REPLACE(@Definition1,'''','''''') +  '%''' 
		  END 
		  IF(@Definition2 <> '')
		  BEGIN 	
			 SET @SelectStmnt=@SelectStmnt   + '  AND Definition2 like ''%'  + REPLACE(@Definition2,'''','''''') +  '%''' 
		  END 
		  IF(@IncludeRetired = 0)
			 SET @SelectStmnt=@SelectStmnt   + ' AND (c.EndDT is null or c.EndDT ='''')'
			 
		  SET @SelectStmnt = @SelectStmnt + @OrderBy

		  DROP TABLE #searchtempval 
		  PRINT @SelectStmnt 
		  EXEC SP_EXECUTESQL @SelectStmnt  
	   END TRY 

	   BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		  RAISERROR ('sp_CategoryMaintenanceSearch: %d: %s',16,1,@error,@message,@lineNo);
	   END CATCH 

END