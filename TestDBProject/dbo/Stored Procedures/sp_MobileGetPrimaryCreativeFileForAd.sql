
-- ===================================================================================================
-- Author				: Karunakar
-- Create date			: 5th October 2015
-- Description			: Get Mobile Primary Creative File from CreativeDetailMOB for Mobile
-- Execution Process	: [dbo].[sp_MobileGetPrimaryCreativeFileForAd] 8378
-- Updated By			:  Karunakar on 20th Oct 2015,Adding CreativeFiletype Selection in Query
-- ===================================================================================================
CREATE PROCEDURE [dbo].[sp_MobileGetPrimaryCreativeFileForAd]
(
@Adid INT
)
AS
BEGIN
	SET NOCOUNT ON;
         BEGIN TRY
			SELECT Top 1 [Creative].PK_Id AS Creativemasterid,CreativeDetailmob.[CreativeDetailMOBID] As CreativeDetailId,[Creative].PrimaryIndicator AS Primarycreativeindicator,
			CreativeDetailmob.CreativeRepository+CreativeDetailmob.CreativeAssetName AS CreativeFilePath,
			CreativeDetailmob.CreativeRepository+CreativeDetailmob.CreativeAssetName AS PrimarySource,
			cast(CreativeDetailmob.[CreativeDetailMOBID] as varchar)+'-'+CreativeDetailmob.CreativeRepository+CreativeDetailmob.CreativeAssetName as DetailIDwithFilepath,
			CreativeDetailmob.CreativeFileType
			FROM [Creative] 
			inner join CreativeDetailmob on [Creative].PK_Id=CreativeDetailmob.[CreativeMasterID] and [Creative].[AdId]=@Adid
			and [Creative].PrimaryIndicator=1
          END TRY 
		   BEGIN CATCH 
				DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT
				SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
				RAISERROR ('[dbo].[sp_MobileGetPrimaryCreativeFileForAd]: %d: %s',16,1,@error,@message,@lineNo);
		   END CATCH 
END
