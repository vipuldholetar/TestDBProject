
-- =============================================     
-- Author:    Govardhan.R     
-- Create date: 05/07/2015     
-- Description:  Check whether station exists or not.   
-- Query : exec sp_RCSIngestionCheckStationExists '2257'     
-- =============================================     
CREATE PROCEDURE [sp_RCSIngestionCheckStationExists] (@StationId 
INT) 
AS 
  BEGIN 
      SELECT Cast(Count(*) AS BIT)[IsExist] 
      FROM   RCSRadioStation 
      WHERE  [RCSRadioStationID] = @StationId 
  END
