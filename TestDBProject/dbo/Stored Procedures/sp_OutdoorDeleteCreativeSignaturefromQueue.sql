-- =============================================
-- Author:		Karunakar
-- Create date: 14th July 2015
-- Description:	This PRocedure is Used to Delete Record for CreativeSignature from PatternMasterStagingODR in Outdoor 
-- =============================================
CREATE PROCEDURE sp_OutdoorDeleteCreativeSignaturefromQueue
	@CreativeSignature AS  NVarchar(max)
AS
BEGIN
	
	SET NOCOUNT ON;
    delete from [PatternStaging] Where [CreativeSignature]=@CreativeSignature
END