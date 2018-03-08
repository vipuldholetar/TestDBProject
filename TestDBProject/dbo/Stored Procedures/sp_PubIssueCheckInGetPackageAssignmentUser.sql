
-- =============================================
-- Author:		Karunakar
-- Create date: 22nd June 2015
-- Description:	This Procedure is Used to Load Package Assignment User Details
-- =============================================
CREATE PROCEDURE [dbo].[sp_PubIssueCheckInGetPackageAssignmentUser]
	@SenderId As Int
AS
BEGIN
	
	SET NOCOUNT ON;

				 SELECT        Sender.DefaultPkgAssignee, [USER].UserID, [USER].Username
				 FROM          Sender 
				 INNER JOIN    [USER] ON 
				 Sender.DefaultPkgAssignee = [USER].UserID And [User].activeind = 1 and Sender.[SenderID]=@SenderId
END
