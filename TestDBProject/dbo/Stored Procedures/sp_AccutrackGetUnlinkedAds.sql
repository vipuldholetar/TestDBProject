
CREATE PROCedure [dbo].[sp_AccutrackGetUnlinkedAds]
	(@BroadcastMonth INT, @SupplierID INT)
AS
BEGIN
	SET NOCOUNT ON

	  SELECT AccutrackUnlinkedAdID, BroadcastMonth, SupplierID, CommercialCode, CreativeDescription, ProductName, AdvertiserName,
			Dollars, Type1 + '/' + Type2 + '/' + Type3 as Types
	  FROM [Canada_Supplier_Radio].[dbo].[AccutrackUnlinkedAds]  
	  WHERE BroadcastMonth = @BroadcastMonth AND SupplierID = @SupplierID
	  ORDER BY dollars DESC

END

