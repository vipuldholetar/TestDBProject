-- =================================================================================================
-- Author			:	Govardhan.R
-- Create date		:	08/04/2015
-- Description		:	Q&A Query Queue
-- Execution Process:  [sp_CPQueryQueueQ&A]
-- ================================================================================================

CREATE PROCEDURE [dbo].[sp_CPQueryQueueQ&A]
(
@Answer  AS NVARCHAR(MAX),
@MediaStream AS NVARCHAR(20),
@QueryId AS INTEGER,
@UserId AS INTEGER,
@KeyId AS BIGINT,
@KeyIdMode AS NVARCHAR(20)
)
AS
SET NOCOUNT ON 
BEGIN
			BEGIN TRY 
					BEGIN TRANSACTION
						UPDATE [QueryDetail] SET [QryAnswer]=@Answer,[QryAnsweredBy]=@UserId,[QryAnsweredOn]=GETDATE() WHERE [QueryID]=@QueryId

						IF(lower(@KeyIdMode)='ad')
						BEGIN
						UPDATE AD SET [Query]=NULL WHERE [AdID]=@KeyId
						END
						ELSE IF(lower(@KeyIdMode)='occurrence')
						BEGIN
							 IF (lower(@MediaStream)='PUB')
								BEGIN	
										UPDATE  [dbo].[OccurrenceDetailPUB] SET [Query]=NULL WHERE [OccurrenceDetailPUBID]=@KeyId 
								END

							ELSE IF (lower(@MediaStream)='CIR')
								BEGIN	
										UPDATE [dbo].[OccurrenceDetailCIR] SET [Query]=NULL WHERE [OccurrenceDetailCIRID]=@KeyId
								END
						END
						ELSE IF(lower(@KeyIdMode)='promotion')
						BEGIN
						UPDATE [Promotion] SET [Query]=NULL WHERE [PromotionID]=@KeyId
						END
	
					COMMIT TRANSACTION 

				END TRY 
				BEGIN CATCH
					ROLLBACK TRANSACTION 
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
   				    SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[dbo].[sp_CPQueryQueueQ&A]: %d: %s',16,1,@error,@message,@lineNo); 					 
				END CATCH

END
