


-- =======================================================================================================================================  

-- Author		: RP    
-- Create date  : May 30, 2015   
-- Description  : Process Scanned Files 
-- Updated By	: Arun Nair on 18/06/2015 - Changes for Publication 
--				: Karunakar on 08/17/2015 - Changes Based on Clean Up of ONE MT DB Creative and Pattern Master 
--				: Arun Nair on 08/25/2015 - Changes in OccurrenceID DataType,Seed Value 
--				  Arun Nair on 11/11/2015 - Changes for Website 
--				  Arun Nair on 26/11/2015 - Changes for Social 
--=========================================================================================================================================    

CREATE PROCEDURE [dbo].[sp_ProcessScanData]
 (
@parameter   AS XML, 
@basePath    AS VARCHAR(500), 
@mediaStream AS VARCHAR(50)
) 
AS 
  BEGIN 
      SET NOCOUNT ON 
      BEGIN TRANSACTION 

      BEGIN TRY 

          DECLARE @Index AS INT=0 
          DECLARE @NumberRecords AS INT=0 
          DECLARE @ID AS INT=0 
          DECLARE @OccurrenceiD AS BIGINT=0 
          DECLARE @OldImageName AS NVARCHAR(max)=''
          DECLARE @PageNumber AS INT=0 
          DECLARE @OldPath AS NVARCHAR(max)='' 
          DECLARE @RecordStatus AS VARCHAR(max)='' 
          DECLARE @FileType AS VARCHAR(max)='' 
          DECLARE @NewPath AS VARCHAR(max)='' 
          DECLARE @NewImageName AS VARCHAR(max)='' 
          DECLARE @CreativeMasterID AS INT=0 
          DECLARE @CreativeDetailsCIRID AS INT=0 
          DECLARE @CreativeDetailsPUBID AS INT=0 
          DECLARE @CreativeDetailsEMID AS INT=0 
		  DECLARE @CreativeDetailsWEBID AS INT=0 
		  DECLARE @CreativeDetailsSOCID AS INT=0 
          DECLARE @IsvalidOccurrenceID AS BIT 
          DECLARE @ExistingCreativeMaster AS BIT 
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @CaseStatus AS VARCHAR(20)='' 
          DECLARE @AdId AS INT=0 
          DECLARE @isprimary AS INT 



          -- Read XML and insert into Temporary table  

          SELECT scandata.value('(@ID)[1]', 'int')                     AS [ID], 
                 scandata.value('(@OccurrenceID)[1]', 'BIGINT')        AS [OccurrenceID],
                 scandata.value('(CreativeMasterID)[1]', 'int')        AS creativemasterid,
                 scandata.value('(@OldImageName)[1]', 'nvarchar(max)') AS [OldImageName], 
                 scandata.value('(@NewImageName)[1]', 'nvarchar(max)') AS [NewImagename], 
                 scandata.value('(@PageNumber)[1]', 'nvarchar(max)')   AS [PageNumber],
                 scandata.value('(@OldPath)[1]', 'nvarchar(max)')      AS [OldPath], 
                 scandata.value('(@RecordStatus)[1]', 'nvarchar(max)') AS [RecordStatus], 
                 scandata.value('(@FileType)[1]', 'nvarchar(max)')     AS [Filetype], 
                 scandata.value('(@NewPath)[1]', 'nvarchar(max)')      AS [NewPath] 
          INTO   #tempscandata 
          FROM   @parameter.nodes('ScanData/OccurrenceImage') AS scandataproc(scandata) 

          -- Iterate through temporary table  

          SELECT @NumberRecords = Count(*) FROM   #tempscandata 
		  
		  PRINT( @NumberRecords ) 

          SET @Index = 1 
		  
          WHILE @Index <= @NumberRecords 
								BEGIN 
									SELECT @id = [id],
										   @OccurrenceID = [occurrenceid], 
										   @CreativemasterID = [creativemasterid],
										   @OldImageName = oldimagename, 
										   @NewImagename = [newimagename], 
										   @PageNumber = [pagenumber], 
										   @OldPath = [oldpath], 
										   @RecordStatus = [recordstatus],
										   @Filetype = [filetype], 
										   @NewPath = [newpath] 
									FROM   #tempscandata 
									WHERE  id = @Index 


									-- Check for Pattern master for the occurrence  

									IF( @mediaStream = 'CIR' ) 
										  BEGIN 
											  SELECT @PatternMasterID = [PatternID] FROM   [OccurrenceDetailCIR] WHERE  [OccurrenceDetailCIRID] = @OccurrenceiD; 
										  END 
									ELSE IF ( @mediaStream = 'PUB' ) 
										  BEGIN 
											  SELECT @PatternMasterID = [PatternID] FROM   [OccurrenceDetailPUB] WHERE  [OccurrenceDetailPUBID] = @OccurrenceiD; 
										  END 
									ELSE IF ( @mediaStream = 'EM' ) 
										  BEGIN 
											  SELECT @PatternMasterID = [PatternID] FROM   [OccurrenceDetailEM] WHERE  [OccurrenceDetailEMID] = @OccurrenceiD; 
										  END 
									  ELSE IF ( @mediaStream = 'WEB' ) 
										  BEGIN 
											  SELECT @PatternMasterID = [PatternID]  FROM   [dbo].[OccurrenceDetailWEB] WHERE  [OccurrenceDetailWEBID] = @OccurrenceiD; 
										  END 
									  ELSE IF ( @mediaStream = 'SOC' ) 
										  BEGIN 
											  SELECT @PatternMasterID = [PatternID]  FROM   [dbo].[OccurrenceDetailSOC] WHERE  [OccurrenceDetailSOCID] = @OccurrenceiD; 
										  END 

									IF @Patternmasterid > 0 
									  BEGIN 
										  SET @IsvalidOccurrenceID=1 
									  END 
									ELSE 
									  BEGIN 
										  SET @IsvalidOccurrenceID=0 
									  END 



									IF EXISTS (SELECT 1  FROM   [Pattern] WHERE  [Pattern].[PatternID] = @PatternMasterID AND [CreativeID] IS NOT NULL) 
									  BEGIN 
										  -- Set Creative master  
										  SELECT @creativemasterid = [CreativeID] FROM   [Pattern]  WHERE  [Pattern].[PatternID] = @PatternMasterID 
										  SET @ExistingCreativeMaster=1 
									  END 
									ELSE 
									  BEGIN 
										  -- Creative master record does not exist 
										  SET @creativemasterid=0 
										  SET @ExistingCreativeMaster=0 
									  END 


									IF @IsvalidOccurrenceID = 1 AND @ExistingCreativeMaster = 0 
									  BEGIN 
										  IF @mediaStream = 'CIR' 
											BEGIN 
												SELECT @adid = [AdID]  FROM   [OccurrenceDetailCIR]  WHERE  [OccurrenceDetailCIRID] = @OccurrenceiD 
											END 
										  ELSE IF @mediastream = 'PUB' 
											BEGIN 
												SELECT @adid = [AdID]  FROM   [OccurrenceDetailPUB]  WHERE  [OccurrenceDetailPUBID] = @OccurrenceiD
											END 
										  ELSE IF @mediastream = 'EM' 
											BEGIN 
												SELECT @adid = [AdID]   FROM   [OccurrenceDetailEM]   WHERE  [OccurrenceDetailEMID] = @OccurrenceiD 
											END
										 ELSE IF @mediastream = 'WEB'
											BEGIN 
												SELECT @adid = [AdID]  FROM   [dbo].[OccurrenceDetailWEB] WHERE  [OccurrenceDetailWEBID] = @OccurrenceiD 
											END  
										 ELSE IF @mediastream = 'SOC'
											BEGIN 
												SELECT @adid = [AdID]  FROM   [dbo].[OccurrenceDetailSOC] WHERE  [OccurrenceDetailSOCID] = @OccurrenceiD 
											END  


										  IF EXISTS(SELECT 1 FROM   [Creative] WHERE  [AdId] = @adid AND primaryindicator = 1  AND [SourceOccurrenceId] IS NOT NULL) 
											BEGIN 
												SET @isPrimary=0 
											END 
										  ELSE 
											BEGIN 
											 SET @isprimary=1 
											END 

										  INSERT INTO [Creative]([AdId], [SourceOccurrenceId],primaryindicator, creativetype) 
										  VALUES      ( @adid,
														@OccurrenceiD, 
														@isprimary,
														@FileType 
													  ) 								  
										  SET @CreativemasterID=Scope_identity();
										  PRINT @creativemasterid 

										  -- Update pattern master with newly created creative master record  
										  UPDATE [Pattern] SET    [CreativeID] = @CreativemasterID  WHERE  [Pattern].[PatternID] = @PatternMasterID      AND [CreativeID] IS NULL 
									  END 
									ELSE IF @IsvalidOccurrenceID = 0 
									  BEGIN 
										  UPDATE #tempscandata   SET    recordstatus = 'Invalid Occurrence'    WHERE  id = @Index 
									  END 

									-- Check if creative detail record do not exists  CIRCULAR 

									IF @mediaStream = 'CIR' 
									   AND @IsvalidOccurrenceID = 1 
									  BEGIN 
										  IF NOT EXISTS(SELECT 1 FROM   creativedetailcir WHERE  creativemasterid = @CreativemasterID AND pagenumber = @PageNumber) 
											BEGIN 
												-- Insert new creativedetailCIR record 
												INSERT INTO creativedetailcir 
															(creativemasterid, 
															 creativeassetname,
															 creativerepository, 
															 creativefiletype, 
															 pagenumber, 
															 deleted) 
												VALUES      ( @CreativemasterID, 
															  @OldImageName,
															  @basePath, 
															  @FileType, 
															  @PageNumber, 
															  0 ) 

										SET @CreativeDetailsCIRID=Scope_identity(); 

										UPDATE creativedetailcir SET    creativeassetname = Cast(@CreativeDetailsCIRID AS VARCHAR) + '.' + @FileType,
												creativerepository = @mediaStream + '\'+ Cast(@CreativemasterID AS VARCHAR) + '\Original\', 
												creativefiletype = @FileType 
										WHERE  creativedetailid = @CreativeDetailsCIRID 


										UPDATE #tempscandata SET    creativemasterid = @CreativemasterID, 
												newimagename = Cast(@CreativeDetailsCIRID AS VARCHAR) + '.' + @FileType,
												newpath = @basePath + '\' + @mediaStream + '\' + Cast(@CreativemasterID AS VARCHAR) + '\Original\' + Cast(@CreativeDetailsCIRID AS VARCHAR) + '.' + @FileType, 
												recordstatus = 'Pending'   WHERE  id = @Index 
											END 
										  ELSE 
											BEGIN 
												SELECT @CreativeDetailsCIRID = creativedetailid FROM   creativedetailcir WHERE  creativemasterid = @CreativemasterID AND pagenumber = @PageNumber 
												UPDATE creativedetailcir SET    creativeassetname = Cast(@CreativeDetailsCIRID AS VARCHAR)

																		   + '.' + @FileType, 

													   creativerepository = @mediaStream + '\' 

																			+ Cast(@CreativemasterID AS VARCHAR) 

																			+ '\Original\', 

													   creativefiletype = @FileType 

												WHERE  creativedetailid = @CreativeDetailsCIRID 



												UPDATE #tempscandata 

												SET    creativemasterid = @CreativemasterID, 

													   newimagename = Cast(@CreativeDetailsCIRID AS VARCHAR) 

																	  + '.' + @FileType, 

													   newpath = @basePath + '\' + @mediaStream + '\' 

																 + Cast(@CreativemasterID AS VARCHAR) 

																 + '\Original\' 

																 + Cast(@CreativeDetailsCIRID AS VARCHAR) 

																 + '.' + @FileType, 

													   recordstatus = 'Pending' 

												WHERE  id = @Index 

											END 

									  END 



									-- Check if creative detail record do not exists  PUBLICATION 

									IF @mediaStream = 'PUB' 

									   AND @IsvalidOccurrenceID = 1 

									  BEGIN 

										  IF NOT EXISTS(SELECT 1 

														FROM   [dbo].[creativedetailpub] 

														WHERE  creativemasterid = @CreativemasterID 

															   AND pagenumber = @PageNumber) 

											BEGIN 

												-- Insert new creativedetailCIR record 

												INSERT INTO [dbo].[creativedetailpub] 

															(creativemasterid, 

															 creativeassetname, 

															 creativerepository, 

															 creativefiletype, 

															 pagenumber, 

															 deleted) 

												VALUES      ( @CreativemasterID, 

															  @OldImageName, 

															  @basePath, 

															  @FileType, 

															  @PageNumber, 

															  0 ) 



												SET @CreativeDetailsPUBID=Scope_identity(); 
												UPDATE [dbo].[creativedetailpub] 
												SET    creativeassetname = Cast(@CreativeDetailsPUBID AS VARCHAR)

																		   + '.' + @FileType, 

													   creativerepository = @mediaStream + '\' 

																			+ Cast(@CreativemasterID AS VARCHAR) 

																			+ '\Original\', 

													   creativefiletype = @FileType 

												WHERE  creativedetailid = @CreativeDetailsPUBID 



												UPDATE #tempscandata 

												SET    creativemasterid = @CreativemasterID, 

													   newimagename = Cast(@CreativeDetailsPUBID AS VARCHAR) 

																	  + '.' + @FileType, 

													   newpath = @basePath + '\' + @mediaStream + '\' 

																 + Cast(@CreativemasterID AS VARCHAR) 

																 + '\Original\' 

																 + Cast(@CreativeDetailsPUBID AS VARCHAR) 

																 + '.' + @FileType, 

													   recordstatus = 'Pending' 

												WHERE  id = @Index 

											END 

										  ELSE 

											BEGIN 

												SELECT @CreativeDetailsPUBID = creativedetailid 

												FROM   creativedetailpub 

												WHERE  creativemasterid = @CreativemasterID 

													   AND pagenumber = @PageNumber 



												UPDATE [dbo].[creativedetailpub] 

												SET    creativeassetname = Cast(@CreativeDetailsPUBID AS VARCHAR)

																		   + '.' + @FileType, 

													   creativerepository = @mediaStream + '\' 

																			+ Cast(@CreativemasterID AS VARCHAR) 

																			+ '\Original\', 

													   creativefiletype = @FileType 

												WHERE  creativedetailid = @CreativeDetailsPUBID 



												UPDATE #tempscandata 

												SET    creativemasterid = @CreativemasterID, 

													   newimagename = Cast(@CreativeDetailsPUBID AS VARCHAR) 

																	  + '.' + @FileType, 

													   newpath = @basePath + '\' + @mediaStream + '\' 

																 + Cast(@CreativemasterID AS VARCHAR) 

																 + '\Original\' 

																 + Cast(@CreativeDetailsPUBID AS VARCHAR) 

																 + '.' + @FileType, 

													   recordstatus = 'Pending' 

												WHERE  id = @Index 

											END 

									  END 



									---------------- 

									-- Check if creative detail record do not exists Email 

									IF @mediaStream = 'EM' 

									   AND @IsvalidOccurrenceID = 1 

									  BEGIN 

										  IF NOT EXISTS(SELECT 1 

														FROM   [dbo].[creativedetailem] 

														WHERE  creativemasterid = @CreativemasterID 

															   AND pagenumber = @PageNumber) 

											BEGIN 

												-- Insert new CreativeDetailEM record 

												INSERT INTO [dbo].[creativedetailem] 

															(creativemasterid, 

															 creativeassetname, 

															 creativerepository, 

															 creativefiletype, 

															 pagenumber, 

															 deleted,creativefiledate) 

												VALUES      ( @CreativemasterID, 

															  @OldImageName, 

															  @basePath, 

															  @FileType, 

															  @PageNumber, 

															  0,getdate() ) 



												SET @CreativeDetailsEMID=Scope_identity(); 



												UPDATE [dbo].[creativedetailem] 

												SET    creativeassetname = Cast(@CreativeDetailsEMID AS VARCHAR) 

																		   + '.' + @FileType, 

													   creativerepository = @mediaStream + '\' 

																			+ Cast(@CreativemasterID AS VARCHAR) 

																			+ '\Original\', 

													   creativefiletype = @FileType 

												WHERE  [CreativeDetailsEMID] = @CreativeDetailsEMID 



												UPDATE #tempscandata 

												SET    creativemasterid = @CreativemasterID, 

													   newimagename = Cast(@CreativeDetailsEMID AS VARCHAR) 

																	  + '.' + @FileType, 

													   newpath = @basePath + '\' + @mediaStream + '\' 

																 + Cast(@CreativemasterID AS VARCHAR) 

																 + '\Original\' 

																 + Cast(@CreativeDetailsEMID AS VARCHAR) 

																 + '.' + @FileType, 

													   recordstatus = 'Pending' 

												WHERE  id = @Index 

											END 

										  ELSE 

											BEGIN 

												SELECT @CreativeDetailsEMID = [CreativeDetailsEMID] 

												FROM   creativedetailem 

												WHERE  creativemasterid = @CreativemasterID 

													   AND pagenumber = @PageNumber 



												UPDATE [dbo].[creativedetailem] 

												SET    creativeassetname = Cast(@CreativeDetailsEMID AS VARCHAR) 

																		   + '.' + @FileType, 

													   creativerepository = @mediaStream + '\' 

																			+ Cast(@CreativemasterID AS VARCHAR) 

																			+ '\Original\', 

													   creativefiletype = @FileType ,

													   creativefiledate=getdate()

												WHERE  [CreativeDetailsEMID] = @CreativeDetailsEMID 



												UPDATE #tempscandata 

												SET    creativemasterid = @CreativemasterID, 

													   newimagename = Cast(@CreativeDetailsEMID AS VARCHAR) 

																	  + '.' + @FileType, 

													   newpath = @basePath + '\' + @mediaStream + '\' 

																 + Cast(@CreativemasterID AS VARCHAR) 

																 + '\Original\' 

																 + Cast(@CreativeDetailsEMID AS VARCHAR) 

																 + '.' + @FileType, 

													   recordstatus = 'Pending' 

												WHERE  id = @Index 

											END 

									  END 



									--------------------- 

									  ---------------- 

									-- Check if creative detail record do not exists Website 

									IF @mediaStream = 'WEB' 

									   AND @IsvalidOccurrenceID = 1 

									  BEGIN 

										  IF NOT EXISTS(SELECT 1 FROM   [dbo].[CreativeDetailWEB] WHERE  creativemasterid = @CreativemasterID AND pagenumber = @PageNumber) 

											BEGIN 

												-- Insert new CreativeDetailEM record 

												INSERT INTO [dbo].[CreativeDetailWEB]

															(creativemasterid, 

															 creativeassetname, 

															 creativerepository, 

						  creativefiletype, 

															 pagenumber, 

															 deleted,creativefiledate) 

												VALUES      ( @CreativemasterID, 

															  @OldImageName, 

															  @basePath, 

															  @FileType, 

															  @PageNumber, 

															  0,getdate() ) 



												SET @CreativeDetailsWEBID=Scope_identity(); 



												UPDATE [dbo].[CreativeDetailWEB] 

												SET    creativeassetname = Cast(@CreativeDetailsWEBID AS VARCHAR) 

																		   + '.' + @FileType, 

													   creativerepository = @mediaStream + '\' 

																			+ Cast(@CreativemasterID AS VARCHAR) 

																			+ '\Original\', 

													   creativefiletype = @FileType 

												WHERE  [CreativeDetailWebID] = @CreativeDetailsWEBID 



												UPDATE #tempscandata 

												SET    creativemasterid = @CreativemasterID, 

													   newimagename = Cast(@CreativeDetailsWEBID AS VARCHAR) 

																	  + '.' + @FileType, 

													   newpath = @basePath + '\' + @mediaStream + '\' 

																 + Cast(@CreativemasterID AS VARCHAR) 

																 + '\Original\' 

																 + Cast(@CreativeDetailsWEBID AS VARCHAR) 

																 + '.' + @FileType, 

													   recordstatus = 'Pending' 

												WHERE  id = @Index 

											END 

										  ELSE 

											BEGIN 

												SELECT @CreativeDetailsWEBID = [CreativeDetailWebID] 

												FROM  [dbo].[CreativeDetailWEB] 

												WHERE  creativemasterid = @CreativemasterID 

													   AND pagenumber = @PageNumber 



												UPDATE [dbo].[CreativeDetailWEB] 

												SET    creativeassetname = Cast(@CreativeDetailsWEBID AS VARCHAR) 

																		   + '.' + @FileType, 

													   creativerepository = @mediaStream + '\' 

																			+ Cast(@CreativemasterID AS VARCHAR) 

																			+ '\Original\', 

													   creativefiletype = @FileType ,

													   creativefiledate=getdate()

												WHERE  [CreativeDetailWebID] = @CreativeDetailsWEBID 



												UPDATE #tempscandata 

												SET    creativemasterid = @CreativemasterID, 

													   newimagename = Cast(@CreativeDetailsWEBID AS VARCHAR) 

																	  + '.' + @FileType, 

													   newpath = @basePath + '\' + @mediaStream + '\' 

																 + Cast(@CreativemasterID AS VARCHAR) 

																 + '\Original\' 

																 + Cast(@CreativeDetailsWEBID AS VARCHAR) 

																 + '.' + @FileType, 

													   recordstatus = 'Pending' 

												WHERE  id = @Index 

											END 

									  END 



									--------------------- 

											--------------------- 

									  ---------------- 

									-- Check if creative detail record do not exists Website 

									IF @mediaStream = 'SOC' 

									   AND @IsvalidOccurrenceID = 1 

									  BEGIN 

										  IF NOT EXISTS(SELECT 1 FROM   [dbo].[CreativeDetailSOC] WHERE  creativemasterid = @CreativemasterID AND pagenumber = @PageNumber) 

											BEGIN 

												-- Insert new CreativeDetailSOC record 

												INSERT INTO [dbo].[CreativeDetailSOC]

															(creativemasterid, 

															 creativeassetname, 

															 creativerepository, 

						  creativefiletype, 

															 pagenumber, 

															 deleted,creativefiledate) 

												VALUES      ( @CreativemasterID, 

															  @OldImageName, 

															  @basePath, 

															  @FileType, 

															  @PageNumber, 

															  0,getdate() ) 



												SET @CreativeDetailsSOCID=Scope_identity(); 



												UPDATE [dbo].[CreativeDetailSOC] 

												SET    creativeassetname = Cast(@CreativeDetailsSOCID AS VARCHAR) 

																		   + '.' + @FileType, 

													   creativerepository = @mediaStream + '\' 

																			+ Cast(@CreativemasterID AS VARCHAR) 

																			+ '\Original\', 

													   creativefiletype = @FileType 

												WHERE  [CreativeDetailSOCID] = @CreativeDetailsSOCID 



												UPDATE #tempscandata 

												SET    creativemasterid = @CreativemasterID, 

													   newimagename = Cast(@CreativeDetailsSOCID AS VARCHAR) 

																	  + '.' + @FileType, 

													   newpath = @basePath + '\' + @mediaStream + '\' 

																 + Cast(@CreativemasterID AS VARCHAR) 

																 + '\Original\' 

																 + Cast(@CreativeDetailsSOCID AS VARCHAR) 

																 + '.' + @FileType, 

													   recordstatus = 'Pending' 

												WHERE  id = @Index 

											END 

										  ELSE 

											BEGIN 

												SELECT @CreativeDetailsSOCID = [CreativeDetailSOCID] 

												FROM  [dbo].[CreativeDetailSOC] 

												WHERE  creativemasterid = @CreativemasterID 

													   AND pagenumber = @PageNumber 



												UPDATE [dbo].[CreativeDetailSOC] 

												SET    creativeassetname = Cast(@CreativeDetailsSOCID AS VARCHAR) 

																		   + '.' + @FileType, 

													   creativerepository = @mediaStream + '\' 

																			+ Cast(@CreativemasterID AS VARCHAR) 

																			+ '\Original\', 

													   creativefiletype = @FileType ,

													   creativefiledate=getdate()

												WHERE  [CreativeDetailSOCID] = @CreativeDetailsSOCID 



												UPDATE #tempscandata 

												SET    creativemasterid = @CreativemasterID, 

													   newimagename = Cast(@CreativeDetailsSOCID AS VARCHAR) 

																	  + '.' + @FileType, 

													   newpath = @basePath + '\' + @mediaStream + '\' 

																 + Cast(@CreativemasterID AS VARCHAR) 

																 + '\Original\' 

																 + Cast(@CreativeDetailsSOCID AS VARCHAR) 

																 + '.' + @FileType, 

													   recordstatus = 'Pending' 

												WHERE  id = @Index 

											END 

									  END 


									--------------------- 

									-- Update Status for OccurrenceDetailsCIR or OccurrenceDetailsPUB  

									IF @mediaStream = 'CIR' 
										  BEGIN 
											  EXEC Sp_updateoccurrencestagestatus @OccurrenceID,3 
										  END 
									ELSE IF @mediaStream = 'PUB' 
										  BEGIN 
											  EXEC [Sp_updatepublicationoccurrencestagestatus] @OccurrenceID,3 
										  END 
									ELSE IF @mediaStream = 'EM' 
										  BEGIN 
											  EXEC Sp_updateemailoccurrencestagestatus   @OccurrenceID, 3 
										  END 
									ELSE IF @mediaStream = 'WEB' 
										  BEGIN 
											  EXEC sp_WebsiteUpdateOccurrenceStageStatus @OccurrenceID,3 
										  END 
									  ELSE IF @mediaStream = 'SOC' 
										  BEGIN 
											  EXEC sp_SocialUpdateOccurrenceStageStatus @OccurrenceID,3 
										  END
				SET @Index=@Index + 1 
            END 
			
          SELECT * FROM   #tempscandata 

          -- Create Updated XML and return  
          -- Drop Temporary table 
          DROP TABLE #tempscandata 
          COMMIT TRANSACTION 
      END TRY 
      BEGIN CATCH 
          ROLLBACK TRANSACTION 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('sp_ProcessScanData: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH 

  END
