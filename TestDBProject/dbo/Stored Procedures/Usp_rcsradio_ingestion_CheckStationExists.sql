-- =============================================    
-- Author:    Govardhan.R    
-- Create date: 05/07/2015    
-- Description:  Check whether station exists or not.  
-- Query : exec Usp_rcsradio_ingestion_CheckStationExists '2257'    
-- =============================================    
Create PROCEDURE [dbo].Usp_rcsradio_ingestion_CheckStationExists (@StationID INT) 
AS 
  BEGIN 
SELECT cast(count(*) as bit)[IsExist]  FROM   [rcsradiostation] 
WHERE  RCSRadioStationID = @StationID
  END
