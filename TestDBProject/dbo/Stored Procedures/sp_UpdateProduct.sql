CREATE PROCEDURE [dbo].[sp_UpdateProduct] 
 @updateXML AS XML,
 @Operation AS VARCHAR(10)
AS 
  BEGIN 
      SET NOCOUNT ON ;
      BEGIN TRY 

		  DECLARE @RefProductID AS INT
		  DECLARE @AdvertiserCode AS NVARCHAR(10)='' 
		  DECLARE @AdvertiserName AS NVARCHAR(100)=''
		  DECLARE @ProductCode AS NVARCHAR(10)
		  DECLARE @ProductName AS NVARCHAR(100)='' 
		  DECLARE @ProductShortName AS NVARCHAR(100)='' 
		  DECLARE @CategoryCode AS NVARCHAR(10)=''
		  DECLARE @CategoryName AS NVARCHAR(100)=''
		  DECLARE @SubCategoryID AS INT
		  DECLARE @SubCategoryCode AS NVARCHAR(10)=''
		  DECLARE @SubCategoryName AS NVARCHAR(100)=''
		  DECLARE @TargetMarketID AS INT
		  DECLARE @seq AS NVARCHAR(10)=''
		  DECLARE @CreateDT AS NVARCHAR(10)=''
		  DECLARE @CreatedByID AS INT
		  DECLARE @ModifiedDT AS NVARCHAR(10)=''
		  DECLARE @ModifiedByID AS INT
		  DECLARE @EndDT AS NVARCHAR(10)=''
		  DECLARE @RetiredByID AS int
		  DECLARE @RetiredByUserName AS NVARCHAR(50)=''
		  
		  SELECT productupdatedetails.value('(RefProductID)[1]','INT') AS 'RefProductID', 
				productupdatedetails.value('(AdvertiserCode)[1]','NVARCHAR(10)') AS 'AdvertiserCode', 
				productupdatedetails.value('(AdvertiserName)[1]','NVARCHAR(100)') AS 'AdvertiserName', 
				productupdatedetails.value('(ProductCode)[1]','NVARCHAR(10)') AS 'ProductCode', 
				productupdatedetails.value('(ProductName)[1]', 'NVARCHAR(100)') AS 'ProductName',
				productupdatedetails.value('(ProductShortName)[1]', 'NVARCHAR(100)') AS 'ProductShortName',
				productupdatedetails.value('(SubCategoryID)[1]', 'INT') AS 'SubCategoryID',
				productupdatedetails.value('(CategoryCode)[1]', 'NVARCHAR(10)') AS 'CategoryCode',
				productupdatedetails.value('(CategoryName)[1]', 'NVARCHAR(100)') AS 'CategoryName',
				productupdatedetails.value('(SubCategoryCode)[1]', 'NVARCHAR(10)') AS 'SubCategoryCode',
				productupdatedetails.value('(SubCategoryName)[1]', 'NVARCHAR(100)') AS 'SubCategoryName',
				productupdatedetails.value('(TargetMarketID)[1]', 'INT') AS 'TargetMarketID',
				productupdatedetails.value('(CreatedDT)[1]', 'NVARCHAR(50)') AS 'CreateDT',
				productupdatedetails.value('(CreatedByID)[1]', 'INT') AS 'CreatedByID',
				productupdatedetails.value('(ModifiedDT)[1]', 'NVARCHAR(50)') AS 'ModifiedDT',
				productupdatedetails.value('(ModifiedByID)[1]', 'INT') AS 'ModifiedByID',
				productupdatedetails.value('(EndDate)[1]', 'NVARCHAR(50)') AS 'EndDT',
				productupdatedetails.value('(RetiredBy)[1]', 'NVARCHAR(50)') AS 'RetiredBy'
		  INTO   #updatetempval
		  FROM   @updateXML.nodes('ProductMaintenanceSearch') AS ProductUpdateProc(productupdatedetails) 

		  SELECT @RefProductID = RefProductID,
				@AdvertiserCode = AdvertiserCode, 
				@AdvertiserName = AdvertiserName,
				@ProductCode = ProductCode,
				@ProductName = ProductName,
				@ProductShortName = ProductShortName,
				@SubCategoryID = SubCategoryID,
				@CategoryCode = CategoryCode,
				@CategoryName = CategoryName,
				@SubCategoryCode = SubCategoryCode,
				@SubCategoryName = SubCategoryName,
				@TargetMarketID = TargetMarketID,
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
		  IF @TargetMarketID <=0
			 SET @TargetMarketID = NULL

		  IF @Operation = 'insert'
		  BEGIN
			 --IF EXISTS(SELECT TOP 1 * FROM RefSubCategory WHERE SubCategoryName = @SubCategoryName or SubCategoryShortName = @SubCategoryShortName)
				--RAISERROR ('sp_SubCategoryMaintenanceSearch',16,1,'SubCategoryName/SubCategoryShortName already exists')
			 --ELSE
			 --BEGIN

				INSERT INTO RefProduct(CTLegacyPRINSTCODE,CTLegacyPRCODE,ProductName,ProductShortName,SubCategoryID,TargetMarketID,CreatedDT
							 ,CreatedByID)
				SELECT AdvertiserCode,ProductCode,ProductName,ProductShortName,SubCategoryID,TargetMarketID, GETDATE(), @CreatedByID 
				FROM   #updatetempval 
			 --END
		  END
		  ELSE IF @Operation = 'update'
		  BEGIN
			 
			 --IF EXISTS(SELECT TOP 1 * FROM RefSubCategory WHERE (SubCategoryName = @SubCategoryName or SubCategoryShortName = @SubCategoryShortName) AND RefSubCategoryID <> @RefSubCategoryID)
				--    RAISERROR ('SubCategoryName/SubCategoryShortName already exists',16,1,'SubCategoryName/SubCategoryShortName already exists')
			 --ELSE
			 --BEGIN
			 print @RefProductID
				UPDATE RefProduct SET CTLegacyPRCODE = @ProductCode, ProductName = @ProductName,ProductShortName = @ProductShortName,
					   CTLegacyPRINSTCODE = @AdvertiserCode, SubCategoryID = @SubCategoryID,TargetMarketID = @TargetMarketID,
					   ModifiedDT = GETDATE(),ModifiedByID = @ModifiedByID, 
					   EndDate = @EndDT, RetiredByID = @RetiredByID
				WHERE RefProductID = @RefProductID
			 --END
		  END
		  ELSE IF @Operation = 'delete'
		  BEGIN
			 --DELETE FROM RefProduct WHERE RefProductID = @RefProductID
			 update RefProduct 
			 set EndDate = getdate()
			 where RefProductID = @RefProductID
		  END

		  DROP TABLE #updatetempval 
	   END TRY 
	   BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		  RAISERROR ('sp_UpdateSubCategory: %d: %s',16,1,@error,@message,@lineNo);
	   END CATCH 

END