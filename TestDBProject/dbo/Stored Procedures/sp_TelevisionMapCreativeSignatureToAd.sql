
-- ====================================================================================================================
-- Author			: Murali
-- Create date		: 15th July 2015
-- Description		: This Procedure is Used to Mapping  on Ad to CreativeSignature
-- Updated By		: Arun Nair on 08/13/2015 -Cleanup OnemT 
--					: Arun Nair on 09/02/2015 -Added CreateBy,ModifiedBy,Update CreativeSignature in PatternMaster
--					  Arun Nair on 09/08/2015 - Added hardcorded mpg check 
--					  Arun Nair on 10/12/2015 - Append Description with MODReason
--Execution			:sp_TelevisionMapCreativeSignatureToAd '','',27680,'7TF7KR1C.PA1',29711029
-- =====================================================================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionMapCreativeSignatureToAd]-- '8078',10,1
(@Description       AS NVARCHAR(max), 
 @RecutDetail          AS NVARCHAR(max), 
 @Adid              INT, 
 @CreativeSignature AS VARCHAR(100),
 @UserID            AS INT
) 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 

  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

	   DECLARE @OccurrenceID AS INT=0 
	   DECLARE @CreativeMasterID AS INT=0 
	   DECLARE @PatternMasterID AS INT=0 
	   DECLARE @CreativeStagingID AS INT=0            
	   DECLARE @NumberRecords AS INT=0 
	   DECLARE @RowCount AS INT=0 
	   DECLARE @MediaStream AS INT=0 
	   DECLARE @occurrencemediastream AS VARCHAR(50)
	   DECLARE @Patternmasterstgid as int=0

          SELECT @mediastream = configurationid 
          FROM   [Configuration] 
          WHERE  systemname = 'ALL' 
                 AND componentname = 'media stream' 
                 AND valuetitle = 'Television' 

          --PRINT( 'Mediastream - ' + Cast(@mediastream AS VARCHAR) ) 

          --Index the creative signature to ad 
          
          CREATE TABLE #tempoccurencesforcreativesignature 
            ( 
               rowid        INT IDENTITY(1, 1), 
			mediastream varchar(50),
               occurrenceid INT 
            ) 

           INSERT INTO #tempoccurencesforcreativesignature(occurrenceid,mediastream)
		 SELECT [OccurrenceDetailID],mediastream FROM  [dbo].[vw_OccurrenceDetailAV]
		  --INNER JOIN [CreativeStaging] ON [dbo].[vw_OccurrenceDetailAV].creativesignature = [CreativeStaging].creativesignature 
		  WHERE  [vw_OccurrenceDetailAV].creativesignature = @creativesignature 

          -- SELECT  [OccurrenceDetailTVID]
          --FROM    [dbo].[OccurrenceDetailTV] inner join  [TVPattern] on [TVPattern].[TVPatternCODE]=[OccurrenceDetailTV].[PRCODE]
          --       Where [OccurrenceDetailTV].[PRCODE]= @CreativeSignature 
				 
          DECLARE @primaryOccurrenceID AS INTEGER 

          SELECT @primaryOccurrenceID = Min(occurrenceid),@occurrencemediastream = mediastream 
          FROM   #tempoccurencesforcreativesignature
		group by  occurrenceid,mediastream

          PRINT ( 'primaryoccurrenceid-'  + Cast(@primaryOccurrenceID AS VARCHAR) ) 

         IF EXISTS(select 1 from [CreativeStaging] a 
				    --inner join  PatternTVStaging b on a.[CreativeStagingID]=b.[CreativeStagingID] 
		            Where a.[CreativeSignature] = @CreativeSignature)  
            BEGIN 
                --- Get data from [CREATIVEMASTER]  
                INSERT INTO [Creative] 
                            (
							 [AdId], 
                             [SourceOccurrenceId], 
                             CheckInOccrncs, 
                             PrimaryIndicator
							 ) 
                SELECT @ADID, 
                       @primaryOccurrenceID, 
                       1, 
                       0 

                PRINT( 'creativemaster - inserted' ) 

                SELECT @CreativeMasterID = Scope_identity() 

               PRINT( 'creativemaster id-' + Cast(@CreativeMasterID AS VARCHAR) ) 
			
			IF @occurrencemediastream = 'TV'    
			BEGIN
				---Get data from [CREATIVEMASTERSTAGING]  
			    SELECT @CreativeStagingID = [CreativeStgID] 
				 from   PatternStaging 		    
				   Where [CreativeSignature] = @CreativeSignature

				INSERT INTO creativedetailTV -- select * from CreativeDetailTVStg
						  (creativemasterid, 
						   creativeassetname, 
						   creativerepository, 
						   legacycreativeassetname, 
						   creativefiletype) 
				SELECT @CreativeMasterID, 
					  MediaFileName, 
					  MediaFilepath, 
					  null, 
					  MediaFormat 
				FROM   [CreativeDetailStagingTV]  WHERE [CreativeDetailStagingTV].MediaFormat='mpg' --Hard Coded Value,to be removed
				AND  [CreativeStgMasterID]= @CreativeStagingID 
			 END
			 ELSE IF @occurrencemediastream = 'ONV'
			 BEGIN
				SELECT @CreativeStagingID= a.[CreativeStagingID],@Patternmasterstgid=b.[PatternStagingID]   FROM   [CreativeStaging] a 
						  INNER JOIN [PatternStaging] b  ON a.[CreativeStagingID] = b.[CreativeStgID] 
						  WHERE  a.CreativeSignature = @creativesignature

						    --- Moving Data from CreativeDetailStagingONV to CreativeDetailONV     
				INSERT INTO creativedetailTV 
						  (creativemasterid, 
						   creativeassetname, 
						   creativerepository, 
						   legacycreativeassetname, 
						   creativefiletype) 
				SELECT	@creativemasterid,
						    [dbo].[CreativeDetailStagingONV].[SignatureDefault]+'.'+[dbo].[CreativeDetailStagingONV].CreativeFileType,
						    CreativeRepository, 
						    Null, 
					  CreativeFileType 
				FROM   CreativeDetailStagingONV
				WHERE  CreativeStagingID = @CreativeStagingID 
				    And CreativeFileType='MP4' and CreativeDownloaded=1 and FileSize>0  --Updated By Karunakar on 15th October 2015,adding Checks for filesize and filetype
			 END
			 ELSE IF @occurrencemediastream = 'CIN'
			 BEGIN
				SELECT @CreativeStagingID= a.[CreativeStagingID],@Patternmasterstgid=b.[PatternStagingID]   FROM   [CreativeStaging] a 
						  INNER JOIN [PatternStaging] b  ON a.[CreativeStagingID] = b.[CreativeStgID] 
						  WHERE  a.CreativeSignature = @creativesignature

				INSERT INTO creativedetailTV 
						  (creativemasterid, 
						   creativeassetname, 
						   creativerepository, 
						   legacycreativeassetname, 
						   creativefiletype) 
				SELECT @CreativeMasterID, 
					[CreativeAssetName], 
					[CreativeRepository], 
					null, 
					[CreativeFileType]
				FROM   dbo.[CreativeDetailStagingCIN]
				WHERE  [CreativeStagingID]= @CreativeStagingID  
			 END

                PRINT ( 'creativedetailstv - inserted' ) 
            END 

          		SELECT @PatternMasterID=PatternID FROM [dbo].[PatternStaging] WHERE  [CreativeSignature] = @CreativeSignature
			--L.E. on 1/31/2017
			IF EXISTS (SELECT TOP 1 * FROM PATTERN WHERE PATTERNID=@PatternMasterID)
			BEGIN 
				UPDATE [Pattern]  
				SET [CreativeID]=@CreativeMasterID, [AdID]=@adid, MediaStream=@MediaStream, [Pattern].[Exception]=[PatternStaging].[Exception],
					[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid', 
					 LastMappedDate=getdate(),LastMapperInits =@userId,
					ModifiedBy=@UserID, ModifyDate=getDate(),CreativeSignature=@CreativeSignature
				FROM [Pattern]  
				INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
				where [Pattern].PatternID =@PatternMasterID and [Pattern].[CreativeSignature] = @CreativeSignature 
			END 
			ELSE 
			BEGIN 

		  IF @occurrencemediastream = 'TV'    
		  BEGIN
		     /*
			 INSERT INTO [Pattern] ([CreativeID], [AdID], MediaStream, [Exception],  [Query], Status, CreateBy,CreateDate,ModifiedBy,ModifyDate,CreativeSignature) 
			   SELECT @CreativeMasterID, @adid, @MediaStream, [Exception], [Query],  'Valid',@UserId,Getdate(),NULL,NULL,@CreativeSignature
			    FROM  [dbo].PatternStaging
			   WHERE  [CreativeSignature] = @CreativeSignature
			*/
			update p
			set [AdId] = @adid, [Exception] = ps.[Exception], [Query] = ps.[Query], [ModifiedBy] = @UserID, [ModifyDate] = getdate()
			from [PatternStaging] ps join [Pattern] p on p.[PatternID] = ps.[PatternID]
			and ps.[CreativeSignature] = @CreativeSignature
		  END
		  ELSE
		  BEGIN
		    --- Inserting data into PatternMaster  from [PatternMasterStg]     
		    INSERT INTO [Pattern] ([CreativeID],[AdID],mediastream,[Exception],[Query],status,createby,createdate,modifiedby,modifydate,creativesignature) 
			   SELECT @creativemasterid,@adid,@mediastream,[Exception],[Query],'Valid',@userid,Getdate(),NULL,NULL,@creativesignature FROM   [dbo].[PatternStaging]
				WHERE [PatternStaging].[PatternStagingID]=@Patternmasterstgid 
		  END

		    PRINT( 'patternmaster - inserted' ) 

		    SET @PatternMasterID=Scope_identity(); 
			END

		    PRINT( 'patternmasterid-' + Cast(@PatternMasterID AS VARCHAR) ) 

		    PRINT( 'creative signature-' + @creativesignature ) 
		    print ('executed')
          --SELECT @NumberRecords = Count(*)      FROM   #tempoccurencesforcreativesignature 
          --SET @RowCount = 1 
          --WHILE @RowCount <= @NumberRecords 
          --  BEGIN 
          --      --- Get OccurrenceID's from Temporary table  
          --      SELECT @OccurrenceID = [occurrenceid] 
          --      FROM   #tempoccurencesforcreativesignature 
          --      WHERE  rowid = @RowCount 

          --      PRINT( 'occurrenceid-'+ Cast(@OccurrenceID AS VARCHAR) ) 

          --      ----Update PatternMasterID and Ad into OCCURRENCEDETAILTV Table
				   
          --      UPDATE [dbo].[OccurrenceDetailTV] 
          --      SET    [PatternID] = @PatternMasterID, 
          --             [AdID] = @AdID 
          --      WHERE  [OccurrenceDetailTVID] = @OccurrenceID  

				
          --      SET @RowCount=@rowcount + 1 
          --  END 

		  IF @occurrencemediastream = 'CIN'
		  BEGIN
			 UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
			 FROM [dbo].[OccurrenceDetailCIN] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailCINID]=b.occurrenceid 
			 
			 DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
			 DELETE FROM [dbo].[CreativeDetailStagingCIN] WHERE [CreativeStagingID] = @CreativeStagingID  
			 
			 Exec sp_CinemaDeleteCreativeSignaturefromQueue @CreativeSignature
		  END
		  ELSE IF @occurrencemediastream = 'TV'    
		  BEGIN
			 UPDATE a SET a.[PatternID] = @PatternMasterID, [AdID] = @AdID 
				FROM [dbo].[OccurrenceDetailTV] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailTVID]=b.[occurrenceid]

			 --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster 
			 DELETE FROM [dbo].[PatternDetailTVStaging] WHERE [PatternStagingID] in   
			 (select a.PatternStagingID   FROM   [dbo].PatternStaging a WHERE  a.[CreativeStgID] = @CreativeStagingID ) 						
			 DELETE FROM [dbo].PatternStaging WHERE [CreativeStgID] = @CreativeStagingID 
			 DELETE FROM [dbo].[CreativeDetailStagingTV] WHERE [CreativeStgMasterID] = @CreativeStagingID 
		  END
		  ELSE IF @occurrencemediastream = 'ONV'
		  BEGIN
			 UPDATE [dbo].[OccurrenceDetailONV] SET  [PatternID] = @patternmasterid,[AdID] = @adid,[PatternStagingID]=Null  
				WHERE  [dbo].[OccurrenceDetailONV].CreativeSignature = @creativesignature

			 EXEC [sp_OnlineVideoDeleteStagingRecords]   @CreativeStagingID  
		  END

		  DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

		  -- Update Occurrence in Ad Table  
		  UPDATE Ad SET    Ad.[PrimaryOccurrenceID] = @primaryOccurrenceID WHERE  Ad.[AdID] = @AdID AND [PrimaryOccurrenceID] IS NULL 
		             
		  IF @Description<>''
			 BEGIN  
			 UPDATE Ad SET    description =description+','+ @Description  WHERE  [AdID] = @AdID
			 END 
			 IF @RecutDetail<>''
			 BEGIN  
			 UPDATE Ad SET    RecutDetail =recutdetail+','+@RecutDetail  WHERE  [AdID] = @AdID
		  END 
		  print('in')
		  IF NOT EXISTS(select 1 from [Creative] where [AdId]=@adid and PrimaryIndicator=1)
		  BEGIN
		  -- updated creativemaster primary indicator
			 UPDATE [Creative] set PrimaryIndicator=1 where PK_Id=@adid	and [SourceOccurrenceId]=@primaryOccurrenceID	
		  END
		
          DROP TABLE #tempoccurencesforcreativesignature 
          COMMIT TRANSACTION 
      END TRY 
      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_TelevisionMapCreativeSignatureToAd]: %d: %s',16,1,@error,@message,@lineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
  END