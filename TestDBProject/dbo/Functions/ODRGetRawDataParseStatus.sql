-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/07/2015   
-- Description:  Get the raw data parse status 
-- Query :   
/* select dbo.ODRGetRawDataParseStatus('ATL',',')  
*/ 
-- ================================================================================================================
CREATE FUNCTION ODRGetRawDataParseStatus
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1)
)
RETURNS varchar(max)
begin
declare @string as varchar(max)
      if((select count(*) from dbo.ODRSplitString(@Input,@Character))=5)
	  begin
	  set @string='Valid';
	  end
      else
	  begin
	  set @string='Invalid';
	  end
	  return @string;
end
