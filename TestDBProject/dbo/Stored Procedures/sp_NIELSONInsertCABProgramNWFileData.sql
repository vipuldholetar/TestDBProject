  -- =============================================   
-- Author:    Govardhan   
-- Create date: 05/22/2015   
-- Description: Process Ingestion for Cable Program national weekly file.  
-- Query :   
/*  

exec sp_NIELSONInsertCABProgramNWFileData '',  

*/ 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_NIELSONInsertCABProgramNWFileData] (@NIELSONINGNWData dbo.NIELSONINGNWData 
readonly) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

        INSERT INTO [ProgramCableData] ([Value])
		SELECT VALUE FROM  @NIELSONINGNWData

          --SELECT Count(*)[ImportedRecCount] 
          --FROM   rcsrawdata 
          --WHERE  batchid = @BatchID 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_NIELSONInsertCABProgramNWFileData: %d: %s',16,1,@error,@message, 
                     @lineNo 
          ); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
