
CREATE VIEW [dbo].[vwLocation]
AS
SELECT     dbo.[CodeType].[CodeTypeID], dbo.[Code].[CodeID], dbo.[Code].Descrip, dbo.[Code].InternalDescrip
FROM         dbo.[CodeType] INNER JOIN
                      dbo.[Code] ON dbo.[CodeType].[CodeTypeID] = dbo.[Code].[CodeTypeID]
WHERE     (dbo.[CodeType].Descrip = 'Location')
