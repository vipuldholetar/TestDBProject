



-- =============================================
-- Author			:	Ramesh Bangi
-- Create date		:	9/18/2015
-- Description		:	Deletes Record for CreativeSignature from PatternMasterStg
-- Execution		:	[sp_OnlineVideoDeleteCSfromQueue] 
-- Updated By		:	 
-- =============================================
CREATE PROCEDURE [dbo].[sp_OnlineVideoDeleteCSfromQueue]
	@CreativeSignature AS  NVARCHAR(max)
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @CreativeMasterStgid AS INT
	SELECT @CreativeMasterStgid=[CreativeStagingID] from [CreativeStaging] Where CreativeSignature=@CreativeSignature
	-- Deleting PatternMasterStg Record
    DELETE FROM [PatternStaging] WHERE  [CreativeStgID]=@CreativeMasterStgid
END