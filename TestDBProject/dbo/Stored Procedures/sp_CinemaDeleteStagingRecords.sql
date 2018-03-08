
-- =================================================================================================================      
-- Author      : RP     
-- Create date    : 18th September 2015     
-- Description    : This Procedure is Used to delete records from staging     
-- Updated By    :      
-- ================================================================================================================      
CREATE PROCEDURE [dbo].[sp_CinemaDeleteStagingRecords] (@CreativeStagingID 
INT) 
AS 
  BEGIN try 
      BEGIN TRANSACTION 

      --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster                  
      DELETE FROM [dbo].[PatternStaging] 
      WHERE  [CreativeStgID] = @CreativeStagingID 

      DELETE FROM [dbo].[CreativeDetailStagingCIN] 
      WHERE  [CreativeStagingID] = @CreativeStagingID 

      DELETE FROM [dbo].[CreativeStaging] 
      WHERE  [CreativeStagingID] = @CreativeStagingID 
  END try 

  BEGIN catch 
      DECLARE @error   INT, 
              @message VARCHAR(4000), 
              @lineno  INT 

      SELECT @error = Error_number(),@message = Error_message(), 
             @lineno = Error_line() 

      RAISERROR ('sp_CinemaDeleteStagingRecords: %d: %s',16,1,@error,@message, 
                 @lineno); 

      ROLLBACK TRANSACTION 
  END catch