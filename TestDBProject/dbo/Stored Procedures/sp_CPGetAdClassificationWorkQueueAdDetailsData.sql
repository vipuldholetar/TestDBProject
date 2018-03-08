-- =============================================================================================================



-- Author		: Govardhan.R



-- Create date	: 10/07/2015



-- Description	: This stored procedure is used to get the details of an AD.



-- Execution	: [sp_CPGetAdClassificationWorkQueueAdDetailsData] ''



-- ===============================================================================================================

CREATE PROCEDURE [dbo].[sp_CPGetAdClassificationWorkQueueAdDetailsData]
	(
	@AdId varchar(50),
	@Stream varchar(50)
	)
AS
BEGIN
	BEGIN TRY
			SELECT LeadAvHeadline[LeadAudioHeadline],RecutAdId[OriginalAdID],RecutDetail[RevisionDetail],
			(SELECT TOP 1 (CM.VALUETITLE+' | '+QD.QUERYTEXT+' | '+QD.[QryAnswer])[QA]
			 FROM [QueryDetail] QD
			INNER JOIN [Configuration] CM ON QD.QUERYCATEGORY=CM.VALUE
			WHERE CM.SYSTEMNAME='All' AND
			CM.COMPONENTNAME='Query Category'AND QD.SYSTEM='C&P'and QD.EntityLevel='AD'AND QD.[AdID]=A.[AdID])[QA],
			(SELECT top 1 (CM.ThmbnlRep+'\'+CM.AssetThmbnlName)[IMAGE] FROM
			[Creative] CM 
			WHERE CM.PRIMARYINDICATOR=1
			AND CM.[AdId]=A.[AdID])[IMAGE],[PrimaryOccurrenceID][PrimaryOccurrenceID],
			A.[AdvertiserID][AdvertiserId],A.[LanguageID],adv.Descrip Advertiser,LM.Description[LANGUAGENAME]
			FROM AD A
			inner join [Advertiser] adv on adv.[AdvertiserID]= A.[AdID]
			inner join [Language] LM on LM.LanguageID=A.[LanguageID]
			WHERE A.[AdID]=@AdId
	END TRY
	BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('sp_CPGetAdClassificationWorkQueueAdDetailsData: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION
	END CATCH 
END