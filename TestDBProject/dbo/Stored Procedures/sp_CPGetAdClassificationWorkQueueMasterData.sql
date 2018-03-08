-- =============================================================================================================
-- Author		: Govardhan.R
-- Create date	: 10/05/2015
-- Description	: This stored procedure is used to get the MASTER data FOR AdClassification view.
-- Execution	: [sp_CPGetAdClassificationWorkQueueMasterData]
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPGetAdClassificationWorkQueueMasterData]
AS
BEGIN
BEGIN TRY
--MEDIA STREAM MASTER DATA
SELECT 0[VALUE],'ALL'[VALUETITLE]
UNION ALL
SELECT CONFIGURATIONID [VALUE],VALUETITLE FROM [Configuration] WHERE COMPONENTNAME='Media Stream' AND SYSTEMNAME='All' and CONFIGURATIONID not in (155,156)

--MASTER DATA FOR LANGUAGE MASTER
SELECT 0[VALUE],'ALL'[VALUETITLE]
UNION ALL
SELECT LANGUAGEID[VALUE],Description[VALUETITLE] FROM [Language]


SELECT DISTINCT CLASSIFICATIONGROUP,CLASSIFICATIONGROUPID FROM vw_ClassifyPromoAdClassificationWorkQueue
END TRY
BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_CPGetAdClassificationWorkQueueMasterData: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
END CATCH 
END