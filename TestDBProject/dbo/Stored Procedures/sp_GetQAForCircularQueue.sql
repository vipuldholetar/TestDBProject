-- =============================================================================================
-- Author		:   Arun Nair
-- Create date	:	25 May 2015
-- Description	:   Load Query Q&A Value fro Circular Preview Queue
-- Updated By	: Updated Changes Based on Configuration Master table LOV on 01 july 2015	
--				:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--============================================================================================

CREATE PROCEDURE [dbo].[sp_GetQAForCircularQueue]--3051
(
@occurrenceID AS BIGINT
)
AS
BEGIN
	SET NOCOUNT ON;--Load Circular Review Queue Market Data	
				BEGIN TRY
					SELECT   dbo.[Configuration].ValueTitle + '|'+ [OccurrenceDetailCIR].QueryText + '|'+ [OccurrenceDetailCIR].QueryAnswer  AS QAndA
					from dbo.[OccurrenceDetailCIR] INNER JOIN  dbo.[Configuration]
					ON dbo.[Configuration].valuetitle=dbo.[OccurrenceDetailCIR].QueryCategory
					WHERE dbo.[Configuration].SystemName='All' AND dbo.[Configuration].ComponentName='Query Category'
					and [OccurrenceDetailCIR].[Query]=1 and [OccurrenceDetailCIR].QueryAnswer is not null
					AND dbo.[OccurrenceDetailCIR].[OccurrenceDetailCIRID]=@occurrenceID
				END TRY

				BEGIN CATCH
					 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					 RAISERROR ('[sp_GetQAForCircularQueue]: %d: %s',16,1,@error,@message,@lineNo); 
				END CATCH

END
