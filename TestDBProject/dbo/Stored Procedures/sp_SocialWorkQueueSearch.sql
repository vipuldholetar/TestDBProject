--===========================================================================================================

-- Author            : Arun Nair

-- Create date       : 11/17/2015

-- Description       : Get Occurrence Data for Social Work Queue 

-- Execution		 : [dbo].[sp_SocialWorkQueueSearch] 2,'ALL','ALL',-1,'ALL',0,0,'12/02/2015','12/21/2015'

-- Updated By		 : 

--					   

--===========================================================================================================



CREATE PROCEDURE [dbo].[sp_SocialWorkQueueSearch]

(

@SocialType AS INTEGER,

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



				--IF(@TradeclassId<>'ALL')

				--		BEGIN

				--			SET @TradeclassId=REPLACE((@TradeclassId), ',' , ''',''')

				--			SET @TradeclassId= ''''+@TradeclassId+''''

				--			PRINT @TradeclassId

				--		END

		

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



				SET @SelectStmnt ='SELECT OccurrenceID,Advertiser,Subject,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,

				Market,convert(varchar,AdDT,101) AS AdDate,ImageAge,OfficeLocation,AdID,CONVERT(VARCHAR,CAST(CreateDate as DATE),110) as CreateDate,

				LanguageId,Language,AdvertiserID,QryRaisedOn,'''' AS [AuditBy/On],SocialType FROM [dbo].[vw_SocialWorkQueueData]'


				SET @Orderby=' ORDER BY Priority,AdDT, Advertiser,OccurrenceID'



				SET @Where=' WHERE (1=1) AND  OCCURRENCESTATUS ='''+@InProgressStatus+''''



				IF( @FromDate <> '' AND @ToDate <> '' ) 

					BEGIN 

						--SET @Where= @where + ' AND  CONVERT(VARCHAR,CAST(createdate as DATE),110) BETWEEN  '''  + convert(varchar,Cast(@FromDate as date),110)  + ''' AND  '''  + convert(varchar,cast(@ToDate as date),110) + '''' 																		
					SET @Where= @where + ' AND  Cast(createdate as date) between '''  + convert(varchar,Cast(@FromDate as date),110)  + ''' AND  '''  + convert(varchar,cast(@ToDate as date),110) + '''' 																		
					END 





				IF(@SocialType =1)

					BEGIN

						SET @Where= @Where + ' AND SocialType =''Brand'''

					END

				ELSE IF (@SocialType =2)

					BEGIN

						SET @Where= @Where + ' AND SocialType =''Promo'''

					END



				IF(@OfficeLocation<>'ALL')

					BEGIN

						SET @Where= @Where + ' AND OfficeLocation in ('+@OfficeLocation+')'

					END



				IF(@TradeclassId<>'ALL')

					BEGIN

						SET @Where= @Where + ' AND TradeclassId in ('+CAST(@TradeclassId as varchar)+')'

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

				EXECUTE SP_EXECUTESQL @Stmnt 				

		END TRY 

		BEGIN CATCH 

				DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 

				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

				RAISERROR ('[sp_SocialWorkQueueSearch]: %d: %s',16,1,@error,@message,@lineNo);          

		END CATCH 



END