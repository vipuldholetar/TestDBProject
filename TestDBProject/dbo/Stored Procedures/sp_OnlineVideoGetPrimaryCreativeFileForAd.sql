-- ==========================================================================================================
-- Author			: KARUNAKAR
-- Create date		: 28th Sep 2015
-- Description		: This stored procedure is used to Getting Online Video Primary Creative File from CreativeDetailONV
-- Execution Process: [sp_OnlineVideoGetPrimaryCreativeFileForAd] 11124 
-- Updated By		: 
-- =================================================================================================================
CREATE PROCEDURE [dbo].[sp_OnlineVideoGetPrimaryCreativeFileForAd]
	@Adid int
AS
		BEGIN TRY
			 SELECT Top 1 [Creative].PK_Id AS Creativemasterid,CreativeDetailONV.[CreativeDetailONVID] As CreativeDetailId,[Creative].PrimaryIndicator AS Primarycreativeindicator,
			CreativeDetailONV.CreativeRepository+CreativeDetailONV.CreativeAssetName AS CreativeFilePath,
			cast(CreativeDetailONV.[CreativeDetailONVID] as varchar)+'-'+CreativeDetailONV.CreativeRepository+CreativeDetailONV.CreativeAssetName as DetailIDwithFilepath
			FROM [Creative] 
			inner join CreativeDetailONV on [Creative].PK_Id=CreativeDetailONV.[CreativeMasterID] and [Creative].[AdId]=@Adid
			and [Creative].PrimaryIndicator=1
		END TRY

		BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_OnlineVideoGetPrimaryCreativeFileForAd]: %d: %s',16,1,@error,@message,@lineNo);
END CATCH
