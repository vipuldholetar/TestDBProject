
-- ========================================================================
-- Author		: Arun Nair 
-- Create date	: 07/08/2015
-- Description	: Update Query in Outdoor Work Queue  
-- Updated By	: Updated By Karunakar on 07/15/2015 ,Based on Feed Back Changes with Exception Details
--				  Arun Nair on 08/14/2015 - Added AssignedTo to ExceptionDetails 
--=========================================================================
CREATE PROCEDURE [dbo].[sp_OutdoorWorkQueueCreativeSignatureMarkAsException]
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
		          
			    Declare @Patternmasterstagingid as Int
				Declare @MediaStream as varchar(50)=''
				BEGIN TRANSACTION 

					SELECT @MediaStream=value FROM [Configuration] WHERE componentname='Media Stream' and Value='OD'
					SELECT @Patternmasterstagingid=[PatternStagingID] FROM [PatternStaging] WHERE [CreativeSignature]=@CreativeSignature

					UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException WHERE [CreativeSignature]=@CreativeSignature

					INSERT INTO  [ExceptionDetail]
					([PatternMasterStagingID],ExceptionType,[CreatedDT],[CreatedByID],[ExcRaisedBy],[ExcRaisedOn],[ExceptionStatus],[MediaStream],[AssignedToID])
					Values 
					(@Patternmasterstagingid,@ExceptionType,getdate(),@UserId,@UserId,getdate(),'Requested',@MediaStream,@AssignedTo)

				COMMIT TRANSACTION
		 END TRY
		 
		 BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_OutdoorWorkQueueCreativeSignatureMarkAsException: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END