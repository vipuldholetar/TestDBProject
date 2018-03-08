--===============================================================================

-- Author			: KARUNAKAR.P 

-- Create date		: 10th December 2015

-- Description		: Update the RCS Adhoc PatternMasterStdID Status in Exception table

-- Updated By		:  

--================================================================================

CREATE PROCEDURE [dbo].[sp_RCSAdhocUpdateExceptionPatternStatus]

(

@PatternmasterStgID  AS BIGINT

)

AS

BEGIN

			SET NOCOUNT ON;	    

			BEGIN TRY

				BEGIN TRANSACTION 



					--Updating Exception Status will be done after Adhoc Media Downloaded.

					Update [ExceptionDetail] set ExceptionStatus='Resolved' where [PatternMasterStagingID]=@PatternmasterStgID
					UPDATE [dbo].[PatternStaging] set [Exception] = 0 where [PatternStagingID]=@PatternmasterStgID


				COMMIT TRANSACTION

 			END TRY 

			BEGIN CATCH 

						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 

						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

						RAISERROR ('sp_RCSAdhocUpdateExceptionPatternStatus: %d: %s',16,1,@error,@message,@lineNo);

						ROLLBACK TRANSACTION

			END CATCH 

	

END