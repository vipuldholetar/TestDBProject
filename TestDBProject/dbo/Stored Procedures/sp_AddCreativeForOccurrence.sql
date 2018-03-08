-- =================================================================================================
-- Author				: RP
-- Create date			: 02/10/2015
-- Description			: This stored procedure is used to add assetname to creativedetailcir
-- Execution Process	: [sp_AddCreativeForOccurrence] 'jpg',630091,'CIR'
-- Updated By			: Arun Nair On 02/12/2016 - Added All Mediastreams for print,OccStage Status
-- ==================================================================================================
CREATE PROCEDURE [dbo].[sp_AddCreativeForOccurrence]
(
@FileType As VARCHAR(max),
@OccurrenceId AS BIGINT,
@MediaStream as VARCHAR(20)
)
AS	 
BEGIN
	SET NOCOUNT ON;
			
			DECLARE @PatternMasterId Int
			DECLARE @NewCreativeMasterID Int 
			DECLARE @NewCreativedetailId Varchar(max)
			
			BEGIN TRY
				BEGIN TRANSACTION
				IF(@MediaStream='CIR') 
					BEGIN
						SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailCIR] WHERE [OccurrenceDetailCIRID]=@OccurrenceId
						SELECT @NewCreativeMasterID=[CreativeID] FROM [Pattern] WHERE [Pattern].[PatternID]=@PatternMasterId
						
						SELECT @NewCreativedetailId=CreativeDetailID FROM creativedetailcir WHERE creativemasterid=@newcreativemasterid
										
						UPDATE CreativeDetailCIR 
						SET CreativeRepository='\'+@MediaStream+'\'+cast(@newcreativemasterid as varchar)+'\',CreativeAssetName=cast(@NewCreativedetailId as varchar)+'.'+@FileType
						WHERE CreativeDetailID=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID	
						EXEC Sp_updateoccurrencestagestatus @OccurrenceID,3 
					END
				IF(@MediaStream='PUB') 
					BEGIN
						SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailPUB] WHERE [OccurrenceDetailPUBID]=@OccurrenceId
						SELECT @NewCreativeMasterID=[CreativeID] FROM [Pattern] WHERE [Pattern].[PatternID]=@PatternMasterId
						
						SELECT @NewCreativedetailId=CreativeDetailID FROM CreativeDetailPUB WHERE CreativeMasterID=@newcreativemasterid
										
						UPDATE CreativeDetailPUB 
						SET CreativeRepository='\'+@MediaStream+'\'+cast(@newcreativemasterid as varchar)+'\',CreativeAssetName=cast(@NewCreativedetailId as varchar)+'.'+@FileType
						WHERE CreativeDetailID=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID	

						EXEC sp_UpdatePublicationOccurrenceStageStatus @OccurrenceID,3 
					END 
				IF(@MediaStream='EM') 
					BEGIN
						SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailEM] WHERE [OccurrenceDetailEMID]=@OccurrenceId
						SELECT @NewCreativeMasterID=[CreativeID] FROM [Pattern] WHERE [Pattern].[PatternID]=@PatternMasterId
						
						SELECT @NewCreativedetailId=[CreativeDetailsEMID] FROM CreativeDetailEM WHERE CreativeMasterID=@newcreativemasterid
										
						UPDATE CreativeDetailEM 
						SET CreativeRepository='\'+@MediaStream+'\'+cast(@newcreativemasterid as varchar)+'\',CreativeAssetName=cast(@NewCreativedetailId as varchar)+'.'+@FileType
						WHERE [CreativeDetailsEMID]=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID	
						EXEC [dbo].[sp_EmailUpdateOccurrenceStageStatus] @OccurrenceID,3 
					END 
				IF(@MediaStream='SOC') 
					BEGIN
						SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailSOC] WHERE [OccurrenceDetailSOCID]=@OccurrenceId
						SELECT @NewCreativeMasterID=[CreativeID] FROM [Pattern] WHERE [Pattern].[PatternID]=@PatternMasterId
						
						SELECT @NewCreativedetailId=[CreativeDetailSOCID] FROM CreativeDetailSOC WHERE CreativeMasterID=@newcreativemasterid
										
						UPDATE CreativeDetailSOC 
						SET CreativeRepository='\'+@MediaStream+'\'+cast(@newcreativemasterid as varchar)+'\',CreativeAssetName=cast(@NewCreativedetailId as varchar)+'.'+@FileType
						WHERE [CreativeDetailSOCID]=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID	
						
						EXEC [dbo].[sp_SocialUpdateOccurrenceStageStatus] @OccurrenceID,3 
					END 
				IF(@MediaStream='WEB') 
					BEGIN
						SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailSOC] WHERE [OccurrenceDetailSOCID]=@OccurrenceId
						SELECT @NewCreativeMasterID=[CreativeID] FROM [Pattern] WHERE [Pattern].[PatternID]=@PatternMasterId
						
						SELECT @NewCreativedetailId=[CreativeDetailSOCID] FROM CreativeDetailSOC WHERE CreativeMasterID=@newcreativemasterid
										
						UPDATE CreativeDetailSOC 
						SET CreativeRepository='\'+@MediaStream+'\'+cast(@newcreativemasterid as varchar)+'\',CreativeAssetName=cast(@NewCreativedetailId as varchar)+'.'+@FileType
						WHERE [CreativeDetailSOCID]=@NewCreativedetailId and CreativeMasterID=@NewCreativeMasterID	
						
						EXEC [dbo].[sp_WebsiteUpdateOccurrenceStageStatus] @OccurrenceID,3 
					END 
						
						SELECT '\'+@MediaStream+'\'+cast(@newcreativemasterid as varchar)+'\' AS newrepository, cast(@NewCreativedetailId as varchar)+'.'+@FileType AS newassetname
						
				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_AddCreativeForOccurrence]: %d: %s',16,1,@error,@message,@lineNo);
				ROLLBACK TRANSACTION
			END CATCH 
    
END
