-- =============================================
-- Author		: Karunakar
-- Create date	: 6th jan 2015
-- Description	: This Procedure is Used to Updating Split Occurrence Data
-- Updated By	: 
--				: sp_MergeUpdateSplitOccurrence 19618,19619,'520016,520022,','Circular'
-- =============================================
CREATE PROCEDURE [dbo].[sp_MergeUpdateSplitOccurrence] 
(
@NonSurvivingAdid AS INT,
@SurvivingAdid AS INT,
@Occurrencelist AS NVARCHAR(Max),
@nonSurvivingMediaStream as NVARCHAR(Max)
)
AS
BEGIN
	
	SET NOCOUNT ON;

			BEGIN TRY
				BEGIN TRANSACTION 
				Declare @IsSplitOccurrence as Bit
				Declare @NoTakeReason as int
				Declare @MediaStreamVal AS NVARCHAR(50)

				Declare @PrimaryOccrnceID as Bigint
				Declare @FirstRunDate as nvarchar(50)
				Declare @LastRunDate as nvarchar(50)
				Declare @FirstRunMarket as integer


				Select @MediaStreamVal=Value from [Configuration] where componentname='Media Stream' and ValueTitle=@nonSurvivingMediaStream

				Select @NoTakeReason=ConfigurationID  from [Configuration]   where componentname='No Take Ad' and ValueTitle='Duplicate'

				--Print(@MediaStreamVal)
				--Print(@NoTakeReason)

				IF(@Occurrencelist<>'' AND @SurvivingAdid<>0)
				BEGIN

				--Print(@Occurrencelist)
				--Print(@SurvivingAdid)

						--Circular
						IF(@MediaStreamVal='CIR')
							BEGIN
								-------Updating  OccurrenceDetails for Circular --------------------  
								BEGIN					
									UPDATE [OccurrenceDetailCIR] SET [AdID] = @SurvivingAdid
									where [OccurrenceDetailCIRID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist)) 
									--Print N'OccurrenceDetailsCIR Updated'
								END
								-------Updating  PatternMaster for Circular --------------------  
								BEGIN
									UPDATE [Pattern] SET [AdID] = @SurvivingAdid FROM [OccurrenceDetailCIR] a, [Pattern] b
									WHERE b.[PatternID] = a.[PatternID]
									AND a.[OccurrenceDetailCIRID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
									--Print N'PatternMaster Updated'
								END
								-------Updating  CreativeMaster for Circular --------------------
								--Updating Creative Master if PrimaryIndicator is No

								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid
									FROM [Creative] a, [OccurrenceDetailCIR] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]
									AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 0
									AND b.[OccurrenceDetailCIRID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
									--Print N'CreativeMaster Updated 1'	
								END
								--Updating Creative Master if PrimaryIndicator is Yes
								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid,PrimaryIndicator=0
									FROM [Creative] a, [OccurrenceDetailCIR] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]  AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 1
									AND b.[OccurrenceDetailCIRID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
									--Print N'CreativeMaster Updated 2'
								END

								--Checking OccurrenceDetailsCIR for ChildOccurrence---
								IF Not Exists(Select 1 from [OccurrenceDetailCIR] where [OccurrenceDetailCIR].[AdID]=@NonSurvivingAdid)
										BEGIN
											--Print N'Child Occurrence'
											Print(@NonSurvivingAdid)
												--if not found make ad notakereason is duplicate
												UPDATE Ad SET NoTakeAdReason = @NoTakeReason WHERE Ad.[AdID] = @NonSurvivingAdid
										END
								ELSE
										BEGIN
											--Checking ad PrimaryOccurrence is not found in OccurrenceDetailsCIR 
											IF Not Exists(Select 1 from [OccurrenceDetailCIR] ocr,Ad a  where a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailCIRID] and a.[AdID]=ocr.[AdID] and a.[AdID]=@NonSurvivingAdid)
												BEGIN
													

													set @PrimaryOccrnceID= (Select Min(b.[OccurrenceDetailCIRID])  FROM Ad a, [OccurrenceDetailCIR] b
													WHERE a.[AdID] = @NonSurvivingAdid AND b.[AdID] = a.[AdID] AND b.NoTakeReason IS NULL --group by b.PK_OccurrenceID
														)

													UPDATE Ad SET [PrimaryOccurrenceID] = @PrimaryOccrnceID WHERE Ad.[AdID] = @NonSurvivingAdid 
													--Print N'Primary Occurrence'
													--Print(@PrimaryOccrnceID)
											
											END
											--Checking if PrimaryCreative Indicator is yes 
											IF Not Exists(Select 1 from ad a inner join [OccurrenceDetailCIR] ocr on a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailCIRID] inner join [Pattern] p on ocr.[PatternID]=p.[PatternID] 
															inner join [Creative] c on p.[CreativeID]=c.PK_Id
															where a.[AdID]=@NonSurvivingAdid and c.PrimaryIndicator=1)
												BEGIN
														UPDATE [Creative] SET PrimaryIndicator = 1 FROM [Creative] a, [OccurrenceDetailCIR] b,[Pattern] c,Ad
														WHERE ad.[PrimaryOccurrenceID]=b.[OccurrenceDetailCIRID] and  c.[PatternID] = b.[PatternID]
														AND a.PK_Id = c.[CreativeID] and a.PK_Id=@NonSurvivingAdid	
												END
								END
						
								----Updating Ad of Surviving Ad with OccurrenceDetailsCIR--
								

								Select @FirstRunDate=[OccurrenceDetailCIR].AdDate,@FirstRunMarket=[OccurrenceDetailCIR].[MarketID] 
								from [OccurrenceDetailCIR] inner join ad on [OccurrenceDetailCIR].[AdID]=ad.[AdID]
								where [OccurrenceDetailCIR].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailCIR].AdDate,[OccurrenceDetailCIR].[MarketID],Ad.FirstRunDate
								Having Min([OccurrenceDetailCIR].AdDate)<=(Ad.FirstRunDate)

								Select @LastRunDate=[OccurrenceDetailCIR].AdDate
								from [OccurrenceDetailCIR] inner join ad on [OccurrenceDetailCIR].[AdID]=ad.[AdID]
								where [OccurrenceDetailCIR].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailCIR].AdDate,Ad.FirstRunDate
								Having Max([OccurrenceDetailCIR].AdDate)>=(Ad.FirstRunDate)

								--Print N'Last Run Date'
								--Print(@FirstRunDate)
								--Print(@FirstRunMarket)
								--Print(@LastRunDate)

								--Updating Serviving Ad with Firstrundate and lastrundate,first run market
								Update Ad  Set Ad.FirstRunDate=@FirstRunDate,ad.[FirstRunMarketID]=@FirstRunMarket,Ad.LastRunDate=@LastRunDate where Ad.[AdID]=@SurvivingAdid
				
								set @IsSplitOccurrence=1	 
						   END
						
						--Publication
						IF(@MediaStreamVal='PUB')
							BEGIN
								-------Updating  OccurrenceDetails for Publication --------------------  
								BEGIN					
									UPDATE [OccurrenceDetailPUB] SET [AdID] = @SurvivingAdid
									where [OccurrenceDetailPUBID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist)) 

							
								END
								-------Updating  PatternMaster for Publication --------------------  
								BEGIN
									UPDATE [Pattern] SET [AdID] = @SurvivingAdid FROM [OccurrenceDetailPUB] a, [Pattern] b
									WHERE b.[PatternID] = a.[PatternID]
									AND a.[OccurrenceDetailPUBID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
						
								END
								-------Updating  CreativeMaster for Publication --------------------
								--Updating Creative Master if PrimaryIndicator is No

								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid
									FROM [Creative] a, [OccurrenceDetailPUB] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]
									AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 0
									AND b.[OccurrenceDetailPUBID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))	
								END
								--Updating Creative Master if PrimaryIndicator is Yes
								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid,PrimaryIndicator=0
									FROM [Creative] a, [OccurrenceDetailPUB] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]  AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 1
									AND b.[OccurrenceDetailPUBID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
								END

								--Checking OccurrenceDetailsCIR for ChildOccurrence---
								IF Not Exists(Select 1 from [OccurrenceDetailPUB] where [OccurrenceDetailPUB].[AdID]=@NonSurvivingAdid)
										BEGIN
												--if not found make ad notakereason is duplicate
												UPDATE Ad SET NoTakeAdReason = @NoTakeReason WHERE Ad.[AdID] = @NonSurvivingAdid
										END
								ELSE
										BEGIN
											--Checking ad PrimaryOccurrence is not found in OccurrenceDetailsPUB 
											IF Not Exists(Select 1 from [OccurrenceDetailPUB] ocr,Ad a  where a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailPUBID] and a.[AdID]=ocr.[AdID] and a.[AdID]=@NonSurvivingAdid)
												BEGIN
													

													set @PrimaryOccrnceID= (Select Min(b.[OccurrenceDetailPUBID])  FROM Ad a, [OccurrenceDetailPUB] b
													WHERE a.[AdID] = @NonSurvivingAdid AND b.[AdID] = a.[AdID] AND b.NoTakeReason IS NULL)

													UPDATE Ad SET [PrimaryOccurrenceID] = @PrimaryOccrnceID WHERE Ad.[AdID] = @NonSurvivingAdid 
											
											END
											--Checking if PrimaryCreative Indicator is yes 
											IF Not Exists(Select 1 from ad a inner join [OccurrenceDetailPUB] ocr on a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailPUBID] inner join [Pattern] p on ocr.[PatternID]=p.[PatternID] 
															inner join [Creative] c on p.[CreativeID]=c.PK_Id
															where a.[AdID]=@NonSurvivingAdid and c.PrimaryIndicator=1)
												BEGIN
														UPDATE [Creative] SET PrimaryIndicator = 1 FROM [Creative] a, [OccurrenceDetailPUB] b,[Pattern] c,Ad
														WHERE ad.[PrimaryOccurrenceID]=b.[OccurrenceDetailPUBID] and  c.[PatternID] = b.[PatternID]
														AND a.PK_Id = c.[CreativeID] and a.PK_Id=@NonSurvivingAdid	
												END
								END
						
								----Updating Ad of Surviving Ad with OccurrenceDetailsPUB--
								

								Select @FirstRunDate=[OccurrenceDetailPUB].[AdDT],@FirstRunMarket=[OccurrenceDetailPUB].[MarketID] 
								from [OccurrenceDetailPUB] inner join ad on [OccurrenceDetailPUB].[AdID]=ad.[AdID]
								where [OccurrenceDetailPUB].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailPUB].[AdDT],[OccurrenceDetailPUB].[MarketID],Ad.FirstRunDate
								Having Min([OccurrenceDetailPUB].[AdDT])<=(Ad.FirstRunDate)

								Select @LastRunDate=[OccurrenceDetailPUB].[AdDT]
								from [OccurrenceDetailPUB] inner join ad on [OccurrenceDetailPUB].[AdID]=ad.[AdID]
								where [OccurrenceDetailPUB].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailPUB].[AdDT],Ad.FirstRunDate
								Having Max([OccurrenceDetailPUB].[AdDT])>=(Ad.FirstRunDate)

								--Updating Serviving Ad with Firstrundate and lastrundate,first run market
								Update Ad  Set Ad.FirstRunDate=@FirstRunDate,ad.[FirstRunMarketID]=@FirstRunMarket,Ad.LastRunDate=@LastRunDate where Ad.[AdID]=@SurvivingAdid
								set @IsSplitOccurrence=1	 
						   END

						--Email
						IF(@MediaStreamVal='EM')
							BEGIN
								-------Updating  OccurrenceDetails for Email --------------------  
								BEGIN					
									UPDATE [OccurrenceDetailEM] SET [AdID] = @SurvivingAdid
									where [OccurrenceDetailEMID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist)) 
							
								END
								-------Updating  PatternMaster for Email --------------------  
								BEGIN
									UPDATE [Pattern] SET [AdID] = @SurvivingAdid FROM [OccurrenceDetailEM] a, [Pattern] b
									WHERE b.[PatternID] = a.[PatternID]
									AND a.[OccurrenceDetailEMID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
						
								END
								-------Updating  CreativeMaster for Email --------------------
								--Updating Creative Master if PrimaryIndicator is No

								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid
									FROM [Creative] a, [OccurrenceDetailEM] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]
									AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 0
									AND b.[OccurrenceDetailEMID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))	
								END
								--Updating Creative Master if PrimaryIndicator is Yes
								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid,PrimaryIndicator=0
									FROM [Creative] a, [OccurrenceDetailEM] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]  AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 1
									AND b.[OccurrenceDetailEMID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
								END

								--Checking OccurrenceDetailsEM for ChildOccurrence---
								IF Not Exists(Select 1 from [OccurrenceDetailEM] where [OccurrenceDetailEM].[AdID]=@NonSurvivingAdid)
										BEGIN
												--if not found make ad notakereason is duplicate
												UPDATE Ad SET NoTakeAdReason = @NoTakeReason WHERE Ad.[AdID] = @NonSurvivingAdid
										END
								ELSE
										BEGIN
											--Checking ad PrimaryOccurrence is not found in OccurrenceDetailsEM 
											IF Not Exists(Select 1 from [OccurrenceDetailEM] ocr,Ad a  where a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailEMID] and a.[AdID]=ocr.[AdID] and a.[AdID]=@NonSurvivingAdid)
												BEGIN
													

													set @PrimaryOccrnceID= (Select Min(b.[OccurrenceDetailEMID])  FROM Ad a, [OccurrenceDetailEM] b
													WHERE a.[AdID] = @NonSurvivingAdid AND b.[AdID] = a.[AdID] AND b.NoTakeReason IS NULL)

													UPDATE Ad SET [PrimaryOccurrenceID] = @PrimaryOccrnceID WHERE Ad.[AdID] = @NonSurvivingAdid 
											
											END
											--Checking if PrimaryCreative Indicator is yes 
											IF Not Exists(Select 1 from ad a inner join [OccurrenceDetailEM] ocr on a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailEMID] inner join [Pattern] p on ocr.[PatternID]=p.[PatternID] 
															inner join [Creative] c on p.[CreativeID]=c.PK_Id
															where a.[AdID]=@NonSurvivingAdid and c.PrimaryIndicator=1)
												BEGIN
														UPDATE [Creative] SET PrimaryIndicator = 1 FROM [Creative] a, [OccurrenceDetailEM] b,[Pattern] c,Ad
														WHERE ad.[PrimaryOccurrenceID]=b.[OccurrenceDetailEMID] and  c.[PatternID] = b.[PatternID]
														AND a.PK_Id = c.[CreativeID] and a.PK_Id=@NonSurvivingAdid	
												END
								END
						
								----Updating Ad of Surviving Ad with OccurrenceDetailsEM--
								

								Select @FirstRunDate=[OccurrenceDetailEM].[AdDT],@FirstRunMarket=[OccurrenceDetailEM].[MarketID] 
								from [OccurrenceDetailEM] inner join ad on [OccurrenceDetailEM].[AdID]=ad.[AdID]
								where [OccurrenceDetailEM].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailEM].[AdDT],[OccurrenceDetailEM].[MarketID],Ad.FirstRunDate
								Having Min([OccurrenceDetailEM].[AdDT])<=(Ad.FirstRunDate)

								Select @LastRunDate=[OccurrenceDetailEM].[AdDT]
								from [OccurrenceDetailEM] inner join ad on [OccurrenceDetailEM].[AdID]=ad.[AdID]
								where [OccurrenceDetailEM].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailEM].[AdDT],Ad.FirstRunDate
								Having Max([OccurrenceDetailEM].[AdDT])>=(Ad.FirstRunDate)

								--Updating Serviving Ad with Firstrundate and lastrundate,first run market
								Update Ad  Set Ad.FirstRunDate=@FirstRunDate,ad.[FirstRunMarketID]=@FirstRunMarket,Ad.LastRunDate=@LastRunDate where Ad.[AdID]=@SurvivingAdid
				
								set @IsSplitOccurrence=1	 
						   END

						--Social
						IF(@MediaStreamVal='SOC')
							BEGIN
								-------Updating  OccurrenceDetails for Social --------------------  
								BEGIN					
									UPDATE [OccurrenceDetailSOC] SET [AdID] = @SurvivingAdid
									where [OccurrenceDetailSOCID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist)) 

							
								END
								-------Updating  PatternMaster for Social --------------------  
								BEGIN
									UPDATE [Pattern] SET [AdID] = @SurvivingAdid FROM [OccurrenceDetailSOC] a, [Pattern] b
									WHERE b.[PatternID] = a.[PatternID]
									AND a.[OccurrenceDetailSOCID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
						
								END
								-------Updating  CreativeMaster for Social --------------------
								--Updating Creative Master if PrimaryIndicator is No

								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid
									FROM [Creative] a, [OccurrenceDetailSOC] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]
									AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 0
									AND b.[OccurrenceDetailSOCID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))	
								END
								--Updating Creative Master if PrimaryIndicator is Yes
								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid,PrimaryIndicator=0
									FROM [Creative] a, [OccurrenceDetailSOC] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]  AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 1
									AND b.[OccurrenceDetailSOCID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
								END

								--Checking OccurrenceDetailsSOC for ChildOccurrence---
								IF Not Exists(Select 1 from [OccurrenceDetailSOC] where [OccurrenceDetailSOC].[AdID]=@NonSurvivingAdid)
										BEGIN
												--if not found make ad notakereason is duplicate
												UPDATE Ad SET NoTakeAdReason = @NoTakeReason WHERE Ad.[AdID] = @NonSurvivingAdid
										END
								ELSE
										BEGIN
											--Checking ad PrimaryOccurrence is not found in OccurrenceDetailsSOC 
											IF Not Exists(Select 1 from [OccurrenceDetailSOC] ocr,Ad a  where a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailSOCID] and a.[AdID]=ocr.[AdID] and a.[AdID]=@NonSurvivingAdid)
												BEGIN
													

													set @PrimaryOccrnceID= (Select Min(b.[OccurrenceDetailSOCID])  FROM Ad a, [OccurrenceDetailSOC] b
													WHERE a.[AdID] = @NonSurvivingAdid AND b.[AdID] = a.[AdID] AND b.NoTakeReason IS NULL)

													UPDATE Ad SET [PrimaryOccurrenceID] = @PrimaryOccrnceID WHERE Ad.[AdID] = @NonSurvivingAdid 
											
											END
											--Checking if PrimaryCreative Indicator is yes 
											IF Not Exists(Select 1 from ad a inner join [OccurrenceDetailSOC] ocr on a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailSOCID] inner join [Pattern] p on ocr.[PatternID]=p.[PatternID] 
															inner join [Creative] c on p.[CreativeID]=c.PK_Id
															where a.[AdID]=@NonSurvivingAdid and c.PrimaryIndicator=1)
												BEGIN
														UPDATE [Creative] SET PrimaryIndicator = 1 FROM [Creative] a, [OccurrenceDetailSOC] b,[Pattern] c,Ad
														WHERE ad.[PrimaryOccurrenceID]=b.[OccurrenceDetailSOCID] and  c.[PatternID] = b.[PatternID]
														AND a.PK_Id = c.[CreativeID] and a.PK_Id=@NonSurvivingAdid	
												END
								END
						
								----Updating Ad of Surviving Ad with OccurrenceDetailsSOC--
								

								Select @FirstRunDate=[OccurrenceDetailSOC].[AdDT],@FirstRunMarket=[OccurrenceDetailSOC].[MarketID] 
								from [OccurrenceDetailSOC] inner join ad on [OccurrenceDetailSOC].[AdID]=ad.[AdID]
								where [OccurrenceDetailSOC].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailSOC].[AdDT],[OccurrenceDetailSOC].[MarketID],Ad.FirstRunDate
								Having Min([OccurrenceDetailSOC].[AdDT])<=(Ad.FirstRunDate)

								Select @LastRunDate=[OccurrenceDetailSOC].[AdDT]
								from [OccurrenceDetailSOC] inner join ad on [OccurrenceDetailSOC].[AdID]=ad.[AdID]
								where [OccurrenceDetailSOC].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailSOC].[AdDT],Ad.FirstRunDate
								Having Max([OccurrenceDetailSOC].[AdDT])>=(Ad.FirstRunDate)

								--Updating Serviving Ad with Firstrundate and lastrundate,first run market
								Update Ad  Set Ad.FirstRunDate=@FirstRunDate,ad.[FirstRunMarketID]=@FirstRunMarket,Ad.LastRunDate=@LastRunDate where Ad.[AdID]=@SurvivingAdid
								set @IsSplitOccurrence=1	 
						   END

						--Website
						IF(@MediaStreamVal='WEB')
							BEGIN
								-------Updating  OccurrenceDetails for Website --------------------  
								BEGIN					
									UPDATE [OccurrenceDetailWEB] SET [AdID] = @SurvivingAdid
									where [OccurrenceDetailWEBID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist)) 
							
								END
								-------Updating  PatternMaster for Website --------------------  
								BEGIN
									UPDATE [Pattern] SET [AdID] = @SurvivingAdid FROM [OccurrenceDetailWEB] a, [Pattern] b
									WHERE b.[PatternID] = a.[PatternID]
									AND a.[OccurrenceDetailWEBID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
						
								END
								-------Updating  CreativeMaster for Website --------------------
								--Updating Creative Master if PrimaryIndicator is No

								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid
									FROM [Creative] a, [OccurrenceDetailWEB] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]
									AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 0
									AND b.[OccurrenceDetailWEBID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))	
								END
								--Updating Creative Master if PrimaryIndicator is Yes
								BEGIN
									UPDATE [Creative] SET [AdId] = @SurvivingAdid,PrimaryIndicator=0
									FROM [Creative] a, [OccurrenceDetailWEB] b, [Pattern] c
									WHERE a.CreativeType = 'Original' OR 	a.CreativeType =Null 
									AND c.[PatternID] = b.[PatternID]  AND a.PK_Id = c.[CreativeID]
									AND a.PrimaryIndicator = 1
									AND b.[OccurrenceDetailWEBID] in (Select Id from [dbo].[fn_CSVToTable](@Occurrencelist))
								END

								--Checking OccurrenceDetailsWEB for ChildOccurrence---
								IF Not Exists(Select 1 from [OccurrenceDetailWEB] where [OccurrenceDetailWEB].[AdID]=@NonSurvivingAdid)
										BEGIN
												--if not found make ad notakereason is duplicate
												UPDATE Ad SET NoTakeAdReason = @NoTakeReason WHERE Ad.[AdID] = @NonSurvivingAdid
										END
								ELSE
										BEGIN
											--Checking ad PrimaryOccurrence is not found in OccurrenceDetailsWEB 
											IF Not Exists(Select 1 from [OccurrenceDetailWEB] ocr,Ad a  where a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailWEBID] and a.[AdID]=ocr.[AdID] and a.[AdID]=@NonSurvivingAdid)
												BEGIN
													

													set @PrimaryOccrnceID= (Select Min(b.[OccurrenceDetailWEBID])  FROM Ad a, [OccurrenceDetailWEB] b
													WHERE a.[AdID] = @NonSurvivingAdid AND b.[AdID] = a.[AdID] AND b.NoTakeReason IS NULL)

													UPDATE Ad SET [PrimaryOccurrenceID] = @PrimaryOccrnceID WHERE Ad.[AdID] = @NonSurvivingAdid 
											
											END
											--Checking if PrimaryCreative Indicator is yes 
											IF Not Exists(Select 1 from ad a inner join [OccurrenceDetailWEB] ocr on a.[PrimaryOccurrenceID]=ocr.[OccurrenceDetailWEBID] inner join [Pattern] p on ocr.[PatternID]=p.[PatternID] 
															inner join [Creative] c on p.[CreativeID]=c.PK_Id
															where a.[AdID]=@NonSurvivingAdid and c.PrimaryIndicator=1)
												BEGIN
														UPDATE [Creative] SET PrimaryIndicator = 1 FROM [Creative] a, [OccurrenceDetailWEB] b,[Pattern] c,Ad
														WHERE ad.[PrimaryOccurrenceID]=b.[OccurrenceDetailWEBID] and  c.[PatternID] = b.[PatternID]
														AND a.PK_Id = c.[CreativeID] and a.PK_Id=@NonSurvivingAdid	
												END
								END
						
								----Updating Ad of Surviving Ad with OccurrenceDetailsWEB--
								

								Select @FirstRunDate=[OccurrenceDetailWEB].[AdDT],@FirstRunMarket=[OccurrenceDetailWEB].[MarketID] 
								from [OccurrenceDetailWEB] inner join ad on [OccurrenceDetailWEB].[AdID]=ad.[AdID]
								where [OccurrenceDetailWEB].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailWEB].[AdDT],[OccurrenceDetailWEB].[MarketID],Ad.FirstRunDate
								Having Min([OccurrenceDetailWEB].[AdDT])<=(Ad.FirstRunDate)

								Select @LastRunDate=[OccurrenceDetailWEB].[AdDT]
								from [OccurrenceDetailWEB] inner join ad on [OccurrenceDetailWEB].[AdID]=ad.[AdID]
								where [OccurrenceDetailWEB].[AdID]=@SurvivingAdid 
								group by [OccurrenceDetailWEB].[AdDT],Ad.FirstRunDate
								Having Max([OccurrenceDetailWEB].[AdDT])>=(Ad.FirstRunDate)

								--Updating Serviving Ad with Firstrundate and lastrundate,first run market
								Update Ad  Set Ad.FirstRunDate=@FirstRunDate,ad.[FirstRunMarketID]=@FirstRunMarket,Ad.LastRunDate=@LastRunDate where Ad.[AdID]=@SurvivingAdid
				
								set @IsSplitOccurrence=1	 
						   END
						
				END
				ELSE
				BEGIN
					SET @IsSplitOccurrence=0
				END

				Select @IsSplitOccurrence as Status

				COMMIT TRANSACTION
 			END TRY 
			BEGIN CATCH 
						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('sp_MergeUpdateSplitOccurrence: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 
   
END