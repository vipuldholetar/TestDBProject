

-- ========================================================================
-- Author		: Arun Nair 
-- Create date	: 07/08/2015
-- Description	: Update Query in Outdoor Work Queue  
-- Updated By	: Updated By Karunakar on 08/18/2015.
--=========================================================================
CREATE PROCEDURE [dbo].[sp_OutdoorWorkQueueCreativeSignatureMarkAsQuery]
(
@CreativeSignature AS NVARCHAR(MAX),
@IsQuery As bit,
@QueryCategory As Nvarchar(max),
@QueryText As Nvarchar(max),
@QueryRaisedBy As Int,
@UserId As Int,
@MediaStreamId As Int,
@AssignedTo AS INT,
@FileType AS NVARCHAR(MAX)
)
AS
BEGIN

		BEGIN TRY
		          
				Declare @OccurrenceId As INT
				DECLARE @PatternMasterStagingId AS INT
				Declare @QueryId as Int
				Declare @QueryPath as Nvarchar(100)
				Declare @QueryDetailFolder As Nvarchar(100)='Query'
				Declare @QueryAssetname As Nvarchar(100)
				BEGIN TRANSACTION 
					Select @OccurrenceId=[OccurrenceDetailODRID] from [OccurrenceDetailODR] Where [ImageFileName]=@CreativeSignature					
					UPDATE  [dbo].[PatternStaging] SET [Query]=@IsQuery,ModifiedDT=Getdate(),ModifiedByID=@UserId WHERE [CreativeSignature]=@CreativeSignature

					SELECT @PatternMasterStagingId=[PatternStagingID] FROM [PatternStaging] Where [CreativeSignature]=@CreativeSignature

					Insert into [QueryDetail]
					([PatternStgID],[OccurrenceID],[MediaStreamID],[System],[EntityLevel],[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[CreatedDT],[CreatedByID],[AssignedToID])
					Values(@PatternMasterStagingId,NULL,'OD','I&O','PAT',@QueryCategory,@QueryText,@QueryRaisedBy,getdate(),getdate(),@UserId,@AssignedTo)					
					Set @QueryId=Scope_identity();
						If(@FileType<>'')
							BEGIN
							Set @QueryAssetname=Cast(@QueryId AS VARCHAR)+'.'+@FileType
							Set @QueryPath=@QueryDetailFolder+'\'+Cast(@QueryId AS VARCHAR)+'\'
							Update [QueryDetail] Set QryCreativeAssetName=@QueryAssetname ,QryCreativeRepository=@QueryPath Where [QueryID]=@QueryId
							Select [QueryID],QryCreativeRepository,QryCreativeAssetName from [QueryDetail] Where [QueryID]=@QueryId
						END
				COMMIT TRANSACTION
		END TRY


		 BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_OutdoorWorkQueueCreativeSignatureMarkAsQuery: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END