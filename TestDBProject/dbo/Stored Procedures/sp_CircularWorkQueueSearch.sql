-- ========================================================================================
-- Author            : Karunakar
-- Create date       : 07/14/2015
-- Description       : Get Creative Signature Data for Circular Work Queue 
-- Execution		 : [dbo].[sp_CircularWorkQueueSearch]  0,0,'12/18/2015','01/17/2016'
-- Updated By		 : Karunakar on 7th Sep 2015
--					   Arun Nair On 10/05/2015 - Added EnvelopeId
--					   Arun Nair On 10/14/2015 - Added Sender 
--			     	   Arun Nair on 01/04/2016 - Added time in CheckIn fromdate and todate
--===========================================================================================

CREATE PROCEDURE [dbo].[sp_CircularWorkQueueSearch]
(
@OccurrenceStatusNoTake AS BIT,
@OccurrenceStatusCompleted AS BIT,
@CheckInFromDate AS VARCHAR(50)='', 
@CheckInToDate AS VARCHAR(50)=''
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

		SELECT @InProgressStatus = valuetitle 
		FROM   [Configuration] 
		WHERE  systemname = 'All' 
		AND componentname = 'Occurrence Status' 
		AND value = 'P' 

				 
		SELECT @NoTakeStatus = valuetitle 
		FROM   [Configuration] 
		WHERE  systemname = 'All' 
		AND componentname = 'Occurrence Status' 
		AND value = 'NT'

				 
		SELECT @CompleteStatus = valuetitle 
		FROM   [Configuration] 
		WHERE  systemname = 'All' 
		AND componentname = 'Occurrence Status' 
		AND value = 'C'

		SET @SelectStmnt ='SELECT  OccurrenceDetailCIRID, Advertiser, OccurrenceStatus,IndexStatus AS MapIndexStatus,ScanStatus,QCStatus,RouteStatus
		,FlashInd AS Flash,OccurrenceCIRPriority AS Priority,convert(varchar,AdDate,101) AS AdDate, MediaTypeDescription AS MediaType,TradeClass,PageCount,
		AdId AS AdID,'''' AS SIMR,Query,AdvertiserID AS AdvertiserID,LanguageID AS LanguageID,Language,CONVERT(VARCHAR,CAST(createddt as DATE),110) as createddate,EnvelopeId,
		sendername FROM [dbo].[vw_CircularOccurrences] '
		
		SET @Orderby=' ORDER BY FlashInd DESC, OccurrenceCIRPriority,AdDate, Advertiser,OccurrenceDetailCIRID'

		SET @Where=' WHERE (1=1) AND (Query<>1 or Query is Null ) AND OCCURRENCESTATUS ='''+@InProgressStatus+''''

		IF( @CheckInFromDate <> '' AND @CheckInToDate <> '' ) 
			BEGIN 
				SET @Where= @where + ' AND  CAST(createddt as DATE) BETWEEN  '''  + convert(varchar,cast(@CheckInFromDate as date),110)  + ''' AND  '''  + convert(varchar,cast(@CheckInToDate as date),110) + '''' 	 																		
			END 
		IF(@OccurrenceStatusNoTake=1)
			BEGIN
				SET @Where= @where + ' OR OCCURRENCESTATUS ='''+@NoTakeStatus+''''
			END

		IF(@OccurrenceStatusCompleted=1)
			BEGIN
				SET @Where= @where + ' OR OCCURRENCESTATUS ='''+@CompleteStatus+''''
			END

			SET @Stmnt=@SelectStmnt + @Where + @Orderby
			PRINT @Stmnt 
			EXECUTE Sp_executesql @Stmnt 
				
		END TRY 
		BEGIN CATCH 
			DECLARE @error   INT, 
			@message VARCHAR(4000), 
			@lineNo  INT 

			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_CircularWorkQueueSearch]: %d: %s',16,1,@error,@message,@lineNo); 
          
		END CATCH 

END