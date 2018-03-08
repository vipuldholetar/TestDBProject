-- =====================================================================================================
-- Author            :      KARUNAKAR
-- Create date       :      2nd Nov 2015
-- Execution  :      
-- Description       :      Saving Parent Occurrence Data for Email in Data Points Form
-- Updated By :      Karunakar on 3rd Nov 2015,By Default given hard coded value for Assign to office is Chicago
-- =======================================================================================================
CREATE PROCEDURE [dbo].[sp_EmailSaveParentOccurrenceData] 
(
@AdId                                                                                           AS INT,
@MediaTypeId                                                                             AS INT,
@LanguageId                                                                                     AS INT,
@MediaStreamId                                                                                  AS INT,
@MarketId                                                                                       AS INT,
@LandingPageURL                                                                                 AS NVARCHAR(MAX),
@AdvertiserEmailId                                                                       AS INT,
@SenderPersonaId                                                                         AS INT,
@Gender                                                                                                AS NVARCHAR(10),
@AgeBracket                                                                                     AS INT,
@DistributionDate                                                                        AS DATETIME,
@ADDate                                                                                                AS DATETIME,
@Subject                                                                                        AS NVARCHAR(MAX),
@EventId                                                                                        AS INT,
@ThemeId                                                                                        AS INT,
@SaleStartDate                                                                                  AS DATETIME,
@SaleEndDate                                                                             AS DATETIME,
@AdvertiserID                                                                            AS INT=0,
@Priority                                                                                       AS INT=0,
@Promotional                                                                             AS bit,
@MediaTypeComments                                                                       AS NVARCHAR(MAX),
@NotakeReason                                               AS VARCHAR(MAX),
@UserId                                                                                                AS INT,
@NewOccurrence                                                                                  AS INT,
@PageDefinitionParamXml                                                                  AS XML,
@BulkUpdateXml                                                                                  AS XML,
@CreativeAssetQuality                                                                    AS INT,
@originalAdDescription     AS NVARCHAR(MAX),
@originalAdRecutDetail     AS NVARCHAR(MAX),
@isScanReqd as BIT,
@isMapAD as BIT
)
AS
IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END
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

                    --SELECT @CompleteStatus = valuetitle      FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Occurrence Status' AND value = 'C'
                    --SELECT @WaitingStatus = valuetitle FROM   [Configuration]  WHERE  Systemname = 'All' AND Componentname = 'Occurrence Status' AND value = 'W' 
                    --SELECT @InProgressStatus = valuetitle FROM   [Configuration] WHERE  Systemname = 'All' AND Componentname = 'Occurrence Status' AND value = 'P' 
                    --SELECT @NotRequiredStatus = valuetitle  FROM   [Configuration] WHERE  Systemname = 'All'  AND Componentname = 'Route Status'  AND value = 'NR' 

                    DECLARE @CompleteStatusID AS INT
                    DECLARE @WaitingStatusID AS INT 
                    DECLARE @InProgressStatusID AS INT
                    DECLARE @NotRequiredStatusID AS INT

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
                  
                            --INSERT INTO [Pattern] 
                            --            (
                            --            [CreativeID],
                            --            [AdID],
                            --            MediaStream,
                            --            Status,
                            --            [EventID],
                            --            [ThemeID],
                            --            [SalesStartDT],
                            --            [SalesEndDT],
                            --            CreateDate,
                            --            CreateBy
                            --            )
                            --            VALUES 
                            --            (
                            --            Null,
                            --            @AdId,
                            --            @MediaStreamId,
                            --            'Valid',
                            --            @EventId,
                            --            @ThemeId,
                            --            @SaleStartDate,
                            --            @SaleEndDate,
                            --            GetDate(),
                            --            @UserId
                            --            )

                            --SET @PatternmasterId=Scope_identity();
							Select @PatternmasterId = patternid from pattern where AdID =@AdId
                            --Print(@PatternmasterId)

                                    --Insert Into OccurrenceDetailEM
                            INSERT INTO [OccurrenceDetailEM]
                            ([AdvertiserID],[MediaTypeID],[MarketID],[AdvertiserEmailID],[SenderPersonaID],
                            [ParentOccurrenceID],[EnvelopeID],[AdID],[PatternID],[DistributionDT],[AdDT],Priority,SubjectLine,
                            LandingPageID,PromotionalInd,AssignedtoOffice,NoTakeReason, MapStatusID, IndexStatusID,
                            ScanStatusID, QCStatusID, RouteStatusID, OccurrenceStatusID, [CreatedDT],[CreatedByID])
                            Values
                            (@AdvertiserID,@MediaTypeId,@MarketId,@AdvertiserEmailId,@SenderPersonaId,
                            Null,Null,@AdId,@PatternmasterId,@DistributionDate,@ADDate,@Priority,@Subject,
                            (select min(LandingPageID) from LandingPage where LandingPage.LandingURL = @LandingPageURL), @Promotional, 'Chi', Null, @CompleteStatusID, @CompleteStatusID,
                            @WaitingStatusID, @WaitingStatusID, @NotRequiredStatusID, @InProgressStatusID, getdate(), @UserId) --By Default given hard coded value for Assign to office is Chicago

                            SET @OccurrenceId=Scope_identity();

                                   
                           -- Page Definition Data
                           --Checking If PageDefinitionParamXml have Data or Not
                           SET @IsDefinitionData= (SELECT  @PageDefinitionParamXml.exist('/DocumentElement'))
                           IF(@IsDefinitionData=1)
                           BEGIN                                           
                                    --Inserting New Records For Page Definition Details in CreativeDetailEM
								IF NOT EXISTS(SELECT PK_Id FROM [Creative] WHERE AdId=@AdId)
								BEGIN
									INSERT INTO [dbo].[Creative]
											([AdId],[SourceOccurrenceId],[PrimaryIndicator],[PrimaryQuality])
									VALUES
									(@AdId,@OccurrenceId,1,@CreativeAssetQuality)

									SET @CreativeMasterID=Scope_identity();
								END
								ELSE
								BEGIN
									SELECT @CreativeMasterID = PK_Id FROM [Creative] WHERE AdId=@AdId
								END
                                         
								Update [Pattern] Set [Pattern].[CreativeID]=@CreativeMasterID WHERE [Pattern].[PatternID]=@PatternmasterId                      
								EXEC [dbo].[sp_EmailDPFUpdatePageDefinitionData] @OccurrenceId,@PatternmasterId,@PageDefinitionParamXml
							END                     
                        -- Update MapMOD details

                                  EXEC  [sp_UpdateMapMODDetails] @originalAdDescription,@originalAdRecutDetail,'EM',@AdId,@isScanReqd,@UserId,@isMapAD          
                     
                 COMMIT TRANSACTION
    END TRY
       BEGIN CATCH
                           DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
                           SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
                           RAISERROR ('[sp_EmailSaveParentOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo)   ; 
                           ROLLBACK TRANSACTION 
        END CATCH
    
END