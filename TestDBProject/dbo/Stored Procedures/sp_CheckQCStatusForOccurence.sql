-- =============================================
-- Author:		Suman Saurav
-- Create date: 08 Feb 2016
-- Description:	without scan, the QCStatus and OccurrenceStatus of occurrences should not be complete
-- =============================================
CREATE PROCEDURE [dbo].[sp_CheckQCStatusForOccurence]
(
	@OccurrenceId	INT = 0 
)
AS
BEGIN
	DECLARE @MediaStream VARCHAR(25) = '', @OccDetailQCStatus VARCHAR(25) = '', @OccDetailOccStatus VARCHAR(25) = '', @Result INT = 0,
			@ConfigQCStatus VARCHAR(25) = '', @ConfigOccStatus VARCHAR(25) = ''
    SET NOCOUNT ON
    BEGIN TRY              
		SET @MediaStream = (SELECT dbo.fn_GetMediaStream(@OccurrenceID))
		SET @ConfigOccStatus = (SELECT ValueTitle FROM [Configuration] WHERE ComponentName = 'Occurrence Status' AND Value = 'C')
		SET @ConfigQCStatus  = (SELECT ValueTitle FROM [Configuration] WHERE ComponentName = 'QC Status' AND Value = 'C')

		IF @MediaStream = 'CIR' 
		BEGIN
			SELECT 
			@OccDetailQCStatus = b.[Status], 
			@OccDetailOccStatus = c.[Status]
			FROM [dbo].[OccurrenceDetailCIR] a
			inner join QCStatus b on a.QCStatusID = b.QCStatusID
			inner join OccurrenceStatus c on a.OccurrenceStatusID = c.OccurrenceStatusID
			WHERE [OccurrenceDetailCIRID] = @OccurrenceId
		END
		IF @MediaStream = 'PUB' 
		BEGIN
			SELECT 
			@OccDetailQCStatus = b.[Status], 
			@OccDetailOccStatus = c.[Status]
			FROM [dbo].[OccurrenceDetailPUB] a
			inner join QCStatus b on a.QCStatusID = b.QCStatusID
			inner join OccurrenceStatus c on a.OccurrenceStatusID = c.OccurrenceStatusID
			WHERE [OccurrenceDetailPUBID] = @OccurrenceId
		END
		IF @MediaStream = 'EM' 
		BEGIN
			SELECT 
			@OccDetailQCStatus = b.[Status], 
			@OccDetailOccStatus = c.[Status]
			FROM [dbo].[OccurrenceDetailEM] a
			inner join QCStatus b on a.QCStatusID = b.QCStatusID
			inner join OccurrenceStatus c on a.OccurrenceStatusID = c.OccurrenceStatusID
			WHERE [OccurrenceDetailEMID] = @OccurrenceId
		END
		IF @MediaStream = 'WEB' 
		BEGIN
			SELECT 
			@OccDetailQCStatus = b.[Status], 
			@OccDetailOccStatus = c.[Status]
			FROM [dbo].[OccurrenceDetailWEB] a
			inner join QCStatus b on a.QCStatusID = b.QCStatusID
			inner join OccurrenceStatus c on a.OccurrenceStatusID = c.OccurrenceStatusID
			WHERE [OccurrenceDetailWEBID] = @OccurrenceId
		END
		IF @MediaStream = 'SOC'
		BEGIN
			SELECT 
			@OccDetailQCStatus = b.[Status], 
			@OccDetailOccStatus = c.[Status]
			FROM [dbo].[OccurrenceDetailSOC] a
			inner join QCStatus b on a.QCStatusID = b.QCStatusID
			inner join OccurrenceStatus c on a.OccurrenceStatusID = c.OccurrenceStatusID
			WHERE [OccurrenceDetailSOCID] = @OccurrenceId
		END

		IF(@OccDetailQCStatus <> @ConfigQCStatus OR @OccDetailOccStatus <> @ConfigOccStatus)
		BEGIN
			SET @Result = 1
		END					
		SELECT @Result
	END TRY
	BEGIN CATCH 
		DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
        SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
		RAISERROR ('[sp_CheckQCStatusForOccurence]: %d: %s', 16, 1, @error, @message, @lineNo); 
	END CATCH 
END