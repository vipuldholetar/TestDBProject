-- ==========================================================================================

-- Author		: Arun Nair
-- Create date	: 10/27/2015
-- Description	: Load IntialDPFOccurenceData for Email
-- Updated By	: 
-- ===============================================================================================
CREATE PROCEDURE [dbo].[sp_EmailLoadIntialDPFOccurrenceData]
AS
BEGIN
		SET NOCOUNT ON;
			BEGIN TRY 
							
			-- MediaType 

				SELECT Descrip, [MediaTypeID]	FROM MediaType WHERE MediaStream = 'EM' AND IndDisplayValue = 1 ORDER BY 1

			-- Market

				SELECT [Descrip],[MarketID] FROM [Market]  WHERE [StartDT] <= GETDATE() AND ([EndDT] >= GETDATE() OR [EndDT] IS NULL) ORDER BY 1

			-- AdvertiserEmail

			    SELECT AdvertiserEmail.[AdvertiserEmailID] as AdvertiserEmailId ,AdvertiserEmail.Email as AdvertiserEmail FROM AdvertiserEmail 
					--INNER JOIN OccurrenceDetailsEM ON AdvertiserEmail.PK_Id = OccurrenceDetailsEM.FK_AdvertiserEmailID ORDER BY 2

			-- SenderPersona

				SELECT [SenderPersonaID],SenderName FROM Senderpersona 
					--INNER JOIN OccurrenceDetailsEM ON SenderPersona.PK_SenderPersonaID = OccurrenceDetailsEM.FK_SenderPersonaID ORDER BY 2

			-- Event 

				SELECT [EventID],Descrip FROM [Event] WHERE  [StartDT] <= GETDATE() AND ([EndDT] >= GETDATE() OR [EndDT] IS NULL) ORDER BY 2

			-- ThemeMaster
				
				SELECT [ThemeID],Descrip FROM [Theme] WHERE [StartDT] <= GETDATE() AND ([EndDT] >= GETDATE() OR [EndDT] IS NULL) ORDER BY 2

			END TRY
			BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_EmailLoadIntialDPFOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo) ; 				
			END CATCH


END