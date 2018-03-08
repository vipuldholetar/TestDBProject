
-- ========================================================================
-- Author		: Arun Nair 
-- Create date	: 08/03/2015
-- Description	: Update Exception in Query Queue
-- Updated By	: Ramesh Bangi on 09/15/2015 for Online Display,
--				: Ramesh Bangi on 09/24/2015 for Online Video,
--				: Ramesh Bangi on 10/13/2015 for Mobile
--=========================================================================
CREATE PROCEDURE [dbo].[sp_QueryQueueException]
(
@CreativeSignature AS NVARCHAR(MAX),
@IsException as BIT,
@ExceptionType As Nvarchar(MAX),
@UserId As INT,
@KeyId As INT,  ---- PatternMasterStagingId
@MediaStreamID  AS VARCHAR(MAX)
)
AS
BEGIN
		BEGIN TRY	 
				BEGIN TRANSACTION 
					IF(@MediaStreamID='TV')
						BEGIN
							UPDATE 	[dbo].[PatternTVStg] SET [Exception]=@IsException,[Query]=NULL WHERE [CreativeSignature]=@CreativeSignature AND [PatternStgTVID]=@KeyId
						END
					ELSE IF (@MediaStreamID='OD')
						BEGIN
							UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException,[Query]=NULL WHERE [CreativeSignature]=@CreativeSignature AND [PatternStagingID]=@KeyId
						END
					ELSE IF (@MediaStreamID='OND')
						BEGIN
							UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException,[Query]=NULL WHERE [PatternStagingID]=@KeyId
						END
					ELSE IF (@MediaStreamID='ONV')
						BEGIN
							UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException,[Query]=NULL WHERE [PatternStagingID]=@KeyId
						END
					ELSE IF (@MediaStreamID='MOB')
						BEGIN
							UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException,[Query]=NULL WHERE [PatternStagingID]=@KeyId
						END
					ELSE IF (@MediaStreamID='CIN')
						BEGIN
							UPDATE  [dbo].[PatternStaging] SET Exception=@IsException,Query=NULL WHERE [CreativeSignature]=@CreativeSignature AND [PatternStagingID]=@KeyId
						END
					ELSE IF (@MediaStreamID='RAD')
						BEGIN
							UPDATE  [dbo].[PatternStaging] SET [Exception]=@IsException,[Query]=NULL WHERE [PatternStagingID]=@KeyId
						END
					
					Insert into  [ExceptionDetail]
					([PatternMasterStagingID],[PatternMasterID],Mediastream,ExceptionType,ExceptionStatus,ExcRaisedBy,ExcRaisedOn,[CreatedDT],[CreatedByID],[ModifiedDT],[ModifiedByID])
					 Values 
					 (@KeyId,NULL,@MediaStreamID,@ExceptionType,'Requested',@UserId,getdate(),getdate(),@UserId,NULL,NULL)
					 
					COMMIT TRANSACTION
		 END TRY
		 BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_QueryQueueException]: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END