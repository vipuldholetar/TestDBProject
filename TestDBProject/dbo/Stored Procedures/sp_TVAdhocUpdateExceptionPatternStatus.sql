--===============================================================================

-- Author			: KARUNAKAR.P 

-- Create date		: 10th December 2015

-- Description		: Update the TV Adhoc PatternMasterStdID Status in Exception table

-- Updated By		:  

--================================================================================

CREATE PROCEDURE [dbo].[sp_TVAdhocUpdateExceptionPatternStatus]

(

@OriginalPRCode  AS NVARCHAR(50)

)

AS

BEGIN

			SET NOCOUNT ON;	    

			BEGIN TRY

				BEGIN TRANSACTION 

				Declare @PatternmasterStgID AS BIGINT

				Declare @IsPatterStatusCompleted As bit

				

				--Selecting PatternMasterStgID



				SET @PatternmasterStgID=(Select Distinct [PatternStagingID] from [PatternStaging]  inner join  [TVPattern] 

				on   [PatternStaging].[CreativeSignature]= [TVPattern].[TVPatternCODE]   

				where  [TVPattern].OriginalPRCode=@OriginalPRCode)



				IF(@PatternmasterStgID<>0)

				BEGIN

					IF EXISTS(Select 1 from [ExceptionDetail] where [PatternMasterStagingID]=@PatternmasterStgID and MediaStream='TV')

					BEGIN

						--Updating Exception Status will be done after Adhoc Media Downloaded.

						Update [ExceptionDetail] set ExceptionStatus='Resolved' where [PatternMasterStagingID]=@PatternmasterStgID and MediaStream='TV'

						update [PatternStaging] set [Exception] = 0 where [PatternStagingID]= @PatternmasterStgID

						set @IsPatterStatusCompleted=1

					END

					ELSE

					BEGIN

					set @IsPatterStatusCompleted=0

					END		

				END

				ELSE

				BEGIN

				set @IsPatterStatusCompleted=0

				END

				--Returning PatternStatus True/False

				Select @IsPatterStatusCompleted As PatternUpdateStatus,@PatternmasterStgID as PatternmasterstgId



				COMMIT TRANSACTION

 			END TRY 

			BEGIN CATCH 

						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 

						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

						RAISERROR ('sp_TVAdhocUpdateExceptionPatternStatus: %d: %s',16,1,@error,@message,@lineNo);

						ROLLBACK TRANSACTION

			END CATCH 

	

END