-- ==========================================================================================



-- Author		: Arun Nair

-- Create date	: 11/12/2015

-- Description	: Load IntialDPFOccurenceData for Website

-- Updated By	: 

-- ===============================================================================================

CREATE PROCEDURE [dbo].[sp_WebsiteLoadIntialDPFOccurrenceData]

AS

BEGIN

		SET NOCOUNT ON;

			BEGIN TRY 									

			-- MediaType 



				SELECT Descrip, [MediaTypeID]	FROM MediaType WHERE MediaStream = 'WEB' AND IndDisplayValue = 1 ORDER BY 1



			-- Market



				SELECT [Descrip],[MarketID] FROM [Market]  WHERE [StartDT] <= GETDATE() AND [EndDT] >= GETDATE() ORDER BY 1			

			

			-- Event 



				SELECT [EventID],Descrip FROM [Event] WHERE  [StartDT] <= GETDATE() AND [EndDT] >= GETDATE() OR [EndDT] IS NULL ORDER BY 2



			-- ThemeMaster

				

				SELECT [ThemeID],Descrip FROM [Theme] WHERE [StartDT] <= GETDATE() AND [EndDT] >= GETDATE() OR [EndDT] IS NULL ORDER BY 2



			END TRY



			BEGIN CATCH

				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 

				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

				RAISERROR ('[sp_WebsiteLoadIntialDPFOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo) ; 				

			END CATCH





END
