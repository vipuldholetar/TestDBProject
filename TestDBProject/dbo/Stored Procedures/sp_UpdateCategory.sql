CREATE PROCEDURE [dbo].[sp_UpdateCategory] 
 @updateXML AS XML,
 @Operation AS VARCHAR(10)
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
		  DECLARE @CreateDT AS NVARCHAR(50)=''
		  DECLARE @CreatedByID AS INT
		  DECLARE @ModifiedDT AS NVARCHAR(50)=''
		  DECLARE @ModifiedByID AS INT
		  DECLARE @EndDT AS NVARCHAR(50)=''
		  DECLARE @RetiredByID AS int
		  DECLARE @RetiredByUserName AS NVARCHAR(50)=''
		  
		  SELECT categoryupdatedetails.value('(CategoryID)[1]','INT') AS 'CategoryID', 
				categoryupdatedetails.value('(Code)[1]','NVARCHAR(10)') AS 'Code', 
				categoryupdatedetails.value('(CategoryName)[1]', 'NVARCHAR(50)') AS 'CategoryName',
				categoryupdatedetails.value('(CategoryShortName)[1]', 'NVARCHAR(50)') AS 'CategoryShortName',
				categoryupdatedetails.value('(Definition1)[1]', 'NVARCHAR(1000)') AS 'Definition1',
				categoryupdatedetails.value('(Definition2)[1]', 'NVARCHAR(1000)') AS 'Definition2',
				categoryupdatedetails.value('(CreateDT)[1]', 'NVARCHAR(50)') AS 'CreateDT',
				categoryupdatedetails.value('(CreatedByID)[1]', 'INT') AS 'CreatedByID',
				categoryupdatedetails.value('(ModifiedDT)[1]', 'NVARCHAR(50)') AS 'ModifiedDT',
				categoryupdatedetails.value('(ModifiedByID)[1]', 'INT') AS 'ModifiedByID',
				categoryupdatedetails.value('(endDT)[1]', 'NVARCHAR(50)') AS 'EndDT',
				categoryupdatedetails.value('(RetiredBy)[1]', 'NVARCHAR(50)') AS 'RetiredBy'
		  INTO   #updatetempval
		  FROM   @updateXML.nodes('CategoryMaintenanceSearch') AS CategoryUpdateProc(categoryupdatedetails) 

		  SELECT @CategoryID = CategoryID, 
				@Code = Code, @CategoryName = CategoryName, @CategoryShortName = CategoryShortName,
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
		  IF LTRIM(RTRIM(@Definition1)) = ''
			 SET @Definition1 = NULL
		  IF LTRIM(RTRIM(@Definition2)) = ''
			 SET @Definition2 = NULL

		  IF @Operation = 'insert'
		  BEGIN
			 --IF EXISTS(SELECT TOP 1 * FROM RefCategory WHERE CategoryName = @CategoryName or CategoryShortName = @CategoryShortName)
				--RAISERROR ('sp_CategoryMaintenanceSearch',16,1,'CategoryName/CategoryShortName already exists')
			 --ELSE
			 --BEGIN
				INSERT INTO RefCategory(CategoryName,CategoryShortName,CTLegacyPCATCODE
								    ,Definition1,Definition2,CreateDT,CreatedByID)
				SELECT CategoryName,CategoryShortName,Code,Definition1,Definition2,GETDATE()
							 ,CreatedByID FROM #updatetempval
			 --END
		  END
		  ELSE IF @Operation = 'update'
		  BEGIN
			 --IF EXISTS(SELECT TOP 1 * FROM RefCategory WHERE (CategoryName = @CategoryName or CategoryShortName = @CategoryShortName) AND RefCategoryID <> @CategoryID)
				--    RAISERROR ('sp_CategoryMaintenanceSearch',16,1,'CategoryName/CategoryShortName already exists')
			 --ELSE
			 --BEGIN
				UPDATE RefCategory SET CategoryName = @CategoryName, CategoryShortName = @CategoryShortName,
					  Definition1 = @Definition1, Definition2 = @Definition2, CTLegacyPCATCODE = @Code, ModifiedDT = GETDATE(),
					   ModifiedByID = @ModifiedByID, EndDT = @EndDT, RetiredByID = @RetiredByID
				WHERE RefCategoryID = @CategoryID
			 --END
		  END
		  ELSE IF @Operation = 'delete'
		  BEGIN
			 DELETE FROM RefCategory WHERE RefCategoryID = @CategoryID
		  END

		  DROP TABLE #updatetempval 
		  --PRINT @SelectStmnt 
		  --EXEC SP_EXECUTESQL @SelectStmnt  
	   END TRY 
	   BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		  RAISERROR ('sp_UpdateCategory: %d: %s',16,1,@error,@message,@lineNo);
	   END CATCH 

END