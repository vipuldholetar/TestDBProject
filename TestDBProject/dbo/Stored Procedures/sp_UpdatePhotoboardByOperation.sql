CREATE PROCEDURE [dbo].[sp_UpdatePhotoboardByOperation]
(
@UserId as int,
@Repository Varchar(100) = '',
@AssetName Varchar(100) = '',
@PhotoboardId int,
@Operation Varchar(100)
)
AS
BEGIN

		SET NOCOUNT ON;
		BEGIN TRY									
		
		if @Operation = 'Start'
		begin
			UPDATE Photoboard
				SET [StartedByID] = @UserId,
					[StartedDT] = GETDATE(),
					[AssignedToID] = @UserId,
					Status = 'S',
					[AVRepository] = @Repository,
					[AVAssetName] = @AssetName
				WHERE PhotoboardID = @PhotoboardId
					  AND [StartedDT] is NULL
		end

		if @Operation = 'Finish'
		begin
			UPDATE	Photoboard
				SET [FinishedByID] = @UserId,
					[FinishedDT] = GETDATE(),
					Status = 'F',
					[PDFRepository] = @Repository,
					[PDFAssetName] = @AssetName
					WHERE PhotoboardID = @PhotoboardId
					AND [StartedDT] is not NULL
					AND [FinishedDT] is NULL
					AND [StartedByID] = @UserId
		end
		
		if @Operation = 'Remove'
		begin
			UPDATE Photoboard
			SET [Deleted] = 1,
			Status = 'X'
			WHERE  PhotoboardID = @PhotoboardId
		end
		
		if @Operation = 'Cancel'
		begin
			UPDATE	Photoboard
			SET		[StartedDT] = NULL,
					[StartedByID] = NULL,
					[AssignedToID] = NULL,
					Status = NULL,
					[AVRepository] = NULL,
					[AVAssetName] = NULL
			WHERE	PhotoboardID =  @PhotoboardId
					AND [StartedDT] is not NULL

		end

		if @Operation = 'Assign'
		begin
			if((select count(*) from photoboard where photoboardid = @PhotoboardId and starteddt is not null) = 1)
			begin
				UPDATE Photoboard
				SET AssignedToID =  @UserId
				WHERE PhotoboardID = @PhotoboardId
			end
			else
			begin
				UPDATE Photoboard
				SET AssignedToID = @UserId,
					StartedDT = GETDATE()
				WHERE PhotoboardID = @PhotoboardId
			end
		end

		if @Operation = 'Replace'
		begin
			UPDATE Photoboard
			SET PDFRepository = NULL,
				PDFAssetName = NULL,
				Status = 'R',
				AuditById = @UserId,
				AuditDT = GETDATE()
			WHERE PhotoboardID = @PhotoboardId
		end

		if @Operation = 'Audit'
		begin
			UPDATE Photoboard
			SET AuditById = @UserId,
				AuditDT = GETDATE()
			WHERE PhotoboardID = @PhotoboardId
		end

		END TRY

		BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_UpdatePhotoboardByOperation]: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 
END