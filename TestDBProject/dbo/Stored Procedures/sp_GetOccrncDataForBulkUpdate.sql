


-- ===================================================================
-- Author		:   Iyub 
-- Create date	:	15 May 2015
-- Description	:   Search Occurrence for OccurrenceCheckIn 
-- Updated By	:	Arun Nair on 22/05/2015
--====================================================================


CREATE PROCEDURE [dbo].[sp_GetOccrncDataForBulkUpdate] 
(
@OccurrenceList As NVARCHAR(max)
)
AS
BEGIN
	SET NOCOUNT ON
			BEGIN TRY
			SELECT [OccurrenceDetailCIRID] as OccurrenceID,MediaTypeID ,MediaTypeDescription,[MarketID] ,MarketDescription,
					[PubEditionID],Publication ,Convert(varchar,DistributionDate,101) as Dist,Convert(varchar,AdDate,101) as AdDate,[FlashInd] as Flash,
					NationalIndicator ,PageCount ,[EventID] ,[ThemeID] ,[Event],theme,
					Convert(varchar,[SalesStartDT],101) as SalesStartDate,Convert(varchar,[SalesEndDT],101)  as SalesEndDate,Color,SizingMethod from vw_CircularOccurrences 
					WHERE [OccurrenceDetailCIRID] in (select * from dbo.fn_CSVToTable(@occurrencelist))
			END TRY 
			BEGIN CATCH
				  DECLARE @error INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
				  RAISERROR ('[sp_GetOccurrenceDataForBulkUpdate]: %d: %s',16,1,@error,@message,@lineNo);
			END CATCH 

END
