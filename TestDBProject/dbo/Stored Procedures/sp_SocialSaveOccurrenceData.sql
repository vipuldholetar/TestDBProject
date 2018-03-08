-- =====================================================================================================
-- Author		:	Arun Nair
-- Create date	:	11/23/2015
-- Execution	:	
-- Description	:	Saving  Occurrence Data for Social in Data Points Form
-- Updated By	:	Karunakar on 11/24/2015, Adding @NewOccurrence ,If it is 1. New OccurrenceId update in Ad  PrimaryOccurrence.
--				:   Arun Nair on 01/19/2016 - Added MapMOD Details 
-- =======================================================================================================

CREATE PROCEDURE [dbo].[sp_SocialSaveOccurrenceData] 
(
@SocialType													AS NVARCHAR(20),
@AdId														AS INT,
@MediaTypeId												AS INT,
@LanguageId													AS INT,
@MediaStreamId												AS INT,
@MarketId													AS INT,
@LandingPageURL												AS NVARCHAR(MAX),
@URL														AS NVARCHAR(MAX),
@CountryOfOrigin											AS NVARCHAR(10),
@Format														AS NVARCHAR(50),
@Rating														AS NVARCHAR(50),
@RelationshiptoAdv											AS NVARCHAR(MAX),
@Priority													AS INT=0,
@DistributionDate											AS DATETIME,
@ADDate														AS DATETIME,
@Subject													AS NVARCHAR(MAX),
@EventId													AS INT,
@ThemeId													AS INT,
@SaleStartDate												AS DATETIME,
@SaleEndDate												AS DATETIME,
@AdvertiserID												AS INT,
@Promotional												AS BIT,
@MediaTypeComments											AS NVARCHAR(MAX),
@NotakeReason                                               AS VARCHAR(MAX),
@UserId														AS INT,
@PageDefinitionParamXml										AS XML,
@CreativeAssetQuality										AS INT,
@NewOccurrence												AS INT,
@originalAdDescription	AS NVARCHAR(MAX),
@originalAdRecutDetail	AS NVARCHAR(MAX),
@isScanReqd as bit,     
@isMapAD as BIT              
)
AS

