/****** Object:  StoredProcedure [dbo].[sp_UpdateRCSPriority]    Script Date: 7/22/2016 6:05:11 PM ******/
CREATE PROCEDURE [dbo].[sp_UpdateRCSPriority] (
    @RCSAcctID int,
    @Priority int
)

AS
BEGIN
    UPDATE RCSCreative 
    SET 
		[Priority] = @Priority
    WHERE 
        RCSAcctID = @RCSAcctID
END