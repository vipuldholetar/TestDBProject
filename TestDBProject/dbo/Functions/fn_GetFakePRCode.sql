CREATE FUNCTION [dbo].[fn_GetFakePRCode] 
(
	-- Add the parameters for the function here
	 @OriginalPRCode nvarchar(20) 
)
RETURNS varchar(100)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar varchar(100)
	declare @tvMMfakeprcode varchar(100)
	declare @tvEthnicfakeprcode varchar(100)


	-- Add the T-SQL statements to compute the return value here
	set @tvEthnicfakeprcode=(select [TVEthnicPRCodeID] from [TVEthnicPRCode] where OriginalPRCode = @OriginalPRCode)
	select @tvMMfakeprcode=Coalesce(@tvMMfakeprcode+';','')+ [TVMMPRCodeCODE] from [TVMMPRCode] where OriginalPatternCode = @OriginalPRCode

IF @tvEthnicfakeprcode<>''
BEGIN

IF @tvMMfakeprcode<>''
BEGIN
set @ResultVar=@tvEthnicfakeprcode+','+@tvMMfakeprcode
END
ELSE
BEGIN
set @ResultVar=@tvEthnicfakeprcode
END

END
else
begin
set @ResultVar=@tvMMfakeprcode
end

	-- Return the result of the function
	RETURN @ResultVar

END
