
--============================================================================================================= 
-- =============================================   
-- Author:    Govardhan   
-- Create date: 03/23/2015   
-- Description:  Get the maximum Biggest Sequence Id  
-- Query :   
/*  
exec [sp_RCSGetMaxBiggestSeqId]  
*/ 
-- =============================================   
CREATE PROCEDURE [dbo].[sp_RCSGetMaxBiggestSeqId] 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          SELECT Max(BiggestSeqForAirplayChange)[BiggestSeqId] 
          FROM   RCSXmlDocs 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_RCSGetMaxBiggestSeqId: %d: %s',16,1,@Error, 
                     @Message, 
                     @LineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
