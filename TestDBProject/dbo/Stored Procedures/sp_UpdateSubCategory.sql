CREATE PROCEDURE [dbo].[sp_UpdateSubCategory] 
 @updateXML AS XML,
 @Operation AS VARCHAR(10)
AS 
  BEGIN 
      SET NOCOUNT ON ;
      BEGIN TRY 

		  DECLARE @RefSubCategoryID AS INT
		  DECLARE @CategoryID AS INT
		  DECLARE @SubCategoryCode AS NVARCHAR(10)
		  DECLARE @SubCategoryName AS NVARCHAR(50)='' 
		  DECLARE @SubCategoryShortName AS NVARCHAR(50)=''
		  DECLARE @Definition1 AS NVARCHAR(1000)=''
		  DECLARE @Definition2 AS NVARCHAR(1000)=''
		  DECLARE @CreateDT AS NVARCHAR(50)=''
		  DECLARE @CreatedByID AS INT
		  DECLARE @ModifiedDT AS NVARCHAR(50)=''
		  DECLARE @ModifiedByID AS INT
		  DECLARE @EndDT AS NVARCHAR(50)=''
		  DECLARE @RetiredByID AS int
		  DECLARE @RetiredByUserName AS NVARCHAR(50)=''
		  DECLARE @SelectStmnt AS NVARCHAR(MAX)=''

		  SELECT subcategoryupdatedetails.value('(RefSubCategoryID)[1]','INT') AS 'RefSubCategoryID', 
				subcategoryupdatedetails.value('(CategoryID)[1]','INT') AS 'CategoryID',
				subcategoryupdatedetails.value('(SubCategoryCode)[1]','NVARCHAR(10)') AS 'SubCategoryCode', 
				subcategoryupdatedetails.value('(SubCategoryName)[1]', 'NVARCHAR(50)') AS 'SubCategoryName',
				subcategoryupdatedetails.value('(SubCategoryShortName)[1]', 'NVARCHAR(50)') AS 'SubCategoryShortName',
				subcategoryupdatedetails.value('(Definition1)[1]', 'NVARCHAR(1000)') AS 'Definition1',
				subcategoryupdatedetails.value('(Definition2)[1]', 'NVARCHAR(1000)') AS 'Definition2',
				subcategoryupdatedetails.value('(CreateDT)[1]', 'NVARCHAR(50)') AS 'CreateDT',
				subcategoryupdatedetails.value('(CreatedByID)[1]', 'INT') AS 'CreatedByID',
				subcategoryupdatedetails.value('(ModifiedDT)[1]', 'NVARCHAR(50)') AS 'ModifiedDT',
				subcategoryupdatedetails.value('(ModifiedByID)[1]', 'INT') AS 'ModifiedByID',
				subcategoryupdatedetails.value('(endDT)[1]', 'NVARCHAR(50)') AS 'EndDT',
				subcategoryupdatedetails.value('(RetiredBy)[1]', 'NVARCHAR(50)') AS 'RetiredBy'
		  INTO   #updatetempval
		  FROM   @updateXML.nodes('SubCategoryMaintenanceSearch') AS SubCategoryUpdateProc(subcategoryupdatedetails) 

		  SELECT @RefSubCategoryID = RefSubCategoryID, 
				@CategoryID = CategoryID,
				@SubCategoryCode = SubCategoryCode, 
				@SubCategoryName = SubCategoryName, 
				@SubCategoryShortName = SubCategoryShortName,
				@Definition1 = Definition1, @Definition2 = Definition2,
				@CreateDT = CreateDT,@CreatedByID = CreatedByID,
				@ModifiedDT=ModifiedDT,@ModifiedByID=ModifiedByID,
				@EndDT = EndDT, @RetiredByUserName = RetiredBy
		  FROM   #updatetempval 

		  IF @RetiredByUserName <> ''
			 SELECT @RetiredByID = UserID FROM [user] where Username=@RetiredByUserName
		  
		  IF ISDATE(@EndDT) <> 1
			 SET @EndDT = NULL
		  IF ISDATE(@CreateDT) <> 1
			 SET @CreateDT = NULL
		  IF ISDATE(@ModifiedDT) <> 1
			 SET @ModifiedDT = NULL
			 
		  IF @CreatedByID <=0
			 SET @CreatedByID = NULL
		  IF @ModifiedByID <=0
			 SET @ModifiedByID = NULL
		  IF @RetiredByID <=0
			 SET @RetiredByID = NULL
		  IF @CategoryID <=0
			 SET @CategoryID = NULL
		  IF LTRIM(RTRIM(@Definition1)) = ''
			 SET @Definition1 = NULL
		  IF LTRIM(RTRIM(@Definition2)) = ''
			 SET @Definition2 = NULL

		  IF @Operation = 'insert'
		  BEGIN
			 --IF EXISTS(SELECT TOP 1 * FROM RefSubCategory WHERE SubCategoryName = @SubCategoryName or SubCategoryShortName = @SubCategoryShortName)
				--RAISERROR ('sp_SubCategoryMaintenanceSearch',16,1,'SubCategoryName/SubCategoryShortName already exists')
			 --ELSE
			 --BEGIN
				INSERT INTO RefSubCategory(SubCategoryName,SubCategoryShortName,SubCategoryCode,CategoryID,Definition1,Definition2,CreatedDT
							 ,CreatedByID)
				SELECT SubCategoryName,SubCategoryShortName,SubCategoryCode,CategoryID,Definition1,Definition2,GETDATE()
							 ,CreatedByID FROM #updatetempval
			 --END
		  END
		  ELSE IF @Operation = 'update'
		  BEGIN
			 
			 --IF EXISTS(SELECT TOP 1 * FROM RefSubCategory WHERE (SubCategoryName = @SubCategoryName or SubCategoryShortName = @SubCategoryShortName) AND RefSubCategoryID <> @RefSubCategoryID)
				--    RAISERROR ('SubCategoryName/SubCategoryShortName already exists',16,1,'SubCategoryName/SubCategoryShortName already exists')
			 --ELSE
			 --BEGIN
				
				UPDATE RefSubCategory SET SubCategoryName = @SubCategoryName, SubCategoryShortName = @SubCategoryShortName,
					   SubCategoryCode = @SubCategoryCode, CategoryID = @CategoryID, Definition1 = @Definition1,
					   Definition2 = @Definition2, ModifiedDT = GETDATE(),ModifiedByID = @ModifiedByID, 
					   EndDT = @EndDT, RetiredByID = @RetiredByID
				WHERE RefSubCategoryID = @RefSubCategoryID
			 --END
		  END
		  ELSE IF @Operation = 'delete'
		  BEGIN
			 DELETE FROM RefSubCategory WHERE RefSubCategoryID = @RefSubCategoryID
		  END

		  DROP TABLE #updatetempval 
		  --PRINT @SelectStmnt 
		  --EXEC SP_EXECUTESQL @SelectStmnt  
	   END TRY 
	   BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		  RAISERROR ('sp_UpdateSubCategory: %d: %s',16,1,@error,@message,@lineNo);
	   END CATCH 

END