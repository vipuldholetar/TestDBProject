-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/07/2015   
-- Description:  Get the Source Map ID  
-- Query :   
/* select dbo.ODRGetSourceFormatMapId(' aerial')  
*/ 
-- ================================================================================================================
CREATE FUNCTION ODRGetSourceFormatMapId
(    
      @Input NVARCHAR(MAX)
)
RETURNS varchar(max)
begin
declare @string as varchar(max)
      if((SELECT count(*) FROM [dbo].[ODRAdFormatMap] WHERE CMSSOURCEFORMAT=ltrim(@Input))>0)
	  begin
	  set @string=(SELECT distinct top 1 [MTFormatID] FROM [ODRAdFormatMap] WHERE CMSSOURCEFORMAT=ltrim(@Input));
	  end
      else
	  begin
	  set @string='UnmappedFormat';
	  end
	  return @string;
end
