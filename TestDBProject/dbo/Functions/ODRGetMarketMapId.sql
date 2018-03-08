-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/07/2015   
-- Description:  Get the Market Map ID  
-- Query :   
/* select dbo.ODRGetMarketMapId('ATL')  
*/ 
-- ================================================================================================================
CREATE FUNCTION ODRGetMarketMapId
(    
      @Input NVARCHAR(MAX)
)
RETURNS varchar(max)
begin
declare @string as varchar(max)
      if((SELECT count(*) FROM MTODRMARKETMAP WHERE [CMSMarketCODE]=ltrim(@Input))>0)
	  begin
	  set @string=(SELECT [MarketID] FROM MTODRMARKETMAP WHERE [CMSMarketCODE]=ltrim(@Input));
	  end
      else
	  begin
	  set @string='UnmappedMarket';
	  end
	  return @string;
end