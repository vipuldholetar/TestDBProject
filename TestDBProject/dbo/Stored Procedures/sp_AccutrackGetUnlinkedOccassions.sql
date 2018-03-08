
CREATE PROCedure [dbo].[sp_AccutrackGetUnlinkedOccassions]
	(@AccutrackUnlinkedAdID INT)
AS
BEGIN
	SET NOCOUNT ON

	  SELECT AccutrackUnlinkedOccassionID, AccutrackUnlinkedAdID, BroadcastMonth, SupplierID, 
			REPLACE(SupplierStation,'-','') as Stn, OneMTStation, 
			AirDateTime as Aired, 
			Duration as Dur, Region, Dollars 
	  FROM [Canada_Supplier_Radio].[dbo].[AccutrackUnlinkedOccassions]  
	  WHERE AccutrackUnlinkedAdID = @AccutrackUnlinkedAdID
	  ORDER BY dollars DESC

END
