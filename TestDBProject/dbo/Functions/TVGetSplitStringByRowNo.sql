-- ==============================================================================================================   
-- Author:    Nagarjuna   
-- Create date: 07/07/2015   
-- Description:  Get the raw data parse string by number 
-- Query :   
/* select dbo.TVGetSplitStringByRowNo('4AE02H7J.WA0','.',1)  
*/ 
-- ================================================================================================================
CREATE FUNCTION [dbo].[TVGetSplitStringByRowNo]
(    
      @Input NVARCHAR(MAX),
      @Character CHAR(1),
	  @SlNo int
)
RETURNS varchar(max)
begin
declare @string as varchar(max)
select @string=item from dbo.TVSplitString(@Input,@Character) where slno=@SlNo;
return @string;
end
