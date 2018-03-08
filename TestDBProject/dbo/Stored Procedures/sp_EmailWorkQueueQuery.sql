

-- ============================================================================================================
-- Author			:	Ramesh Bangi	 
-- Create date		:   10/19/2015
-- Description		:	This stored procedure is used to Update Queried Occurrence in Email Work Queue 
-- Execution Process: 
-- Updated By		:	
-- ============================================================================================================
CREATE PROCEDURE [dbo].[sp_EmailWorkQueueQuery]
(
@IsQuery bit,
@QueryCategory  varchar(max)='',
@QueryText varchar(max)='',
@QryRaisedBy varchar(max)='',
@QryRaisedOn Datetime,
@OccurrenceID Bigint,
@AssignedTo AS INT,
@FileType AS NVARCHAR(MAX),
@UserId as INT
)
AS
BEGIN
	
	SET NOCOUNT ON;
			
		BEGIN TRY
			BEGIN TRANSACTION		
					
					Declare @MediaStreamId as int
					DECLARE @QueryId AS INT
					DECLARE @QueryPath AS NVARCHAR(100)
					DECLARE @QueryDetailFolder AS NVARCHAR(100)='Query' --Hard Coded Value
					DECLARE @QueryAssetname AS NVARCHAR(100)
					DECLARE @Patternmasterstagingid AS INT


					SELECT @Patternmasterstagingid = [PatternStagingID] FROM [PatternStaging] inner join [dbo].[OccurrenceDetailEM]  on [dbo].[OccurrenceDetailEM].PatternID=[dbo].[PatternStaging].PatternID WHERE [OccurrenceDetailEMID] = @OccurrenceID	
					--UPDATE  IsQuery BASED ON CREATIVESIGNATURE		
					UPDATE  [dbo].[PatternStaging] SET [Query]=@IsQuery,ModifiedDT=Getdate(),ModifiedByID=@UserId WHERE [PatternStagingID] = @Patternmasterstagingid 

					-- Update OccurrenceDetailsEM from EmailWorkQueue Query 						
					Update  [dbo].[OccurrenceDetailEM]  set [Query]=@IsQuery
					where [OccurrenceDetailEMID]=@OccurrenceID				
						
					select @OccurrenceID = [OccurrenceDetailEMID] from [OccurrenceDetailEM] where [OccurrenceDetailEMID] = @OccurrenceID				
					INSERT INTO [dbo].[QueryDetail]
					(
					[PatternStgID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
						[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
						[CreatedDT],[CreatedByID],[AssignedToID]
						)
					VALUES
					(
					@Patternmasterstagingid,@OccurrenceID,NULL,NULL,NULL,'EM','I&O','OCC',@QueryCategory,@QueryText,@QryRaisedBy,getdate(),NULL,NULL,NULL,NULL,getdate(),@QryRaisedBy,@AssignedTo
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
				RAISERROR ('[sp_EmailWorkQueueQuery]: %d: %s',16,1,@error,@message,@lineNo); 
				ROLLBACK TRANSACTION 
		END CATCH 

END