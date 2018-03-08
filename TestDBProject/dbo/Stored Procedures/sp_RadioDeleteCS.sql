
-- ================================================================================
-- Author			:Karunakar
-- Create date		:04/16/2015
-- Description		:This stored procedure is used to delete record form Queue
-- Execution Process:[Ino_raq_deletercscreativefromqueue] 'M2207953-20297041'
-- Updated By		: Arun Nair On 08/10/2015 -Naming Conventions,CleanUp ONEMT	
-- =================================================================================
CREATE PROCEDURE [dbo].[sp_RadioDeleteCS]
	@pCreativeSignatureId As Varchar(50)
AS
BEGIN	
  SET NOCOUNT ON;
		BEGIN TRY
			BEGIN TRANSACTION
				Update  [RCSCreative] set [Deleted]=1 where [RCSCreative].[RCSCreativeID]=@pCreativeSignatureId
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH 
				ROLLBACK TRANSACTION
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('sp_RadioDeleteCS: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH
END
