-- ===========================================================================

-- Author			:Govardhan

-- Create date		:12 Aug 2015

-- Description		:Get  Competitor Values
--=============================================================================

CREATE PROCEDURE [dbo].[sp_LoadCompetitorMaster]
AS
BEGIN
SET NOCOUNT ON;
		BEGIN TRY

			SELECT DISTINCT ADV.[AdvertiserID][ID],ADV.Advertiser[NAME] FROM Ad A, AdCoopComp ACC, [AdvertiserOld] ADV
            WHERE A.[AdID]=ACC.[AdCoopID] AND ADV.[AdvertiserID]=ACC.[AdvertiserID]

		END TRY

		BEGIN CATCH 

			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 

			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

			  RAISERROR ('[sp_LoadCompetitorMaster]: %d: %s',16,1,@error,@message,@lineNo); 			  

		END CATCH 

END
