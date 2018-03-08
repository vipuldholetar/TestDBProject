
--===========================================================================================================
-- Author            : Ramesh Bangi
-- Create date       : 10/19/2015
-- Description       : Get Occurrence Data for Email Work Queue 
-- Execution		 : [dbo].[sp_EmailWorkQueueSearch] 'ALL','ALL',-1,'ALL',0,0,'11/11/2015','01/21/2016'
-- Updated By		 : Arun Nair on 11/03/2015 - Updated LanguageId,Language 
--					   Arun Nair on 11/11/2015 - AdvertiserID changed  Integer
--					   Mark Marshall on 02/21/2017 - AdvertiserID changed  Integer
--===========================================================================================================

CREATE PROCEDURE [dbo].[sp_EmailWorkQueueSearch]
(
@OfficeLocation AS VARCHAR(200),
@TradeclassId AS VARCHAR(200),
@AdvertiserId AS INT,
@UserId AS VARCHAR(200),
@OccurrenceStatusNoTake AS BIT,
@OccurrenceStatusCompleted AS BIT,
@FromDate AS VARCHAR(50)='', 
@ToDate AS VARCHAR(50)=''
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

		IF(@OfficeLocation<>'ALL')
				BEGIN
					SET @OfficeLocation=REPLACE((@OfficeLocation), ',' , ''',''')
					SET @OfficeLocation= ''''+@OfficeLocation+''''
					PRINT @OfficeLocation
				END 

		IF(@TradeclassId<>'ALL')
				BEGIN
					SET @TradeclassId=REPLACE((@TradeclassId), ',' , ''',''')
					SET @TradeclassId= ''''+@TradeclassId+''''
					PRINT @TradeclassId
				END
		
		IF(@UserId<>'ALL')
				BEGIN
					SET @UserId=REPLACE((@UserId), ',' , ''',''')
					SET @UserId= ''''+@UserId+''''
					PRINT @UserId
				END
		
		BEGIN TRY								

		SELECT @InProgressStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'P' 
				 
		SELECT @NoTakeStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'NT'
				 
		SELECT @CompleteStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'C'

		--SET @SelectStmnt ='SELECT OccurrenceID,Advertiser,Subject,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,
		--Market,convert(varchar,AdDate,101) AS AdDate,ImageAge,OfficeLocation,AdID,CONVERT(VARCHAR,CAST(CreateDate as DATE),110) as createddate,Sender,
		--LanguageId,Language,AdvertiserID,QryRaisedOn,ParentOccurrenceId FROM [dbo].[vw_EmailWorkQueueData]'

		SET @SelectStmnt ='SELECT  [vw_EmailWorkQueueData].OccurrenceID,
		CASE WHEN NOT EXISTS(select distinct top 1 AdvertiserEmail.AdvertiserEmailID from AdvertiserEmail where AdvertiserEmail.AdvertiserEmailID=vw_EmailWorkQueueData.SourceEmail and vw_EmailWorkQueueData.AdvertiserID=17542)
       THEN Advertiser  ELSE RIGHT(AdvertiserEmail.Email, LEN(AdvertiserEmail.Email) - CHARINDEX(''@'', AdvertiserEmail.email)) END AS Advertiser 
	   ,[vw_EmailWorkQueueData].Subject,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,vw_EmailWorkQueueData.SourceEmail,
		Market,convert(varchar,[vw_EmailWorkQueueData].AdDate,101) AS AdDate,ImageAge,OfficeLocation,AdID,CONVERT(VARCHAR,CAST(CreateDate as DATE),110) as createddate,Sender,
		LanguageId,Language,[vw_EmailWorkQueueData].AdvertiserID,QryRaisedOn,ParentOccurrenceId,PatternMasterID 
		FROM [dbo].[vw_EmailWorkQueueData] 
		JOIN (SELECT advertiserid, Min(occurrenceid) occurrenceid,Subject,AdDate FROM [dbo].[vw_EmailWorkQueueData] GROUP BY advertiserid,Subject,AdDate) AS subEmailWorkQueue ON [dbo].[vw_EmailWorkQueueData].OccurrenceID = subEmailWorkQueue.occurrenceid
		left join  AdvertiserEmail on vw_EmailWorkQueueData.SourceEmail=AdvertiserEmail.AdvertiserEmailID'

		SET @Orderby=' ORDER BY AdDate desc,Priority, Advertiser,OccurrenceID'

		SET @Where=' WHERE (1=1) AND (Query IS NULL OR Query=0) AND (Exception is null or Exception<>1) AND ParentOccurrenceId IS NULL AND OCCURRENCESTATUS ='''+@InProgressStatus+''''

		IF( @FromDate <> '' AND @ToDate <> '' ) 
			BEGIN 
				SET @Where= @where + ' AND  CAST(createdate as DATE) BETWEEN  '''  + convert(varchar,Cast(@FromDate as date),110)  + ''' AND  '''  + convert(varchar,cast(@ToDate as date),110) + '''' 																		
			END 


		IF(@OfficeLocation<>'ALL')
			BEGIN
				SET @Where= @Where + ' AND OfficeLocation in ('+@OfficeLocation+')'
			END

		IF(@TradeclassId<>'ALL')
			BEGIN
				SET @Where= @Where + ' AND TradeclassId in ('+@TradeclassId+')'
			END

		IF(@AdvertiserId<>-1)
			BEGIN
				SET @Where=@Where + ' and AdvertiserEmail.AdvertiserId = ' 
								+ Cast(@AdvertiserId AS VARCHAR) 
			END

		IF(@UserId<>'ALL')
			BEGIN
				SET @Where= @Where + ' AND UserId in ('+@UserId+')'
			END
						

		IF(@OccurrenceStatusNoTake=1)
			BEGIN
				SET @Where= @where + ' OR OCCURRENCESTATUS ='''+@NoTakeStatus+''''
			END

		IF(@OccurrenceStatusCompleted=1)
			BEGIN
				SET @Where= @where + ' OR OCCURRENCESTATUS ='''+@CompleteStatus+''''
			END
			ElSE
			BEGIN
			SET @Where= @Where + ' AND ADId is null'
			END

		SET @Stmnt=@SelectStmnt + @Where + @Orderby
		PRINT @Stmnt 
		EXECUTE Sp_executesql @Stmnt 
				
		END TRY 			
	
		BEGIN CATCH 
			DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('[sp_EmailWorkQueueSearch]: %d: %s',16,1,@error,@message,@lineNo);          
		END CATCH 

END