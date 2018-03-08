-- =============================================

-- Author			:	Nanjunda

-- Create date		:	07/15/2015

-- Description		:	Get Creative names for Cinema Media Retreival Engine

-- Execution Process: sp_CinemaGetPatterns 

-- =============================================

CREATE PROCEDURE [dbo].[sp_CinemaGetPatterns]

AS

BEGIN

		BEGIN TRY

		BEGIN TRANSACTION

			SELECT DISTINCT PM.[PatternStagingID] AS PatternMasterStaggingId,PM.[CreativeSignature] ,MIN(OD.[OccurrenceDetailCINID]) AS OccuranceId
			FROM [PatternStaging] PM,[OccurrenceDetailCIN] OD
			WHERE pm.[CreativeSignature] = od.[CreativeID] and PM.[CreativeStgID] IS NULL  
			group by PM.[PatternStagingID],PM.[CreativeSignature]

		COMMIT TRANSACTION	

		END TRY



		BEGIN CATCH

		ROLLBACK TRANSACTION

				 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 

				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

				  RAISERROR ('sp_CinemaGetPatterns: %d: %s',16,1,@error,@message,@lineNo); 		

		END CATCH

		

END