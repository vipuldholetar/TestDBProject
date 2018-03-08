
-- =============================================
-- Author		: Karunakar
-- Create date	: 17th June 2015
-- Description	: This stored procedure is used to Mark Adid as Notake Ad
--UpdatedBy		: Ramesh Bangi on 08/14/2015  for OneMT CleanUp
-- =============================================
CREATE PROCEDURE [dbo].[sp_PublicationAdMarkAsNoTake] 
	@adId int,
	@notakereasoncode int
AS
BEGIN
	
	SET NOCOUNT ON;
    BEGIN Try
   update Ad set NoTakeAdReason=@notakereasoncode where [AdID]=@adId
   End Try
   BEGIN CATCH 

        DECLARE @error   INT, 
                @message VARCHAR(4000), 
                @lineNo  INT
        SELECT @error = Error_number(), 
               @message = Error_message(), 
               @lineNo = Error_line() 
    RAISERROR ('Ino_dpf_markadasnotake: %d: %s',16,1,@error,@message,@lineNo);
    END CATCH 
END
