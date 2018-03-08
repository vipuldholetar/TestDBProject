-- =============================================
-- Author:		Ashanie Cole
-- Create date: May 2016
-- Description:	check lockstatus
-- =============================================
CREATE PROCEDURE [dbo].[sp_RecordLockStatus] 
    @EntityID varchar(50),
    @EntityName varchar(50),
    @OUTLockStatus bit = 0 OUTPUT,
    @OUTMessage varchar(100) ='' OUTPUT
AS
BEGIN
    
    IF EXISTS(SELECT EntityID FROM ActiveLock WHERE EntityID = @EntityID AND EntityName = @EntityName) 
    BEGIN
	   SELECT @OUTMessage = CONCAT('This record is currently locked by ', isnull(b.FName,''), ' ', isnull(b.LName,''), ' on ', a.FormName,'.  Please retry later.'), 
			 @OUTLockStatus = 1
	   FROM ActiveLock a left JOIN [User] b ON b.UserID = a.LockedBy
	   WHERE a.EntityID = @EntityID AND EntityName = @EntityName

	   RETURN 
    END
    ELSE
    BEGIN
	   SET @OUTLockStatus = 0
    END
    
    
END