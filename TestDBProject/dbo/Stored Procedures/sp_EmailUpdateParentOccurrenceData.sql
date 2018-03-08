
-- =====================================================================================================
-- Author		:	Arun Nair
-- Create date	:	10/27-28/2015
-- Execution	:	sp_EmailUpdateParentOccurrenceData '1030,1031,1032',9426,13,1,154,50,'www.google.com',1,1,'Female',26,'10/20/2015','10/20/2015','Sample Text',1,1,'10/30/2015','10/30/2015',1,11,1,'',0,29712040,1,'<DocumentElement><PageDefinition> <PageTypeId>B</PageTypeId> <SizeId>8</SizeId> <PageName>1</PageName><Size>00.00 X 01.75</Size><PageNumberOrder>1</PageNumberOrder><PageNumber>1</PageNumber><PubPageNumber>2</PubPageNumber></PageDefinition><PageDefinition><PageTypeId>B</PageTypeId><SizeId>8</SizeId><PageName>2</PageName><Size>00.00 X 01.75</Size><PageNumberOrder>2</PageNumberOrder><PageNumber>2</PageNumber><PubPageNumber>2</PubPageNumber></PageDefinition><PageDefinition><PageTypeId>I</PageTypeId><SizeId>8</SizeId><PageName>I1-1</PageName><Size>00.00 X 01.75</Size><InsertNumber>1</InsertNumber><PageNumberOrder>1</PageNumberOrder><PageNumber>3</PageNumber><PubPageNumber>2</PubPageNumber></PageDefinition></DocumentElement>','',91
-- Description	:	Updating Occurrence Data for Email in Data Points Form
-- Updated By	:	Arun Nair on 01/19/2015 - Added MapMod Details
-- =======================================================================================================
CREATE PROCEDURE [dbo].[sp_EmailUpdateParentOccurrenceData] 
(
@ParentOccurrenceId											AS NVARCHAR(MAX),
@AdId														AS INT,
@MediaTypeId												AS INT,
@LanguageId													AS INT,
@MediaStreamId												AS INT,
@MarketId													AS INT,
@LandingPageURL												AS NVARCHAR(MAX),
@AdvertiserEmailId											AS INT,
@SenderPersonaId											AS INT,
@Gender														AS NVARCHAR(10),
@AgeBracket													AS INT,
@DistributionDate											AS DATETIME,
@ADDate														AS DATETIME,
@Subject													AS NVARCHAR(MAX),
@EventId													AS INT,
@ThemeId													AS INT,
@SaleStartDate												AS DATETIME,
@SaleEndDate												AS DATETIME,
@AdvertiserID												AS INT,
@Priority													AS INT=0,
@Promotional												AS bit,
@MediaTypeComments											AS NVARCHAR(MAX),
@NotakeReason                                               AS VARCHAR(MAX),
@UserId														AS INT,
@NewOccurrence												AS INT,
@PageDefinitionParamXml										AS XML,
@BulkUpdateXml												AS XML,
@CreativeAssetQuality										AS INT,
@IsRemap													AS BIT,
@originalAdDescription	AS NVARCHAR(MAX),
@originalAdRecutDetail	AS NVARCHAR(MAX),
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

		        DECLARE @RecordsCount AS INTEGER
				DECLARE @PatternMasterID AS nvarchar(max)
				DECLARE @OccurrenceID AS NVARCHAR(Max)
				DECLARE @Counter AS INTEGER
				DECLARE @IsDefinitionData AS INTEGER 
				DECLARE @IsBulkData AS INTEGER
				DECLARE @CreativemasterId AS INTEGER
				Declare @PrimaryParentOccurrenceID as NVARCHAR(Max)
				Declare @PrimaryParentPatternMasterID as NVARCHAR(Max)

				DECLARE @TableOccurrence
				TABLE (			
						ID INT IDENTITY(1,1),			
						OccurrenceIDTemp NVARCHAR(MAX) NOT NULL
					  )	

			    INSERT INTO @TableOccurrence(OccurrenceIDTemp)
				SELECT ITEM From SplitString(''+@ParentOccurrenceId+'',',')


				--SET @PrimaryParentOccurrenceID=(SELECT OccurrenceIDTemp from @TableOccurrence WHERE ID=1)

				--Print(@PrimaryParentOccurrenceID)

				SELECT @RecordsCount =Count(OccurrenceIDTemp) FROM @TableOccurrence		

				SET @Counter=1
				WHILE @Counter<=@RecordsCount
					BEGIN 
						SELECT @OccurrenceID=OccurrenceIDTemp FROM @TableOccurrence WHERE ID =@Counter

						IF EXISTS (SELECT TOP 1 * FROM Ad WHERE [PrimaryOccurrenceID] =@OccurrenceID)
						BEGIN 
						SET @PrimaryParentOccurrenceID=@OccurrenceID
						End
																
					    IF @OccurrenceID<>@PrimaryParentOccurrenceID
						BEGIN 
						 print(@OccurrenceID +' ok map creative '+  convert(nvarchar,@ADID))
						exec [dbo].[sp_EmailMapCreativeOccurrenceToAd]  @Description='', @RecutDetail='' , @Adid=@ADID , @OccurrenceID=  @OccurrenceID ,@UserID =@UserId
						END

						
					 SELECT @PatternMasterID=[PatternID] FROM [OccurrenceDetailEM] WHERE [OccurrenceDetailEMID]=@OccurrenceID
					 if @counter=1
					 begin
					 set @PrimaryParentPatternMasterID=@PatternMasterID
					 end
					 --print(@PatternMasterID)
	
					 ---Updating OccurrenceDetailsEM Table----	
		 	
					 UPDATE [OccurrenceDetailEM] SET [OccurrenceDetailEM].[MediaTypeID]=@MediaTypeId, 
													[OccurrenceDetailEM].[AdvertiserID]=@AdvertiserID, 
													[OccurrenceDetailEM].[MarketID]=@MarketId, 
													[OccurrenceDetailEM].[AdvertiserEmailID]=@AdvertiserEmailId,
													[OccurrenceDetailEM].[SenderPersonaID]= @SenderPersonaId, 													
													[OccurrenceDetailEM].Priority=@Priority,
													[OccurrenceDetailEM].[AdDT]= @ADDate, 													
													[OccurrenceDetailEM].[AdID]=@AdId,
													[OccurrenceDetailEM].[PatternID]=@PatternMasterID,
													[OccurrenceDetailEM].[DistributionDT]=@DistributionDate,
													[OccurrenceDetailEM].SubjectLine= @Subject,
													LandingPageID = (select min(LandingPageID) from LandingPage where LandingPage.LandingURL = @LandingPageURL),
													[OccurrenceDetailEM].[ModifiedDT]= Getdate(),
													[OccurrenceDetailEM].[ModifiedByID]=@UserId,
													[OccurrenceDetailEM].PromotionalInd=@Promotional 
													where [OccurrenceDetailEM].[OccurrenceDetailEMID]=@OccurrenceID

					---Updating Pattern Master Table----

					UPDATE [Pattern] SET [Pattern].[EventID]=@EventID,[Pattern].[ThemeID]=@ThemeId, 
											[Pattern].[SalesStartDT]=@SaleStartDate, [Pattern].[SalesEndDT]=@SaleEndDate,
											[Pattern].MediaStream=@MediaStreamId,[Pattern].[AdID]=@AdId
											WHERE [Pattern].[PatternID]=@PatternMasterID
															
						EXEC  [sp_UpdateMapMODDetails] @originalAdDescription,@originalAdRecutDetail,'EM',@AdId,@isScanReqd,@UserId,@isMapAD		

						--- Update Status for Occurrence
					   EXEC  [dbo].[sp_EmailUpdateOccurrenceStageStatus] @OccurrenceID, 2				
					   SET @Counter=@Counter+1
				END 

				
				--- Update Bulk Status
				--EXEC [sp_UpdateOccrncDataForBulkUpdate] @pBulkUpdateXML

				--Set @IsBulkData=(Select @pBulkUpdateXML.exist('/DocumentElement'))

				--IF(@IsBulkData=0)
				--BEGIN

				-- Insert/Updating Page Definition Data From CreativeDetailCIR for Single Occurrence

				-- Page Definition Data

				--Set @CreativemasterId=(Select [Pattern].[CreativeID] from [Pattern] where  [Pattern].[PatternID]=@PrimaryParentPatternMasterID)
			
				--Print(@CreativeMasterID)


				----Checking If PageDefinitionParamXml have Data or Not
				--SET @IsDefinitionData= (SELECT  @PageDefinitionParamXml.exist('/DocumentElement'))
				--Print(@IsDefinitionData)
				--IF(@IsDefinitionData=1)
				--BEGIN		
				--	IF Exists(Select 1  from [Creative] Where [Creative].PK_Id=@Creativemasterid)
				--	BEGIN
				--			-- Updating Records For Page Definition Details in CreativeDetailPub
				--		  EXEC [dbo].[sp_EmailDPFUpdatePageDefinitionData] @OccurrenceId,@PrimaryParentPatternMasterID,@PageDefinitionParamXml  ----Need to change 
						  
				--		  IF EXISTS(Select 1  from [Creative] Where [Creative].PK_Id=@Creativemasterid AND AdId IS NULL)
				--			 UPDATE [Creative] SET AdId= @AdId Where [Creative].PK_Id=@Creativemasterid
				--	END
				--	ELSE
				--	BEGIN
				--		--Inserting New Records For Page Definition Details in CreativeDetailPub
				--		print @AdId
				--		print @PrimaryParentOccurrenceID

				--		INSERT INTO [dbo].[Creative]([AdId],[SourceOccurrenceId],[PrimaryIndicator],[PrimaryQuality]) VALUES(@AdId,@PrimaryParentOccurrenceID,1,@CreativeAssetQuality)
				--		 SET @CreativeMasterID=Scope_identity();
						 
				--		 Print N'Creative master generated'
				--		Print(@CreativeMasterID)
				--		PRINT @PatternmasterId
				--		Update [Pattern] Set [Pattern].[CreativeID]=@CreativeMasterID WHERE [Pattern].[PatternID]=@PrimaryParentPatternMasterID
				--		Print N'Updated Patternmaster'				
				--		EXEC [dbo].[sp_EmailDPFUpdatePageDefinitionData] @PrimaryParentOccurrenceID,@PrimaryParentPatternMasterID,@PageDefinitionParamXml    ----Need to change 
				--	END				
				--END
				--	--Page Definition Data

			IF(@IsRemap=1)  --Remap of Updating Creative Master Data for Parent Occurrence
			BEGIN
					IF Exists(Select 1  from [Creative] Where [Creative].PK_Id=@Creativemasterid)
					BEGIN
						Update [Creative] Set [Creative].[AdId]=@AdId,[SourceOccurrenceId]=@PrimaryParentOccurrenceID,PrimaryQuality= @CreativeAssetQuality	
						WHERE [Creative].PK_Id=@Creativemasterid	 
					END
			END
		   COMMIT TRANSACTION
     END TRY
	 BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_EmailUpdateParentOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
	 END CATCH
    
END