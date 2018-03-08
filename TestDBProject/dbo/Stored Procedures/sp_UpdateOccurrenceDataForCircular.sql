
-- =====================================================================================================
-- Author		:	Karunakar
-- Create date	:	21/5/2015
-- Execution	:	[dbo].[sp_UpdateOccurrenceDataForCircular] 
-- Description	:	Updating Occurrence Data for Circular in Data Points Form
-- Updated By	:	Update By Karunakar on 11th August 2015,Changing Patternmaster and Ad table Fileds
--					Arun Nair on 01/18/2016 - Updated sp_UpdateMapMODDetails to this procedure 
-- =======================================================================================================
CREATE PROCEDURE [dbo].[sp_UpdateOccurrenceDataForCircular] 
(
	@pOccurrenceID Varchar(max),
	@pMediaTypeId as  int,
	@pMarketId as int,
	@pEventID as int,
	@pThemeId as int,
	@pFlash as bit,
	@pNational as bit,
	@pColor as varchar(max),
	@pPageCount as int,
	@pDistDate as datetime,
	@pSaleStartDate as datetime,
	@pSaleEndDate as datetime,
	@pSizingMethod as varchar(max),
	@pMediaStream as Int,
	@pSource as int,
	@pAdId As Int,
	@pPriority as Int,
	@pMODReason as Varchar(max),
	@pUserId as Int,
	@pBulkUpdateXML as XML,
	@PageDefinitionParamXml As Xml,
	@CreativeQualityAsset As Int,
	@originalAdDescription as varchar(max),
	@originalAdRecutDetail as varchar(max),
	@isScanReqd as bit,
	@isMapAD as bit,
	@pAdDate as datetime
)
AS
 IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 
