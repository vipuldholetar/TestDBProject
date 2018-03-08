-- =============================================================================================================
-- Author		: Govardhan.R
-- Create date	: 10/05/2015
-- Description	: This stored procedure is used to get the data from AdClassification view.
-- Execution	: [sp_CPGetAdClassificationWorkQueueData] '144,145,146,147,148,149,150,151,152,153,154,155,156','0','08/13/15','10/12/15','1','0'
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPGetAdClassificationWorkQueueData]
(
@MediaStream varchar(250),
@LanguageId varchar(250),
@FirstRunDateFrom varchar(250),
@FirstRunDateTo varchar(250),
@Priority int,
@OnlyAdsWithCreative int
)
as
BEGIN 
--BEGIN TRY	
	IF (@OnlyAdsWithCreative=0)
		BEGIN
		PRINT('Without Creative');
			SELECT * FROM vw_ClassifyPromoAdClassificationWorkQueue VW
			WHERE VW.CONFIGURATIONID IN (SELECT Item FROM dbo.SplitString(@MediaStream, ','))
			AND VW.LANGUAGEID=(CASE WHEN @LanguageId='0' then VW.LANGUAGEID else @LanguageId end)
			--AND VW.LANGUAGEID IN (SELECT Item FROM dbo.SplitString(@LanguageId, ','))
			AND VW.FirstRunDate>= CONVERT(VARCHAR, @FirstRunDateFrom, 110) AND VW.FirstRunDate <= CONVERT(VARCHAR, @FirstRunDateTo, 110) 

			SELECT vw.ClassificationGroup[ClassificationGroup],count(distinct adid)[Count] FROM vw_ClassifyPromoAdClassificationWorkQueue VW
			WHERE VW.CONFIGURATIONID IN (SELECT Item FROM dbo.SplitString(@MediaStream, ','))
			AND VW.LANGUAGEID=(CASE WHEN @LanguageId='0' then VW.LANGUAGEID else @LanguageId end)
			--AND VW.LANGUAGEID IN (SELECT Item FROM dbo.SplitString(@LanguageId, ','))
			AND VW.FirstRunDate>= CONVERT(VARCHAR, @FirstRunDateFrom, 110) AND VW.FirstRunDate <= CONVERT(VARCHAR, @FirstRunDateTo, 110)
			group by vw.classificationgroup
			UNION 
			SELECT 'Priority' +CONVERT(VARCHAR,Priority)[ClassificationGroup], COUNT(distinct AdID)[Count]
			FROM [vw_ClassifyPromoAdClassificationWorkQueue] VW
			WHERE 1= (CASE WHEN @Priority=1 THEN 1 ELSE 0 END )
			AND VW.CONFIGURATIONID IN (SELECT Item FROM dbo.SplitString(@MediaStream, ','))
			AND VW.LANGUAGEID=(CASE WHEN @LanguageId='0' then VW.LANGUAGEID else @LanguageId end)
			--AND VW.LANGUAGEID IN (SELECT Item FROM dbo.SplitString(@LanguageId, ','))
			AND VW.FirstRunDate>= CONVERT(VARCHAR, @FirstRunDateFrom, 110) AND VW.FirstRunDate <= CONVERT(VARCHAR, @FirstRunDateTo, 110)
			GROUP BY Priority
	

		END
	IF (@OnlyAdsWithCreative=1)
		BEGIN
		PRINT('With Creative');
			SELECT distinct VW.* FROM vw_ClassifyPromoAdClassificationWorkQueue VW 
			INNER JOIN [Creative] CM ON CM.[AdId]=VW.ADID
			WHERE VW.CONFIGURATIONID IN (SELECT Item FROM dbo.SplitString(@MediaStream, ','))
			AND VW.LANGUAGEID=(CASE WHEN @LanguageId='0' then VW.LANGUAGEID else @LanguageId end)
			--AND VW.LANGUAGEID IN (SELECT Item FROM dbo.SplitString(@LanguageId, ','))
			AND VW.FirstRunDate>= CONVERT(VARCHAR, @FirstRunDateFrom, 110) AND VW.FirstRunDate <= CONVERT(VARCHAR, @FirstRunDateTo, 110) 
			AND CM.PrimaryIndicator=1

			SELECT vw.ClassificationGroup[ClassificationGroup],count(distinct vw.adid)[Count] FROM vw_ClassifyPromoAdClassificationWorkQueue VW 
			INNER JOIN [Creative] CM ON CM.[AdId]=VW.ADID
			WHERE VW.CONFIGURATIONID IN (SELECT Item FROM dbo.SplitString(@MediaStream, ','))
			AND VW.LANGUAGEID=(CASE WHEN @LanguageId='0' then VW.LANGUAGEID else @LanguageId end)
			--AND VW.LANGUAGEID IN (SELECT Item FROM dbo.SplitString(@LanguageId, ','))
			AND VW.FirstRunDate>= CONVERT(VARCHAR, @FirstRunDateFrom, 110) AND VW.FirstRunDate <= CONVERT(VARCHAR, @FirstRunDateTo, 110)
			AND CM.PrimaryIndicator=1
			group by vw.classificationgroup
			UNION 
			SELECT 'Priority' +CONVERT(VARCHAR,VW.Priority)[ClassificationGroup], COUNT(distinct vw.AdID)[Count]
			FROM [vw_ClassifyPromoAdClassificationWorkQueue] VW
			INNER JOIN [Creative] CM ON CM.[AdId]=VW.ADID
			WHERE 1= (CASE WHEN @Priority=1 THEN 1 ELSE 0 END )
			AND VW.CONFIGURATIONID IN (SELECT Item FROM dbo.SplitString(@MediaStream, ','))
			AND VW.LANGUAGEID=(CASE WHEN @LanguageId='0' then VW.LANGUAGEID else @LanguageId end)
			--AND VW.LANGUAGEID IN (SELECT Item FROM dbo.SplitString(@LanguageId, ','))
			AND VW.FirstRunDate>= CONVERT(VARCHAR, @FirstRunDateFrom, 110) AND VW.FirstRunDate <= CONVERT(VARCHAR, @FirstRunDateTo, 110)
			AND CM.PrimaryIndicator=1
			GROUP BY VW.Priority

		END
--END TRY
--		BEGIN CATCH 
--			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
--			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
--			  RAISERROR ('sp_CPGetAdClassificationWorkQueueData: %d: %s',16,1,@error,@message,@lineNo); 
--			  ROLLBACK TRANSACTION
--		END CATCH 

END