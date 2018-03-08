CREATE PROCEDURE [dbo].[sp_ProductMaintenanceSearch] 
 @SeachXML AS XML

AS 
  BEGIN 
      SET NOCOUNT ON ;
      BEGIN TRY 
	 
		  DECLARE @AdvertiserCode AS NVARCHAR(10)='' 
		  DECLARE @AdvertiserName AS NVARCHAR(100)=''
		  DECLARE @ProductCode AS NVARCHAR(10)
		  DECLARE @ProductName AS NVARCHAR(100)='' 
		  DECLARE @ProductShortName AS NVARCHAR(100)='' 
		  DECLARE @CategoryCode AS NVARCHAR(10)=''
		  DECLARE @CategoryName AS NVARCHAR(100)=''
		  DECLARE @SubCategoryID AS INT
		  DECLARE @SubCategoryCode AS NVARCHAR(10)=''
		  DECLARE @SubCategoryName AS NVARCHAR(100)=''
		  DECLARE @TargetMarketID AS INT
		  DECLARE @seq AS NVARCHAR(10)=''
		  DECLARE @CreateDT AS DateTime
		  DECLARE @CreatedByID AS INT
		  DECLARE @ModifiedDT AS DateTime
		  DECLARE @ModifiedByID AS INT
		  DECLARE @EndDT AS DateTime
		  DECLARE @IncludeRetired  AS INT
		  DECLARE @SelectStmnt AS NVARCHAR(MAX)=''
		  DECLARE @Where AS NVARCHAR(MAX)
		  DECLARE @OrderBy AS NVARCHAR(250)='' 

		  SET @Where = ''
		  SET @OrderBy = ' ORDER BY ProductName ASC'

		  SELECT productsearchdetails.value('(AdvertiserCode)[1]','NVARCHAR(10)') AS 'AdvertiserCode', 
				productsearchdetails.value('(AdvertiserName)[1]','NVARCHAR(100)') AS 'AdvertiserName', 
				productsearchdetails.value('(ProductCode)[1]','NVARCHAR(10)') AS 'ProductCode', 
				productsearchdetails.value('(ProductName)[1]', 'NVARCHAR(100)') AS 'ProductName',
				productsearchdetails.value('(ProductShortName)[1]', 'NVARCHAR(100)') AS 'ProductShortName',
				productsearchdetails.value('(CategoryCode)[1]', 'NVARCHAR(10)') AS 'CategoryCode',
				productsearchdetails.value('(CategoryName)[1]', 'NVARCHAR(100)') AS 'CategoryName',
				productsearchdetails.value('(SubCategoryID)[1]', 'INT') AS 'SubCategoryID',
				productsearchdetails.value('(SubCategoryCode)[1]', 'NVARCHAR(10)') AS 'SubCategoryCode',
				productsearchdetails.value('(SubCategoryName)[1]', 'NVARCHAR(100)') AS 'SubCategoryName',
				productsearchdetails.value('(TargetMarketID)[1]', 'INT') AS 'TargetMarketID',
				productsearchdetails.value('(IncludeRetired)[1]', 'INT') AS 'IncludeRetired',
				productsearchdetails.value('(seq)[1]', 'INT') AS 'seq'
		  INTO   #searchtempval
		  FROM   @SeachXML.nodes('ProductMaintenanceSearch') AS ProductSearchProc(productsearchdetails) 

		  SELECT @AdvertiserCode = AdvertiserCode, 
				@AdvertiserName = AdvertiserName,
				@ProductCode = ProductCode,
				@ProductName = ProductName,
				@ProductShortName = ProductShortName,
				@CategoryCode = CategoryCode,
				@CategoryName = CategoryName,
				@SubCategoryID = SubCategoryID,
				@SubCategoryCode = SubCategoryCode,
				@SubCategoryName = SubCategoryName,
				@TargetMarketID = TargetMarketID,
				@IncludeRetired = IncludeRetired,
				@seq = seq
		  FROM   #searchtempval 
		  
		  SET @SelectStmnt='SELECT p.RefProductID, p.CTLegacyPRCODE as ProductCode, p.ProductName, p.ProductShortName, 
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
					   WHERE 1=1 '

		  IF( @AdvertiserCode <> '' ) 
			 SET @SelectStmnt=@SelectStmnt + ' AND p.CTLegacyPRINSTCODE like ''%' + REPLACE(@AdvertiserCode,'''','''''') + '%''' 
		  IF( @AdvertiserName <> '' ) 
			 SET @SelectStmnt=@SelectStmnt + ' AND a.Descrip like  ''%'+ REPLACE(@AdvertiserName,'''','''''') + '%''' 
		  IF( @ProductCode <> '')
			 SET @SelectStmnt=@SelectStmnt   + ' AND p.CTLegacyPRCODE = '''  + @ProductCode +  '''' 
		  IF( @ProductName <> '')	
			 SET @SelectStmnt=@SelectStmnt   + ' AND p.ProductName like  ''%'  + REPLACE(@ProductName,'''','''''') +  '%''' 
		  IF( @ProductShortName <> '')	
			 SET @SelectStmnt=@SelectStmnt   + ' AND p.ProductShortName like  ''%'  + REPLACE(@ProductShortName,'''','''''') +  '%''' 
		  IF( @CategoryCode <> '')	
			 SET @SelectStmnt=@SelectStmnt   + ' AND c.CTLegacyPCATCODE like  ''%'  + @CategoryCode +  '%''' 
		  IF( @CategoryName <> '')	
			 SET @SelectStmnt=@SelectStmnt   + ' AND c.CategoryName like  ''%'  + REPLACE(@CategoryName,'''','''''') +  '%''' 
		  IF( @SubCategoryID > 0)	
			 SET @SelectStmnt=@SelectStmnt   + ' AND p.SubCategoryID = '''  + CONVERT(VARCHAR(10), @SubCategoryID) +  '''' 
		  IF( @SubCategoryCode <> '')	
			 SET @SelectStmnt=@SelectStmnt   + ' AND sc.SubCategoryCode like  ''%'  + @SubCategoryCode +  '%''' 
		  IF( @SubCategoryName <> '')	
			 SET @SelectStmnt=@SelectStmnt   + ' AND sc.SubCategoryName like  ''%'  + REPLACE(@SubCategoryName,'''','''''') +  '%''' 
		  IF( @TargetMarketID > 0)	
			 SET @SelectStmnt=@SelectStmnt   + ' AND p.TargetMarketID =  '''  + CONVERT(VARCHAR(10), @TargetMarketID) +  '''' 
		  IF(@IncludeRetired = 0)
			 SET @SelectStmnt=@SelectStmnt   + ' AND (p.EndDate is null or p.EndDate ='''')'
		  
		  SET @SelectStmnt = @SelectStmnt + @OrderBy

		  DROP TABLE #searchtempval 
		  PRINT @SelectStmnt 
		  EXEC SP_EXECUTESQL @SelectStmnt  
	   END TRY 

	   BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
		  RAISERROR ('sp_ProductMaintenanceSearch: %d: %s',16,1,@error,@message,@lineNo);
	   END CATCH 

END