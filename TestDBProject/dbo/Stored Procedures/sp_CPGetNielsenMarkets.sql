-- ===========================================================================
-- Author:		Govardhan 
-- Create date: 25 April 2015
-- Description:	Get Nielsen Market Maps
-- Updated By		:
--=============================================================================
CREATE PROCEDURE [dbo].[sp_CPGetNielsenMarkets]
AS
BEGIN
		BEGIN TRY
			SELECT DISTINCT NLSNMARKETCODE,NLSNDMACODE FROM [dbo].[NLSNMarketStationMap]
			WHERE NLSNMARKETCODE IS NOT NULL AND NLSNDMACODE IS NOT NULL
			AND NLSNMARKETCODE<>'9999' AND [Tracked]=1
			ORDER BY NLSNMARKETCODE
		END TRY

		BEGIN CATCH
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_CPGetNielsenMarkets]: %d: %s',16,1,@error,@message,@lineNo);           
      END CATCH

END
