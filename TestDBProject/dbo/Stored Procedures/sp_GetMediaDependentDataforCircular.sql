-- ======================================================================================
-- Author		: Karunakar
-- Create date	: 22/05/2015
-- Description	: Media Dependent Data for Circular
-- Updated By	:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- =========================================================================================
CREATE PROCEDURE [dbo].[sp_GetMediaDependentDataforCircular] 
	@pOccurrenceId as bigint
AS
BEGIN
	
	SET NOCOUNT ON;
		BEGIN TRY
			select DistributionDate As FirstRunDate,DistributionDate As LastRunDate,'' AS FirstRunDMA,'NA' As Length from [dbo].[vw_CircularOccurrences] 
			Where [OccurrenceDetailCIRID]=@pOccurrenceId
		END TRY
		BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_GetMediaDependentDataforCircular]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END
