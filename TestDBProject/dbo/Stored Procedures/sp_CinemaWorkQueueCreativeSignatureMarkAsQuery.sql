

-- ==============================================================================================================
-- Author				: Arun Nair 
-- Create date			: 07/14/2015
-- Description			: Update Query in Cinema Work Queue  
-- Execution Process	: [dbo].[sp_CinemaWorkQueueCreativeSignatureMarkAsQuery] '337251aen',1,'','',0,0,149
-- Updated By			: Karunakar on 08/18/2015
--===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CinemaWorkQueueCreativeSignatureMarkAsQuery]
(
@CreativeSignature AS NVARCHAR(MAX),
@IsQuery AS BIT,
@QueryCategory AS NVARCHAR(MAX),
@QueryText AS NVARCHAR(MAX),
@QueryRaisedBy AS INT,
@UserId AS INT,
@MediaStreamId AS INT,
@AssignedTo AS INT,
@FileType AS NVARCHAR(MAX)
)
AS
BEGIN

		BEGIN TRY
			
				DECLARE @OccurrenceId As INT
				DECLARE @RowCount AS INT
				DECLARE @Counter AS INT =1
				DECLARE @PatternMasterStagingID AS INT
				DECLARE @QueryId as Int
				DECLARE @QueryPath as Nvarchar(100)
				DECLARE @QueryDetailFolder As Nvarchar(100)='Query'
				DECLARE @QueryAssetname As Nvarchar(100)

				BEGIN TRANSACTION	
				--UPDATE  IsQuery BASED ON CREATIVESIGNATURE		
				UPDATE  [dbo].[PatternStaging] SET QUERY=@IsQuery WHERE [CreativeSignature]=@CreativeSignature
				SELECT @PatternMasterStagingID=[PatternStagingID] From [dbo].[PatternStaging] WHERE [CreativeSignature]=@CreativeSignature
					--INSERT QUERY DETAILS FOR OCCURRENCES BASED ON CREATIVE SIGNATURE SELECTED
					INSERT INTO [dbo].[QueryDetail]
					(
					[PatternStgID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
						[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
						[CreatedDT],[CreatedByID],[AssignedToID]
						)
					VALUES
					(
					@PatternMasterStagingID,NULL,NULL,NULL,NULL,'CIN','I&O','PAT',@QueryCategory,@QueryText,@UserId,getdate(),NULL,NULL,NULL,NULL,getdate(),@UserId,@AssignedTo
					) 
					Set @QueryId=Scope_identity();
					If(@FileType<>'')
					BEGIN
						SET @QueryAssetname=Cast(@QueryId AS VARCHAR)+'.'+@FileType
						SET @QueryPath=@QueryDetailFolder+'\'+Cast(@QueryId AS VARCHAR)+'\'
						UPDATE [QueryDetail] SET QryCreativeAssetName=@QueryAssetname ,QryCreativeRepository=@QueryPath WHERE [QueryID]=@QueryId
						SELECT [QueryID],QryCreativeRepository,QryCreativeAssetName FROM [QueryDetail] WHERE [QueryID]=@QueryId
					END
				
				COMMIT TRANSACTION
		END TRY


		 BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_CinemaWorkQueueCreativeSignatureMarkAsQuery]: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END