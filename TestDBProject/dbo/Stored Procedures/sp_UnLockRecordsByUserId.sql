-- =============================================
-- Author:		Ashanie Cole
-- Create date: May 2016
-- Description:	unlock records by user
-- =============================================
create PROCEDURE [dbo].[sp_UnLockRecordsByUserId] 
    @UserID int,
    @OUTUnLockStatus bit = 0 OUTPUT
AS
BEGIN
    DELETE FROM ActiveLock
    WHERE LockedBy = @UserID

    IF @@ERROR <> 0 
	   SET @OUTUnLockStatus = 0  
    ELSE
	   SET @OUTUnLockStatus = 1    

END