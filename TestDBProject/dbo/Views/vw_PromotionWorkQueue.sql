CREATE VIEW [dbo].[vw_PromotionWorkQueue]
AS
--SELECT        b.Score, c.Advertiser, CASE WHEN g.FK_OccurrenceID != NULL THEN g.FK_OccurrenceID ELSE g.FK_ID END AS RecordID, g.AdDate AS RunDate, b.PK_ID AS CropID, 
--                         b.CompositeImageSize AS CropSize, e.CategoryGroupName AS CategoryGroup, d.CategoryName AS Category, f.ProductName AS Product, 
--                         a.ProductDescription AS ProductDesc, a.PromoPrice, a.PK_ID AS KeyID, d.FK_KETemplateId AS PromoTemplate, g.MediaStream, g.FK_ID AS AdID, 
--                         g.FK_OccurrenceID AS OccurrenceID, a.FK_CategoryID AS CategoryID, d.FK_CategoryGroupId AS CategoryGroupID, a.ModifiedBy, 
--                         h.ConfigurationID AS MediastreamID, h.ValueTitle AS MediastreamName, a.IsQuery
--FROM            dbo.PromotionMaster AS a INNER JOIN
--                         dbo.CompositeCrop AS b ON a.FK_CropID = b.PK_ID INNER JOIN
--                         dbo.Advertiser AS c ON a.FK_AdvertiserID = c.PK_AdvertiserID INNER JOIN
--                         dbo.RefCategory AS d ON a.FK_CategoryID = d.PK_Id INNER JOIN
--                         dbo.RefCategoryGroup AS e ON d.FK_CategoryGroupId = e.PK_Id INNER JOIN
--                         dbo.CreativeforCrop AS g ON b.FK_CreativeCropID = g.PK_ID INNER JOIN
--                         dbo.CONFIGURATIONMASTER AS h ON g.MediaStream = h.Value CROSS JOIN
--                         dbo.RefProduct AS f
--WHERE        (ISNULL(a.IsQuery, 0) <> 1)

--SELECT        b.Score, /*c.Advertiser*/'' as Advertiser, CASE WHEN g.[OccurrenceID] != NULL THEN g.[OccurrenceID] ELSE g.[CreativeID] END AS RecordID, g.AdDate AS RunDate, b.[CompositeCropID] AS CropID, --TODO: Map "Advertiser" value to something - was missing from table
SELECT        b.Score, c.Descrip Advertiser, CASE WHEN g.[OccurrenceID] != NULL THEN g.[OccurrenceID] ELSE g.[CreativeID] END AS RecordID, g.AdDate AS RunDate, b.[CompositeCropID] AS CropID, 
                         b.CompositeImageSize AS CropSize, e.CategoryGroupName AS CategoryGroup, d.CategoryName AS Category, f.ProductName AS Product, 
                         a.[ProductDescrip] AS ProductDesc, a.PromoPrice, a.[PromotionID] AS KeyID, d.[KETemplateID] AS PromoTemplate, h.Value as MediaStream, g.[CreativeID] AS AdID, 
                         g.[OccurrenceID] AS OccurrenceID, a.[CategoryID] AS CategoryID, d.[CategoryGroupID] AS CategoryGroupID, a.[ModifiedByID], 
                         h.ConfigurationID AS MediastreamID, h.ValueTitle AS MediastreamName, a.[Query]
FROM            dbo.[Promotion] AS a INNER JOIN
                         dbo.CompositeCrop AS b ON a.[CropID] = b.[CompositeCropID] INNER JOIN
                         dbo.[Advertiser] AS c ON a.[AdvertiserID] = c.[AdvertiserID] INNER JOIN
                         dbo.RefCategory AS d ON a.[CategoryID] = d.[RefCategoryID] INNER JOIN
                         dbo.RefCategoryGroup AS e ON d.[CategoryGroupID] = e.[RefCategoryGroupID] INNER JOIN
                         dbo.[CreativeForCrop] AS g ON b.[CreativeCropID] = g.[CreativeForCropID] INNER JOIN
                         dbo.[Configuration] AS h ON g.MediaStream = h.ConfigurationID left outer JOIN    dbo.RefProduct AS f  on f.[RefProductID]=a.[ProductID]
WHERE        (ISNULL(a.[Query], 0) <> 1)
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 229
            End
            DisplayFlags = 280
            TopColumn = 10
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 6
               Left = 267
               Bottom = 135
               Right = 467
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "c"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 233
               Right = 210
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "d"
            Begin Extent = 
               Top = 138
               Left = 248
               Bottom = 267
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "e"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 399
               Right = 258
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 531
               Right = 235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "h"
            Begin Extent = 
               Top = 402
               Left = 273
               Bottom = 531
               Right = 458
            End
            DisplayFlags = 280
            TopColumn = 0
         End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_PromotionWorkQueue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'Begin Table = "f"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 663
               Right = 258
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_PromotionWorkQueue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'vw_PromotionWorkQueue';