BEGIN
	
	SET NOCOUNT ON;
	 BEGIN Try 
          BEGIN TRANSACTION 


		        DECLARE @RecordsCount AS INTEGER
				declare @PatternMasterID as nvarchar(max)
				DECLARE @OccurrenceID AS NVARCHAR(Max)
				DECLARE @Counter AS INTEGER
				Declare @IsDefinitionData As Int 
				Declare @IsBulkData As Int
				DeClare @CreativemasterId As Int
				DECLARE @OccurrenceMediaStream AS VARCHAR(50)


				DECLARE @TableOccurrence
				TABLE (			
						ID INT IDENTITY(1,1),			
						OccurrenceIDTemp NVARCHAR(MAX) NOT NULL
					  )	

			    INSERT INTO @TableOccurrence(OccurrenceIDTemp)
				Select ITEM From SplitString(''+@pOccurrenceID+'',',')
				select * from @TableOccurrence
				SELECT @RecordsCount =Count(OccurrenceIDTemp) FROM @TableOccurrence		

				SET @Counter=1
				WHILE @Counter<=@RecordsCount
				BEGIN 
					SELECT @OccurrenceID=OccurrenceIDTemp FROM @TableOccurrence WHERE ID =@Counter

				   --print(@OccurrenceID)
				   IF EXISTS(select 1 
								    from [OccurrenceDetailPUB] 
										  where [OccurrenceDetailPUBID]=@OccurrenceId)
				    BEGIN
						  SET @OccurrenceMediaStream = 'PUB'
						  select @PatternMasterID=[PatternID] from [OccurrenceDetailPUB] where [OccurrenceDetailPUBID]=@OccurrenceID
					   
						  UPDATE [OccurrenceDetailPUB]
								SET [AdID]=@pAdId,
								    [MediaTypeID]=@pMediaTypeId,
								    [MarketID]=@pMarketId,
								    [SubSourceID]=@pSource,
								    [AdDT]=@pADDate,
								    Priority=@pPriority,
								    Color=@pColor,
								    SizingMethod=@pSizingMethod,
								    PageCount=@pPageCount,
								    [ModifiedDT]=getdate(),
								    [ModifiedByID]=@pUserId
							 WHERE  [OccurrenceDetailPUBID]=@OccurrenceId
				    END 
				    ELSE IF EXISTS(select 1 
								    from [OccurrenceDetailCIR] 
										  where [OccurrenceDetailCIRID]=@OccurrenceId)
				    BEGIN
						  SET @OccurrenceMediaStream = 'CIR'
						  select @PatternMasterID=[PatternID] from [OccurrenceDetailCIR] where [OccurrenceDetailCIRID]=@OccurrenceID

						 ---Updating OccurrenceDetailsCir Table----	
		 	
						  update [OccurrenceDetailCIR]  SET [OccurrenceDetailCIR].[MediaTypeID]=@pMediaTypeId, 
												[OccurrenceDetailCIR].[MarketID]=@pMarketId, 
												[OccurrenceDetailCIR].DistributionDate=@pDistDate, 
												[OccurrenceDetailCIR].AdDate=@pAdDate, 
												[OccurrenceDetailCIR].PageCount=@pPageCount,
												[OccurrenceDetailCIR].Color= @pColor, 
												[OccurrenceDetailCIR].SizingMethod=@pSizingMethod,
												[OccurrenceDetailCIR].[SubSourceID]=@pSource,
												[OccurrenceDetailCIR].[AdID]=@pAdId,
												[OccurrenceDetailCIR].Priority=@pPriority,
												[OccurrenceDetailCIR].[ModifiedDT]= Getdate(),
												[OccurrenceDetailCIR].[ModifiedByID]=@pUserId
										  where [OccurrenceDetailCIR].[OccurrenceDetailCIRID]=@OccurrenceID
				    END

				    ---Updating Pattern Master Table----
				    update [Pattern] set [Pattern].[EventID]=@pEventID,[Pattern].[ThemeID]=@pThemeId, 
								    [Pattern].[FlashInd]=@pFlash, [Pattern].NationalIndicator=@pNational,
								    [Pattern].[SalesStartDT]=@pSaleStartDate, [Pattern].[SalesEndDT]=@pSaleEndDate,
								    [Pattern].MediaStream=@pMediaStream,[Pattern].[AdID]=@pAdId
								where [Pattern].[PatternID]=@PatternMasterID


				    EXEC  [sp_UpdateMapMODDetails] @originalAdDescription,@originalAdRecutDetail,
								    @OccurrenceMediaStream,@pAdId,@isScanReqd,@pUserId,@isMapAd


				    --- Update Status for Occurrence
				    IF @OccurrenceMediaStream = 'CIR'
				    BEGIN
						  exec  sp_UpdateOccurrenceStageStatus @OccurrenceID, 2
				    END
				    ELSE IF @OccurrenceMediaStream = 'PUB'
				    BEGIN
						  -- Update status in OccurrenceDetailsPub
						  Exec sp_PublicationDPFOccurrenceStatus @OccurrenceId,2

						  IF @pMODReason ='Visual Change' ---L.E. 3.16.17 MI-977 If visual change MapMod occurrenece req new scan
						  BEGIN 
							 EXEC sp_UpdatePublicationOccurrenceStageStatus @OccurrenceId, 5
						  END 
						  ELSE
						  BEGIN 
							 EXEC sp_UpdatePublicationOccurrenceStageStatus @OccurrenceId, 3
						  END 

				    END	
				    		
				    Set @Counter=@Counter+1
				End 

				--- Update Bulk Status
				IF @OccurrenceMediaStream = 'CIR'
				    exec [sp_UpdateOccrncDataForBulkUpdate] @pBulkUpdateXML

				--Checking If PageDefinitionParamXml have Data or Not
				SET @IsDefinitionData= (SELECT  @PageDefinitionParamXml.exist('/DocumentElement'))
				IF(@IsDefinitionData=1)
				BEGIN		
				    Set @CreativemasterId=(Select [Pattern].[CreativeID] from [Pattern] where  [Pattern].[PatternID]=@PatternMasterID)

				    IF Exists(Select 1  from [Creative] Where [Creative].PK_Id=@Creativemasterid)
				    BEGIN
						  -- Updating Records For Page Definition Details in CreativeDetailPub
						  Exec [sp_CircularDPFUpdatePageDefinitionData] @OccurrenceId,@PatternMasterID,@PageDefinitionParamXml
				    END
				    ELSE
				    BEGIN
						  --Inserting New Records For Page Definition Details in CreativeDetailPub
						  INSERT INTO [dbo].[Creative]
							 ([AdId],[SourceOccurrenceId],[PrimaryIndicator],[PrimaryQuality])
						  Values
							 (@pAdId,@OccurrenceId,1,@CreativeQualityAsset)

						  SET @CreativeMasterID=Scope_identity();

						  Update [Pattern] Set [Pattern].[CreativeID]=@CreativeMasterID Where [Pattern].[PatternID]=@PatternmasterId				
						  Exec [sp_CircularDPFInsertPageDefinitionData] @OccurrenceId,@CreativeMasterID,@PageDefinitionParamXml
				    END				
				END
					--Page Definition Data
			  --END
		   COMMIT TRANSACTION
     End TRY
	 BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('SP_UpdateOccurrenceDataForCircular: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
	 END CATCH
    
END
