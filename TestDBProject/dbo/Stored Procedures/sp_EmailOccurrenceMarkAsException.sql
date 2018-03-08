CREATE PROCEDURE [dbo].[sp_EmailOccurrenceMarkAsException]
(
@OccurrenceId AS Int,
@IsException as bit,
@ExceptionType As Nvarchar(max),
@UserId As Int,
@AssignedTo AS INT
)
AS
BEGIN

		BEGIN TRY
				DECLARE @Patternmasterstagingid as Int
				DECLARE @MediaStream as varchar(50)='',@CreativeSignature AS NVARCHAR(MAX)
				DECLARE @CreativeMasterStgid AS INT 

				BEGIN TRANSACTION 
					SELECT @MediaStream=value from [Configuration] where componentname='Media Stream' and Value='EM'
					
					
					if exists(Select [PatternStagingID] FROM [PatternStaging] inner join [dbo].[OccurrenceDetailEM]  on [dbo].[OccurrenceDetailEM].PatternID=[dbo].[PatternStaging].PatternID WHERE [OccurrenceDetailEMID] = @OccurrenceID	)
					BEGIN
					SELECT @Patternmasterstagingid = [PatternStagingID] FROM [PatternStaging] inner join [dbo].[OccurrenceDetailEM]  on [dbo].[OccurrenceDetailEM].PatternID=[dbo].[PatternStaging].PatternID WHERE [OccurrenceDetailEMID] = @OccurrenceID	
					--Updating PatternMasterStgCIN IsException , Based on Creative Signature
					UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException WHERE [PatternStagingID] = @Patternmasterstagingid 
					
					END
					ELSE
					BEGIN
					SELECT @Patternmasterstagingid =  [Pattern].[PatternID] FROM [Pattern] inner join [dbo].[OccurrenceDetailEM]  on [dbo].[OccurrenceDetailEM].PatternID=[dbo].[Pattern].PatternID WHERE [OccurrenceDetailEMID] = @OccurrenceID	
					--Updating PatternMasterStgCIN IsException , Based on Creative Signature
					UPDATE  [dbo].[Pattern] SET [Exception]=@IsException,ModifyDate=GETDATE(),ModifiedBy=@UserId WHERE [PatternID] = @Patternmasterstagingid 
					END
									
										
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
			  RAISERROR ('[dbo].[sp_EmailOccurrenceMarkAsException]: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END