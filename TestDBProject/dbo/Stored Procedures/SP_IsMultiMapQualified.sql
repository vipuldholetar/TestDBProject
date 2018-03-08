 CREATE PROCEDURE [dbo].[SP_IsMultiMapQualified] 
 @AdvertiserId int 
 AS 
 BEGIN 
   SET nocount ON;  
       BEGIN try  
 		SELECT dbo.ufn_IsQualifiedForMultiMap(@AdvertiserId) as IsQualified 
       END try  
  
       BEGIN catch  
           DECLARE @error   INT,  
                   @message VARCHAR(4000),  
                   @lineNo  INT  
  
           SELECT @error = Error_number(),@message = Error_message(),  
                  @lineNo = Error_line()  
  
           RAISERROR ('[SP_IsMultiMapQualified]: %d: %s',16,1,@error,@message,  
                      @lineNo);  
  
           ROLLBACK TRANSACTION  
       END catch  
  
 END