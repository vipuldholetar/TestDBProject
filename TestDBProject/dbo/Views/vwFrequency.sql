
CREATE VIEW [dbo].[vwFrequency]
AS
SELECT     dbo.CodeType.CodeTypeId, dbo.Code.CodeId, dbo.Code.Descrip
FROM         dbo.CodeType INNER JOIN
                      dbo.Code ON dbo.CodeType.CodeTypeId = dbo.Code.CodeTypeId
WHERE     (dbo.CodeType.Descrip = 'Frequency')