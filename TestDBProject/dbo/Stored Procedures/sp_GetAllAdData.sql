
-- ===========================================================================
-- Author			: Arun Nair
-- Create date		: 05/12/2015
-- Description		: This Procedure  getting ad data 
--Execution			: sp_GetAllAdData
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--=============================================================================
CREATE PROCEDURE [dbo].[sp_GetAllAdData]
AS
BEGIN

	SET NOCOUNT ON;

		 BEGIN TRY
			SELECT  Ad.[AdID] As Adid,Ad.[AdvertiserID] AS [AdvertiserID],Ad.[LanguageID],[OriginalAdID], [Advertiser].descrip as AdvertiserName
			FROM Ad INNER JOIN [Advertiser] on [Advertiser].Advertiserid=Ad.[AdvertiserID]  WHERE   Ad.[AdID] IS NOT NULL
		END  TRY

		BEGIN CATCH
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_GetAllAdData]: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH

END
