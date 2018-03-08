
-- ===================================================================================
-- Author		: Karunakar
-- Create date	: 06/05/2015
-- Description	: fill the Data in Publication Work Queue Issue List	
-- Execution	: Exec sp_GetPublicationOccurrenceData  14326
-- Updated By	: Arun Nair on 12/31/2015 - Added New Cols for MultiEdition,Pubtype

-- ====================================================================================

CREATE PROCEDURE [dbo].[sp_GetPublicationOccurrenceData] 
(
	@PubIssueId As Int,
    @IncludeNoTake as BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Stmnt AS NVARCHAR(max)='' 
	DECLARE @SelectStmnt AS NVARCHAR(max)='' 
	DECLARE @Where AS NVARCHAR(max)=''      
	DECLARE @Orderby AS NVARCHAR(max)='' 
	DECLARE @InProgressStatus as nvarchar(max)
	DECLARE @NoTakeStatus as nvarchar(max)
	DECLARE @CompleteStatus as nvarchar(max)
					  
	BEGIN TRY
	
			SELECT @NoTakeStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'NT'

			SET @SelectStmnt ='Select OccurrenceDetailPUBID,Advertiser,OccurrenceStatus,MapStatus + ''/'' + IndexStatus as MapIndexStatus,ScanStatus,
								QCStatus,RouteStatus,OccurrencePriority as Priority,PublicationPriority,
								AdDT,MediaType, PageCount, PageTypeId,PubPageNumber,AdId,AdvertiserID,PubIssueId,SizeID,PubSectionID,Size,PubType
								from vw_PublicationOccurrenceData'

			SET @Orderby=' ORDER BY OccurrenceDetailPUBID'

			SET @Where=' WHERE (1=1)' --AND (Query is null or Query=0) '		--L.E. 3.16.17 MI-977					

			IF (@IncludeNoTake = 0)
			BEGIN
				SET @Where = @Where + ' AND OccurrenceStatus <> '''+@NoTakeStatus+''''	
			END

			IF( @PubIssueId <> '')		
				BEGIN
					PRint(@PubIssueId)
					SET @Where= @where + ' AND PubIssueId='+Cast(@PubIssueId AS VARCHAR)
				END
										
															
			SET @Stmnt=@SelectStmnt + @Where + @Orderby 
			EXECUTE Sp_executesql @Stmnt 
			Print(@Stmnt)
	END TRY
	BEGIN CATCH
			DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_GetPublicationOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH
	
END