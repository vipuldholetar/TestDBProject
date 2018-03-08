
-- ===========================================================================
-- Author			: Ashanie
-- Create date		: 03/27/2017
-- Description		: 
--=============================================================================
CREATE PROCEDURE [dbo].[sp_isValidRevisionID]
    @originalAdID INT,
    @advertiserID INT
AS
BEGIN
    
	SET NOCOUNT ON;

	   BEGIN TRY
		  SELECT COUNT(*) AS COUNT
		  FROM Ad INNER JOIN [Advertiser] on [Advertiser].Advertiserid=Ad.[AdvertiserID]  
		  WHERE --(originaladid is null or originaladid =0) and
		  Ad.[AdID] = @originalAdID AND [Advertiser].Advertiserid= @advertiserID  
	   END  TRY

	   BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_isValidRevisionID]: %d: %s',16,1,@error,@message,@lineNo);
	   END CATCH

END
