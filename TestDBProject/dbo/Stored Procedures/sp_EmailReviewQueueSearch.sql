
--===========================================================================================================
-- Author            : Ramesh Bangi
-- Create date       : 11/2/2015
-- Description       : Get Occurrence Data for Email Review Queue 
-- Execution		 : [dbo].[sp_EmailReviewQueueSearch] 'ALL','ALL','10/1/2015','11/4/2015',1
-- Updated By		 : 
--===========================================================================================================
CREATE PROCEDURE [dbo].[sp_EmailReviewQueueSearch]
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
              --Declare @InProgressStatus as nvarchar(max)
              --Declare @NoTakeStatus as nvarchar(max)
              --Declare @CompleteStatus as nvarchar(max)
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
              --SELECT @InProgressStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'P'
              --SELECT @NoTakeStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'NT'
              --SELECT @CompleteStatus = valuetitle FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'C'
              IF(@EXPECTEDFORAUDIT=1)
                           BEGIN
                           --Change 0.1 to required Value to change Total Value Records Taken By Auditor
                           DECLARE @AuditCount AS INTEGER
                           DECLARE @AuditRecords AS INTEGER
                           SELECT @AuditCount=Count(*) FROM [dbo].[vw_EmailReivewQueueData]
                           SET @AuditRecords= @AuditCount*0.1
                                  --SET @SelectStmnt ='SELECT TOP ' +CONVERT(VARCHAR,@AuditRecords)+' OccurrenceID,Advertiser,Subject,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,
                                  --Market,convert(varchar,AdDT,101) AS AdDate,ImageAge,OfficeLocation,AdID,
                                  --[User].FName+'' ''+[User].LName  +''/''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),110)+'' ''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),108) AS AuditBy,
                                  --Sender,SourceEmail,LPURL,DistributionDT,PatternMasterID,TradeclassID,LocationCode,MarketID,LanguageId,Language,AdvertiserID,ParentOccurrenceId
                                  --FROM [dbo].[vw_EmailReivewQueueData]
                                  --left join [User] on vw_EmailReivewQueueData.AuditByUser=[User].UserID'
 
                                  SET @SelectStmnt ='SELECT TOP ' +CONVERT(VARCHAR,@AuditRecords)+' vw_EmailReivewQueueData.OccurrenceID,
 
                                  CASE WHEN NOT EXISTS(select distinct top 1 AdvertiserEmail.AdvertiserEmailID from AdvertiserEmail where AdvertiserEmail.AdvertiserEmailID=vw_EmailReivewQueueData.SourceEmail and vw_EmailReivewQueueData.AdvertiserID=17542)
                                  THEN Advertiser  ELSE RIGHT(AdvertiserEmail.Email, LEN(AdvertiserEmail.Email) - CHARINDEX(''@'', AdvertiserEmail.email)) END AS Advertiser
                                  ,Subject,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,vw_EmailReivewQueueData.SourceEmail,
                                  Market,convert(varchar,AdDT,101) AS AdDate,ImageAge,OfficeLocation,AdID,
                                  [User].FName+'' ''+[User].LName  +''/''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),110)+'' ''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),108) AS AuditBy,
                                  Sender,SourceEmail,LPURL,DistributionDT,PatternMasterID,TradeclassID,LocationCode,vw_EmailReivewQueueData.MarketID,LanguageId,Language,vw_EmailReivewQueueData.AdvertiserID,ParentOccurrenceId
                                  FROM [dbo].[vw_EmailReivewQueueData] left join [User] on vw_EmailReivewQueueData.AuditByUser=[User].UserID
                                  JOIN (SELECT advertiserid, Min(occurrenceid) occurrenceid,Subject,AdDate FROM [dbo].[vw_EmailWorkQueueData] GROUP BY advertiserid,Subject,AdDate) AS subEmailWorkQueue ON vw_EmailReivewQueueData.OccurrenceID = subEmailWorkQueue.occurrenceid
                                  left join  AdvertiserEmail on vw_EmailReivewQueueData.SourceEmail=AdvertiserEmail.AdvertiserEmailID'
 
 
                           END
                           ELSE
                           BEGIN
                                  --SET @SelectStmnt ='SELECT OccurrenceID,Advertiser,Subject,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,
                                  --Market,convert(varchar,AdDT,101) AS AdDate,ImageAge,OfficeLocation,AdID,
                                  --[User].FName+'' ''+[User].LName  +''/''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),110)+'' ''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),108) AS AuditBy,
                                  --Sender,SourceEmail,LPURL,DistributionDT,PatternMasterID,TradeclassID,LocationCode,MarketID,LanguageId,Language,AdvertiserID,ParentOccurrenceId
                                  --FROM [dbo].[vw_EmailReivewQueueData]
                                  --left join [User] on vw_EmailReivewQueueData.AuditByUser=[User].UserID'
                                  SET @SelectStmnt =' SELECT vw_EmailReivewQueueData.OccurrenceID,
                                  CASE WHEN NOT EXISTS(select distinct top 1 AdvertiserEmail.AdvertiserEmailID from AdvertiserEmail where AdvertiserEmail.AdvertiserEmailID=vw_EmailReivewQueueData.SourceEmail and vw_EmailReivewQueueData.AdvertiserID=17542)                               
                                  THEN Advertiser  ELSE RIGHT(AdvertiserEmail.Email, LEN(AdvertiserEmail.Email) - CHARINDEX(''@'', AdvertiserEmail.email)) END AS Advertiser
                                  ,vw_EmailReivewQueueData.Subject,OccurrenceStatus,MapStatus,IndexStatus,ScanStatus,QCStatus,RouteStatus,Priority,Tradeclass,
                                  Market,convert(varchar,AdDT,101) AS AdDate,ImageAge,OfficeLocation,AdID,
                                  [User].FName+'' ''+[User].LName  +''/''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),110)+'' ''+CONVERT(VARCHAR,CAST(AuditedDT as DATETIME),108) AS AuditBy,
                                  Sender,SourceEmail,LPURL,DistributionDT,PatternMasterID,TradeclassID,LocationCode,vw_EmailReivewQueueData.MarketID,LanguageId,Language,vw_EmailReivewQueueData.AdvertiserID,ParentOccurrenceId
                                  FROM [dbo].[vw_EmailReivewQueueData] left join [User] on vw_EmailReivewQueueData.AuditByUser=[User].UserID
                                  JOIN (SELECT advertiserid, Min(occurrenceid) occurrenceid,Subject,AdDate FROM [dbo].[vw_EmailWorkQueueData] GROUP BY advertiserid,Subject,AdDate) AS subEmailWorkQueue ON vw_EmailReivewQueueData.OccurrenceID = subEmailWorkQueue.occurrenceid
                                  left join  AdvertiserEmail on vw_EmailReivewQueueData.SourceEmail=AdvertiserEmail.AdvertiserEmailID'
 
                           END
              SET @Orderby=' ORDER BY Priority,AdDT, Advertiser,OccurrenceID'
              SET @Where=' WHERE (1=1) AND (Query IS NULL   OR Query=0) AND ParentOccurrenceId IS NULL'
              IF( @AdDateFromParm <> '' AND @AdDateToParm <> '' )
                     BEGIN
                           SET @Where= @where + ' AND  CAST(AdDT as DATE) BETWEEN  '''  + convert(varchar,cast(@AdDateFromParm as date),110)  + ''' AND  '''  + convert(varchar,cast(@AdDateToParm as date),110) + ''''                                                                                                                          
                     END
              IF(@UserId<>'ALL')
                     BEGIN
                           SET @Where= @Where + ' AND vw_EmailReivewQueueData.UserId in ('+@UserId+')'
                     END
              IF(@MarketCode<>'ALL')
                     BEGIN
                           SET @Where= @Where + ' AND vw_EmailReivewQueueData.MarketId in ('+@MarketCode+')'
                     END
              --IF(@ExpectedforAudit=1)
              --     BEGIN
              --            SET @Where= @where + ' OR OCCURRENCESTATUS ='''+@ExpectedforAudit+''''
              --     END
              SET @Stmnt=@SelectStmnt + @Where + @Orderby
              PRINT @Stmnt
              EXECUTE Sp_executesql @Stmnt
              END TRY                   
              BEGIN CATCH
                     DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT
                     SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
                     RAISERROR ('[sp_EmailReviewQueueSearch]: %d: %s',16,1,@error,@message,@lineNo);         
              END CATCH
END