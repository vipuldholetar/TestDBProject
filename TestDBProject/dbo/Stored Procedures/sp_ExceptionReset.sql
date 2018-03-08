

-- ===========================================================================================================================
-- Author				: Ramesh Bangi
-- Create Date			: 7/28/2015
-- Description			: This stored procedure is used to Getting Exception Queue View Data
-- Execution Process	: [dbo].[sp_ExceptionReset]'22777','Cinema'
-- Updated By			: Ramesh Bangi for Online Display and Online Video
--                      : Karunakar on 10/12/2015 - Adding Mobile Media Stream in to Reset Exception
--						: Arun Nair on 10/14/2015 - MI-229 On Reset Exception Change Status to "Resolved w/o Further Action"
-- ============================================================================================================================

CREATE PROCEDURE [dbo].[sp_ExceptionReset]  
(
 @KeyId AS Integer,
 @MediaStreamId AS NVARCHAR(MAX)
)
AS
Declare @Pk_Id INT
BEGIN
		Declare @MediaStreamValue As NVARCHAR(50)
		Select @MediaStreamValue = Value From [Configuration] Where SystemName = 'All' And ComponentName = 'Media Stream' And ValueTitle = @MediaStreamId
		BEGIN TRY

		IF(@MediaStreamValue='CIN')
			BEGIN
				UPDATE [dbo].[PatternStaging] set Exception = 0 where [PatternStagingID]=@KeyId
			END
		IF(@MediaStreamValue='TV')
			BEGIN
				UPDATE [dbo].[PatternStaging] set [Exception] = 0 where  [PatternStagingID]=@KeyId
			END

         IF(@MediaStreamValue='OD')
			BEGIN
				UPDATE [dbo].[PatternStaging] set [Exception] = 0 where [PatternStagingID]=@KeyId
			END
	     IF(@MediaStreamValue='RAD')
			BEGIN
				UPDATE [dbo].[PatternStaging] set [Exception] = 0 where [PatternStagingID]=@KeyId
			END
		IF(@MediaStreamValue='OND')
			BEGIN
				UPDATE [dbo].[PatternStaging] set [Exception] = 0 where [PatternStagingID]=@KeyId
			END
		IF(@MediaStreamValue='ONV')
			BEGIN
				UPDATE [dbo].[PatternStaging] set [Exception] = 0 where [PatternStagingID]=@KeyId
			END

		IF(@MediaStreamValue='MOB')		--Adding Mobile Media Stream in to Reset Exception
			BEGIN
				UPDATE [dbo].[PatternStaging] set [Exception] = 0 where [PatternStagingID]=@KeyId
			END

		--On Reset Exception Change Status to "Resolved w/o Further Action"
			UPDATE [dbo].[ExceptionDetail] set ExceptionStatus  = 'Resolved w/o Further Action' where [PatternMasterStagingID] = @KeyId
		END TRY

		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_ExceptionReset]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH

END