-- =============================================================================================================
-- Author		: Govardhan.R
-- Create date	: 10/09/2015
-- Description	: This stored procedure is used to get the master data .
-- Execution	: [sp_CPGetMasterDataInAdClassQueryForm] 'Cinema'
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPGetMasterDataInAdClassQueryForm]
(
@MediaStream varchar(50)
)
AS
BEGIN

select ValueTitle,Value FROM [Configuration]
WHERE SystemName = 'All' AND ComponentName ='Query Category'

select '--Select--'[NAME],0[USERID] 
union all
SELECT FNAME+' '+LNAME [NAME],USERID FROM [USER]


SELECT * FROM [Configuration] WHERE valuegroup in 
(
SELECT VALUE FROM [Configuration] where ValueTitle=@MediaStream and 
SystemName='All' and ComponentName='Media Stream'
) and componentname='Creative File Type'

END
