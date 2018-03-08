-- =============================================
-- Author		: Arun Nair
-- Create date	: 8/14/2015
-- Description	: Get Assigned  USER NAME 
-- Updated By	: 
--===================================================

CREATE FUNCTION [dbo].[GetAssignedUserName]
(
@AssignedTo  INTEGER
)
RETURNS NVARCHAR(MAX)
AS 

BEGIN
	IF(@AssignedTo IS NOT NULL)
	BEGIN
		DECLARE @AssignedUser AS NVARCHAR(MAX)=''
					
		SELECT @AssignedUser=FNAME+ ' '+ LName FROM [USER] WHERE UserId=@AssignedTo
	END 
	RETURN @AssignedUser
END
