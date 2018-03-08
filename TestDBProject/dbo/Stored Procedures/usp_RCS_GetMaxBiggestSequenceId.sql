--============================================================================================================= 
-- =============================================  
-- Author:    Govardhan  
-- Create date: 03/23/2015  
-- Description:  Get the maximum Biggest Sequence ID 
-- Query :  
/* 



exec [usp_RCS_GetMaxBiggestSequenceId] 



*/ 
-- =============================================  
CREATE PROCEDURE [dbo].[usp_RCS_GetMaxBiggestSequenceId] 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          SELECT Max(BiggestSeqForAirplayChange)[BiggestSequenceId] 
          FROM   rcsxmldocs 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('usp_RCS_GetMaxBiggestSequenceId: %d: %s',16,1,@error, 
                     @message, 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
