
-- =============================================
-- Author			:	Imtiaz Khan
-- Create date		:	07/28/2015
-- Description		:	Get Exception Media Stream
-- Execution		: [sp_ExceptionQueueLoadMediastream] 'TV,CIN'
-- Updated By		: Karunakar on 7th Sep 2015
-- =============================================

CREATE PROCEDURE [dbo].[sp_ExceptionQueueLoadMediastream]
(
@MediaStreamIdlist AS NVARCHAR(MAX)=''
)
AS

BEGIN
	
	DECLARE @MediaStreamIds NVARCHAR(MAX)
	SET @MediaStreamIdlist=REPLACE((@MediaStreamIdlist), ',' , ''',''')
	SET @MediaStreamIdlist= ''''+@MediaStreamIdlist+''''
			
	Declare @SQLSTMNT AS NVARCHAR(MAX)
	 
	 SET @SQLSTMNT='SELECT VALUE As MediaStreamId,ValueTitle as MediaStream	 from configurationMaster 
	WHERE ComponentName=''Media Stream'' AND VALUE IN ('+@MediaStreamIdlist+')'

	EXECUTE SP_EXECUTESQL @SQLSTMNT
END