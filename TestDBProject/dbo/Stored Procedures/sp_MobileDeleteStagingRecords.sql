
-- =================================================================================================================      
-- Author			: Arun Nair      
-- Create date		: 10/05/2015
-- Description		: This Procedure is Used to delete records from Mobile Staging Tables
-- Execution		: sp_MobileDeleteStagingRecords  
-- Updated By		:      
-- ================================================================================================================      
CREATE PROCEDURE [dbo].[sp_MobileDeleteStagingRecords] 
(
@CreativeStagingID INT
) 
AS 
	  BEGIN TRY      
		  --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster                  
		 
		  DELETE FROM [dbo].[CreativeDetailStagingMOB]  WHERE  CreativeStagingID = @CreativeStagingID 

		  DELETE FROM [dbo].[CreativeStaging] WHERE  [CreativeStagingID] = @CreativeStagingID 

		   DELETE FROM [dbo].[PatternStaging]  WHERE  [CreativeStgID] = @CreativeStagingID 
	  END TRY 

  BEGIN CATCH 
	  DECLARE @error   INT,@message VARCHAR(4000),@lineno  INT 
      SELECT @error = Error_number(),@message = Error_message(),@lineno = Error_line() 
      RAISERROR ('[sp_MobileDeleteStagingRecords]: %d: %s',16,1,@error,@message, @lineno);        
  END CATCH