-- ==========================================================================================

-- Author		: KARUNAKAR
-- Create date	: 11/20/2015
-- Description	: Load IntialDPFOccurenceData for Social
-- Updated By	: exec sp_SocialLoadIntialDPFOccurrenceData
-- ===============================================================================================
CREATE PROCEDURE [dbo].[sp_SocialLoadIntialDPFOccurrenceData]
AS
BEGIN
		SET NOCOUNT ON;
			BEGIN TRY 
							
			-- MediaType 

				SELECT Descrip, [MediaTypeID],MediaStream FROM MediaType WHERE MediaStream like 'SOC%' ORDER BY 1

			-- Market

				SELECT [Descrip],[MarketID] FROM [Market]  WHERE [StartDT] <= GETDATE() AND ([EndDT] is null or [EndDT]>= GETDATE()) ORDER BY 1

			-- Event 

				SELECT [EventID],Descrip FROM [Event] WHERE  [StartDT] <= GETDATE() AND [EndDT] >= GETDATE() OR [EndDT] IS NULL ORDER BY 2

			-- ThemeMaster
				
				SELECT [ThemeID],Descrip FROM [Theme] WHERE [StartDT] <= GETDATE() AND [EndDT] >= GETDATE() OR [EndDT] IS NULL ORDER BY 2

			--Format
					SELECT Value,ValueTitle FROM [Configuration] WHERE SystemName = 'All' AND ComponentName = 'Social Format'

			--Rating
					SELECT Value,ValueTitle  FROM [Configuration] WHERE SystemName = 'All' AND ComponentName = 'Rating'

			--Relationship to Advertiser
					SELECT Value,ValueTitle FROM [Configuration] WHERE SystemName = 'All' AND ComponentName = 'Relationship to Adv'
		

			END TRY
			BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_SocialLoadIntialDPFOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo) ; 				
			END CATCH


END