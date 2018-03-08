
-- ============================================================================================================
-- Author			:	Arun Nair on 12/05/2015	 
-- Create date		:
-- Description		:	This stored procedure is used to Update Queried Occurrence in Circular Work Queue 
-- Execution Process: 
-- Updated By		:	Arun Nair on 18/05/2015
--					:	Murali on 08/04/2015
--					:	Karunakar on 08/18/2015 for Updating Query Details
--					:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--					:	Karunakar on 7th Sep 2015
-- ============================================================================================================
CREATE PROCEDURE [dbo].[sp_CircularWorkQueueQuery]--
(
@IsQuery bit,
@QueryCategory  varchar(max)='',
@QueryText varchar(max)='',
@QryRaisedBy varchar(max)='',
@QryRaisedOn Datetime,
@OccurrenceID Bigint,
@AssignedTo AS INT,
@FileType AS NVARCHAR(MAX)
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

					-- Update OccurrenceDetailsCir from CircularWorkQueue Query 						
					Update  [dbo].[OccurrenceDetailCIR]  set [Query]=@IsQuery,[QueryCategory]=@QueryCategory,
					[QueryText]=@QueryText,[QryRaisedBy]=@QryRaisedBy,[QryRaisedDT]=@QryRaisedOn
					where [OccurrenceDetailCIRID]=@OccurrenceID				
						
					select @OccurrenceID = [OccurrenceDetailCIRID] from [OccurrenceDetailCIR] where [OccurrenceDetailCIRID] = @OccurrenceID				
					INSERT INTO [dbo].[QueryDetail]
					(
					[PatternStgID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
						[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
						[CreatedDT],[CreatedByID],[AssignedToID]
						)
					VALUES
					(
					NULL,@OccurrenceID,NULL,NULL,NULL,'CIR','I&O','OCC',@QueryCategory,@QueryText,@QryRaisedBy,getdate(),NULL,NULL,NULL,NULL,getdate(),@QryRaisedBy,@AssignedTo
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
				RAISERROR ('[sp_CircularWorkQueueQuery]: %d: %s',16,1,@error,@message,@lineNo); 
				ROLLBACK TRANSACTION 
		END CATCH 

END
