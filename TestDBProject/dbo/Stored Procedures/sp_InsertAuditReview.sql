/****** Object:  StoredProcedure [dbo].[sp_InsertAuditReview]    Script Date: 6/7/2016 12:45:14 PM ******/
CREATE PROCEDURE [dbo].[sp_InsertAuditReview] 
	-- Add the parameters for the stored procedure here
	@UserID int = 0, 
	@OccurrenceID int = 0,
	@OccurrenceMediaType int = 0,
	@Action varchar(50)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Insert INTO AuditReview (UserID, OccurrenceID, OccurrenceMediaType, Action, CreatedDT, AuditedDT, AuditedBy)
	 
	VALUES 
	(@UserID, @OccurrenceID, @OccurrenceMediaType, @Action, GetDate(), NULL, NULL)

END