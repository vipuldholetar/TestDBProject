-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE sp_UpdateNoTakeOccurrenceDetailsPUB
	-- Add the parameters for the stored procedure here
@OccurrenceStatus VARCHAR(100),@OccurrenceID INT,@NoTakeReason VARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     BEGIN TRY 
	 --UPDATE [OccurrenceDetailPUB] SET OccurrenceStatus = @OccurrenceStatus, NoTakeReason = @NoTakeReason WHERE [OccurrenceDetailPUBID] = @OccurrenceID
	 update [OccurrenceDetailPUB]
	 set 
	 OccurrenceStatusID = (select OccurrenceStatusID from OccurrenceStatus where [Status] = @OccurrenceStatus), 
	 NoTakeReason = @NoTakeReason 
	 WHERE [OccurrenceDetailPUBID] = @OccurrenceID

	 END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number() 
                 ,@message = Error_message() 
                 ,@lineNo = Error_line() 

          RAISERROR ('sp_UpdateNoTakeOccurrenceDetailsPUB: %d: %s',16,1,@error, @message,@lineNo); 
      END CATCH 

END