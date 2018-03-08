

-- =========================================================================================================
-- Author			: RP
-- Create date		: 04/18/2015
-- Description		: This stored procedure is used to create a creative
-- Execution Process: sp_RadioCopyCreativeForAd 8072
-- Updated By		: Update By Karunakar on 3rd july 2015,Changing Insert data for creativedetailra
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 						
-- ========================================================================================================
CREATE PROCEDURE [dbo].[sp_RadioCopyCreativeForAd]
	@pADID int
AS
BEGIN
    declare @oldcreativemasterid int
  declare @newcreativemasterid int

       BEGIN Try
	   BEGIN TRANSACTION 
					   SELECT @oldcreativemasterid=PK_Id FROM [Creative] WHERE [AdId]=@padid and PrimaryIndicator=1
					   print (@oldcreativemasterid)
					   -- Insert creative as per primary creative indicator
					   INSERT INTO [Creative]([AdId]
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
					  ,DistDate
					  ,[CINI]
					  ,[ERIN]
					  ,[INIT]
					  ,AssetThmbnlName
					  ,ThmbnlRep
					  ,LegacyThmbnlAssetName
					  ,ThmbnlFileType
					  ,CreatedDT)
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
					  ,DistDate
					  ,[CINI]
					  ,[ERIN]
					  ,[INIT]
					  ,AssetThmbnlName
					  ,ThmbnlRep
					  ,LegacyThmbnlAssetName
					  ,ThmbnlFileType
					  ,Getdate()
				  FROM [Creative] where PK_Id=@oldcreativemasterid

				SELECT @newcreativemasterid=scope_identity();
				print(@newcreativemasterid)
				
				INSERT INTO [CreativeDetailRA]([CreativeID],AssetName,Rep,LegacyAssetName,FileType) 
				SELECT @NewCreativeMasterID,AssetName,Rep,LegacyAssetName,FileType FROM [CreativeDetailRA] WHERE [CreativeID]=@oldcreativemasterid

				UPDATE [Creative] set PrimaryIndicator=0 where PK_Id=@oldcreativemasterid
				UPDATE [Pattern] set [CreativeID]=  @NewCreativeMasterID where [AdID]=@pADID and [CreativeID]= @oldcreativemasterid
				COMMIT TRANSACTION
	   END TRY 
     BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
			SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
			RAISERROR ('sp_RadioCopyCreativeForAd: %d: %s',16,1,@error,@message,@lineNo);
			ROLLBACK TRANSACTION
    END CATCH 
END
