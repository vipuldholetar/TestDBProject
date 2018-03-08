-- ========================================================================
-- Author		: Murali Jaganathan
-- Create date	: 07/13/2015
-- Description	: Update Query in Television Work Queue  
-- Updated By	: Updated Changes by Karunakar on 8/18/2015
--				: Karunakar on 14th Sep 2015
--=========================================================================

CREATE PROCEDURE [dbo].[sp_TelevisionWorkQueueCreativeSignatureMarkAsQuery]
(
@CreativeSignature AS NVARCHAR(MAX),
@IsQuery AS BIT,
@QueryCategory AS NVARCHAR(max),
@QueryText AS NVARCHAR(max),
@QueryRaisedBy AS INT,
@UserId AS INT,
@MediaStreamId AS INT,
@AssignedTo AS INT,
@FileType AS NVARCHAR(MAX)
)
AS
BEGIN
		BEGIN TRY			
				DECLARE @OccurrenceId AS INT
				DECLARE @RowCount AS INT
				DECLARE @Counter AS INT =1
				DECLARE @PatternMasterStagingID AS INT
				Declare @QueryId AS INT
				Declare @QueryPath AS NVARCHAR(100)
				Declare @QueryDetailFolder AS NVARCHAR(100)='Query'
				Declare @QueryAssetname AS NVARCHAR(100)
				
				BEGIN TRANSACTION	

				--UPDATE  IsQuery BASED ON CREATIVESIGNATURE		
				UPDATE  [dbo].[PatternStaging] SET [Query]=@IsQuery WHERE [CreativeSignature]=@CreativeSignature
				Select @PatternMasterStagingID= [PatternStagingID] FROM [dbo].[PatternStaging]  WHERE [CreativeSignature]=@CreativeSignature
				
					
					--INSERT QUERY DETAILS FOR OCCURRENCES BASED ON CREATIVE SIGNATURE SELECTED
					INSERT INTO [dbo].[QueryDetail]
					(
					[PatternStgID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
						[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
						[CreatedDT],[CreatedByID],[AssignedToID]
						)
					VALUES
					(
					@PatternMasterStagingID,NULL,NULL,NULL,NULL,'TV','I&O','PAT',@QueryCategory,@QueryText,@UserId,getdate(),NULL,NULL,NULL,NULL,getdate(),@UserId,@AssignedTo
					) 
					Set @QueryId=Scope_identity();
					If(@FileType<>'')
					BEGIN
						SET @QueryAssetname=Cast(@QueryId AS VARCHAR)+'.'+@FileType
						SET @QueryPath=@QueryDetailFolder+'\'+Cast(@QueryId AS VARCHAR)+'\'

						--Updating QueryDetails for CS as Query
						UPDATE [QueryDetail] SET QryCreativeAssetName=@QueryAssetname ,QryCreativeRepository=@QueryPath WHERE [QueryID]=@QueryId
						SELECT [QueryID],QryCreativeRepository,QryCreativeAssetName FROM [QueryDetail] WHERE [QueryID]=@QueryId
					END
					
				COMMIT TRANSACTION
		END TRY
		BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_TelevisionWorkQueueCreativeSignatureMarkAsQuery: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		END CATCH 
END