
-- ===================================================================================================
-- Author				: Arun Nair
-- Create date			: 09/21/2015
-- Description			: Get Outdoor Primary Creative File from CreativeDetailODR for OnlineDisplay
-- Execution Process	:[dbo].[sp_OnlineDisplayGetPrimaryCreativeFileForAd]
-- Updated By			: 
-- ===================================================================================================
CREATE PROCEDURE [dbo].[sp_OnlineDisplayGetPrimaryCreativeFileForAd]
(
@Adid INT
)
AS
BEGIN
	SET NOCOUNT ON;
         BEGIN TRY
		       SELECT Top 1 [Creative].PK_Id,CreativeDetailOND.[CreativeDetailONDID] AS CreativeDetailId,
			   [Creative].PrimaryIndicator,
		       CreativeDetailOND.CreativeRepository+CreativeDetailOND.CreativeAssetName AS [PrimarySource]
			   FROM [Creative] 	INNER JOIN CreativeDetailOND ON [Creative].PK_Id=CreativeDetailOND.[CreativeMasterID]
			   AND [Creative].[AdId]=@Adid AND [Creative].PrimaryIndicator=1
          END TRY 
		   BEGIN CATCH 
				DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT
				SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
				RAISERROR ('[dbo].[sp_OnlineDisplayGetPrimaryCreativeFileForAd]: %d: %s',16,1,@error,@message,@lineNo);
		   END CATCH 
END