--IF 1 = 0 
--      BEGIN 
--          SET fmtonly OFF 
--      END
BEGIN
	
	SET NOCOUNT ON;
	 BEGIN TRY 
          BEGIN TRANSACTION 
		     
					DECLARE @OccurrenceId As BigInt
					DECLARE @PatternmasterId As Int	
					DECLARE @IsDefinitionData As Int 
					DECLARE @CreativeMasterID As Int

					Declare @AdDescription as NVARCHAR(MAX)=''

					--DECLARE @CompleteStatus AS VARCHAR(20)
					--DECLARE @WaitingStatus AS VARCHAR(20) 
					--DECLARE @InProgressStatus AS VARCHAR(20)
					--DECLARE @NotRequiredStatus AS VARCHAR(20)


					--SELECT @CompleteStatus = valuetitle 	FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'C'
					--SELECT @WaitingStatus = valuetitle FROM   [Configuration]  WHERE  Systemname = 'All' AND Componentname = 'Occurrence Status' AND value = 'W' 
     --               SELECT @InProgressStatus = valuetitle FROM   [Configuration] WHERE  Systemname = 'All' AND Componentname = 'Occurrence Status' AND value = 'P' 
					--SELECT @NotRequiredStatus = valuetitle  FROM   [Configuration] WHERE  Systemname = 'All'  AND Componentname = 'Route Status'  AND value = 'NR' 

                    DECLARE @CompleteStatusID AS VARCHAR(20)
                    DECLARE @WaitingStatusID AS VARCHAR(20) 
                    DECLARE @InProgressStatusID AS VARCHAR(20)
                    DECLARE @NotRequiredStatusID AS VARCHAR(20)

					select @CompleteStatusID = os.[OccurrenceStatusID] 
					from OccurrenceStatus os
					inner join Configuration c on os.[Status] = c.ValueTitle
					where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'C' 

					select @WaitingStatusID = os.[OccurrenceStatusID] 
					from OccurrenceStatus os
					inner join Configuration c on os.[Status] = c.ValueTitle
					where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'W' 

					select @InProgressStatusID = os.[OccurrenceStatusID] 
					from OccurrenceStatus os
					inner join Configuration c on os.[Status] = c.ValueTitle
					where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'P' 

					select @NotRequiredStatusID = os.[RouteStatusID] 
					from RouteStatus os
					inner join Configuration c on os.[Status] = c.ValueTitle
					where c.SystemName = 'All' and c.ComponentName = 'Route Status' AND c.Value = 'NR' 

						  --Insert Into Pattern Master
		    
							INSERT INTO [Pattern] 
								  (
								  [CreativeID],
								  [AdID],
								  MediaStream,
								  Status,
								  [EventID],
								  [ThemeID],
								  [SalesStartDT],
								  [SalesEndDT],
								  CreateDate,
								  CreateBy
								  )
								   VALUES 
								   (
								   Null,
								   @AdId,
								   @MediaStreamId,
								   'Valid',
								   @EventId,
								   @ThemeId,
								   @SaleStartDate,
								   @SaleEndDate,
								   GetDate(),
								   @UserId
								   )

							 SET @PatternmasterId=Scope_identity();

							--Print(@PatternmasterId)

						--Insert Into OccurrenceDetailSOC --Assign to office default to Chicago,Country of Origin Default to 'USA'
					INSERT INTO [OccurrenceDetailSOC]
					([MediaTypeID],[MarketID],[AdID],[PatternID],SocialType,[DistributionDT],[AdDT],Priority,SubjectPost,
					LandingPageURL,URL,CountryOrigin,FormatCode,RatingCode,RelationshiptoAdv,PromotionalInd,AssignedtoOffice,NoTakeReason,[Query],MapStatusID,IndexStatusID,
					ScanStatusID,QCStatusID,RouteStatusID,OccurrenceStatusID,[CreateFromAuditInd],FlyerID,[AuditedByID],[AuditedDT],[CreatedDT],[CreatedByID],[ModifiedDT],[ModifiedByID])
					VALUES
					(@MediaTypeId,@MarketId,@AdId,@PatternmasterId,@SocialType,@DistributionDate,@ADDate,@Priority,@Subject,@LandingPageURL,@URL,@CountryOfOrigin,
					@Format,@Rating,@RelationshiptoAdv,@Promotional,'Chi',Null,NULL,@CompleteStatusID,@CompleteStatusID,
					@WaitingStatusID,@WaitingStatusID,@NotRequiredStatusID,@InProgressStatusID,NULL,NULL,NULL,NULL,getdate(),@UserId,NULL,NULL) 

					SET @OccurrenceId=Scope_identity();


					IF(@NewOccurrence=1) -- If it is 1. New OccurrenceId update in Ad  PrimaryOccurrence.
					BEGIN
					UPDATE ad SET  [PrimaryOccurrenceID]=@OccurrenceId   WHERE  ad.[AdID] = @AdId 
					END

					  -- Updating MOD Reason Into AD table     
					  IF @NotakeReason <> '' 
						BEGIN 
							 DECLARE @ModDescription AS NVARCHAR(MAX)			
							SELECT @ModDescription=Description From Ad WHERE  [AdID] = @AdId
							IF(@ModDescription <>'')
								BEGIN
									SET @ModDescription=@ModDescription+',MOD: ' + @NotakeReason    -- Append description with MOD
								END 
							ELSE
								BEGIN
									SET @ModDescription='MOD: ' + @NotakeReason
								END 
							UPDATE Ad SET    description =@ModDescription  WHERE  [AdID] = @AdId
						END 


					EXEC  [sp_UpdateMapMODDetails] @originalAdDescription,@originalAdRecutDetail,'SOC',@AdId,@isScanReqd,@UserId,@isMapAD
						--- Update Status for Occurrence
					EXEC  [dbo].[sp_SocialUpdateOccurrenceStageStatus] @OccurrenceID, 1				
				-- Page Definition Data

			  --Returing Generated OccurrenceID 
			   Select @OccurrenceId AS OccrnID

				--Checking If PageDefinitionParamXml have Data or Not
				SET @IsDefinitionData= (SELECT  @PageDefinitionParamXml.exist('/DocumentElement'))
				IF(@IsDefinitionData=1)
				BEGIN							
						--Inserting New Records For Page Definition Details in CreativeDetailEM
						INSERT INTO [dbo].[Creative]
						  ([AdId],[SourceOccurrenceId],[PrimaryIndicator],[PrimaryQuality])
						 VALUES
						 (@AdId,@OccurrenceId,1,@CreativeAssetQuality)

						 SET @CreativeMasterID=Scope_identity();

						Update [Pattern] Set [Pattern].[CreativeID]=@CreativeMasterID WHERE [Pattern].[PatternID]=@PatternmasterId				
						EXEC [dbo].[sp_SocialDPFUpdatePageDefinitionData] @OccurrenceId,@PatternmasterId,@PageDefinitionParamXml
			   END	
			   
			 
			   		
		   COMMIT TRANSACTION
    END TRY
	 BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_SocialSaveOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
	 END CATCH
    
END