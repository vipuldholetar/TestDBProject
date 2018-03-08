-- ========================================================================
-- Author		: Murali Jaganathan 
-- Create date	: 07/13/2015
-- Description	: Update Query in Television Work Queue  
-- Updated By	: Updated Changes by Karunakar on 24th july 2015
--				  Arun Nair on 08/14/2015 - Added AssignedTo to ExceptionDetails 
--=========================================================================

CREATE PROCEDURE [dbo].[sp_TelevisionWorkQueueCreativeSignatureMarkAsException]
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

				Select @MediaStream=value from [Configuration] where componentname='Media Stream' and Value='TV'
					--Update IsQuery  Based on Creative Signature
					UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException WHERE [CreativeSignature]=@CreativeSignature
					

					 Select @Patternmasterstagingid=[PatternStagingID] from [PatternStaging] Where [CreativeSignature]=@CreativeSignature
					--Insert Exception Details for Pattern
					INSERT INTO [dbo].[ExceptionDetail]
					(
					  [PatternMasterStagingID],[PatternMasterID],[ExceptionType],[ExceptionStatus],[ExcRaisedBy],[ExcRaisedOn],[CreatedDT],[CreatedByID],[MediaStream],[AssignedToID]
					)
					VALUES
					(
					  @Patternmasterstagingid,NULL,@ExceptionType,'Requested',@UserId,getdate(),getdate(),@UserId,@MediaStream,@AssignedTo
					)

				COMMIT TRANSACTION
		END TRY


		 BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_TelevisionWorkQueueCreativeSignatureMarkAsException: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END