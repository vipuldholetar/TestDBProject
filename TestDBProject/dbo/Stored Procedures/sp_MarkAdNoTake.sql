-- =============================================
-- Author:		Karunakar
-- Create date: 04/19/2015
-- Description: This stored procedure is used to Mark Adid as Notake Ad
-- Execution Process: [Ino_dpf_markadasnotake] 
-- =============================================
CREATE PROCEDURE [dbo].[sp_MarkAdNoTake]
	@adId int,
	@notakereasoncode int,
	@UserId Int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN Try
   update ad set NoTakeAdReason=@notakereasoncode,ModifiedDate=getDate(),ModifiedBy=@UserId where ad.[AdID]=@adId
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
