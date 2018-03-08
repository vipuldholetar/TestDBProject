-- =====================================================================================================
-- Author		:	KARUNAKAR
-- Create date	:	11/23/2015
-- Execution	:	sp_SocialUpdateOccurrenceData
-- Description	:	Updating Occurrence Data for Social in Data Points Form
-- Updated By	:	Arun Nair on 01/19/2016 - Added MapMOD details
-- =======================================================================================================
CREATE PROCEDURE [dbo].[sp_SocialUpdateOccurrenceData] 
(
@OccurrenceId											AS NVARCHAR(MAX),
@AdId														AS INT,
@MediaStreamId												AS INT,
@MarketId													AS INT,
@EventId													AS INT,
@ThemeId													AS INT,
@UserId														AS INT,
@PageDefinitionParamXml										AS XML,
@CreativeAssetQuality										AS INT,
@SaleStartDate												As Date,
@SaleEndDate												As Date,
@Promotional												AS BIT,
@originalAdDescription	AS NVARCHAR(MAX),
@originalAdRecutDetail	AS NVARCHAR(MAX),
@isScanReqd as bit,
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
					DECLARE @PatternMasterID AS nvarchar(MAX)
					DECLARE @IsDefinitionData AS INTEGER 				
					DECLARE @CreativemasterId AS INTEGER
					 	
			        SELECT @PatternMasterID=[PatternID] FROM [OccurrenceDetailSOC] WHERE [OccurrenceDetailSOC].[OccurrenceDetailSOCID]=@OccurrenceID			 		

					Update [OccurrenceDetailSOC] set [AdID]=@AdId,[MarketID]=@MarketId,PromotionalInd=@Promotional Where [OccurrenceDetailSOC].[OccurrenceDetailSOCID]=@OccurrenceID

					-- Remap Scenario
					if exists(select 1 from ad where [AdID]=@AdId and [PrimaryOccurrenceID] is null)
					begin
					update ad set [PrimaryOccurrenceID]=@OccurrenceID where   [AdID]=@AdId 
					end 


					---Updating Pattern Master Table----

					UPDATE [Pattern] SET [Pattern].[EventID]=@EventID,[Pattern].[ThemeID]=@ThemeId,[Pattern].[AdID]=@AdId,
											[SalesStartDT]=@SaleStartDate,[SalesEndDT]=@SaleEndDate,ModifiedBy=@UserId,ModifyDate=getdate()
											WHERE [Pattern].[PatternID]=@PatternMasterID
					 
					EXEC  [sp_UpdateMapMODDetails] @originalAdDescription,@originalAdRecutDetail,'SOC',@AdId,@isScanReqd,@UserId,@isMapAD

						--- Update Status for Occurrence
					EXEC  [dbo].[sp_SocialUpdateOccurrenceStageStatus] @OccurrenceID, 2							
				
				-- Page Definition Data

						Set @CreativemasterId=(Select [Pattern].[CreativeID] from [Pattern] where  [Pattern].[PatternID]=@PatternMasterID)			
						--Print(@CreativeMasterID)

						--Checking If PageDefinitionParamXml have Data or Not
						SET @IsDefinitionData= (SELECT  @PageDefinitionParamXml.exist('/DocumentElement'))
						--Print(@IsDefinitionData)
						IF(@IsDefinitionData=1)
						BEGIN		
							IF Exists(Select 1  from [Creative] Where [Creative].PK_Id=@Creativemasterid)
							BEGIN
									-- Updating Records For Page Definition Details in CreativeDetailPub

									UPDATE [Creative] SET [AdId]=@AdId where [Creative].PK_Id=@Creativemasterid
									update CreativedetailSOC set PageTypeId = 'B',SizeId = 1 where CreativeMasterId = @CreativeMasterId
									EXEC [dbo].[sp_SocialDPFUpdatePageDefinitionData] @OccurrenceId,@PatternMasterID,@PageDefinitionParamXml  ----Need to change 
							END
							ELSE
							BEGIN
								--Inserting New Records For Page Definition Details in CreativeDetailPub
								--print @AdId
								--print @OccurrenceID

								INSERT INTO [dbo].[Creative]([AdId],[SourceOccurrenceId],[PrimaryIndicator],[PrimaryQuality]) VALUES(@AdId,@OccurrenceId,1,@CreativeAssetQuality)
								 SET @CreativeMasterID=Scope_identity();
						 
								 --Print N'Creative master generated'
								--Print(@CreativeMasterID)
								--PRINT @PatternmasterId
								update CreativedetailSOC set PageTypeId = 'B',SizeId = 1 where CreativeMasterId = @CreativeMasterId
								Update [Pattern] Set [Pattern].[CreativeID]=@CreativeMasterID WHERE [Pattern].[PatternID]=@PatternMasterID
								--Print N'Updated Patternmaster'				
								EXEC [dbo].[sp_SocialDPFUpdatePageDefinitionData] @OccurrenceId,@PatternMasterID,@PageDefinitionParamXml    ----Need to change 
							END				
						END
			
				   COMMIT TRANSACTION
    END TRY
	 BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_SocialUpdateOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
	 END CATCH
    
END