-- =============================================
-- Author:		Ashanie Cole
-- Create date:	May 2016
-- Description:	Lock records
-- =============================================
CREATE PROCEDURE [dbo].[sp_LockRecord]
    @EntityID varchar(255),
    @EntityName varchar(50),
    @FormName varchar(100),
    @UserID int,
    @OUTLockStatus bit = 0 OUTPUT,
    @OUTMessage varchar(100) = '' OUTPUT
AS
BEGIN

    IF EXISTS(SELECT EntityID FROM ActiveLock WHERE EntityID = @EntityID AND EntityName = @EntityName AND LockedBy <> @UserID) 
    BEGIN

	   SELECT @OUTMessage = CONCAT('This record is currently locked by ', isnull(b.FName,''), ' ', isnull(b.LName,'') + char(13), 
								' (', a.FormName,' since ' + CONVERT(varchar, LockDT,100) + ').')
			 , @OUTLockStatus = 0
	   FROM ActiveLock a LEFT JOIN [User] b ON b.UserID = a.LockedBy
	   WHERE a.EntityID = @EntityID AND EntityName = @EntityName

    END
    ELSE
    BEGIN
	   IF EXISTS(SELECT EntityID FROM ActiveLock WHERE EntityID = @EntityID AND EntityName = @EntityName AND LockedBy = @UserID) 
	   BEGIN
		  UPDATE ActiveLock SET LockDT = GETDATE() WHERE EntityID = @EntityID AND EntityName = @EntityName AND LockedBy = @UserID
		  SET @OUTLockStatus = 1
		  SET @OUTMessage = ''
	   END
	   ELSE
	   BEGIN
		  INSERT INTO ActiveLock(EntityID,
			 EntityName,
			 FormName,
			 LockedBy,
			 LockDT)
		  VALUES (@EntityID,
			 @EntityName,
			 @FormName,
			 @UserID,
			 GETDATE())

		  IF @@ERROR <> 0 
		  BEGIN
			 SELECT @OUTMessage = CONCAT('This record is currently locked by ', isnull(b.FName,''), ' ', isnull(b.LName,'') + char(13), 
									   ' (', a.FormName,' since ' + CONVERT(varchar, LockDT,100) + ').'), @OUTLockStatus = 0
			 FROM ActiveLock a INNER JOIN [User] b ON b.UserID = a.LockedBy
			 WHERE a.EntityID = @EntityID AND EntityName = @EntityName
		  END
		  ELSE
		  BEGIN
			 SET @OUTLockStatus = 1
			 SET @OUTMessage = ''
		  END
	   END
    END

END