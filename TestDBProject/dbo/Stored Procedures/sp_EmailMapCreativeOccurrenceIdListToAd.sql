

-- ====================================================================================================================== 
-- Author			: Karunakar
-- Create date		: 06th July 2015
-- Description		: This Procedure is Used to Mapping  on Ad to CreativeSignature
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--					  Arun Nair on 09/02/2015 -Added CreateBy,ModifiedBy,Update CreativeSignature in PatternMaster
--					  Arun Nair on 10/12/2015 - Append Description with MODReason
--					:Mark Marshall modify to make update for staging Tables
--					: Lisa East modify to stop the update of PatternID remains constant for occurence mappings
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[sp_EmailMapCreativeOccurrenceIdListToAd] 
(
 @Description       AS NVARCHAR(max), 
 @RecutDetail       AS NVARCHAR(max), 
 @Adid              INT, 
 @OccurrenceID AS Nvarchar(max),
 @UserID            AS INT
) 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 

  BEGIN 
      SET nocount ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 

			DECLARE @SingleOccurrenceID AS INT=0 
			DECLARE @RecordsCount AS INTEGER
			DECLARE @CreativeMasterID AS INT=0 
			DECLARE @PatternMasterID AS INT=0 
			DECLARE @CreativeStagingID AS INT=0           
			DECLARE @NumberRecords AS INT=0 
			DECLARE @RowCount AS INT=0 
			DECLARE @MediaStream AS INT=0 
			DECLARE @Counter AS INTEGER
			DECLARE @PrimaryParentOccurrenceID as NVARCHAR(Max)

				  SELECT @mediastream = configurationid FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'media stream' AND valuetitle = 'Email' 

				  PRINT( 'Mediastream - ' + Cast(@mediastream AS VARCHAR) ) 

				 DECLARE @TableOccurrence
						TABLE (			
								ID INT IDENTITY(1,1),			
								OccurrenceIDTemp NVARCHAR(MAX) NOT NULL
							  )	

				INSERT INTO @TableOccurrence(OccurrenceIDTemp)
				SELECT ITEM From SplitString(''+@OccurrenceID+'',',')


				SET @PrimaryParentOccurrenceID=(SELECT OccurrenceIDTemp from @TableOccurrence WHERE ID=1)

				PRINT(@PrimaryParentOccurrenceID)

				SELECT * from @TableOccurrence
				SELECT @RecordsCount =Count(OccurrenceIDTemp) FROM @TableOccurrence		

					SET @Counter=1
					WHILE @Counter<=@RecordsCount
					BEGIN 
						SELECT @SingleOccurrenceID=OccurrenceIDTemp FROM @TableOccurrence WHERE ID =@Counter

						DECLARE @primaryOccurrenceID AS INTEGER 

						SELECT @primaryOccurrenceID = @SingleOccurrenceID
						PRINT ( 'primaryoccurrenceid-' + Cast(@primaryOccurrenceID AS VARCHAR) ) 

						IF EXISTS(SELECT * FROM   [CreativeStaging]  WHERE  [OccurrenceID] = @primaryOccurrenceID) ---Mapped creative details moved from staging 
						BEGIN 
							--- Get data from [CREATIVEMASTER]  
							INSERT INTO [Creative] 
							([AdId], 
							[SourceOccurrenceId], 
							CheckInOccrncs, 
							PrimaryIndicator) 
							SELECT @ADID, 
							@primaryOccurrenceID, 
							1, 
							0 

							PRINT( 'creativemaster - inserted' ) 

							SELECT @CreativeMasterID = Scope_identity() 

							PRINT( 'creativemaster id-'  + Cast(@CreativeMasterID AS VARCHAR) ) 

							---Get data from [CREATIVEMASTERSTAGING]
				
							SELECT distinct @CreativeStagingID = [CreativeStaging].[CreativeStagingID]  
							FROM   [CreativeStaging] 
							inner join [CreativeDetailStagingEM] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingEM].CreativeStagingID 
							WHERE [CreativeStaging].[OccurrenceID] = @primaryOccurrenceID
				  
               
							INSERT INTO creativedetailEM 
							(creativemasterid, 
							creativeassetname, 
							creativerepository, 
							legacyassetname, 
							creativefiletype,Deleted,PageNumber,PageTypeId) 
							SELECT @CreativeMasterID, 
							[CreativeAssetName], 
							[CreativeRepository], 
							'', 
							[CreativeFileType],Deleted,PageNumber,PageTypeId 
							FROM   [CreativeDetailStagingEM]
							WHERE  [CreativeStagingID]= @CreativeStagingID  

							PRINT ( 'creativedetailsEM - inserted' ) 
						END 

         
						---Get Pattern ID into @PatternMasterID from [PATTERNSTAGING] used for OccuranceDetailEM update as well 
			
						SELECT @PatternMasterID=PatternID FROM [dbo].[PatternStaging] WHERE  CreativeStgID = @CreativeStagingID
						--L.E. on 1/31/2017
						IF EXISTS (SELECT TOP 1 * FROM PATTERN WHERE PATTERNID=@PatternMasterID) --IF PATTERN ALREADY EXIST UPDATE, IF NOT INSERT FOR NEW ADS FROM STAGING
						BEGIN 
							UPDATE [Pattern]  
							SET [CreativeID]=@CreativeMasterID, [AdID]=@adid, MediaStream=@MediaStream, [Pattern].[Exception]=[PatternStaging].[Exception],
								[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid',
								ModifiedBy=NULL, ModifyDate=NULL,LastMappedDate=GetDate(),LastMapperInits=@userID
							FROM [Pattern]  
							INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
							WHERE [Pattern].PatternID =@PatternMasterID
						END 
						ELSE 
						BEGIN 
							INSERT INTO [Pattern] 
							([CreativeID], 
							[AdID], 
							MediaStream, 
							[Exception],  
							[Query], 
							[Status], 
							CreateBy,
							CreateDate,
							ModifiedBy, 
							ModifyDate) 
							SELECT @CreativeMasterID, 
							@adid, 
							@MediaStream, 
							[Exception], 
							[Query],  
							'Valid',                          -- Status Value HardCoded
							@UserId,
							Getdate(), 
							NULL,
							NULL
							FROM   [dbo].[PatternStaging] 
							WHERE  creativestgid = @CreativeStagingID
				
							PRINT( 'patternmaster - inserted' ) 

							SET @PatternMasterID=Scope_identity();  --get new patternid
						END

						PRINT( 'patternmasterid-' + Cast(@PatternMasterID AS VARCHAR) ) 
						PRINT( 'OccurrenceID-' + Cast(@SingleOccurrenceId AS VARCHAR) ) 		   
						print ('executed')



						IF EXISTS (SELECT TOP 1 * FROM [dbo].[OccurrenceDetailEM]  WHERE [OccurrenceDetailEMID] = @SingleOccurrenceID  AND [AdID] IS NOT NULL) --ADID IS NOT NULL, REMAP AND LEAVE PATTERN DETAILS 
						BEGIN 
												-- for Review Remap 
							UPDATE [dbo].[OccurrenceDetailEM] 
							SET   [AdID] = @AdID 
							WHERE  [OccurrenceDetailEMID] = @SingleOccurrenceID  

							UPDATE [Pattern] 
							SET [Pattern].ADID=@AdID
							FROM [OccurrenceDetailEM]  
							INNER JOIN [Pattern]  ON [Pattern].PATTERNID=[OccurrenceDetailEM].PATTERNID
							WHERE [OccurrenceDetailEM].[OccurrenceDetailEMID] = @SingleOccurrenceID 

							UPDATE [Creative] 
							SET [Creative].ADID=@AdID
							FROM [OccurrenceDetailEM] 
							INNER JOIN [Creative]  ON [Creative].SOURCEOCCURRENCEID=[OccurrenceDetailEM].[OccurrenceDetailEMID] 							
							WHERE [OccurrenceDetailEM].[OccurrenceDetailEMID] = @SingleOccurrenceID 
						END
						ELSE
						BEGIN 													----Update PatternMasterID and Ad in the OCCURRENCEDETAILEM Table	
							UPDATE [dbo].[OccurrenceDetailEM] 
							SET   [AdID] = @AdID, [PatternID] = @PatternMasterID
							WHERE  [OccurrenceDetailEMID] = @SingleOccurrenceID  
						END


						-- update QueryDetail
						UPDATE [QueryDetail]
						SET [PatternMasterId] = @PatternMasterID, [PatternStgId] = null
						WHERE [PatternStgId] = (select [PatternStagingId] from [PatternStaging] where [PatternId] = @PatternMasterID)

						--Remove record from PatternDetailsRAStaging and CreativeDetailsRAStaging which are moved to PatternMaster and CreativeMaster 						
						DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
						DELETE FROM [dbo].[CreativeDetailStagingEM] WHERE CreativeStagingID = @CreativeStagingID 
						DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

						-- Update Occurrence in Ad Table  
						UPDATE Ad 
						SET    [PrimaryOccurrenceID] = @primaryOccurrenceID 
						WHERE  [AdID] = @AdID 
						AND [PrimaryOccurrenceID] IS NULL 

      
						-- PRINT( @mtoreason) 

						IF @Description<>''
						BEGIN  
						UPDATE Ad SET    description =description+','+ @Description  WHERE  [AdID] = @AdID
						END 
						IF @RecutDetail<>''
						BEGIN  
						UPDATE Ad SET    RecutDetail =recutdetail+','+@RecutDetail  WHERE  [AdID] = @AdID
						END 


						if not exists(select 1 from [Creative] where [AdId]=@adid and PrimaryIndicator=1)
						begin
						-- updated creativemaster primary indicator
						update [Creative] set PrimaryIndicator=1 where [AdId]=@adid	and [SourceOccurrenceId]=@primaryOccurrenceID	
						end
						SET @Counter=@Counter+1
					END	
          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
          RAISERROR ('[sp_EmailMapOccurrenceToAd]: %d: %s',16,1,@error,  @message ,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END