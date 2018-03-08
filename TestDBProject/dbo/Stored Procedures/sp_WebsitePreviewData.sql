-- ====================================================================================================================================

-- Author		: Ramesh Bangi

-- Create date	: 10/19/2015

-- Description	: Fills the Data in Website Work Queue  Preview Details 

-- Execution	:  [dbo].[sp_WebsitePreviewData] 3

-- Updated By	: 

-- ====================================================================================================================================

CREATE PROCEDURE [dbo].[sp_WebsitePreviewData] 

(

@OccurrenceId AS INT

)

AS

BEGIN

	SET NOCOUNT ON;

			

	BEGIN TRY



		SELECT  ([dbo].[QueryDetail].QueryText) +' | '+ Convert(NVARCHAR(MAX),[dbo].[QueryDetail].[QryAnswer]) AS QAndA


		

		FROM [QueryDetail]

		INNER JOIN [Configuration] ON [Configuration].Value = [QueryDetail].QueryCategory

		AND [QueryDetail].[System] = 'I&O'

		AND [QueryDetail].EntityLevel = 'OCC'

		AND [Configuration].SystemName = 'All'

		AND [Configuration].ComponentName = 'Query Category'

		AND [QueryDetail].[MediaStreamID]='WEB'

		WHERE [QueryDetail].[OccurrenceID] = @OccurrenceID

	END TRY



	BEGIN CATCH 

				DECLARE @Error   INT,@Message VARCHAR(4000),@LineNo  INT 

				SELECT @Error = Error_number(),@Message = Error_message(),@LineNo = Error_line() 

				RAISERROR (' [dbo].[sp_WebsitePreviewData]: %d: %s',16,1,@error,@message,@lineNo); 

	END CATCH   

END
