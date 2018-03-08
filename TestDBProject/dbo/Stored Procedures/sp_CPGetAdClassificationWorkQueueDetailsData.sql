-- =============================================================================================================
-- Author		: Govardhan.R
-- Create date	: 10/07/2015
-- Description	: This stored procedure is used to get the details of an AD.
-- Execution	: [sp_CPGetAdClassificationWorkQueueDetailsData]
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPGetAdClassificationWorkQueueDetailsData]
(
@AdId varchar(50)
)
AS
BEGIN
SELECT LeadAvHeadline[LeadAudioHeadline],RecutAdId[OriginalAdID],RecutDetail[RevisionDetail],
(SELECT TOP 1 (CM.VALUETITLE+' | '+QD.QUERYTEXT+' | '+QD.[QryAnswer])[QA]
 FROM [QueryDetail] QD
INNER JOIN [Configuration] CM ON QD.QUERYCATEGORY=CM.VALUE
WHERE CM.SYSTEMNAME='All' AND
CM.COMPONENTNAME='Query Category'
AND QD.SYSTEM='C&P'
and QD.EntityLevel='AD'
AND QD.[AdID]=A.[AdID])[QA],
(SELECT (CM.ThmbnlRep+'\'+CM.AssetThmbnlName)[IMAGE] FROM
[Creative] CM 
WHERE CM.PRIMARYINDICATOR=1
AND CM.[AdId]=A.[AdID])[IMAGE]
FROM AD A
WHERE A.[AdID]=@AdId


END
