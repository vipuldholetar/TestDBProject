-- =============================================
-- Author:		Ashanie Cole
-- Create date: May 2016
-- Description:	load all locked records
-- =============================================
CREATE PROCEDURE [dbo].[sp_LoadLockedRecords] 

AS
BEGIN
    
    SELECT a.EntityID,a.EntityName, a.FormName, b.FName + ' ' + b.LName as LockedBy, a.LockDT
    FROM ActiveLock a left join [User] b on a.LockedBy = b.UserID

END