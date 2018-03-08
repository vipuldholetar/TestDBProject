-- =============================================================================================================
-- Author		: Govardhan.R
-- Create date	: 10/09/2015
-- Description	: This stored procedure is used insert the query details.
-- Execution	: [sp_CPInsertQueryDetailsInAdClassWorkQueue] '2166','Advertiser Not Correct',''
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPInsertQueryDetailsInAdClassWorkQueue]
(
@AdId INT,
@OccurrenceID INT,
@QueryText varchar(250),
@UserId int,
@MediaStream AS varchar(50),
@AssignedTo AS INT,
@FileType AS NVARCHAR(MAX),
@Form As NVARCHAR(50)
)
AS
BEGIN
BEGIN TRY

				Declare @QueryId AS INT
					Declare @QueryPath AS NVARCHAR(100)
					Declare @QueryDetailFolder AS NVARCHAR(100)='Query'
					Declare @QueryAssetname AS NVARCHAR(100)

IF(@Form ='C&R')
	BEGIN
		--DECLARE @OccurrenceID int
		--SET @OccurrenceID = (Select OccurrenceID from vw_CropRouteWorkQueueData WHERE PK_ID=@AdId)
		IF(@OccurrenceID IS NOT NULL AND @OccurrenceID <> 0)
			BEGIN
				IF(@MediaStream ='CIRCULAR')
				UPDATE [OccurrenceDetailCIR] SET [Query] = 1 WHERE [OccurrenceDetailCIRID]=@OccurrenceID
				ELSE IF(@MediaStream ='Publication')
				UPDATE [OccurrenceDetailPUB] SET [Query] = 1 WHERE [OccurrenceDetailPUBID]=@OccurrenceID
				ELSE IF(@MediaStream ='Email')
				UPDATE [OccurrenceDetailEM] SET [Query] = 1 WHERE [OccurrenceDetailEMID]=@OccurrenceID
				ELSE IF(@MediaStream ='Website')
				UPDATE [OccurrenceDetailWEB] SET [Query] = 1 WHERE [OccurrenceDetailWEBID]=@OccurrenceID

				--Add Query Details
				INSERT INTO [QueryDetail]([AdID],[OccurrenceID],[MediaStreamID],System,EntityLevel,QueryCategory,QueryText,QryRaisedBy,QryRaisedOn,[CreatedDT],[CreatedByID],[AssignedToID])
				SELECT @AdId,@OccurrenceID,(select Value from [Configuration] where SystemName='All' and ComponentName='Media Stream' and ValueTitle=@MediaStream),'C&P','OCC',(select value FROM [Configuration]
				WHERE SystemName = 'All' AND ComponentName ='Query Category'),@QueryText,@UserId,getdate(),getdate(),1,(case when @AssignedTo=0 then null else @AssignedTo end )
			END
		ELSE
			BEGIN
				--update pattern master
				UPDATE AD SET [Query]=1 WHERE [AdID]=@AdId

				--Add Query Details
				INSERT INTO [QueryDetail]([AdID],[MediaStreamID],System,EntityLevel,QueryCategory,QueryText,QryRaisedBy,QryRaisedOn,[CreatedDT],[CreatedByID],[AssignedToID])
				SELECT @AdId,(select Value from [Configuration] where SystemName='All' and ComponentName='Media Stream' and ValueTitle=@MediaStream),'C&P','AD',(select value FROM [Configuration]
				WHERE SystemName = 'All' AND ComponentName ='Query Category'),@QueryText,@UserId,getdate(),getdate(),1,(case when @AssignedTo=0 then null else @AssignedTo end )
			END

			Set @QueryId=Scope_identity();

				If(@FileType<>'')
						BEGIN
							SET @QueryAssetname=Cast(@QueryId AS VARCHAR)+'.'+@FileType
							SET @QueryPath=@QueryDetailFolder+'\'+Cast(@QueryId AS VARCHAR)+'\'

							--Updating QueryDetails for CS as Query
							UPDATE [QueryDetail] SET QryCreativeAssetName=@QueryAssetname ,QryCreativeRepository=@QueryPath WHERE [QueryID]=@QueryId
							SELECT [QueryID],QryCreativeRepository,QryCreativeAssetName,(select VALUE from [Configuration] where SystemName='All' and ComponentName='Creative Repository')[LocalPath] FROM [QueryDetail] WHERE [QueryID]=@QueryId
						END
	END
	ELSE
	BEGIN
		--update pattern master
		UPDATE AD SET [Query]=1 WHERE [AdID]=@AdId

		--Add Query Details
		INSERT INTO [QueryDetail]([AdID],[MediaStreamID],System,EntityLevel,QueryCategory,QueryText,QryRaisedBy,QryRaisedOn,[CreatedDT],[CreatedByID],[AssignedToID])
		SELECT @AdId,(select Value from [Configuration] where SystemName='All' and ComponentName='Media Stream' and ValueTitle=@MediaStream),'C&P','AD',(select value FROM [Configuration]
		WHERE SystemName = 'All' AND ComponentName ='Query Category'),@QueryText,@UserId,getdate(),getdate(),1,(case when @AssignedTo=0 then null else @AssignedTo end )

		Set @QueryId=Scope_identity();

				If(@FileType<>'')
						BEGIN
							SET @QueryAssetname=Cast(@QueryId AS VARCHAR)+'.'+@FileType
							SET @QueryPath=@QueryDetailFolder+'\'+Cast(@QueryId AS VARCHAR)+'\'

							--Updating QueryDetails for CS as Query
							UPDATE [QueryDetail] SET QryCreativeAssetName=@QueryAssetname ,QryCreativeRepository=@QueryPath WHERE [QueryID]=@QueryId
							SELECT [QueryID],QryCreativeRepository,QryCreativeAssetName,(select VALUE from [Configuration] where SystemName='All' and ComponentName='Creative Repository')[LocalPath] FROM [QueryDetail] WHERE [QueryID]=@QueryId
						END
	END

	END TRY
	BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('sp_CPInsertQueryDetailsInAdClassWorkQueue: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION
	END CATCH 
	END
