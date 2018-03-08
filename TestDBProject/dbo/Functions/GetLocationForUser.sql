-- ===========================================================================================================
-- Author                  :  Ramesh Bangi
-- Create date             :  08/17/2015
-- Description             :  Get Location Based on User
-- Execution Process	   : 
-- ===========================================================================================================
CREATE FUNCTION [dbo].[GetLocationForUser]
(
	@UserId BIGINT
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN
	DECLARE @Location AS NVARCHAR(MAX)
	SET @Location= (SELECT  DISTINCT Descrip FROM [User] 
					LEFT JOIN  [Code] 
					ON [User].locationId = [Code].CodeID and [Code].CodeTypeId = 8 
					WHERE [User].[UserId]=@UserId
	AND Descrip IS NOT NULL)
	RETURN  @Location
END