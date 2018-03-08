CREATE FUNCTION ufn_FrontPage (@CreativemasterID int,@MediaStreamID int)
RETURNS Varchar(200)
AS
  BEGIN 
    DECLARE @frontPage varchar(200)
	DECLARE @MediaStreamVal as Varchar(20)

	SET @MediaStreamVal=(Select Value From [Configuration] where Componentname='Media Stream' and Configurationid=@MediaStreamID)

	IF(@MediaStreamVal='CIR')
	BEGIN
		SELECT @frontPage = CreativeRepository+CreativeAssetName FROM creativedetailCIR WHERE creativemasterid = @CreativemasterID order BY CreativeDetailID desc 	
	END
	IF(@MediaStreamVal='PUB')
	BEGIN
		SELECT @frontPage = CreativeRepository+CreativeAssetName FROM creativedetailPUB WHERE creativemasterid = @CreativemasterID order BY CreativeDetailID desc 
	END
	IF(@MediaStreamVal='EM')
	BEGIN
		SELECT @frontPage = CreativeRepository+CreativeAssetName FROM creativedetailEM WHERE creativemasterid = @CreativemasterID order BY [CreativeDetailsEMID] desc 	
	END
	IF(@MediaStreamVal='SOC')
	BEGIN
		SELECT @frontPage = CreativeRepository+CreativeAssetName FROM creativedetailSOC WHERE creativemasterid = @CreativemasterID order BY [CreativeDetailSOCID] desc 	
	END
	IF(@MediaStreamVal='WEB')
	BEGIN
		SELECT @frontPage = CreativeRepository+CreativeAssetName FROM creativedetailWEB WHERE creativemasterid = @CreativemasterID order BY [CreativeDetailWebID] desc 	
	END
    RETURN @frontPage
  END
