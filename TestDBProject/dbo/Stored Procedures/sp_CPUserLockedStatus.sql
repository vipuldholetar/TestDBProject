-- =============================================
-- Author:		Monika. J
-- Create date: 12-16-15
-- Description:	To get User locked status
-- sp_CPUserLockedStatus 29712222,12
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPUserLockedStatus] 
	-- Add the parameters for the stored procedure here
	@UserID int,
	@CropID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here
	DECLARE @Status INT
	DECLARE @UserName NVARCHAR(MAX)
	DECLARE @CreativeCropStgID INT
	DECLARE @ID INT	
	
	select distinct @CreativeCropStgID=[CreativeCropStagingID] from CompositeCropStaging where [CropID]=@CropID
	--select @CreativeCropStgID 11095
	if(Exists(select * from [CreativeForCropStaging] where [CreativeForCropStagingID]=@CreativeCropStgID))
		BEGIN
			IF(EXISTS(select [LockedByID] from [CreativeForCropStaging] where [LockedByID]=@UserID AND [CreativeForCropStagingID]=@CreativeCropStgID))	
				BEGIN
					select @ID=[LockedByID] from [CreativeForCropStaging] where [CreativeForCropStagingID]=@CreativeCropStgID	
					SELECT @UserName= FName + ' ' + LName FROM [USER] where UserID=@ID--29712222					
					SET @Status=1
				END
			ELSE
				BEGIN
					select @ID=[LockedByID] from [CreativeForCropStaging] where  [CreativeForCropStagingID]=@CreativeCropStgID					
					SELECT @UserName= FName + ' ' + LName FROM [USER] where UserID=@ID--29712222
					SET @Status=2
				END
		END
	ELSE
		BEGIN			
			SET @Status=1
		END

	SELECT @Status as Status,@UserName as UserName
	END TRY
	BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_CPUserLockedStatus: %d: %s',16,1,@error,@message,@lineNo); 
			 -- ROLLBACK TRANSACTION
END CATCH 
END
