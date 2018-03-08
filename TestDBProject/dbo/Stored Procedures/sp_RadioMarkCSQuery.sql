
-- ==============================================================================================================
-- Author				: Murali Jaganathan
-- Create date			: 07/14/2015
-- Description			: Update Query in Radio Work Queue  
-- Execution Process	: dbo].[sp_RadioMarkCSQuery] '337251aen',1,'','',0,0,149
-- Updated By			: Ramesh on 08/11/2015 - CleanUp for OneMT DB, 
--===============================================================================================================
CREATE PROCEDURE [dbo].[sp_RadioMarkCSQuery]
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
				DECLARE @OccurrenceId As INT
				DECLARE @RowCount AS INT
				DECLARE @Counter AS INT =1
				DECLARE @Patternmasterstagingid AS INT
				DECLARE @MediaStream AS VARCHAR(100)=''
				DECLARE @QueryId AS INT
				DECLARE @QueryPath AS NVARCHAR(100)
				DECLARE @QueryDetailFolder AS NVARCHAR(100)='Query'
				DECLARE @QueryAssetname AS NVARCHAR(100)

				BEGIN TRANSACTION	
				
				SELECT @Patternmasterstagingid = [PatternStagingID] FROM [PatternStaging] WHERE CreativeSignature = @CreativeSignature 
				--UPDATE  IsQuery BASED ON CREATIVESIGNATURE		
				UPDATE  [dbo].[PatternStaging] SET [Query]=@IsQuery,ModifiedDT=Getdate(),ModifiedByID=@UserId WHERE [PatternStagingID] = @Patternmasterstagingid 			
					INSERT INTO [dbo].[QueryDetail]
					(
					[PatternStgID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
						[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
						[CreatedDT],[CreatedByID],[AssignedToID]
						)
					VALUES
					(
					@Patternmasterstagingid,NULL,NULL,NULL,NULL,'RAD','I&O','PAT',@QueryCategory,@QueryText,@UserId,getdate(),NULL,NULL,NULL,NULL,getdate(),@UserId,@AssignedTo
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
			  RAISERROR ('[sp_RadioMarkCSQuery]: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END