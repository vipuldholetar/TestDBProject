CREATE view [dbo].[vwPackageType]
As


SELECT    TOP (100) PERCENT    ShippingMethod.[ShippingMethodID], Shipper.[ShipperID], ShippingMethod.ShipmentMethodName
FROM            ShippingMethod INNER JOIN
                         Shipper ON ShippingMethod.[ShipperID] = Shipper.[ShipperID]
						 where (Shipper.Descrip='Package Type')
