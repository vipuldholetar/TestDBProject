--===========================================================================================================



-- Author            : Ramesh Bangi



-- Create date       : 11/2/2015



-- Description       : Get Occurrence Data for Website Review Queue 



-- Execution		 : [dbo].[sp_WebsiteReviewQueueSearch] 'ALL','29712221, 29712040','11/10/2015','11/24/2015',0



-- Updated By		 : 



--===========================================================================================================







CREATE PROCEDURE [dbo].[sp_WebsiteReviewQueueSearch]



(



@MarketCode VARCHAR(MAX)='',



@UserId AS VARCHAR(MAX),



@AdDateFromParm AS VARCHAR(MAX)='', 



@AdDateToParm AS VARCHAR(MAX)='',



@ExpectedforAudit AS BIT



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







		IF(@MarketCode<>'ALL')



				BEGIN



					SET @MarketCode=REPLACE((@MarketCode), ',' , ''',''')



					SET @MarketCode= ''''+@MarketCode+''''



					PRINT @MarketCode



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







		--SET @SelectStmnt ='SELECT OccurrenceID,Advertiser,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,



		--Market,convert(varchar,AdDate,101) AS AdDate,ImageAge,OfficeLocation,AdID, 



		--[User].FName+' '+[User].LName  +''/''+CONVERT(VARCHAR,CAST(AuditDate as DATETIME),110)+'' ''+CONVERT(VARCHAR,CAST(AuditDate as DATETIME),108) AS AuditBy,



		--PatternMasterID,TradeclassID,LocationCode,MarketID,LanguageId,Language,AdvertiserID FROM [dbo].[vw_WebsiteReivewQueueData] left join [User] on vw_WebsiteReivewQueueData.AuditByUser=[User].UserID'



		IF(@EXPECTEDFORAUDIT=1)



				BEGIN



				--Change 0.1 to required Value to change Total Value Records Taken By Auditor



				DECLARE @AuditCount AS INTEGER



				DECLARE @AuditRecords AS INTEGER



				SELECT @AuditCount=Count(*) FROM [dbo].[vw_WebsiteReivewQueueData]



				SET @AuditRecords= @AuditCount*0.1



					SET @SelectStmnt ='SELECT TOP ' +CONVERT(VARCHAR,@AuditRecords)+' OccurrenceID,Advertiser,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,



					Market,convert(varchar,AdDT,101) AS AdDate,ImageAge,OfficeLocation,AdID, 



					[User].FName+'' ''+[User].LName  +''/''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),110)+'' ''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),108) AS AuditBy,



					PatternMasterID,TradeclassID,LocationCode,MarketID,LanguageId,Language,AdvertiserID 



					FROM [dbo].[vw_WebsiteReivewQueueData] 



					left join [User] on vw_WebsiteReivewQueueData.AuditByUser=[User].UserID'



				END

				ELSE

				BEGIN

					SET @SelectStmnt ='SELECT OccurrenceID,Advertiser,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,



					Market,convert(varchar,AdDT,101) AS AdDate,ImageAge,OfficeLocation,AdID, 



					[User].FName+'' ''+[User].LName  +''/''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),110)+'' ''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),108) AS AuditBy,



					PatternMasterID,TradeclassID,LocationCode,MarketID,LanguageId,Language,AdvertiserID 



					FROM [dbo].[vw_WebsiteReivewQueueData] 



					left join [User] on vw_WebsiteReivewQueueData.AuditByUser=[User].UserID'



				END



				







		SET @Orderby=' ORDER BY Priority,AdDT, Advertiser,OccurrenceID'







		SET @Where=' WHERE (1=1) AND (Query IS NULL   OR Query=0) '







		IF( @AdDateFromParm <> '' AND @AdDateToParm <> '' ) 



			BEGIN 



				--SET @Where= @where + ' AND  CONVERT(VARCHAR,CAST(AdDate as DATE),110) BETWEEN  '''  + convert(varchar,cast(@AdDateFromParm as date),110)  + ''' AND  '''  + convert(varchar,cast(@AdDateToParm as date),110) + '''' 																		

				SET @Where= @where + ' AND  CAST(AdDT as DATE) BETWEEN  '''  + convert(varchar,cast(@AdDateFromParm as date),110)  + ''' AND  '''  + convert(varchar,cast(@AdDateToParm as date),110) + '''' 	

			END 







		IF(@UserId<>'ALL')



			BEGIN



				SET @Where= @Where + ' AND [dbo].[vw_WebsiteReivewQueueData].UserId in ('+@UserId+')'



			END







		IF(@MarketCode<>'ALL')



			BEGIN



				SET @Where= @Where + ' AND MarketId in ('+@MarketCode+')'



			END







		--IF(@ExpectedforAudit=1)



		--	BEGIN



		--		SET @Where= @where + ' OR OCCURRENCESTATUS ='''+@ExpectedforAudit+''''



		--	END







		SET @Stmnt=@SelectStmnt + @Where + @Orderby



		PRINT @Stmnt 



		EXECUTE Sp_executesql @Stmnt 



				



		END TRY 			



	



		BEGIN CATCH 



			DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 



			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 



			RAISERROR ('[sp_WebsiteReviewQueueSearch]: %d: %s',16,1,@error,@message,@lineNo);          



		END CATCH 







END