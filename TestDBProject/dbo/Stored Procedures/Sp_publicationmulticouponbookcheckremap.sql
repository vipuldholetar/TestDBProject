
-- ===================================================================  
-- Author    :  Arun Nair  
-- Create date  :   01 Feb 2016  
-- Description  :    
-- Exec      :     
-- ===================================================================  
CREATE PROCEDURE [dbo].[Sp_publicationmulticouponbookcheckremap] @Adid AS INT 
--@Occurrencelist AS NVARCHAR(MAX)  
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @PatternCount AS INT=0 

      BEGIN try 
          SELECT @PatternCount = Count(*) 
          FROM   [Pattern] 
          WHERE  [AdID] = @Adid 

          IF @PatternCount = 1 
            BEGIN 
                SELECT 0 AS Result 
            END 
          ELSE 
            BEGIN 
                SELECT 1 AS Result 
            END 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(),@message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_PublicationMultiCouponBookCheckReMap]: %d: %s',16,1, 
                     @error, 
                     @message,@lineNo); 
      END catch 
  END
