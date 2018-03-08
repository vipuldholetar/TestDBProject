
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[sp_UpdateCreativeAssetName]
	-- Add the parameters for the stored procedure here
@AdID as Int,
@CreativeSignature as NVarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   update [CreativeDetailRA] set LegacyAssetName =@AdId,assetName=@AdID where creativeid in (select distinct creativeid from Pattern where CreativeSignature=@creativeSignature)

END
