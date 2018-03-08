
-- =============================================    
-- Author:    Govardhan.R    
-- Create date: 04/06/2015    
-- Description:  Get RCS Batches    
-- Query : exec Getbatchesforingestion    
-- =============================================    
CREATE PROCEDURE [dbo].[GetBatchesForIngestion] 
AS 
  BEGIN 
      SELECT * 
      FROM   rcsxmldocs 
  END
