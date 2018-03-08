-- =============================================
-- Author		:	Karunakar			
-- Create date	:	31st August 2015
-- Description	:	This Procedure is Used to getting All Non Print Media Streams 
-- =============================================
CREATE PROCEDURE [dbo].[sp_ReviewQueueMediaStreamData]

AS
BEGIN
	
	SET NOCOUNT ON;
	
	Select ConfigurationID As MediaStreamId,Value,ValueTitle As MediaStreamValue from [Configuration] 
	Where SystemName='All' and ComponentName='Media Stream' AND [Configuration].ValueGroup Not IN ('Print') 

    
END
