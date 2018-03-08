


-- ============================================================================================
-- Author		:	Karunakar
-- Create date	:	2nd September 2015
-- Description	:	This Procedure is Used to Perform QC NoTake Change to Unable to Index
-- Updated By	:	Ramesh Bangi for Online Display
--				:   Karunakar on 13th October 2015,Adding Mobile and Online Video Media Streams
					-- SP needs to be refactored for Hard coded values
-- ============================================================================================
CREATE PROCEDURE [dbo].[sp_ReviewQueueUpdatePatternQCUnableIndex]
	@Patternmasterstgid As Int,
	@MediaStreamId As Int,
	@UserId as int	
AS
BEGIN
SET NOCOUNT ON;
    BEGIN TRY
				
				BEGIN TRANSACTION 
				Declare @MediaStream As Nvarchar(max)=''
				Declare @MediaStreamValue As NVARCHAR(MAX)=''
				Declare @ExceptionStatus as Nvarchar(max)='Requested'
				Declare @ExceptionType as nvarchar(50)='UI'
				Select @MediaStream=ValueTitle ,@MediaStreamValue=Value from   [dbo].[Configuration] Where ConfigurationID=@MediaStreamId
				
				IF(@MediaStreamValue='RAD')	-- Radio
					BEGIN
					 Update [PatternStaging] Set [Exception]=1 ,ExceptionText='Unable to Index' Where [PatternStaging].[PatternStagingID]=@Patternmasterstgid
					END
				IF(@MediaStreamValue='TV')	-- Television
					BEGIN
					Update [dbo].[PatternStaging] Set [Exception]=1  Where [PatternStaging].[PatternStagingID]=@Patternmasterstgid
					END
				IF(@MediaStreamValue='CIN')	-- Cinema
					BEGIN
					Update [dbo].[PatternStaging] Set Exception=1  Where [PatternStaging].[PatternStagingID]=@Patternmasterstgid
					END
				IF(@MediaStreamValue='OD')	-- Outdoor
					BEGIN
					Update [dbo].[PatternStaging] Set [Exception]=1  Where [PatternStaging].[PatternStagingID]=@Patternmasterstgid
					END
				IF(@MediaStreamValue='OND')	-- Online Display
					BEGIN
					 Update [PatternStaging] Set [Exception]=1 ,ExceptionText='Unable to Index' Where [PatternStaging].[PatternStagingID]=@Patternmasterstgid
					END
				IF(@MediaStreamValue='ONV')	-- Online Video
					BEGIN
					 Update [PatternStaging] Set [Exception]=1 ,ExceptionText='Unable to Index' Where [PatternStaging].[PatternStagingID]=@Patternmasterstgid
					END
				IF(@MediaStreamValue='MOB')	-- Mobile
					BEGIN
					 Update [PatternStaging] Set [Exception]=1 ,ExceptionText='Unable to Index' Where [PatternStaging].[PatternStagingID]=@Patternmasterstgid
					END
				-- Inserting Exception Details
				 Insert into [ExceptionDetail]
				 ([PatternMasterStagingID],[MediaStream],[ExceptionType],[ExceptionStatus],[ExcRaisedBy],[ExcRaisedOn],[CreatedDT],[CreatedByID])
				 Values
				 (@Patternmasterstgid,@MediaStreamValue,@ExceptionType,@ExceptionStatus,@UserId,getdate(),getdate(),@UserId)
				COMMIT TRANSACTION
 			END TRY 
			BEGIN CATCH 
						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('sp_ReviewQueueUpdatePattermasterMoveData: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 
			END