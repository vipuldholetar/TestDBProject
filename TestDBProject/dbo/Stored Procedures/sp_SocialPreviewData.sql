-- ====================================================================================================================================
-- Author		: Arun Nair 
-- Create date	: 11/17/2015
-- Description	: Fills the Data in Social Work Queue  Preview Details 
-- Execution	:  [dbo].[sp_SocialPreviewData] 3
-- Updated By	: 
-- ====================================================================================================================================
CREATE PROCEDURE [dbo].[sp_SocialPreviewData] 
(
@OccurrenceId AS INT
)
AS
BEGIN
	SET NOCOUNT ON;			
	BEGIN TRY
		SELECT  [OccurrenceDetailSOC].SubjectPost AS [Subject],
		(Select ValueTitle FROM [Configuration] WHERE SystemName = 'All' AND ComponentName = 'Social Format' AND Value= [OccurrenceDetailSOC].FormatCode) AS [Format],
		(Select ValueTitle FROM [Configuration] WHERE SystemName = 'All' AND ComponentName = 'Rating' AND Value= [OccurrenceDetailSOC].RatingCode) AS Rating,
		[dbo].[QueryDetail].QueryText,
		[dbo].[QueryDetail].[QryAnswer],
		[OccurrenceDetailSOC].LandingPageURL,
		[OccurrenceDetailSOC].URL,
		CONVERT(NVARCHAR,[OccurrenceDetailSOC].[DistributionDT],101) AS DistributionDate,
		[OccurrenceDetailSOC].CountryOrigin
		FROM dbo.[OccurrenceDetailSOC] 
		LEFT JOIN [QueryDetail] ON [QueryDetail].[OccurrenceID]= [OccurrenceDetailSOC].[OccurrenceDetailSOCID]  
			 AND [QueryDetail].[MediaStreamID]='SOC'		
		WHERE [OccurrenceDetailSOC].[OccurrenceDetailSOCID]=@OccurrenceID
	END TRY
	BEGIN CATCH 
		DECLARE @Error   INT,@Message VARCHAR(4000),@LineNo  INT 
		SELECT @Error = Error_number(),@Message = Error_message(),@LineNo = Error_line() 
		RAISERROR ('[dbo].[sp_SocialPreviewData]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH   
END
