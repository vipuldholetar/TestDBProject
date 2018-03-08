
-- ========================================================================
-- Author		: Arun Nair 
-- Create date	: 07/14/2015
-- Description	: Update Exception for  Cinema Work Queue
-- Execution	: sp_CinemaWorkQueueCreativeSignatureMarkAsException  
-- Updated By	: Arun Nair on 08/14/2015 - Added AssignedTo to ExceptionDetails
--				  Karunakar on 7th Sep 2015				   
--=========================================================================
CREATE PROCEDURE [dbo].[sp_CinemaWorkQueueCreativeSignatureMarkAsException]
(
@CreativeSignature AS NVARCHAR(MAX),
@IsException as bit,
@ExceptionType As Nvarchar(max),
@UserId As Int,
@AssignedTo AS INT
)
AS
BEGIN

		BEGIN TRY
				DECLARE @Patternmasterstagingid as Int
				Declare @MediaStream as varchar(50)=''
				BEGIN TRANSACTION 
					SELECT @MediaStream=value from [Configuration] where componentname='Media Stream' and Value='CIN'
					
					--Updating PatternMasterStgCIN IsException , Based on Creative Signature
					UPDATE  [dbo].[PatternStaging] SET Exception=@IsException WHERE [CreativeSignature]=@CreativeSignature
					

					 Select @Patternmasterstagingid=[PatternStagingID] from [PatternStaging] Where [CreativeSignature]=@CreativeSignature

					--Insert Exception Details for Pattern
					Insert into  [ExceptionDetail]
					([PatternMasterStagingID],ExceptionType,[CreatedDT],[CreatedByID],[ExcRaisedBy],[ExcRaisedOn],[ExceptionStatus],[MediaStream],[AssignedToID])
					 Values 
					 (
					 @Patternmasterstagingid,@ExceptionType,getdate(),@UserId,@UserId,getdate(),'Requested',@MediaStream,@AssignedTo
					 )

				COMMIT TRANSACTION
		END TRY

		 BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_CinemaWorkQueueCreativeSignatureMarkAsException]: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END