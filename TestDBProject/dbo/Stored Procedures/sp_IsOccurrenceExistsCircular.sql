-- ========================================================================================
-- Author		:   Arun Nair
-- Create date	:	28 May 2015
-- Description	:   Search OccurrenceID on Multiple Occurrence
-- Updated By	:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--========================================================================================

CREATE PROCEDURE [dbo].[sp_IsOccurrenceExistsCircular] 
(
@OccurrenceID AS BIGINT
)
AS
BEGIN
		BEGIN TRY
			IF EXISTS(SELECT [OccurrenceDetailCIRID] FROM [dbo].[OccurrenceDetailCIR] WHERE [OccurrenceDetailCIRID]=@OccurrenceID)
				BEGIN
					SELECT [OccurrenceDetailCIRID],CONVERT(VARCHAR,AdDate,101) AS [AdDate],CONVERT(VARCHAR,[CreatedDT],101) AS [CreateDTM]
					FROM [dbo].[OccurrenceDetailCIR] WHERE [OccurrenceDetailCIRID]=@OccurrenceID
				END
		END TRY

		BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[dbo].[sp_CircularSearchIsOccurrenceExists ]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH

	
END
