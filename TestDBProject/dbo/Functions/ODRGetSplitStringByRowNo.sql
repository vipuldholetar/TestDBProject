-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/07/2015   
-- Description:  Get the raw data parse string by number 
-- Query :   
/* select dbo.ODRGetSplitStringByRowNo('ATL',',')  
*/ 
-- ================================================================================================================
CREATE FUNCTION ODRGetSplitStringByRowNo
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1),
	  @SlNo int
)
RETURNS varchar(max)
begin
declare @string as varchar(max)
      if((select count(*) from dbo.ODRSplitString(@Input,@Character))=5)
	  begin
	  select @string=item from dbo.ODRSplitString(@Input,@Character) where slno=@SlNo;
	  end
      else
	  begin
	  set @string='Invalid';
	  end
	  return @string;
end
