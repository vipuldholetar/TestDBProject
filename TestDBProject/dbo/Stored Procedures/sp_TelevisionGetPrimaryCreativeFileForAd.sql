-- ==========================================================================================================
-- Author			: Ramesh
-- Create date		: 07/23/2015
-- Description		: This stored procedure is used to Getting Television Primary Creative File from CreativeDetailTV
-- Execution Process: [sp_TelevisionGetPrimaryCreativeFileForAd] 11124 
-- Updated By		: Arun on 08/13/2015 -Cleanup OnemT
-- =================================================================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionGetPrimaryCreativeFileForAd]
	@Adid int
AS
		BEGIN TRY
			 SELECT [Creative].PK_Id AS Creativemasterid,CreativeDetailTV.[CreativeDetailTVID] As CreativeDetailId,[Creative].PrimaryIndicator AS Primarycreativeindicator,
			CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName AS CreativeFilePath,
			cast(CreativeDetailTV.[CreativeDetailTVID] as varchar)+'-'+CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName as DetailIDwithFilepath
			FROM [Creative] 
			inner join CreativeDetailTV on [Creative].PK_Id=CreativeDetailTV.creativemasterid and [Creative].[AdId]=@Adid
			and [Creative].PrimaryIndicator=1
		END TRY

		BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_TelevisionGetPrimaryCreativeFileForAd]: %d: %s',16,1,@error,@message,@lineNo);
END CATCH
