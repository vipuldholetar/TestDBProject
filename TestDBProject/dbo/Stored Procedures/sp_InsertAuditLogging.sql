/****** Object:  StoredProcedure [dbo].[sp_InsertAuditLogging]    Script Date: 6/9/2016 10:27:41 AM ******/
CREATE PROCEDURE [dbo].[sp_InsertAuditLogging] 
	-- Add the parameters for the stored procedure here
	@UserID int = 0, 
	--@OccurrenceID int = 0,
	@idType varchar(20) ,
	@idValue int  = 0 ,
	@Action varchar(50),
	@MediaType int = 0,
	@CreatedDT datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Insert INTO AuditLogging (UserID, idType,idvalue, [Action], MediaType, [Update], CreatedDT)
	
	VALUES (@UserID, @idType,@idValue, @Action, @MediaType, NULL, @CreatedDT)
END