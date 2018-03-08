
-- ==============================================================================================================
-- Author				: Ramesh Bangi 
-- Create date			: 9/30/2015
-- Description			: Update Query in Mobile Work Queue  
-- Execution Process	: [dbo].[sp_MobileCSMarkAsQuery]
-- Updated By			: 
--===============================================================================================================
CREATE PROCEDURE [dbo].[sp_MobileCSMarkAsQuery]
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
				DECLARE @CreativeMasterStgid AS INT 

				BEGIN TRANSACTION	
				--UPDATE  IsQuery BASED ON CREATIVESIGNATURE	
				SELECT @CreativeMasterStgid=[CreativeStagingID] from [CreativeStaging] Where CreativeSignature=@CreativeSignature
				UPDATE  [dbo].[PatternStaging] SET [Query]=@IsQuery WHERE [CreativeStgID]=@CreativeMasterStgid

				SELECT @PatternMasterStagingID=[PatternStagingID] From [dbo].[PatternStaging] WHERE [CreativeStgID]=@CreativeMasterStgid
					--INSERT QUERY DETAILS FOR OCCURRENCES BASED ON CREATIVE SIGNATURE SELECTED
					INSERT INTO [dbo].[QueryDetail]
					(
					[PatternStgID],[OccurrenceID],[PubIssueID],[AdID],[PromoID],[MediaStreamID],[System],[EntityLevel],
						[QueryCategory],[QueryText],[QryRaisedBy],[QryRaisedOn],[QryAnswer],[QryAnsweredBy],[QryCreativeRepository],[QryCreativeAssetName],
						[CreatedDT],[CreatedByID],[AssignedToID]
						)
					VALUES
					(
					@PatternMasterStagingID,NULL,NULL,NULL,NULL,'MOB','I&O','PAT',@QueryCategory,@QueryText,@UserId,getdate(),NULL,NULL,NULL,NULL,getdate(),@UserId,@AssignedTo
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
			  RAISERROR ('[dbo].[sp_MobileCSMarkAsQuery]: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION
		  END CATCH 
END