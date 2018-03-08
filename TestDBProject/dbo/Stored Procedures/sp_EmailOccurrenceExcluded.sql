-- ====================================================================================================================================
-- Author		: Mark Marshall
-- Create date	: 02/16/2017
-- Description	: Fills the Data in Email occurrences that were excluded 
-- Execution	:  [dbo].[sp_EmailOccurrenceExcluded]
-- Updated By	: 
-- ====================================================================================================================================
CREATE PROCEDURE [dbo].[sp_EmailOccurrenceExcluded] 
(
@SubjectLine as varchar(max),
@AdvertiserID as Int,
@AdDate as Datetime 
)
AS
BEGIN
	SET NOCOUNT ON;
			
	BEGIN TRY

		SELECT OccurrenceID  FROM [dbo].[vw_EmailWorkQueueData] where Subject=@SubjectLine and AdvertiserID=@AdvertiserID and CAST(AdDate as DATE)=Cast(@AdDate as Date) order by OccurrenceID
	END TRY

	BEGIN CATCH 
				DECLARE @Error   INT,@Message VARCHAR(4000),@LineNo  INT 
				SELECT @Error = Error_number(),@Message = Error_message(),@LineNo = Error_line() 
				RAISERROR (' [dbo].[sp_EmailPreviewData]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH   
END