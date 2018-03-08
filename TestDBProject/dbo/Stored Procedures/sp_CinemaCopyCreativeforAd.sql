
-- ==========================================================================================
-- Author			: Karunakar
-- Create date		: 20th July 2015
-- Description		: This stored procedure is used to create a New creative file for Cinema
-- Execution Process: sp_CinemaCopyCreativeforAd 8072
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
-- ==========================================================================================
CREATE PROCEDURE [dbo].[sp_CinemaCopyCreativeforAd]
	@AdId int
AS
BEGIN
    declare @oldcreativemasterid int
	declare @newcreativemasterid int

       BEGIN TRY
			BEGIN TRANSACTION
				   SELECT @oldcreativemasterid=PK_Id FROM [Creative] WHERE [AdId]=@AdId and PrimaryIndicator=1
				   print (@oldcreativemasterid)
				   -- Insert creative as per primary creative indicator
				   INSERT INTO [Creative]    
				   SELECT [AdId]
				  ,[SourceOccurrenceId]
				  ,[EnvelopId]
				  ,PrimaryIndicator
				  ,[PrimaryQuality]
				  ,[CreativeType]
				  ,[StatusId]
				  ,[PullPageCount]
				  ,[Weight]
				  ,[FormName]
				  ,[CheckInOccrncs]
				  ,[SpReviewStatusId]
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
				  ,[Cini]
				  ,[Erin]
				  ,[Init]
				  ,[AssetThmbnlName]
				  ,[ThmbnlRep]
				  ,[LegacyThmbnlAssetName]
				  ,[ThmbnlFileType]
				  , getdate()
			    FROM [Creative] WHERE PK_Id=@oldcreativemasterid

			    SELECT @newcreativemasterid=scope_identity();

				PRINT(@newcreativemasterid)
				--Insert into creativedetailCIN table
			    INSERT INTO creativedetailCIN([CreativeMasterID],CreativeAssetName,creativeRepository,LegacyCreativeAssetname,CreativeFileType) 
			    SELECT @NewCreativeMasterID,CreativeAssetname,creativeRepository,LegacyCreativeAssetname,CreativeFileType 
			    FROM creativedetailCIN WHERE [CreativeMasterID]=@oldcreativemasterid

				--Updating Creative Master and Pattern Master tables
			    UPDATE [Creative] SET PrimaryIndicator=0 WHERE PK_Id=@oldcreativemasterid

				UPDATE [Pattern] SET [CreativeID]=  @NewCreativeMasterID WHERE [AdID]=@AdId and [CreativeID]= @oldcreativemasterid
		   COMMIT TRANSACTION
	   END TRY 

     BEGIN CATCH 
        DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
        SELECT @error = Error_number(),@message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('sp_CinemaCopyCreativeforAd: %d: %s',16,1,@error,@message,@lineNo);
		ROLLBACK TRANSACTION
    END CATCH 

END