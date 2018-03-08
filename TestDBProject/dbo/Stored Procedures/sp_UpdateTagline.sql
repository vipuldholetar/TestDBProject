CREATE PROCEDURE [dbo].[sp_UpdateTagline] 
 @updateXML AS XML,
 @Operation AS VARCHAR(10)
AS 
  BEGIN 
      SET NOCOUNT ON ;
      BEGIN TRY 

		  DECLARE @RefTaglineID AS INT
		  DECLARE @AdvertiserID AS INT
		  DECLARE @AdvertiserCode AS NVARCHAR(100)
		  DECLARE @AdvertiserName AS NVARCHAR(100)
		  DECLARE @Tagline AS NVARCHAR(1000)
		  DECLARE @Display  AS INT
		  DECLARE @CreateDT AS NVARCHAR(10)=''
		  DECLARE @CreateByID AS INT
		  DECLARE @ModifiedDT AS NVARCHAR(10)=''
		  DECLARE @ModifiedByID AS INT
		  
		  SELECT taglineupdatedetails.value('(RefTaglineID)[1]','INT') AS 'RefTaglineID', 
				taglineupdatedetails.value('(AdvertiserID)[1]','INT') AS 'AdvertiserID', 
				taglineupdatedetails.value('(AdvertiserCode)[1]','NVARCHAR(100)') AS 'AdvertiserCode', 
				taglineupdatedetails.value('(AdvertiserName)[1]','NVARCHAR(100)') AS 'AdvertiserName', 
				taglineupdatedetails.value('(Tagline)[1]','NVARCHAR(1000)') AS 'Tagline', 
				taglineupdatedetails.value('(Display)[1]', 'NVARCHAR(2)') AS 'Display',
				taglineupdatedetails.value('(CreatedDT)[1]', 'NVARCHAR(50)') AS 'CreateDT',
				taglineupdatedetails.value('(CreateByID)[1]', 'INT') AS 'CreateByID',
				taglineupdatedetails.value('(ModifiedDT)[1]', 'NVARCHAR(50)') AS 'ModifiedDT',
				taglineupdatedetails.value('(ModifiedByID)[1]', 'INT') AS 'ModifiedByID'
		  INTO   #updatetempval
		  FROM   @updateXML.nodes('TaglineMaintenanceSearch') AS TaglineUpdateProc(taglineupdatedetails) 

		  SELECT @RefTaglineID = RefTaglineID,
				@AdvertiserID = AdvertiserID,
				@AdvertiserCode = AdvertiserCode, 
				@AdvertiserName = AdvertiserName,
				@Tagline = Tagline,
				@Display = CASE WHEN LTRIM(RTRIM(Display)) = 'Y' THEN 1 ELSE 0 END,
				@CreateDT = CreateDT, @CreateByID = CreateByID,
				@ModifiedDT=ModifiedDT, @ModifiedByID=ModifiedByID
		  FROM   #updatetempval 
		  		  
		  IF ISDATE(@CreateDT) <> 1
			 SET @CreateDT = NULL
		  IF ISDATE(@ModifiedDT) <> 1
			 SET @ModifiedDT = NULL
			 
		  IF @CreateByID <=0
			 SET @CreateByID = NULL
		  IF @ModifiedByID <=0
			 SET @ModifiedByID = NULL

		  IF @Operation = 'insert'
		  BEGIN
			 --IF EXISTS(SELECT TOP 1 * FROM RefSubCategory WHERE SubCategoryName = @SubCategoryName or SubCategoryShortName = @SubCategoryShortName)
				--RAISERROR ('sp_SubCategoryMaintenanceSearch',16,1,'SubCategoryName/SubCategoryShortName already exists')
			 --ELSE
			 --BEGIN
				INSERT INTO RefTagline(AdvertiserID,Tagline,Display,CreatedDT,CreateByID)
				SELECT @AdvertiserID,@Tagline,@Display, GETDATE(), @CreateByID 
				FROM   #updatetempval 
			 --END
		  END
		  ELSE IF @Operation = 'update'
		  BEGIN
			 
			 --IF EXISTS(SELECT TOP 1 * FROM RefSubCategory WHERE (SubCategoryName = @SubCategoryName or SubCategoryShortName = @SubCategoryShortName) AND RefSubCategoryID <> @RefSubCategoryID)
				--    RAISERROR ('SubCategoryName/SubCategoryShortName already exists',16,1,'SubCategoryName/SubCategoryShortName already exists')
			 --ELSE
			 --BEGIN
				UPDATE RefTagline SET AdvertiserID = @AdvertiserID, Tagline = @Tagline,Display = @Display,
					   ModifiedDT = GETDATE(),ModifiedByID = @ModifiedByID
				WHERE RefTaglineID = @RefTaglineID
			 --END
		  END
		  ELSE IF @Operation = 'delete'
		  BEGIN
			 DELETE FROM RefTagline WHERE RefTaglineID = @RefTaglineID
		  END

		  DROP TABLE #updatetempval 
	   END TRY 
	   BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		  RAISERROR ('sp_UpdateTagline: %d: %s',16,1,@error,@message,@lineNo);
	   END CATCH 

END