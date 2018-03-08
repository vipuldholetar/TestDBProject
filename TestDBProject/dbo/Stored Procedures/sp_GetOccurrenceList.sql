CREATE PROCEDURE [dbo].[sp_GetOccurrenceList]
		@OccurrenceList varchar(200)
AS
BEGIN
	SET NOCOUNT ON;
		BEGIN TRY

			Select [OccurrenceDetailCIRID] as OccurrenceID,FrontPage,BackPage,CreateDTM,Market,MediaType,Theme,Event,AdDate,StartDate,EndDate,FirstMarket,Pages,
			Language,Status,CASE WHEN FlashStatus =1 THEN 'Yes'ELSE 'No' END AS FlashStatus,FlyerID,SizeDescription	
			from vw_MergeQueueOccurrenceData where [OccurrenceDetailCIRID] in (Select Id from [dbo].[fn_CSVToTable](@OccurrenceList))
			

		END TRY
		BEGIN CATCH
		   DECLARE @ERROR   INT, 
                   @MESSAGE VARCHAR(4000), 
                   @LINENO  INT 

          SELECT @ERROR = Error_number(),@MESSAGE = Error_message(),@LINENO = Error_line() 
          RAISERROR ('[sp_GetOccurrenceList]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
		END CATCH
  
END