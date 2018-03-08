


-- ==============================================================================================
-- Author			: Lisa East
-- Create date		: 02/08/17
-- Description		: Get  Data in Publication Work Queue Issue List by from the OccuranceID	
-- Exec				: dbo.sp_PublicationWorkQueueSearchbyOccurenceID occurenceID
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationWorkQueueSearchbyOccurenceID] 
	(
		@OccurrenceId AS Int 
	)
AS
BEGIN
	
	SET NOCOUNT ON;
					  DECLARE @Stmnt AS NVARCHAR(max)='' 
					  DECLARE @SelectStmnt AS NVARCHAR(max)='' 
					  DECLARE @Where AS NVARCHAR(max)=''      
					  DECLARE @Orderby AS NVARCHAR(max)='' 
					  Declare @InProgressStatus as nvarchar(max)
					  Declare @NoTakeStatus as nvarchar(max)
					  Declare @CompleteStatus as nvarchar(max)
			BEGIN TRY
					 SELECT @InProgressStatus = valuetitle 
					  FROM   [Configuration] 
					  WHERE  systemname = 'All' 
							 AND componentname = 'Published Issue Status' 
							 AND value = 'P' 

					  SELECT @NoTakeStatus = valuetitle 
					  FROM   [Configuration] 
					  WHERE  systemname = 'All' 
							 AND componentname = 'Published Issue Status' 
							 AND value = 'NT'

				 
					 SELECT @CompleteStatus = valuetitle 
					  FROM   [Configuration] 
					  WHERE  systemname = 'All' 
							 AND componentname = 'Published Issue Status' 
							 AND value = 'C'


						SET @SelectStmnt ='Select Pub.IssueId, Pub.Publication, convert(varchar,Pub.IssueDate,101) AS IssueDate,
						                   Pub.Priority,Pub.Sender,Pub.Market,Pub.IssueComplete,Pub.IssueAudited,Pub.PubIssueStatus,Pub.Comments,Pub.LanguageID,Pub.Language,Pub.MarketId,Pub.SourceOccurrenceID,Pub.PubSectionName
										   from vw_PublicationWorkQueueIssueData Pub INNER JOIN vw_PublicationOccurrenceData  Occ on Pub.IssueId=Occ.PubIssueId '
										   
						
						SET @Orderby=' ORDER BY  Pub.Priority,Pub.Publication,Pub.IssueDate,Pub.IssueId'

						SET @Where=' WHERE (1=1) AND Occ.OccurrenceDetailPUBID = '+ convert(varchar, @OccurrenceId ) + ' AND (IsQuery is null or isquery=0)  AND Pub.PubIssueStatus ='''+@InProgressStatus+''''

					

						SET @Stmnt=@SelectStmnt + @Where + @Orderby 
						PRINT @Stmnt
						EXECUTE Sp_executesql @Stmnt 

			END TRY
			BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_PublicationWorkQueueSearch]: %d: %s',16,1,@error,@message,@lineNo);
			END CATCH
    
END