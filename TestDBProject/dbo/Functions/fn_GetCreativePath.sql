

-- =============================================
-- Author:		SURESH N
-- Create date: 07/12/2015
-- Description:	Get Creative Path using Occurance ID
-- Execution :  SELECT OneMT_12062015.dbo.[fn_GetCreativePath](500002,'CIR') AS Result
-- =============================================
CREATE FUNCTION [dbo].[fn_GetCreativePath] 
(
	-- Add the parameters for the function here
	@OccurrenceID BIGINT,
	@MediaStream varchar(50)

)
RETURNS VARCHAR(20)
AS
BEGIN
	-- Declare the return variable here
	

	 RETURN  CASE 
	 --OccurrenceID inbetween below values then omCircular
        WHEN @MediaStream='CIR' then (select top 1 creativerepository from creativedetailcir where creativemasterid in (select [Pattern].[CreativeID] from [OccurrenceDetailCIR] inner join [Pattern] on
[OccurrenceDetailCIR].[PatternID]=[Pattern].[PatternID]
and [OccurrenceDetailCIRID]=@OccurrenceID))
		WHEN @MediaStream='PUB' then (select top 1 creativerepository from creativedetailpub where creativemasterid in (select [Pattern].[CreativeID] from [OccurrenceDetailPUB] inner join [Pattern] on
[OccurrenceDetailPUB].[PatternID]=[Pattern].[PatternID]
and [OccurrenceDetailPUBID]=@OccurrenceID))
		WHEN @MediaStream='SOC' then (select top 1 creativerepository from creativedetailsoc where creativemasterid in (select [Pattern].[CreativeID] from [OccurrenceDetailSOC] inner join [Pattern] on
[OccurrenceDetailSOC].[PatternID]=[Pattern].[PatternID]
and [OccurrenceDetailSOCID]=@OccurrenceID))
		WHEN @MediaStream='EM' then (select top 1 creativerepository from creativedetailem where creativemasterid in (select [Pattern].[CreativeID] from [OccurrenceDetailEM] inner join [Pattern] on
[OccurrenceDetailEM].[PatternID]=[Pattern].[PatternID]
and [OccurrenceDetailEM].[OccurrenceDetailEMID]=@OccurrenceID))
		WHEN @MediaStream='WEB' then (select top 1 creativerepository from creativedetailweb where creativemasterid in (select [Pattern].[CreativeID] from [OccurrenceDetailWEB] inner join [Pattern] on
[OccurrenceDetailWEB].[PatternID]=[Pattern].[PatternID]
and [OccurrenceDetailWEB].[OccurrenceDetailWEBID]=@OccurrenceID))
        ELSE ''
    END 

END
