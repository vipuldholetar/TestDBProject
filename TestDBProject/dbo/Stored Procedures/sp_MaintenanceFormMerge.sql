CREATE PROCEDURE [dbo].[sp_MaintenanceFormMerge]
    @TableName varchar(100),
    @FromCode varchar(100),
    @ToCode varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
	   DECLARE @oldID INT
	   DECLARE @NewID INT
	   DECLARE @AdvertiserID INT

	   IF LTRIM(RTRIM(@FromCode)) <> '' AND LTRIM(RTRIM(@ToCode)) <> ''
	   BEGIN
		  IF @TableName = 'Category'
		  BEGIN
			 SELECT @oldID = RefCategoryID FROM RefCategory WHERE CTLegacyPCATCODE = @FromCode
			 SELECT @NewID = RefCategoryID FROM RefCategory WHERE CTLegacyPCATCODE = @ToCode
			 IF @NewID IS NOT NULL
			 BEGIN
				UPDATE RefSubCategory SET CategoryID = @NewID, CTLegacyPSPCATCODE = @ToCode WHERE CategoryID = @oldID
				UPDATE PromotionStaging SET CategoryID = @NewID WHERE CategoryID = @oldID
				
				DELETE FROM RefCategory WHERE RefCategoryID = @oldID
			 END
		  END
		  ELSE IF @TableName = 'SubCategory'
		  BEGIN
			 SELECT @oldID = RefSubCategoryID FROM RefSubCategory WHERE SubCategoryCODE = @FromCode
			 SELECT @NewID = RefSubCategoryID FROM RefSubCategory WHERE SubCategoryCODE = @ToCode
			 IF @NewID IS NOT NULL
			 BEGIN
				UPDATE RefProduct SET SubCategoryID = @NewID, CTLegacyPRSBCATCODE = @ToCode WHERE SubCategoryID = @oldID

				DELETE FROM RefSubCategory WHERE RefSubCategoryID = @oldID
			 END
		  END
		  ELSE IF @TableName = 'Product'
		  BEGIN
			 SELECT @oldID = RefProductID FROM RefProduct WHERE CTLegacyPRCODE = @FromCode
			 SELECT @NewID = RefProductID, @AdvertiserID = AdvertiserID FROM RefProduct WHERE CTLegacyPRCODE = @ToCode
			 IF @NewID IS NOT NULL
			 BEGIN
				UPDATE Ad SET ProductID = @NewID, AdvertiserID = @AdvertiserID WHERE ProductID = @oldID
				UPDATE PromotionStaging SET ProductID = @NewID, AdvertiserID = @AdvertiserID WHERE ProductID = @oldID

				DELETE FROM RefProduct WHERE RefProductID = @oldID
			 END
		  END
		  ELSE IF @TableName = 'Tagline'
		  BEGIN
			 UPDATE Ad SET TaglineId = @ToCode WHERE TaglineId = @FromCode

			 DELETE FROM RefTagline WHERE RefTaglineID = @FromCode
		  END	   
	   END
    END TRY
    BEGIN CATCH
	   DECLARE @ERROR   INT, 
		  @MESSAGE VARCHAR(4000), 
		  @LINENO  INT 

	   SELECT @ERROR = Error_number(),@MESSAGE = Error_message(),@LINENO = Error_line() 
	   RAISERROR ('sp_MaintenanceFormMerge: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
    END CATCH
  
END