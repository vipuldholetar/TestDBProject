-- =============================================    
-- Author:    Govardhan.R    
-- Create date: 04/06/2015    
-- Description:  Get Raw Rcs Data for particular batch.  
-- Query : exec Getrcsrawdataforbatchingestion '1'    
-- =============================================    
CREATE PROCEDURE [dbo].[GetRcsRawDataForBatchIngestion] @BatchID INT 
AS 
  BEGIN 
      SELECT * 
      FROM   [rcsrawdata] 
      WHERE  [BatchID] = @BatchID 
             AND ingestionstatus = 0 
  END
