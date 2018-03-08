-- =====================================================================================================
-- Author		:	Arun Nair
-- Create date	:	11/12/2015
-- Execution	:	sp_WebsiteUpdateOccurrenceData
-- Description	:	Updating Occurrence Data for Email in Data Points Form
-- Updated By	:	
-- =======================================================================================================
CREATE PROCEDURE [dbo].[sp_WebsiteUpdateOccurrenceData] 
(
@OccurrenceId											AS NVARCHAR(MAX),
@AdId														AS INT,
@MediaTypeId												AS INT,
@MediaStreamId												AS INT,
@MarketId													AS INT,
@EventId													AS INT,
@ThemeId													AS INT,
@UserId														AS INT,
@PageDefinitionParamXml										AS XML,
@CreativeAssetQuality										AS INT
)
AS
BEGIN
	
	SET NOCOUNT ON;
	 BEGIN TRY 
          BEGIN TRANSACTION 

					DECLARE @RecordsCount AS INTEGER
					DECLARE @PatternMasterID AS nvarchar(MAX)
					DECLARE @IsDefinitionData AS INTEGER 				
					DECLARE @CreativemasterId AS INTEGER
					 	
			        SELECT @PatternMasterID=[PatternID] FROM [OccurrenceDetailWEB] WHERE [OccurrenceDetailWEBID]=@OccurrenceID			 		

					---Updating Pattern Master Table----

					UPDATE [Pattern] SET [Pattern].[EventID]=@EventID,[Pattern].[ThemeID]=@ThemeId,[Pattern].[AdID]=@AdId
											WHERE [Pattern].[PatternID]=@PatternMasterID
					 
						--- Update Status for Occurrence
					EXEC  [dbo].[sp_WebsiteUpdateOccurrenceStageStatus] @OccurrenceID, 2							
				
				-- Page Definition Data

						Set @CreativemasterId=(Select [Pattern].[CreativeID] from [Pattern] where  [Pattern].[PatternID]=@PatternMasterID)			
						Print(@CreativeMasterID)

						--Checking If PageDefinitionParamXml have Data or Not
						SET @IsDefinitionData= (SELECT  @PageDefinitionParamXml.exist('/DocumentElement'))
						Print(@IsDefinitionData)
						IF(@IsDefinitionData=1)
						BEGIN		
							IF Exists(Select 1  from [Creative] Where [Creative].PK_Id=@Creativemasterid)
							BEGIN
									-- Updating Records For Page Definition Details in CreativeDetailPub
									EXEC [dbo].[sp_WebsiteDPFUpdatePageDefinitionData] @OccurrenceId,@PatternMasterID,@PageDefinitionParamXml  ----Need to change 
							END
							ELSE
							BEGIN
								--Inserting New Records For Page Definition Details in CreativeDetailPub
								print @AdId
								print @OccurrenceID

								INSERT INTO [dbo].[Creative]([AdId],[SourceOccurrenceId],[PrimaryIndicator],[PrimaryQuality]) VALUES(@AdId,@OccurrenceId,1,@CreativeAssetQuality)
								 SET @CreativeMasterID=Scope_identity();
						 
								 Print N'Creative master generated'
								Print(@CreativeMasterID)
								PRINT @PatternmasterId
								Update [Pattern] Set [Pattern].[CreativeID]=@CreativeMasterID WHERE [Pattern].[PatternID]=@PatternMasterID
								Print N'Updated Patternmaster'				
								EXEC [dbo].[sp_WebsiteDPFUpdatePageDefinitionData] @OccurrenceId,@PatternMasterID,@PageDefinitionParamXml    ----Need to change 
							END				
						END
			
				   COMMIT TRANSACTION
    END TRY
	 BEGIN CATCH
				DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_WebsiteUpdateParentOccurrenceData]: %d: %s',16,1,@error,@message,@lineNo)   ; 
				ROLLBACK TRANSACTION 
	 END CATCH
    
END
