
-- =======================================================================================
-- Author			: Karunakar P	 
-- Create date		: 06/09/2015
-- Description		: This stored procedure is used to Update 
--					  Queried PubIssue in Publication Work Queue 
-- Updated By		: Arun Nair on 06/15/2015 changed OccurrenceID to PubissueId  
--					  Arun Nair on 08/04/2015  for update issueid
--					  Karunakar on 08/18/2015 for Updating Query Details
-- Updated by		: Lisa East MI-977 allow for occurrence level query
-- ========================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationWorkQueueQueryUpdate]--
(
@IsQuery bit,
@QueryCategory  varchar(max)='',
@QueryText varchar(max)='',
@QryRaisedBy varchar(max)='',
@QryRaisedOn Datetime,
@IssueID int,
@AssignedTo AS INT,
@FileType AS NVARCHAR(MAX), 
@QryOccurrenceID as int=0  --L.E. 3/16/2017 MI-977
)
AS
BEGIN
	
	SET NOCOUNT ON; ---Update PubIssue from Publication WorkQueue Query PubissueID
			
				BEGIN TRY
					BEGIN TRANSACTION		
					DECLARE @PatternMasterID varchar(100)
					DECLARE @OccurrenceID varchar(100)
					DECLARE @QueryId AS INT
					DECLARE @QueryPath AS NVARCHAR(100)
					DECLARE @QueryDetailFolder AS NVARCHAR(100)='Query'
					DECLARE @QueryAssetname AS NVARCHAR(100)
					Declare @PubIssueStatus as nvarchar(20) --L.E. 3/8/2017 MI-977
					Declare @OccurrenceStatus as int --L.E. 3/16/2017 MI-977

			
					 SELECT @PubIssueStatus = valuetitle 
					  FROM   [Configuration] 
					  WHERE  systemname = 'All' 
							 AND componentname = 'Published Issue Status' 
							 AND value = 'Q' 

					SELECT @OccurrenceStatus = os.[OccurrenceStatusID] 
					FROM OccurrenceStatus OS
					inner join Configuration c on os.[Status] = c.ValueTitle
					WHERE c.SystemName = 'All' 
					and c.ComponentName = 'Occurrence Status' 
					AND c.Value = 'Q' 



					IF @QryOccurrenceID > 0 --L.E. if occurrence ID sent update occurrence detail ignore Pub level
					BEGIN
						Update  [dbo].OccurrenceDetailPUB
								SET [Query]=@IsQuery,[QueryCategory]=@QueryCategory,[QueryText]=@QueryText,[QryRaisedBy]=@QryRaisedBy,[QryRaisedDT]=@QryRaisedOn,
								OccurrenceStatusID=@OccurrenceStatus
								WHERE [PubIssueID]=@IssueID	and [OccurrenceDetailPUBID]=@QryOccurrenceID


						INSERT INTO [dbo].[QueryDetail]
						(
							[PatternMasterID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
							[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
							[CreatedDT],[CreatedByID],[AssignedToID]
						)
						VALUES
						(
							NULL,@QryOccurrenceID,NULL,NULL,NULL,'PUB','I&O','OCC',@QueryCategory,@QueryText,@QryRaisedBy,getdate(),NULL,NULL,NULL,NULL,getdate(),@QryRaisedBy,@AssignedTo
						) 
						Set @QueryId=Scope_identity();


					END 
					ELSE
					BEGIN
					
						Update  [dbo].[PubIssue]
								SET [IsQuery]=@IsQuery,[QueryCategory]=@QueryCategory,[QueryText]=@QueryText,[QryRaisedBy]=@QryRaisedBy,[QryRaisedOn]=@QryRaisedOn,
								[Status]=@PubIssueStatus
								WHERE [PubIssueID]=@IssueID	

						INSERT INTO [dbo].[QueryDetail]
						(
							[PatternMasterID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
							[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
							[CreatedDT],[CreatedByID],[AssignedToID]
						)
						VALUES
						(
							NULL,NULL,@IssueID,NULL,NULL,'PUB','I&O','PUB',@QueryCategory,@QueryText,@QryRaisedBy,getdate(),NULL,NULL,NULL,NULL,getdate(),@QryRaisedBy,@AssignedTo
						) 
						Set @QueryId=Scope_identity();
					END 
						
					select @OccurrenceID = [OccurrenceDetailPUBID] from [OccurrenceDetailPUB] where [PubIssueID] = @IssueID
					



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
          RAISERROR ('[sp_PublicationWorkQueueQueryUpdate]: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 

END