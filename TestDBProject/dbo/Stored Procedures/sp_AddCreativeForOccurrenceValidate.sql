-- =================================================================================================
-- Author				: Arun Nair 
-- Create date			: 02/10/2016
-- Description			: To validate add creative in Occurrence Tab
-- Execution			: sp_AddCreativeForOccurrenceValidate 1120124,'PUB'
-- Updated By			: Arun Nair on 02/11/2016- added for various MediaStream
--						
-- ==================================================================================================
CREATE PROCEDURE [dbo].[sp_AddCreativeForOccurrenceValidate]
(
@OccurrenceId AS BIGINT,
@MediastreamID AS VARCHAR(20)
)
AS
BEGIN
		SET NOCOUNT ON;
		 BEGIN TRY
				DECLARE @PageCount AS INTEGER
				DECLARE @CreativeAssetName AS VARCHAR(MAX)
				DECLARE @Result AS INT=0
				IF(@MediastreamID='CIR')  
					BEGIN
						IF NOT EXISTS(SELECT 1 FROM [Pattern] t WHERE [PatternID]=(SELECT [PatternID] FROM [OccurrenceDetailCIR] 
										WHERE [OccurrenceDetailCIRID]=@OccurrenceId) and [CreativeID] is not null)  --If Page definition doesnt exist
							BEGIN
								SET @Result=3
							END 
						ELSE
						BEGIN
							SELECT @PageCount=[OccurrenceDetailCIR].[PageCount] ,@CreativeAssetName=CreativeDetailCIR.CreativeAssetName
							FROM [OccurrenceDetailCIR] 
							INNER JOIN [Pattern] ON [Pattern].[PatternID]=[OccurrenceDetailCIR].[PatternID]
							INNER JOIN [Creative] ON [Creative].PK_Id=[Pattern].[CreativeID]
							INNER JOIN CreativeDetailCIR ON CreativeDetailCIR.CreativeMasterID=[Creative].PK_Id
							WHERE [OccurrenceDetailCIRID]=@OccurrenceId					
						END 
					END 
				 IF(@MediastreamID='PUB')  
					BEGIN
					IF NOT EXISTS(SELECT 1 FROM [Pattern] t WHERE [PatternID]=(SELECT [PatternID] FROM [OccurrenceDetailPUB] 
										WHERE [OccurrenceDetailPUBID]=@OccurrenceId) and [CreativeID] is not null)  --If Page definition doesnt exist
							BEGIN
								SET @Result=3
							END 
						ELSE
						BEGIN
							SELECT @PageCount=[OccurrenceDetailPUB].[PageCount] ,@CreativeAssetName=CreativeDetailPUB.CreativeAssetName
							FROM [OccurrenceDetailPUB]
							INNER JOIN [Pattern] ON [Pattern].[PatternID]=[OccurrenceDetailPUB].[PatternID]
							INNER JOIN [Creative] ON [Creative].PK_Id=[Pattern].[CreativeID]
							INNER JOIN CreativeDetailPUB ON CreativeDetailPUB.CreativeMasterID=[Creative].PK_Id
							WHERE [OccurrenceDetailPUBID]=@OccurrenceId					
						END 
					END 
					 IF(@MediastreamID='EM')  
					BEGIN
						IF NOT EXISTS(SELECT 1 FROM [Pattern] t WHERE [PatternID]=(SELECT [PatternID] FROM [OccurrenceDetailEM] 
										WHERE [OccurrenceDetailEMID]=@OccurrenceId) and [CreativeID] is not null)  --If Page definition doesnt exist
							BEGIN
								SET @Result=3
							END 
						ELSE
						BEGIN
							SELECT @PageCount=1 ,
							@CreativeAssetName=CreativeDetailEM.CreativeAssetName
							FROM [OccurrenceDetailEM]
							INNER JOIN [Pattern] ON [Pattern].[PatternID]=[OccurrenceDetailEM].[PatternID]
							INNER JOIN [Creative] ON [Creative].PK_Id=[Pattern].[CreativeID]
							INNER JOIN CreativeDetailEM ON CreativeDetailEM.CreativeMasterID=[Creative].PK_Id
							WHERE [OccurrenceDetailEM].[OccurrenceDetailEMID]=@OccurrenceId					
						END 
					END 
					 IF(@MediastreamID='SOC')  
					BEGIN
						IF NOT EXISTS(SELECT 1 FROM [Pattern] t WHERE [PatternID]=(SELECT [PatternID] FROM [OccurrenceDetailSOC] 
										WHERE [OccurrenceDetailSOCID]=@OccurrenceId) and [CreativeID] is not null)  --If Page definition doesnt exist
							BEGIN
								SET @Result=3
							END 
						ELSE
						BEGIN
							SELECT @PageCount=1 ,@CreativeAssetName=CreativeDetailSOC.CreativeAssetName
							FROM [OccurrenceDetailSOC]
							INNER JOIN [Pattern] ON [Pattern].[PatternID]=[OccurrenceDetailSOC].[PatternID]
							INNER JOIN [Creative] ON [Creative].PK_Id=[Pattern].[CreativeID]
							INNER JOIN CreativeDetailSOC ON CreativeDetailSOC.CreativeMasterID=[Creative].PK_Id
							WHERE [OccurrenceDetailSOCID]=@OccurrenceId					
						END 
					END 
					IF(@MediastreamID='WEB')  
					BEGIN
						IF NOT EXISTS(SELECT 1 FROM [Pattern] t WHERE [PatternID]=(SELECT [PatternID] FROM [OccurrenceDetailWEB] 
										WHERE [OccurrenceDetailWEBID]=@OccurrenceId) and [CreativeID] is not null)  --If Page definition doesnt exist
							BEGIN
								SET @Result=3
							END 
						ELSE
						BEGIN
							SELECT @PageCount=1 ,@CreativeAssetName=CreativeDetailWEB.CreativeAssetName
							FROM [OccurrenceDetailWEB]
							INNER JOIN [Pattern] ON [Pattern].[PatternID]=[OccurrenceDetailWEB].[PatternID]
							INNER JOIN [Creative] ON [Creative].PK_Id=[Pattern].[CreativeID]
							INNER JOIN CreativeDetailWEB ON CreativeDetailWEB.CreativeMasterID=[Creative].PK_Id
							WHERE [OccurrenceDetailWEB].[OccurrenceDetailWEBID]=@OccurrenceId					
						END 
					END 
						IF(@PageCount>1) --Check if PageCount >1 
							BEGIN
								SET @Result=1
							END
						PRINT @CreativeAssetName
						IF(@CreativeAssetName <>'')  --Check if Creative Exists
							BEGIN
								SET @Result=2
							END
								
					SELECT @Result AS RESULT
			END TRY
			BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_AddCreativeForOccurrenceValidate]: %d: %s',16,1,@error,@message,@lineNo);			
			END CATCH 
			
END
