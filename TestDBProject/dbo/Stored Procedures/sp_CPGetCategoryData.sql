CREATE PROCEDURE sp_CPGetCategoryData
AS
BEGIN
	BEGIN TRY
		--USER MASTER DATA
		SELECT 0[VALUE],'ALL'[VALUETITLE]
		UNION ALL
		SELECT [RefCategoryGroupID] as [VALUE],[CategoryGroupName]as  [VALUETITLE] FROM [dbo].[RefCategoryGroup]
		
	
	END TRY
BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_CPGetCategoryData: %d: %s',16,1,@error,@message,@lineNo); 
			 -- ROLLBACK TRANSACTION
END CATCH 
END
