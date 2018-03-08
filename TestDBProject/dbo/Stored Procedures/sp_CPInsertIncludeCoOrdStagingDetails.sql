-- =============================================
-- Author:		Monika. J
-- Create date: 11/20/2015
-- Description:	To Insert Include CoOrdinates for the cropID
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPInsertIncludeCoOrdStagingDetails] 
	-- Add the parameters for the stored procedure here	
	@X1 INT,
	@X2 INT,
	@Y1 INT,
	@Y2 INT,
	@ContentDetStgID INT,
	@CompositeStgID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here
	BEGIN TRANSACTION
    -- Insert statements for procedure here
	INSERT INTO CropDetailIncludeStaging
			([CompositeCropStagingID],
			[ContentDetailStagingID],
			CropRectCoordX1,
			CropRectCoordY1,
			CropRectCoordX2,
			CropRectCoordY2)
	VALUES
			(@CompositeStgID,
			@ContentDetStgID,
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
				  RAISERROR ('sp_CPInsertIncludeCoOrdStagingDetails: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION
	END CATCH 
END
