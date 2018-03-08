-- =============================================
-- Author		:	Ashanie Cole			
-- Create date	:	December 2016
-- Description	:	Used to get All Media Streams 
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetMediaStreamList]

AS
BEGIN
	
	SET NOCOUNT ON;
	
	Select ConfigurationID As MediaStreamId,Value,ValueTitle As MediaStreamValue from [Configuration] 
	Where SystemName='All' and ComponentName='Media Stream'

    
END