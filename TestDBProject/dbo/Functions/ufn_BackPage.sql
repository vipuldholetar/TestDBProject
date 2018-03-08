CREATE FUNCTION ufn_BackPage (@CreativemasterID int,@MediaStreamID int)
RETURNS Varchar(200)
AS
  BEGIN 
    DECLARE @backPage varchar(200)
	DECLARE @MediaStreamVal as Varchar(20)

	SET @MediaStreamVal=(Select Value From [Configuration] where Componentname='Media Stream' and Configurationid=@MediaStreamID)

	IF(@MediaStreamVal='CIR')
	BEGIN
		SELECT @backPage = CreativeRepository+CreativeAssetName FROM creativedetailCIR WHERE creativemasterid = @CreativemasterID order BY CreativeDetailID asc 	
	END
	IF(@MediaStreamVal='PUB')
	BEGIN
		SELECT @backPage = CreativeRepository+CreativeAssetName FROM creativedetailPUB WHERE creativemasterid = @CreativemasterID order BY CreativeDetailID asc 
	END
	IF(@MediaStreamVal='EM')
	BEGIN
		SELECT @backPage = CreativeRepository+CreativeAssetName FROM creativedetailEM WHERE creativemasterid = @CreativemasterID order BY [CreativeDetailsEMID] asc 	
	END
	IF(@MediaStreamVal='SOC')
	BEGIN
		SELECT @backPage = CreativeRepository+CreativeAssetName FROM creativedetailSOC WHERE creativemasterid = @CreativemasterID order BY [CreativeDetailSOCID] asc 	
	END
	IF(@MediaStreamVal='WEB')
	BEGIN
		SELECT @backPage = CreativeRepository+CreativeAssetName FROM creativedetailWEB WHERE creativemasterid = @CreativemasterID order BY [CreativeDetailWebID] asc 	
	END
    RETURN @backPage
  END
