
-- ====================================================================================================================
-- Author			: KARUNAKAR
-- Create date		: 07/07/2015
-- Description		: This stored procedure is used to Getting Outdoor Primary Creative File from CreativeDetailODR
-- Execution Process: [sp_OutdoorGetPrimaryCreativeFileForAd] 8079 
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
-- ====================================================================================================================
CREATE PROCEDURE [dbo].[sp_OutdoorGetPrimaryCreativeFileForAd]
	@Adid INT
AS
   BEGIN TRY

		SELECT [Creative].PK_Id AS [CreativeMasterID],CreativeDetailODR.[CreativeDetailODRID] AS CreativeDetailId,[Creative].PrimaryIndicator,
		CreativeDetailODR.CreativeRepository+CreativeDetailODR.CreativeAssetName AS [PrimarySource] FROM [Creative] 
		INNER JOIN CreativeDetailODR ON [Creative].PK_Id=CreativeDetailODR.creativemasterid
		AND [Creative].[AdId]=@Adid
		AND [Creative].PrimaryIndicator=1

   END TRY 

   BEGIN CATCH 
        DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT
        SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
        RAISERROR ('[sp_OutdoorGetPrimaryCreativeFileForAd]: %d: %s',16,1,@error,@message,@lineNo);
   END CATCH
