-- ================================================================================
-- Author		: Arun Nair 
-- Create date	: 07/08/2015
-- Description	: Update Query in Radio Queue  
-- Updated By	: Ramesh on 08//11/2015 - CleanUp for OneMTDB/ 
--				  Arun Nair on 08/14/2015 - Added AssignedTo to ExceptionDetails 
--==================================================================================
CREATE PROCEDURE [dbo].[sp_RadioMarkCSException]
(
@CreativeSignature AS NVARCHAR(MAX),
@IsException as bit,
@ExceptionType As Nvarchar(max),
@UserId As INT,
@AssignedTo AS INT
)
AS
BEGIN

		BEGIN TRY
		          
			    DECLARE @Patternmasterstagingid as Int
				DECLARE @MediaStream as varchar(50)=''

				BEGIN TRANSACTION 

				SELECT @MediaStream=value from [Configuration] where componentname='Media Stream' and Value='RAD'
				SELECT @Patternmasterstagingid = [PatternStagingID] from [PatternStaging] where CreativeSignature = @CreativeSignature 

				UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException WHERE [PatternStagingID] = @Patternmasterstagingid 

				INSERT INTO  [ExceptionDetail]
					([PatternMasterStagingID],ExceptionType,[CreatedDT],[CreatedByID],[ExcRaisedBy],[ExcRaisedOn],[ExceptionStatus],[MediaStream],[AssignedToID])
				VALUES 
					 (@Patternmasterstagingid,@ExceptionType,getdate(),@UserId,@UserId,getdate(),'Requested',@MediaStream,@AssignedTo)

				COMMIT TRANSACTION
		END TRY

		 BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_RadioQueueCreativeSignatureMarkAsException: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END