-- ========================================================================================================================================    
-- Author        :	Karunakar    
-- Create date   :	09/28/2015     
-- Description   :  This Procedure is used to getting Occurrence Online Video Data    
-- Exec			 :  sp_OnlineVideoGetOccurrenceData 23049	
-- Updated By	 :	
-- ========================================================================================================================================= 
CREATE PROCEDURE [dbo].[sp_OnlineVideoGetOccurrenceData] 
( 
@OccurrenceID Bigint
) 
AS 
BEGIN
Select    TOP 1 [OccurrenceDetailONVID] as OccurrenceId,'' As [Format],'' As Program,'' as [Length],CreativeDetailONV.CreativeFileType as FileType, '' as LPQuality,
		LandingPage.LandingURL as LandingPageURL,ScrapePage.PageURL as AdPageURL,'' as SessionURL,ScrapePage.[CreatedDT] As SessionDate
from [dbo].[OccurrenceDetailONV] 
Left Join [Pattern] on [OccurrenceDetailONV].[PatternID]=[Pattern].[PatternID]
Left Join [Creative] on [Pattern].[CreativeID]=[Creative].PK_Id 
Left Join CreativeDetailONV on [Creative].PK_Id=CreativeDetailONV.[CreativeMasterID]
and [OccurrenceDetailONV].[OccurrenceDetailONVID]=[Creative].[SourceOccurrenceId]
left join LandingPage on [OccurrenceDetailONV].[LandingPageID]=LandingPage.[LandingPageID]
left Join [dbo].[ScrapePage] on [OccurrenceDetailONV].[ScrapePageID]=ScrapePage.[ScrapePageID]
Where [OccurrenceDetailONVID]=@OccurrenceID
END
