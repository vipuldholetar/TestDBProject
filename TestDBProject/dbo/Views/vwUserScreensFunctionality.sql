
CREATE VIEW [dbo].[vwUserScreensFunctionality]
AS
SELECT     TOP (100) PERCENT dbo.[User].UserID, dbo.Screen.FormName, dbo.Screen.Functionality, dbo.Screen.ObjectName
FROM         dbo.[User] INNER JOIN
                      dbo.UserRoles ON dbo.[User].UserID = dbo.UserRoles.[UserID] INNER JOIN
                      dbo.ScreenRoles ON dbo.UserRoles.[RoleID] = dbo.ScreenRoles.[RoleID] INNER JOIN
                      dbo.Screen ON dbo.ScreenRoles.[ScreenID] = dbo.Screen.[ScreenID]
ORDER BY dbo.[User].UserID, dbo.Screen.FormName
