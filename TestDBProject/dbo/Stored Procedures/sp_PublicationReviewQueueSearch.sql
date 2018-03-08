
-- =============================================
-- Author		:   Murali Jaganathan
-- Create date	:	16/06/2015
-- Description	:   Load Pub Issue List Based on Issue Id
-- Updated By	:	
--===================================================
CREATE PROCEDURE  [dbo].[sp_PublicationReviewQueueSearch] 
(
@PubIssueID AS VARCHAR(100) 
)
AS

BEGIN
SET NOCOUNT ON; 
        BEGIN TRY                                   
			 Select [OccurrenceDetailPUBID],Advertiser,AdvertiserID,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,occurrencePriority as priority, 
		     [AdDT],Publication as MediaType,[PageTypeID],PubPageNumber,AdId,LanguageName,LanguageID
			 from vw_PublicationOccurrenceData where PubIssueID = @PubIssueID
		END TRY
		BEGIN CATCH
			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('[sp_PublicationReviewQueueSearch]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
		
END
