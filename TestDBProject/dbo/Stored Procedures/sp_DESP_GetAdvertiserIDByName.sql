-- =============================================
-- Author:		Lisa East
-- Create date: 8.24.17
-- Description:	Returns the AdvertiserID for th AdvertiserName entered
-- =============================================
CREATE PROCEDURE [dbo].[sp_DESP_GetAdvertiserIDByName]
	-- Add the parameters for the stored procedure here
@AdvName as varchar(50)=''
AS
BEGIN

	SET NOCOUNT ON;

    
	If @AdvName='' 
		SELECT AdvertiserID, Descrip as AdvertiserName from Advertiser 
	else
		SELECT  AdvertiserID, Descrip as AdvertiserName from Advertiser where Descrip=@AdvName
END
