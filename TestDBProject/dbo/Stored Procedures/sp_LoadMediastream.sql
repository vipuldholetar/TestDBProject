
-- ===================================================================
-- Author			: Imtiaz Khan
-- Create date		: 07/31/2015
-- Description		: Get Exception Media Stream
-- Execution Process: [sp_LoadMediastream] 'TV,CIN'
-- Updated By		: Arun Nair on 09/23/2015 - Added Exception Handling
-- ====================================================================

CREATE PROCEDURE [dbo].[sp_LoadMediastream]
(
@MediaStreamIdlist AS NVARCHAR(MAX)=''
)
AS
SET NOCOUNT ON;
BEGIN
	BEGIN TRY
		DECLARE @MediaStreamIds NVARCHAR(MAX)
		SET @MediaStreamIdlist=REPLACE((@MediaStreamIdlist), ',' , ''',''')
		SET @MediaStreamIdlist= ''''+@MediaStreamIdlist+''''	
		DECLARE @SQLSTMNT AS NVARCHAR(MAX)
	 
	   SET @SQLSTMNT='SELECT VALUE As MediaStreamID, ValueTitle as MediaStream from Configuration WHERE ComponentName = ''Media Stream'' AND VALUE IN ('+@MediaStreamIdlist+')'
	   EXECUTE SP_EXECUTESQL @SQLSTMNT
	END TRY
	BEGIN CATCH 
		DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		RAISERROR ('sp_LoadMediastream: %d: %s',16,1,@error,@message,@lineNo); 
	END CATCH 

END
