


-- =============================================
-- Author			:	Ramesh Bangi
-- Create date		:	9/7/2015
-- Description		:	Deletes Record for CreativeSignature from PatternMasterStgOND
-- Execution		:	[sp_OnlineDisplayDeleteCSfromQueue] 
-- Updated By		:	 
-- =============================================
CREATE PROCEDURE [dbo].[sp_OnlineDisplayDeleteCSfromQueue]
	@CreativeSignature AS  NVARCHAR(max)
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @CreativeMasterStgid AS INT
	SELECT @CreativeMasterStgid=[CreativeStagingID] from [CreativeStaging] Where CreativeSignature=@CreativeSignature
	-- Deleting PatternMasterStg Record
    DELETE FROM [PatternStaging] WHERE  [CreativeStgID]=@CreativeMasterStgid
END