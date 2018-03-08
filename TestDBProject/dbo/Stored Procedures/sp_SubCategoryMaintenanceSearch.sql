CREATE PROCEDURE [dbo].[sp_SubCategoryMaintenanceSearch] 
 @SeachXML AS XML

AS 
  BEGIN 
      SET NOCOUNT ON ;
      BEGIN TRY 
	 
		  DECLARE @RefSubCategoryID AS INT
		  DECLARE @CategoryCode AS NVARCHAR(10)
		  DECLARE @SubCategoryCode AS NVARCHAR(10)
		  DECLARE @SubCategoryName AS NVARCHAR(50)='' 
		  DECLARE @SubCategoryShortName AS NVARCHAR(50)=''
		  DECLARE @CreateDT AS DateTime
		  DECLARE @CreatedByID AS INT
		  DECLARE @ModifiedDT AS DateTime
		  DECLARE @ModifiedByID AS INT
		  DECLARE @EndDT AS DateTime
		  DECLARE @IncludeRetired  AS INT
		  DECLARE @SelectStmnt AS NVARCHAR(MAX)=''
		  DECLARE @Where AS NVARCHAR(MAX)
		  DECLARE @OrderBy AS NVARCHAR(250)='' 

		  SET @Where = ''
		  SET @OrderBy = ' ORDER BY SubCategoryName ASC'

		  SELECT SubCategorysearchdetails.value('(RefSubCategoryID)[1]','INT') AS 'RefSubCategoryID', 
				SubCategorysearchdetails.value('(CategoryCode)[1]','NVARCHAR(10)') AS 'CategoryCode', 
				SubCategorysearchdetails.value('(SubCategoryCode)[1]','NVARCHAR(10)') AS 'SubCategoryCode', 
				SubCategorysearchdetails.value('(SubCategoryName)[1]', 'NVARCHAR(50)') AS 'SubCategoryName',
				SubCategorysearchdetails.value('(SubCategoryShortName)[1]', 'NVARCHAR(50)') AS 'SubCategoryShortName',
				SubCategorysearchdetails.value('(IncludeRetired)[1]', 'INT') AS 'IncludeRetired'

		  INTO   #searchtempval
		  FROM   @SeachXML.nodes('SubCategoryMaintenanceSearch') AS SubCategorySearchProc(SubCategorysearchdetails) 

		  SELECT @RefSubCategoryID = RefSubCategoryID, 
				@CategoryCode = CategoryCode,
				@SubCategoryCode = SubCategoryCode,
				@SubCategoryName = SubCategoryName,
				@SubCategoryShortName = SubCategoryShortName,
				@IncludeRetired = IncludeRetired
		  FROM   #searchtempval 

		  SET @SelectStmnt=' SELECT sc.RefSubCategoryID,sc.SubCategoryName,sc.SubCategoryShortName,sc.SubCategoryCode,sc.CategoryID, c.CategoryName,c.CTLegacyPCATCODE AS CategoryCode
						  ,sc.CreatedDT,sc.CreatedByID,sc.ModifiedDT,sc.ModifiedByID,sc.endDT, 
						  isnull(sc.Definition1,'''') AS Definition1 , isnull(sc.Definition2,'''') AS Definition2 , u.username as RetiredByUsername
						  FROM RefSubCategory sc LEFT JOIN RefCategory c ON c.RefCategoryID = sc.CategoryID LEFT JOIN [user] u on sc.RetiredByID = u.UserID
						  WHERE 1=1 '

		  IF( @SubCategoryName <> '' ) 
		  BEGIN 
			 SET @SelectStmnt=@SelectStmnt + ' AND sc.SubCategoryName like ''%' + REPLACE(@SubCategoryName,'''','''''') + '%''' 
		  END 
		  IF( @SubCategoryShortName <> '' ) 
		  BEGIN 
			 SET @SelectStmnt=@SelectStmnt + ' AND sc.SubCategoryShortName like  ''%'+ REPLACE(@SubCategoryShortName,'''','''''') + '%''' 
		  END 
		  IF( @SubCategoryCode <> '')
		  BEGIN 	
			 SET @SelectStmnt=@SelectStmnt   + ' AND sc.SubCategoryCode = '''  + @SubCategoryCode +  '''' 
		  END 
		  IF( @CategoryCode <> '')
		  BEGIN 	
			 SET @SelectStmnt=@SelectStmnt   + ' AND c.CTLegacyPCATCODE = '''  + @CategoryCode +  '''' 
		  END 
		  IF(@IncludeRetired = 0)
			 SET @SelectStmnt=@SelectStmnt   + ' AND (sc.EndDT is null or sc.EndDT ='''')'
					
		  SET @SelectStmnt = @SelectStmnt + @OrderBy

		  DROP TABLE #searchtempval 
		  PRINT @SelectStmnt 
		  EXEC SP_EXECUTESQL @SelectStmnt  
	   END TRY 

	   BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		  RAISERROR ('sp_SubCategoryMaintenanceSearch: %d: %s',16,1,@error,@message,@lineNo);
	   END CATCH 

END