
-- ======================================================================================================================
-- Author			: KARUNAKAR
-- Create date		: 07/17/2015
-- Description		: This stored procedure is used to Getting Cinema Primary Creative File from CreativeDetailCIN
-- Execution Process: [sp_CinemaGetPrimaryCreativeFileForAd] 11124 
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
-- ======================================================================================================================
CREATE PROCEDURE [dbo].[sp_CinemaGetPrimaryCreativeFileForAd]
	@Adid int
AS
    BEGIN  TRY

		SELECT [Creative].PK_Id,CreativeDetailCIN.[CreativeDetailCINID] As CreativeDetailId,[Creative].PrimaryIndicator,
		CreativeDetailCIN.CreativeRepository+CreativeDetailCIN.CreativeAssetName AS CreativeFilePath,
		cast(CreativeDetailCIN.[CreativeDetailCINID] as varchar)+'-'+CreativeDetailCIN.CreativeRepository+CreativeDetailCIN.CreativeAssetName as DetailIDwithFilepath
		FROM [Creative] 
		inner join CreativeDetailCIN on [Creative].PK_Id=CreativeDetailCIN.[CreativeMasterID] and [Creative].[AdId]=@Adid
		and [Creative].PrimaryIndicator=1

   END TRY
    
   BEGIN CATCH 
        DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
        RAISERROR ('[sp_CinemaGetPrimaryCreativeFileForAd]: %d: %s',16,1,@error,@message,@lineNo);
   END CATCH
