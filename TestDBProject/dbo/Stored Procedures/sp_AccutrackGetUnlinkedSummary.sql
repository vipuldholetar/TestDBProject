
CREATE PROCEDURE [dbo].[sp_AccutrackGetUnlinkedSummary]
AS
BEGIN
	SET NOCOUNT ON

	  SELECT N.Supplier_Id AS SupplierID, N.Name AS SupplierNAME, A.BroadcastMonth AS BroadcastMonth, sum(A.Dollars) as Dollars
	  FROM [Canada_Supplier_Radio].[dbo].[AccutrackUnlinkedAds] A
	  JOIN [Canada_Supplier_Radio].[dbo].newsupplier N ON A.Supplierid = N.Supplier_id
	  GROUP BY N.Supplier_id, N.Name, A.BroadcastMonth 
	  ORDER BY SUM(Dollars) DESC
END

