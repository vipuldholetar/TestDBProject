-- =============================================
-- Author			:	Karunakar
-- Create date		:	17th July 2015
-- Description		:	This PRocedure is Used to Delete Record for CreativeSignature from PatternMasterStagingCIN in Outdoor 
-- Execution		:	sp_CinemaDeleteCreativeSignaturefromQueue 
-- Updated By		:	Karunakar on 7th Sep 2015 
-- =============================================
CREATE PROCEDURE [dbo].[sp_CinemaDeleteCreativeSignaturefromQueue]
	@CreativeSignature AS  NVarchar(max)
AS
BEGIN
	
	SET NOCOUNT ON;
	-- Deleting PatternMasterStgCin Record
    delete from [PatternStaging] Where [CreativeSignature]=@CreativeSignature
END