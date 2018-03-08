
-- =================================================================================================
-- Author			: KARUNAKAR
-- Create date		: 28th Sep 2015
-- Description		: This stored procedure is used to create a New creative file for Online Video
-- Execution Process: sp_OnlineVideoCopyCreativeforAd 8072
-- Updated By		: 
-- ================================================================================================
CREATE PROCEDURE [dbo].[sp_OnlineVideoCopyCreativeforAd]
	@AdId INTEGER
AS
BEGIN
    DECLARE @oldcreativemasterid INTEGER
	DECLARE @newcreativemasterid INTEGER

       BEGIN TRY
			   BEGIN TRANSACTION
					   SELECT @oldcreativemasterid=PK_Id FROM [Creative] WHERE [AdId]=@AdId and PrimaryIndicator=1
					   PRINT (@oldcreativemasterid)
					   -- Insert creative as per primary creative indicator
					   INSERT INTO [Creative]
					   SELECT [AdId]
					  ,[SourceOccurrenceId]
					  ,[EnvelopId]
					  ,PrimaryIndicator
					  ,PrimaryQuality
					  ,[CreativeType]
					  ,[StatusID]
					  ,[PullPageCount]
					  ,[Weight]
					  ,[FormName]
					  ,CheckInOccrncs
					  ,[SPReviewStatusId]
					  ,[EntryInd]
					  ,[ParentVehicleId]
					  ,[FilterMatches]
					  ,[SourceMatchInd]
					  ,[TypeId]
					  ,[FlashInd]
					  ,[CouponInd]
					  ,[Priority]
					  ,[NationalInd]
					  ,[DistDate]
					  ,[CINI]
					  ,[ERIN]
					  ,[INIT]
					  ,AssetThmbnlName
					  ,ThmbnlRep
					  ,LegacyThmbnlAssetName
					  ,ThmbnlFileType
						FROM [Creative] WHERE PK_Id=@oldcreativemasterid
						SELECT @newcreativemasterid=scope_identity();
						PRINT(@newcreativemasterid)
						--Inserting into CreativeDetailONV for
				  INSERT INTO CreativeDetailONV([CreativeMasterID],CreativeAssetName,creativeRepository,LegacyAssetName,CreativeFileType,CreativeFileSize,[CreativeFileDT]) 
							 SELECT @NewCreativeMasterID,CreativeAssetname,creativeRepository,LegacyAssetName,CreativeFileType,CreativeFileSize,GETDATE() 
				  FROM  CreativeDetailONV WHERE [CreativeMasterID]=@oldcreativemasterid

				UPDATE [Creative] SET PrimaryIndicator=0 WHERE PK_Id=@oldcreativemasterid
				UPDATE [Pattern] SET [CreativeID]=  @NewCreativeMasterID WHERE [AdID]=@AdId and [CreativeID]= @oldcreativemasterid
			COMMIT TRANSACTION
	   END TRY 
     BEGIN CATCH 
        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('sp_OnlineVideoCopyCreativeforAd: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
    END CATCH 

END
