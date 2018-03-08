-- =============================================    

-- Author:    Govardhan.R    

-- Create date: 04/06/2015    

-- Description:  Get RCS Batches    

-- Query : exec sp_RCSGetBatchesForIngestion    

-- =============================================    

CREATE PROCEDURE [sp_RCSGetBatchesForIngestion] 

AS 

  BEGIN 

      SELECT * 
      FROM   RCSXmlDocs 
	  where exists (select 1 FROM   RCSRawData WHERE   IngestionStatus = 0 )
	  order by [RCSXmlDocsID]

  END