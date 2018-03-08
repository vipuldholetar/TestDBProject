
-- =============================================
-- Author:		Murali
-- Create date: 15th July 2015
-- Description:	This Procedure is Used to Delete Record for CreativeSignature from PatternMasterStagingTV in Television 
-- =============================================
CREATE PROCEDURE [dbo].[sp_TelevisionDeleteCreativeSignaturefromQueue]
	@CreativeSignature AS  NVarchar(max)
AS
BEGIN
	
	SET NOCOUNT ON;
    delete from [PatternStaging] Where [CreativeSignature] = @CreativeSignature
END