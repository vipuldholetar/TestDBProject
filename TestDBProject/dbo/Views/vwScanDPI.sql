CREATE VIEW [dbo].[vwScanDPI]
AS
SELECT     dbo.Code.CodeId, CAST(dbo.Code.Descrip AS INT) AS Descrip, dbo.Code.InternalDescrip
FROM         dbo.CodeType INNER JOIN
                      dbo.Code ON dbo.CodeType.CodeTypeId = dbo.Code.CodeTypeId
WHERE     (dbo.CodeType.Descrip = 'DPI') AND (dbo.Code.Descrip NOT LIKE '%[^0-9]%')