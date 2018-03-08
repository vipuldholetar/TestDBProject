-- ========================================================================
-- Author		: Ramesh Bangi 
-- Create date	: 9/18/2015
-- Description	: Update Exception for  Online Video Work Queue
-- Execution	: [dbo].[sp_OnlineVideoCSMarkAsException] 
-- Updated By	: 			   
--=========================================================================
CREATE PROCEDURE [dbo].[sp_OnlineVideoCSMarkAsException]
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
				DECLARE @MediaStream as varchar(50)=''
				DECLARE @CreativeMasterStgid AS INT 

				BEGIN TRANSACTION 
					SELECT @MediaStream=value from [Configuration] where componentname='Media Stream' and Value='ONV'
					SELECT @CreativeMasterStgid=[CreativeStagingID] from [CreativeStaging] Where CreativeSignature=@CreativeSignature


					--Updating PatternMasterStgCIN IsException , Based on Creative Signature
					UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException WHERE [CreativeStgID]=@CreativeMasterStgid

					 Select @Patternmasterstagingid=[PatternStagingID] from [PatternStaging] WHERE [CreativeStgID]=@CreativeMasterStgid

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
			  RAISERROR ('[dbo].[sp_OnlineVideoCSMarkAsException]: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END