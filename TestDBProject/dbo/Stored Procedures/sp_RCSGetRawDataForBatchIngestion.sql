-- =============================================    
-- Author:    Govardhan.R    
-- Create date: 04/06/2015    
-- Description:  Get Raw RCS Data for particular batch.  
-- Query : exec sp_RCSGetRawDataForBatchIngestion '1'    
-- =============================================    
CREATE PROCEDURE [sp_RCSGetRawDataForBatchIngestion] @BatchId INT 
AS 
  BEGIN 
      SELECT * 
      FROM   RCSRawData 
      WHERE  [BatchID] = @BatchId 
             AND IngestionStatus = 0 
			 order by RCSRawDataID
  END