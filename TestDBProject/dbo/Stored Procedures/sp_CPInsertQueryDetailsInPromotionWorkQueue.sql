-- =============================================================================================================
-- Author		: Amrutha Lakshmi
-- Create date	: 12/17/2015
-- Description	: This stored procedure is used insert the query details.
-- Execution	: sp_CPInsertQueryDetailsInPromotionWorkQueue '2166','Advertiser Not Correct',''
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[sp_CPInsertQueryDetailsInPromotionWorkQueue]
(
@keyId INT,
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


	
	
		--update pattern master
		UPDATE [Promotion] SET [Query]=1 WHERE [PromotionID]=@keyId

		--Add Query Details
		INSERT INTO [QueryDetail]([PromoID],[MediaStreamID],System,EntityLevel,QueryCategory,QueryText,QryRaisedBy,QryRaisedOn,[CreatedDT],[CreatedByID],[AssignedToID])
		SELECT @keyId,(select Value from [Configuration] where SystemName='All' and ComponentName='Media Stream' and ValueTitle=@MediaStream),'C&P','PRO',(select value FROM [Configuration]
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
	

	END TRY
	BEGIN CATCH 
				  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
				  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				  RAISERROR ('sp_CPInsertQueryDetailsInPromotionWorkQueue: %d: %s',16,1,@error,@message,@lineNo); 
				  ROLLBACK TRANSACTION
	END CATCH 
	END
