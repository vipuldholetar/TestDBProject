
-- ==============================================================================================
-- Author			: Karunakar
-- Create date		: 06/05/2015
-- Description		: Get  Data in Publication Work Queue Issue List	
-- Exec				: sp_PublicationWorkQueueSearch '12/01/2015','01/04/2016',-1,1,0,0
-- Updated By		: Arun Nair on 01/04/2016 - Added time in CheckIn fromdate and todate
--					: Karunakar on 20th Jan 2016,Adding Source OccurrenceID and Pub section name
-- ==============================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationWorkQueueSearch] 
	(
		@CheckInFromDate AS VARCHAR(50)='', 
		@CheckInToDate AS VARCHAR(50)='',
		@SourceId As Int,
		@LanguageId AS Int,
		@PubIssueStatusNoTake AS BIT,
		@PubIssueStatusCompleted AS BIT
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
					  Declare @PubIssueStatus as nvarchar(max)
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

					  SELECT @PubIssueStatus = valuetitle  --L.E. 3.7.17 MI-977
					  FROM   [Configuration] 
					  WHERE  systemname = 'All' 
							 AND componentname = 'Published Issue Status' 
							 AND value = 'Q' 




						SET @SelectStmnt ='Select IssueId,Publication,convert(varchar,IssueDate,101) AS IssueDate,
						                   Priority,Sender,Market,IssueComplete,IssueAudited,PubIssueStatus,Comments,LanguageID,Language,MarketId,SourceOccurrenceID,PubSectionName
										   from vw_PublicationWorkQueueIssueData'
						
						SET @Orderby=' ORDER BY  Priority,Publication,IssueDate,IssueId'

						--SET @Where=' WHERE (1=1) AND (IsQuery is null or isquery=0)  AND PubIssueStatus ='''+@InProgressStatus+'''' 'L.E. 3.7.17 MI-977

						SET @Where=' WHERE (1=1)  AND PubIssueStatus  in ('''+@InProgressStatus+''', '''+@PubIssueStatus+ ''')'

						    IF( @CheckInFromDate <> '' AND @CheckInToDate <> '' ) 
								BEGIN 
									SET @Where= @where + ' AND CreateDTM  BETWEEN  '''  + convert(varchar,cast(@CheckInFromDate as date),110)  + ''' AND  '''  + convert(varchar,cast(@CheckInToDate as date),110) + + ' 23:59:59''' 																		
								END 		
							
							IF( @SourceId <> -1)
							BEGIN
							SET @Where= @where + ' AND SourceId='+Cast(@SourceId AS VARCHAR)
							END
							IF( @LanguageId <> '')
							BEGIN
							SET @Where= @where + ' AND LanguageID=' + Cast(@LanguageId AS VARCHAR)
							END		
							IF(@PubIssueStatusNoTake=1)
								BEGIN
									SET @Where= @where + ' OR PubIssueStatus ='''+@NoTakeStatus+''''
								END

							IF(@PubIssueStatusCompleted=1)
								BEGIN
									SET @Where= @where + ' OR PubIssueStatus ='''+@CompleteStatus+''''
								END

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