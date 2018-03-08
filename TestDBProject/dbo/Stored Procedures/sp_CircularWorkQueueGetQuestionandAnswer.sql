-- =============================================
-- Author:		<Lisa East>
-- Create date: <3/27/2017>
-- Description:	This stored procedure is used to return all the  Q AND A in for a circular occurrence 
-- Exec sp_CircularWorkQueueGetQuestionandAnswer 5127
-- =============================================
CREATE PROCEDURE  [dbo].[sp_CircularWorkQueueGetQuestionandAnswer]

(
@OccurrenceId AS INTEGER
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		If @OccurrenceId > 0
		BEGIN 
	       SELECT [dbo].[QueryDetail].QueryText,[dbo].[QueryDetail].[QryAnswer] 
		   FROM dbo.OccurrenceDetailCIR Left Join [QueryDetail] On [QueryDetail].Occurrenceid=OccurrenceDetailCIR.OccurrenceDetailCIRID 
		   Where OccurrenceDetailCIR.OccurrenceDetailCIRID=@OccurrenceID  AND [QueryDetail].QueryText is not null
		END 
	END TRY 
	BEGIN CATCH
		DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		RAISERROR ('[sp_PublicationWorkQueueGetQuestionandAnswer]: %d: %s',16,1,@error,@message,@lineNo);
	END CATCH
END
