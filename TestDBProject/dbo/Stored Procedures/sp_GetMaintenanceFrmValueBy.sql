CREATE PROCEDURE [dbo].[sp_GetMaintenanceFrmValueBy]
    @ComponentName varchar(100),
    @ByValue varchar(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

	   IF lower(@ComponentName) = 'categorybysubcatcode'
	   BEGIN
		  SELECT DISTINCT sc.SubCategoryCODE, sc.CategoryID, c.CTLegacyPCATCODE as CategoryCode, c.CategoryName, RefSubCategoryID, SubCategoryName
			 FROM RefSubCategory sc inner join RefCategory c on sc.CategoryID=c.RefCategoryID 
			 WHERE sc.SubCategoryCODE = @ByValue
	   END
	   ELSE IF lower(@ComponentName) = 'advertiserbycode'
	   BEGIN
		  select DISTINCT AdvertiserID, CTLegacyINSTCOD as AdvertiserCode, Descrip from Advertiser where CTLegacyINSTCOD = @ByValue
	   END
	   ELSE IF lower(@ComponentName) = 'advertiserbyname'
	   BEGIN
		  select DISTINCT AdvertiserID, CTLegacyINSTCOD as AdvertiserCode, Descrip from Advertiser where Descrip = @ByValue
	   END
	   ELSE IF lower(@ComponentName) = 'productbycode'
	   BEGIN
		  select DISTINCT CTLegacyPRCODE as ProductCode, ProductName, ProductShortName from RefProduct where CTLegacyPRCODE = @ByValue
	   END
	   ELSE IF lower(@ComponentName) = 'refcategory'
	   BEGIN
		  IF (ISNUMERIC(@ByValue)= 1)
		  BEGIN
			SELECT RefCategoryID,CategoryName,CategoryShortName,CTLegacyPCATCODE as Code,CTLegacyPSUPCODE as SuperCat,CreateDT
				,CreatedByID,ModifiedDT,ModifiedByID, isnull(Definition1,'') AS Definition1 , isnull(Definition2,'') AS Definition2 
				,endDT, c.RetiredByID, u.username as RetiredByUsername
				FROM RefCategory c LEFT JOIN [user] u on c.RetiredByID = u.UserID
				WHERE RefCategoryID = @ByValue
		  END
	   END
	   ELSE IF lower(@ComponentName) = 'refcategorybycode'
	   BEGIN
		 SELECT RefCategoryID, c.CategoryGroupID, ISNULL(cg.CategoryGroupName,'') AS CategoryGroupName, CategoryName,CTLegacyPCATCODE as Code
			 FROM RefCategory c LEFT JOIN RefCategoryGroup cg on c.CategoryGroupID=cg.RefCategoryGroupID
			 WHERE CTLegacyPCATCODE = @ByValue
	   END
	   ELSE IF lower(@ComponentName) = 'categorybysubcatid'
	   BEGIN
		  IF (ISNUMERIC(@ByValue)= 1)
		  BEGIN
			SELECT c.RefCategoryID, c.CategoryName, c.CTLegacyPCATCODE AS CategoryCode
				FROM RefSubCategory sc RIGHT JOIN RefCategory c ON c.RefCategoryID = sc.CategoryID 
				WHERE c.RefCategoryID = @ByValue
		  END
	   END
	   ELSE IF lower(@ComponentName) = 'refsubcategory'
	   BEGIN
		  IF (ISNUMERIC(@ByValue)= 1)
		  BEGIN
			SELECT sc.RefSubCategoryID,sc.SubCategoryName,sc.SubCategoryShortName,sc.SubCategoryCode, c.CategoryName,c.CTLegacyPCATCODE AS CategoryCode
				,sc.CategoryID ,sc.CreatedDT,sc.CreatedByID,sc.ModifiedDT,sc.ModifiedByID,sc.endDT, 
				isnull(sc.Definition1,'') AS Definition1 , isnull(sc.Definition2,'') AS Definition2 , u.username as RetiredByUsername
				FROM RefSubCategory sc LEFT JOIN RefCategory c ON c.RefCategoryID = sc.CategoryID LEFT JOIN [user] u on sc.RetiredByID = u.UserID
				WHERE RefSubCategoryID = @ByValue
		  END
	   END
	   ELSE IF lower(@ComponentName) = 'refsubcategorybycode'
	   BEGIN
		 SELECT RefSubCategoryID,SubCategoryName, SubCategoryCode, sc.CategoryID, ISNULL(c.CategoryName,'') AS CategoryName
			 FROM RefSubCategory sc LEFT JOIN RefCategory c ON sc.CategoryID = c.RefCategoryID
			 WHERE SubCategoryCode = @ByValue
	   END
	   ELSE IF lower(@ComponentName) = 'distinctsubcategories'
	   BEGIN
		  SELECT -1 AS RefSubCategoryID, '' AS SubCategoryName,'' AS SubCategoryCode
		  UNION
		  SELECT DISTINCT RefSubCategoryID,SubCategoryName  + ' - ' + SubCategoryCode, SubCategoryCode FROM RefSubCategory
		  ORDER BY SubCategoryName ASC
	   END
	   ELSE IF lower(@ComponentName) = 'refproduct'
	   BEGIN
		  IF (ISNUMERIC(@ByValue)= 1)
		  BEGIN
			 SELECT p.RefProductID, p.CTLegacyPRCODE as ProductCode, p.ProductName, p.ProductShortName, 
				p.CTLegacyPRINSTCODE as AdvertiserCode, a.Descrip as AdvertiserName,
				p.SubCategoryID, sc.SubCategoryCode, sc.SubCategoryName, c.CTLegacyPCATCODE as CategoryCode, c.CategoryName,
				p.TargetMarketID, m.Name as MarketName, p.IndustryGroup, p.IndustryGroup as IndustryGroupName,
				p.CTLegacyPRINSTCODE + p.CTLegacyPRSBCATCODE as InstSub,
				p.CTLegacyPRINSTCODE + CTLegacyPRCATGYCODE as InstCat,
				p.CreatedDT, p.ModifiedDT, p.EndDate, u.UserName as RetiredByUsername
			 FROM RefProduct p 
			 LEFT JOIN Advertiser a on p.AdvertiserID = a.AdvertiserID
			 LEFT JOIN RefSubCategory sc on p.SubCategoryID = sc.RefSubCategoryID 
			 LEFT JOIN RefCategory c on c.RefCategoryID = sc.CategoryID
			 LEFT JOIN RefTargetMarket m on p.TargetMarketID = m.RefTargetMarketID
			 LEFT JOIN [user] u on p.RetiredByID = u.UserID
			 WHERE RefProductID = @ByValue
		  END
	   END
	   ELSE IF lower(@ComponentName) = 'refproductbycode'
	   BEGIN
		 SELECT RefProductID, CTLegacyPRCODE as ProductCode, ProductName, p.AdvertiserID, ISNULL(a.Descrip,'') as AdvertiserName, 
			 SubCategoryID, ISNULL(sc.SubCategoryName,'') AS SubCategoryName
			 FROM RefProduct p LEFT JOIN RefSubCategory sc on p.SubCategoryID = sc.RefSubCategoryID
			 LEFT JOIN Advertiser a on p.AdvertiserID = a.AdvertiserID
			 WHERE CTLegacyPRCODE = @ByValue
	   END
	   ELSE IF lower(@ComponentName) = 'reftagline'
	   BEGIN
		  IF (ISNUMERIC(@ByValue)= 1)
		  BEGIN
			 SELECT RefTaglineID, t.AdvertiserID, a.CTLegacyINSTCOD as AdvertiserCode,
				ISNULL(a.Descrip,'') as AdvertiserName, Tagline, CASE WHEN t.Display = 1 THEN 'Y' ELSE 'N' END AS Display,
				CONVERT(VARCHAR(15), T.CreatedDT, 101) AS CreatedDT, u.Username as CreatedBy, 
				CONVERT(VARCHAR(15), T.ModifiedDT, 101) AS ModifiedDT, CONVERT(VARCHAR(15), GETDATE(), 101) AS MaxDate
				FROM RefTagline t LEFT JOIN Advertiser a on t.AdvertiserID = a.AdvertiserID 
				LEFT JOIN [user] u on t.CreateByID = u.UserID
				WHERE RefTaglineID = @ByValue
		  END
	   END
	   ELSE IF lower(@ComponentName) = 'distincttargetmarket'
	   BEGIN
		  SELECT -1 AS RefTargetMarketID, '' AS Code,'' AS Name
		  UNION
		  SELECT DISTINCT RefTargetMarketID, Code, Name FROM RefTargetMarket
		  ORDER BY Name ASC
	   END

    END TRY
    BEGIN CATCH
	   DECLARE @ERROR   INT, 
		  @MESSAGE VARCHAR(4000), 
		  @LINENO  INT 

    SELECT @ERROR = Error_number(),@MESSAGE = Error_message(),@LINENO = Error_line() 
    RAISERROR ('sp_GetMaintenanceFrmValueBy: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
    END CATCH
  
END
