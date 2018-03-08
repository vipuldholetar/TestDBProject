-- =================================================================================
-- Author		:	Arun Nair 
-- Create date	:	2nd September 2015
-- Description	:	ReviewQueueUndo QCNoTake & MapIndex
-- Updated By	:	Ramesh Bangi for Online Display on 	09/25/2015
--				:	Karunakar on 13th October 2015,Adding Online Video and Mobile Media Streams to QC Notake Map Index				
-- =================================================================================

CREATE PROCEDURE [dbo].[sp_ReviewQueueUndoQCNoTakeMapIndex]
(
@MediaStreamID AS Int,
@PatternmasterId AS INT,
@AdId AS INT,
@OccurrenceId AS INT,
@UserId AS INT 
)
AS
BEGIN
		SET NOCOUNT ON;
		BEGIN TRY								
				DECLARE @MediaStream As Nvarchar(max)=''
				SELECT @MediaStream=Value  FROM   [dbo].[Configuration] WHERE ConfigurationID=@MediaStreamID

				BEGIN TRANSACTION 
					IF(@MediaStream='RAD')
						BEGIN
							UPDATE [dbo].[Pattern] SET NoTakeReasonCode=NULL,[AdID]=@AdId,AuditBy=@UserId,AuditDate=getdate() WHERE [PatternID] =@PatternmasterId
							UPDATE [dbo].[OccurrenceDetailRA] SET [AdID]=@AdId WHERE [PatternID]=@PatternmasterId
						END
					IF(@MediaStream='TV')
						BEGIN
							UPDATE [dbo].[Pattern] SET NoTakeReasonCode=NULL,[AdID]=@AdId,AuditBy=@UserId,AuditDate=getdate() WHERE [PatternID] =@PatternmasterId
							UPDATE [dbo].[OccurrenceDetailTV] SET [AdID]=@AdId WHERE [PatternID]=@PatternmasterId										
						END
					IF(@MediaStream='OD')
						BEGIN
							UPDATE [dbo].[Pattern] SET NoTakeReasonCode=NULL,[AdID]=@AdId,AuditBy=@UserId,AuditDate=getdate() WHERE [PatternID] =@PatternmasterId
							UPDATE [dbo].[OccurrenceDetailODR] SET [AdID]=@AdId WHERE [PatternID]=@PatternmasterId		
						END
					IF(@MediaStream='CIN')
						BEGIN
							UPDATE [dbo].[Pattern] SET NoTakeReasonCode=NULL,[AdID]=@AdId,AuditBy=@UserId,AuditDate=getdate() WHERE [PatternID] =@PatternmasterId
							UPDATE [dbo].[OccurrenceDetailCIN] SET [AdID]=@AdId WHERE [PatternID]=@PatternmasterId	
						END
					IF(@MediaStream='OND')
						BEGIN
							UPDATE [dbo].[Pattern] SET NoTakeReasonCode=NULL,[AdID]=@AdId,AuditBy=@UserId,AuditDate=getdate() WHERE [PatternID] =@PatternmasterId
							UPDATE [dbo].[OccurrenceDetailOND] SET [AdID]=@AdId WHERE [PatternID]=@PatternmasterId	
						END
					IF(@MediaStream='ONV')
						BEGIN
							UPDATE [dbo].[Pattern] SET NoTakeReasonCode=NULL,[AdID]=@AdId,AuditBy=@UserId,AuditDate=getdate() WHERE [PatternID] =@PatternmasterId
							UPDATE [dbo].[OccurrenceDetailONV] SET [AdID]=@AdId WHERE [PatternID]=@PatternmasterId	
						END
					IF(@MediaStream='MOB')
						BEGIN
							UPDATE [dbo].[Pattern] SET NoTakeReasonCode=NULL,[AdID]=@AdId,AuditBy=@UserId,AuditDate=getdate() WHERE [PatternID] =@PatternmasterId
							UPDATE [dbo].[OccurrenceDetailMOB] SET [AdID]=@AdId WHERE [PatternID]=@PatternmasterId	
						END
				COMMIT TRANSACTION
		END TRY
		BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_ReviewQueueQCNoTakeUndoMapIndex]: %d: %s',16,1,@error,@message,@lineNo);
				ROLLBACK TRANSACTION
		END CATCH 
		
END