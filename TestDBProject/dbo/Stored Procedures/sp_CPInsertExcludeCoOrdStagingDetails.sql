-- =============================================
-- Author:		Monika. J
-- Create date: 11/20/15
-- Description:	To Insert Exclude Data into Staging table
-- =============================================
CREATE PROCEDURE sp_CPInsertExcludeCoOrdStagingDetails 
	-- Add the parameters for the stored procedure here
	@X1 int,
	@X2 int,
	@Y1 int,
	@Y2 INT,
	@CreativeContentDetailStaging INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here
	BEGIN TRANSACTION
    -- Insert statements for procedure here
	INSERT INTO CropDetailExcludeStaging
			([ContentDetailStagingID],
			CropRectCoordX1,
			CropRectCoordY1,
			CropRectCoordX2,
			CropRectCoordY2)
	VALUES(@CreativeContentDetailStaging,
			@X1,
			@Y1,
			@X2,
			@Y2
		  )
   COMMIT TRANSACTION
	END TRY
	BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('sp_CPInsertExcludeCoOrdStagingDetails: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION
	END CATCH 
END
