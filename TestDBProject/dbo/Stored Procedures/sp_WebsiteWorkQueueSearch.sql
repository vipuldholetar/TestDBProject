--===========================================================================================================

-- Author            : Ramesh Bangi

-- Create date       : 10/19/2015

-- Description       : Get Occurrence Data for Website Work Queue 

-- Execution		 : [dbo].[sp_WebsiteWorkQueueSearch] 'ALL','ALL',1,'ALL',0,0,'3/2/2015','10/28/2015'

-- Updated By		 : 

--===========================================================================================================



CREATE PROCEDURE [dbo].[sp_WebsiteWorkQueueSearch]

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

				 

		SELECT @NoTakeStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND Componentname='Occurrence Status' and Value='NT'

				 

		SELECT @CompleteStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'C'



		SET @SelectStmnt ='SELECT OccurrenceID,Advertiser,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,

		Market,convert(varchar,AdDate,101) AS AdDate,'''' AS ImageAge,OfficeLocation,AdID,CONVERT(VARCHAR,CAST(CreateDate as DATE),110) as createddate,

		LanguageId,Language,AdvertiserID,QryRaisedOn FROM [dbo].[vw_WebsiteWorkQueueData]'

		

		SET @Orderby=' ORDER BY Priority,AdDate, Advertiser,OccurrenceID'



		SET @Where=' WHERE (1=1) AND (Query IS NULL   OR Query=0) AND OCCURRENCESTATUS ='''+@InProgressStatus+''''



		IF( @FromDate <> '' AND @ToDate <> '' ) 

			BEGIN 

				SET @Where= @where + ' AND  CAST(createdate as DATE) BETWEEN  '''  + convert(varchar,cast(@FromDate as date),110)  + ''' AND  '''  + convert(varchar,cast(@ToDate as date),110) + '''' 																		

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

				SET @Where=@Where + ' and AdvertiserId = '+ Cast(@AdvertiserId AS VARCHAR) 

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



		SET @Stmnt=@SelectStmnt + @Where + @Orderby

		PRINT @Stmnt 

		EXECUTE Sp_executesql @Stmnt 

				

		END TRY 			

	

		BEGIN CATCH 

			DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 

			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

			RAISERROR ('[sp_WebsiteWorkQueueSearch]: %d: %s',16,1,@error,@message,@lineNo);          

		END CATCH 



END