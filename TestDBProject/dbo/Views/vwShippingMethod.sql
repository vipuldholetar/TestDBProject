
CREATE view [dbo].[vwShippingMethod]
As

SELECT        ShippingMethod.[ShippingMethodID], Shipper.[ShipperID], ShippingMethod.ShipmentMethodName
FROM            ShippingMethod INNER JOIN
                         Shipper ON ShippingMethod.[ShipperID] = Shipper.[ShipperID]
						 where (Shipper.Descrip='Shipping Method')
