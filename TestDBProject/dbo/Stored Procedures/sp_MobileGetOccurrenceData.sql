
-- ========================================================================================================================================    
-- Author        :	Karunakar    
-- Create date   :	6th October 2015   
-- Description   :  This Procedure is used to getting Mobile Occurrence  Data    
-- Exec			 :  sp_MobileGetOccurrenceData 4192022	
-- Updated By	 :	
-- ========================================================================================================================================= 
CREATE PROCEDURE [dbo].[sp_MobileGetOccurrenceData] 
( 
@OccurrenceID Bigint

) 
AS 

BEGIN

Select Top  1 [OccurrenceDetailMOBID] as OccurrenceId,'' as LPQuality,CreativeDetailMob.CreativeAssetName as LocalFilename,
		LandingPage.LandingURL as LandingPageURL,ScrapePage.PageURL as AdPageURL,'' as SessionURL,ScrapePage.[CreatedDT] As SessionDate,'' as Device
from [dbo].[OccurrenceDetailMOB] 
Left Join [Pattern] on [OccurrenceDetailMOB].[PatternID]=[Pattern].[PatternID]
Left Join [Creative] on [Pattern].[CreativeID]=[Creative].PK_Id 
Left Join CreativeDetailMob on [Creative].PK_Id=CreativeDetailMob.[CreativeMasterID]
and [OccurrenceDetailMOB].[OccurrenceDetailMOBID]=[Creative].[SourceOccurrenceId]
Left join LandingPage on [OccurrenceDetailMOB].[LandingPageID]=LandingPage.[LandingPageID]
Left Join [dbo].[ScrapePage] on [OccurrenceDetailMOB].[ScrapePageID]=ScrapePage.[ScrapePageID]
Where [OccurrenceDetailMOBID]=@OccurrenceID
END
