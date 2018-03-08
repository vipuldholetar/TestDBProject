CREATE Procedure [dbo].[sp_AccutrackGetSupplierAdvertiserLinks]
	(@SupplierID INT, @SupplierAdvertiserName NVARCHAR(255))
AS
BEGIN
	SET NOCOUNT ON

	  SELECT A.AdvertiserID, A.Descrip AS AdvertiserName, P.AdvertiserID as ParentID, P.Descrip AS ParentName
	  FROM [Canada_Supplier_Radio].[dbo].[SupplierAdLink] SAL
	  JOIN [CanadaOneMT].[dbo].[Ad] AD on SAL.AdID = AD.AdID
	  JOIN [CanadaOneMT].[dbo].[Advertiser] A on AD.AdvertiserID = A.AdvertiserID
	  LEFT JOIN [CanadaOneMT].[dbo].[Advertiser] P on A.ParentAdvertiserID = P.AdvertiserID
	  WHERE SAL.SupplierID = @SupplierID AND SAL.AdvertiserName = @SupplierAdvertiserName
	  ORDER BY A.Descrip 

END