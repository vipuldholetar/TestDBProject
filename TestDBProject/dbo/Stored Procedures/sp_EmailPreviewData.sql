-- ====================================================================================================================================
-- Author		: Ramesh Bangi
-- Create date	: 10/19/2015
-- Description	: Fills the Data in Email Work Queue  Preview Details 
-- Execution	:  [dbo].[sp_EmailPreviewData] 3
-- Updated By	: 
-- ====================================================================================================================================
CREATE PROCEDURE [dbo].[sp_EmailPreviewData] 
(
@OccurrenceId AS INT
)
AS
BEGIN
	SET NOCOUNT ON;
			
	BEGIN TRY

		SELECT   AdvertiserEmail.Email			AS SourceEmail,
		SenderPersona.SenderName				AS Sender,         
		[OccurrenceDetailEM].SubjectLine			AS [Subject],
		--([dbo].[QueryDetail].QueryText) +' | '+ Convert(NVARCHAR(MAX),[dbo].[QueryDetail].[QryAnswer]) AS QAndA, --L.E. 3.24.2017 MI-918
		[dbo].[QueryDetail].QueryText, [dbo].[QueryDetail].[QryAnswer],
		(select LandingURL from LandingPage where LandingPage.LandingPageID = OccurrenceDetailEM.LandingPageID)		AS LandingPageURL,
		''										AS ParentOccurrenceID,
		[OccurrenceDetailEM].[DistributionDT]	AS DistributionDate 
		FROM dbo.[OccurrenceDetailEM] 
		Left Join [QueryDetail] On [QueryDetail].[OccurrenceID]= [OccurrenceDetailEM].[OccurrenceDetailEMID]  AND [QueryDetail].[MediaStreamID]='EM'
		INNER JOIN   AdvertiserEmail ON  AdvertiserEmail.[AdvertiserEmailID]=[OccurrenceDetailEM].[AdvertiserEmailID]
		INNER JOIN SenderPersona ON SenderPersona.[SenderPersonaID] = [OccurrenceDetailEM].[SenderPersonaID]
		WHERE [OccurrenceDetailEM].[OccurrenceDetailEMID]=@OccurrenceID
	END TRY

	BEGIN CATCH 
				DECLARE @Error   INT,@Message VARCHAR(4000),@LineNo  INT 
				SELECT @Error = Error_number(),@Message = Error_message(),@LineNo = Error_line() 
				RAISERROR (' [dbo].[sp_EmailPreviewData]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH   
END