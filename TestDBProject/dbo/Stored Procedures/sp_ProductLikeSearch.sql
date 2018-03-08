-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE sp_ProductLikeSearch
	@SearchString VARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SQL AS VARCHAR(MAX)

	SET @SQL = 'SELECT RefProductId as ProductId, ProductName, a.AdvertiserID, a.Descrip AS Advertiser
				FROM RefProduct p LEFT JOIN Advertiser a
				    ON a.AdvertiserID = p.AdvertiserID				    
				WHERE ProductName Like ''' + @SearchString + '%'''
	--PRINT @SQL
	EXECUTE(@SQL)
END