-- ==================================================================================================================

-- Author		:   Arun Nair

-- Create date	:	25/05/2015

-- Description	:   Load Circular Review Queue

-- Execution	:   [dbo].[sp_CircularReviewQueueSearchData] '1/25/2016',-1,-1,0

-- Updated By	:	Arun Nair On 28/05/2015 for changes Stated by Ron on TotalVolume ExpectedforAudit

--				:	Karunakar on 7th Sep 2015 : MONIKA ON 25TH JAN 2016 (AD DATE FORMAT IN SELECT STATEMENT

--===================================================================================================================

CREATE PROCEDURE  [dbo].[sp_CircularReviewQueueSearchData] --'8/25/2015',-1,-1,0

(

@AdDate AS  VARCHAR(50)='',

@UserID AS INT,

@MarketID AS INT,

@EXPECTEDFORAUDIT AS BIT

)

AS

BEGIN

		SET NOCOUNT ON;

		

				--Load Circular Review Queue Data	



				DECLARE @Stmnt AS NVARCHAR(max)='' 

				DECLARE @SelectStmnt AS NVARCHAR(max)='' 

				DECLARE @Where AS NVARCHAR(max)=''      

				DECLARE @Orderby AS NVARCHAR(max)='' 



		BEGIN TRY

				

				IF(@EXPECTEDFORAUDIT=1)

				BEGIN

				--Change 0.1 to required Value to change Total Value Records Taken By Auditor

				DECLARE @AuditCount AS INTEGER

				DECLARE @AuditRecords AS INTEGER

				SELECT @AuditCount=Count(*) FROM [dbo].[vw_CircularOccurrences]

				SET @AuditRecords= @AuditCount*0.1



				SET @SelectStmnt ='SELECT TOP '+CONVERT(VARCHAR,@AuditRecords)+' OccurrenceDetailCIRID,Advertiser,AdvertiserId As AdvertiserID,OccurrenceStatus,MapStatus AS MapIndexStatus,IndexStatus,Scanstatus,QCStatus,

				RouteStatus,FlashInd AS Flash,OccurrenceCIRPriority AS Priority,CONVERT(VARCHAR,CAST(AdDate as DATE),101) AS AdDate,MediaTypeDescription AS MediaType,

				TradeClass,[PageCount],AdId AS AdID,'''' AS SIMR,QueryCateGory,QueryText,QueryAnswer,ModifiedByID,

				MarketID,MarketDescription,Language,LanguageID As LanguageId,AuditBy,AuditDTM,(AuditBy +''/''+ AuditDTM) AS AuditedByOn,Createddt FROM [dbo].[vw_CircularOccurrences]'

				END	

				ELSE

				BEGIN

				SET @SelectStmnt ='SELECT OccurrenceDetailCIRID,Advertiser,AdvertiserId As AdvertiserID,OccurrenceStatus,MapStatus AS MapIndexStatus,IndexStatus,Scanstatus,QCStatus,

				RouteStatus,FlashInd AS Flash,OccurrenceCIRPriority AS Priority,CONVERT(VARCHAR,CAST(AdDate as DATE),101) AS AdDate,MediaTypeDescription AS MediaType,

				TradeClass,[PageCount],AdId AS AdID,'''' AS SIMR,QueryCateGory,QueryText,QueryAnswer,ModifiedByID,

				MarketID,MarketDescription,Language,LanguageID As LanguageId,AuditBy,AuditDTM,(AuditBy + ''/''+AuditDTM) AS AuditedByOn,Createddt FROM [dbo].[vw_CircularOccurrences]'

				END

				SET @Orderby=' ORDER BY FlashInd DESC, OccurrenceCIRPriority,AdDate, Advertiser,OccurrenceDetailCIRID'



				SET @Where=' WHERE (1=1) AND (Query<>1 OR Query IS NULL)'



				IF(@AdDate <> '')

				BEGIN

				SET @Where =@Where + ' AND convert(VARCHAR,cast(AdDate as DATE),110) ='''  + convert(VARCHAR,cast(@AdDate as DATE),110) + ''''

				END



				IF(@UserID <> -1)

				BEGIN

				--SET @Where =@Where + ' AND ModifiedBy ='''+Convert(VARCHAR,@UserID)+''' AND ModifiedBy IS NOT NULL'
				SET @Where =@Where + ' AND ModifiedByID ='''+Convert(VARCHAR,@UserID)+''''

				END



				IF(@MarketID <> -1)

				BEGIN

				SET @Where =@Where + ' AND MarketID ='''+Convert(VARCHAR,@MarketID)+''' AND MarketID IS NOT NULL '

				END			

				SET @Stmnt=@SelectStmnt + @Where + @Orderby

				PRINT @Stmnt 

				EXECUTE Sp_executesql @Stmnt 

		END TRY



		BEGIN CATCH

			 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 

			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

			 RAISERROR ('[sp_CircularReviewQueueSearchData]: %d: %s',16,1,@error,@message,@lineNo); 

		END CATCH





END