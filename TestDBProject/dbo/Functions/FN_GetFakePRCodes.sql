CREATE FUNCTION [dbo].[FN_GetFakePRCodes]
(	
	    @OriginalPRCode nvarchar(20) 
)

RETURNS TABLE 

AS

RETURN 

(
	select COALESCE([TVEthnicPRCode].[TVEthnicPRCodeID] , [TVMMPRCode].[TVMMPRCodeCODE] )   as FakePR
		from  [TVMMPRCode]
		 full join [TVEthnicPRCode]
		on [TVMMPRCode].OriginalPatternCode = [TVEthnicPRCode].OriginalPRCode  
		where OriginalPatternCode = (@OriginalPRCode)	
 )
--select * from TvEthnicPrCodes where OriginalPRCode = '03457W6J.WA0'
--select * from TVMMPrCodes where OriginalPatternCode = '03457W6J.WA0'
--select * from [dbo].[FN_GetFakePRCodes]('03457W6J.WA0')

--Select * from TVMMPrCodes
