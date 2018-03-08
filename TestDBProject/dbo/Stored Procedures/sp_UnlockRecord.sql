-- =============================================
-- Author:		Ashanie Cole
-- Create date: May 2016
-- Description:	unlock records
-- =============================================
CREATE PROCEDURE [dbo].[sp_UnlockRecord] 
    @EntityID varchar(255),
    @EntityName varchar(50),
    @UserID int,
    @OUTUnLockStatus bit = 0 OUTPUT
AS
BEGIN
    DELETE FROM ActiveLock
    WHERE EntityID = @EntityID AND EntityName = @EntityName AND LockedBy = @UserID

    IF @@ERROR <> 0
	   SET @OUTUnLockStatus = 0    
    ELSE
	   SET @OUTUnLockStatus = 1  
END