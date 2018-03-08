
-- =================================================================================================================      
-- Author			: Karunakar     
-- Create date		: 28th September 2015     
-- Description		: This Procedure is Used to delete records from online display staging tables
-- Execution		: sp_OnlineVideoDeleteStagingRecords  
-- Updated By		:      
-- ================================================================================================================      
CREATE PROCEDURE [dbo].[sp_OnlineVideoDeleteStagingRecords] 
(
@CreativeStagingID INT
) 
AS 
  BEGIN try 
     
      --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster                  
      DELETE FROM [dbo].[PatternStaging] 
      WHERE  [CreativeStgID] = @CreativeStagingID 

      DELETE FROM [dbo].[CreativeDetailStagingONV] 
      WHERE  CreativeStagingID = @CreativeStagingID 

      DELETE FROM [dbo].[CreativeStaging] 
      WHERE  [CreativeStagingID] = @CreativeStagingID 
  END try 

  BEGIN catch 
			  DECLARE @error   INT, 
              @message VARCHAR(4000), 
              @lineno  INT 
      SELECT @error = Error_number(),@message = Error_message(),@lineno = Error_line() 
      RAISERROR ('sp_OnlineVideoDeleteStagingRecords: %d: %s',16,1,@error,@message, @lineno); 
       
  END catch