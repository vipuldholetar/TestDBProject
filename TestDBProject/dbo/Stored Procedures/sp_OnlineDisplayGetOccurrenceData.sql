



-- ========================================================================================================================================    
-- Author        :	Karunakar    
-- Create date   :	09/23/2015     
-- Description   :  This Procedure is used to getting Occurrence Online Display Data    
-- Exec			 :  sp_OnlineDisplayGetOccurrenceData 4192022	
-- Updated By	 :	Karunakar on 24th Sep 2015,Changing Selection Query
-- ========================================================================================================================================= 
CREATE PROCEDURE [dbo].[sp_OnlineDisplayGetOccurrenceData] 
( 
@OccurrenceID Bigint

) 
AS 

BEGIN

Select Top  1 [OccurrenceDetailONDID] as OccurrenceId,'' As [Format],CreativeDetailOND.CreativeFileType as FileType, '' as AdSize,'' as LPQuality,
		CreativeDetailOND.CreativeAssetName as LocalFilename,LandingPage.LandingURL as LandingPageURL,
   ScrapePage.PageURL as AdPageURL,'' as ImageURL,'' as RichMedia,'' as WebsiteName,'' as LPTakeover
from [dbo].[OccurrenceDetailOND] 
Left Join [Pattern] on [OccurrenceDetailOND].[PatternID]=[Pattern].[PatternID]
Left Join [Creative] on [Pattern].[CreativeID]=[Creative].PK_Id 
Left Join CreativeDetailOND on [Creative].PK_Id=CreativeDetailOND.[CreativeMasterID]
and [OccurrenceDetailOND].[OccurrenceDetailONDID]=[Creative].[SourceOccurrenceId]
Inner join LandingPage on [OccurrenceDetailOND].[LandingPageID]=LandingPage.[LandingPageID]
Inner Join [dbo].[ScrapePage] on [OccurrenceDetailOND].[ScrapePageID]=ScrapePage.[ScrapePageID]
Where [OccurrenceDetailONDID]=@OccurrenceID
END
