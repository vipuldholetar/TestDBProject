

-- =====================================================================================================
-- Author		:	KARUNAKAR
-- Create date	:	11th Nov 2015
-- Execution	:	sp_WebSiteSaveOccurrenceData 10450,10,1,156,0,'11/12/2015','11/12/2015',1,221,29692010,0,29712221,'<DocumentElement><PageDefinition><PageTypeId>B</PageTypeId><SizeId>26</SizeId><PageName>1</PageName><Size>00.00 X07.50</Size><PageNumberOrder>1</PageNumberOrder><PageNumber>1</PageNumber><PubPageNumber>4</PubPageNumber></PageDefinition><PageDefinition><PageTypeId>B</PageTypeId><SizeId>26</SizeId><PageName>2</PageName><Size>00.00 X 07.50</Size><PageNumberOrder>2</PageNumberOrder><PageNumber>2</PageNumber><PubPageNumber>4</PubPageNumber></PageDefinition><PageDefinition><PageTypeId>B</PageTypeId><SizeId>26</SizeId><PageName>3</PageName><Size>00.00 X 07.50</Size><PageNumberOrder>3</PageNumberOrder><PageNumber>3</PageNumber><PubPageNumber>4</PubPageNumber></PageDefinition></DocumentElement>',91
-- Description	:	Saving Parent Occurrence Data for WebSite in Data Points Form
-- Updated By	:	By Default given hard coded value for Assign to office is Chicago
-- =======================================================================================================
CREATE PROCEDURE [dbo].[sp_WebSiteSaveOccurrenceData] 
(
@AdId														AS INT,
@MediaTypeId												AS INT,
@LanguageId													AS INT,
@MediaStreamId												AS INT,
@MarketId													AS INT,
@DistributionDate											AS DATETIME,
@ADDate														AS DATETIME,
@EventId													AS INT,
@ThemeId													AS INT,
@AdvertiserID												AS INT,
@Priority													AS INT=0,
@UserId														AS INT,
@PageDefinitionParamXml										AS XML,
@CreativeAssetQuality										AS INT
)
AS
BEGIN
	
	SET NOCOUNT ON;
	 BEGIN TRY 
          BEGIN TRANSACTION 
		     
					DECLARE @MarketValue AS VARCHAR(40)
					DECLARE @OccurrenceId As BigInt
					DECLARE @PatternmasterId As Int	
					DECLARE @IsDefinitionData As Int 
					DECLARE @CreativeMasterID As Int

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
		    
							INSERT INTO [Pattern] 
								  (
								  [CreativeID],
								  [AdID],
								  MediaStream,
								  Status,
								  [EventID],
								  [ThemeID],
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
								   GetDate(),
								   @UserId
								   )

							 SET @PatternmasterId=Scope_identity();

							Print(@PatternmasterId)

						--Insert Into OccurrenceDetailEM

						insert into [OccurrenceDetailWEB]
						([MediaTypeID],[MarketID],[EnvelopeID],[AdID],[PatternID],[DistributionDT],
						[AdDT],Priority,AssignedtoOffice,MapStatusID,IndexStatusID,ScanStatusID,QCStatusID,
						RouteStatusID,OccurrenceStatusID,[CreatedDT],[CreatedByID])
						Values
						(@MediaTypeId,@MarketId,Null,@AdId,@PatternmasterId,@DistributionDate,
						@ADDate,@Priority,'Chi',@CompleteStatusID,@CompleteStatusID,@WaitingStatusID,@WaitingStatusID,
						@NotRequiredStatusID,@InProgressStatusID,getdate(),@UserId)		--By Default given hard coded value for Assign to office is Chicago				
				


					 SET @OccurrenceId=Scope_identity();
					 Print(@OccurrenceId)

					 IF(@MarketId<>0)
					 begin
					 set @MarketValue=(Select [Descrip] from [Market] where [MarketID]=@MarketId)
					 end

					 UPDATE ad SET    [PrimaryOccurrenceID] =@OccurrenceId,FirstRunDate=@DistributionDate,LastRunDate=@DistributionDate,[FirstRunMarketID]=@MarketValue  WHERE  ad.[AdID] = @AdId


					 -- IF @NotakeReason <> '' 
					 -- BEGIN 				
						--UPDATE ad SET    description ='MOD:'+@NotakeReason  WHERE  ad.PK_Id = @AdId 
					 -- END 
									
				-- Page Definition Data
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
						EXEC [dbo].[sp_WebsiteDPFUpdatePageDefinitionData] @OccurrenceId,@PatternmasterId,@PageDefinitionParamXml
			   END				
				
					--Page Definition Data
			
		   COMMIT TRANSACTION
    END TRY
	 BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_WebSiteSaveOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
	 END CATCH
    
END