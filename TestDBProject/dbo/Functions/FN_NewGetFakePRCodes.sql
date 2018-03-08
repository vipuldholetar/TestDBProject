CREATE FUNCTION [FN_NewGetFakePRCodes] 
(
	@OriginalPRCode nvarchar(20) 
)
RETURNS @retContactInformation TABLE 
(
	ERRORCODES nvarchar(50)
)
AS
BEGIN
	Insert into @retContactInformation(ERRORCODES)
	(select [TVEthnicPRCode].[TVEthnicPRCodeID] +',' 
		+convert(nvarchar,[TVMMPRCode].[TVMMPRCodeCODE]) 
		from [TVEthnicPRCode]
		 inner join [TVMMPRCode]
		on [TVMMPRCode].OriginalPatternCode = [TVEthnicPRCode].OriginalPRCode  
		where OriginalPatternCode = @OriginalPRCode)
	
	RETURN ;
END
