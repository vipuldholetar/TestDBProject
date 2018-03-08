-- ==================================================================================
-- Author			: Karunakar
-- Create date		: 7/6/2015
-- Description		: This Procedure is Used to Mark Creative Signature As No Take
-- Exec				: sp_CinemaMarkCreativeSignatureasNoTake '335919aeg',162
-- Updated By		: Ramesh On 08/12/2015 - CleanUp for OneMTDB 
--					  Arun Nair On 08/24/2015 - For OccurrenceId Change Datatype-Seeding
--					  Arun Nair On 09/02/2015 - PatternMaster Bug corrected
--					  Karunakar on 7th Sep 2015
-- ================================================================================== 

CREATE PROCEDURE [dbo].[sp_CinemaMarkCreativeSignatureasNoTake]
(
@CreativeSignature NVARCHAR(max),
@NoTakeReasonID INT,
@UserId INT
) 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 

  BEGIN 
      SET nocount ON; 

      DECLARE @OccurrenceID AS BIGINT=0 
      DECLARE @CreativeMasterID AS INT=0 
      DECLARE @PatternMasterID AS INT=0 
      DECLARE @CreativeStagingID AS INT=0 
      DECLARE @NoTakeReason AS VARCHAR(100) 
      DECLARE @NumberRecords AS INT=0 
      DECLARE @RowCount AS INT=0
	  Declare @Mediastreamid as int  

      BEGIN TRY 
          BEGIN TRANSACTION 
		  Select @Mediastreamid=ConfigurationID  from   [dbo].[Configuration] Where Value='CIN'
          SELECT @NoTakeReason = valuetitle FROM   [Configuration] WHERE  configurationid = @NoTakeReasonID 

          ----create temp table  
          
          CREATE TABLE #tempoccurencesforcreativesignature 
            ( 
               rowid        INT IDENTITY(1, 1), 
               occurrenceid BIGINT 
            ) 

          INSERT INTO #tempoccurencesforcreativesignature 
          SELECT  [OccurrenceDetailCINID] FROM [dbo].[OccurrenceDetailCIN] Where [OccurrenceDetailCIN].[CreativeID]= @CreativeSignature
          SELECT @NumberRecords = Count(*) FROM   #tempoccurencesforcreativesignature 
          SET @RowCount = 1 

       

                --- Get data from [CREATIVEMASTER]  
                INSERT INTO [Creative]([AdId],[SourceOccurrenceId],CheckInOccrncs) 
                SELECT null, @OccurrenceID, 1                       

                --PRINT( 'creativemster - inserted' ) 

                SELECT @CreativeMasterID = Scope_identity() 

                --PRINT( 'creativemasterid-'+ Cast(@CreativeMasterID AS VARCHAR) ) 

                ---Get data from [CREATIVEMASTERSTAGING]  
                 SELECT @CreativeStagingID = [CreativeStgID] from   [PatternStaging] Where [CreativeSignature] = @CreativeSignature

				 -- Getting data from CreativeDetailsCINStg  and inserting data into CreativeDetailCIN 
                 INSERT INTO CreativeDetailCIN 
                            ([CreativeMasterID], 
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
				
				
				
		  SELECT @PatternMasterID = p.Patternid FROM Pattern p inner join [PatternStaging] ps on p.PatternID=ps.PatternID
			 WHERE  ps.[CreativeStgID] = @CreativeStagingID

			 IF @PatternMasterID IS NULL OR @PatternMasterID = 0
			  BEGIN 

                --PRINT ( 'creativedetailcin - inserted' ) 
				-- Getting data from PatternMasterStgCIN  and inserting data into PatternMaster 
                INSERT INTO [Pattern] 
                      ([CreativeID], 
                       [AdID], 
                       MediaStream, 
                       [Exception],  
                       [Query], 
                       Status,
					   CreateBy, 
                       CreateDate,
					   NoTakeReasonCode,
					   CreativeSignature 
                       ) 
			 SELECT @CreativeMasterID, 
					 null, 
					 @Mediastreamid, 
					 exception, 
					 query,  
					 'Valid',
					 @UserId,                          -- Status Value HardCoded
					 Getdate(), 
					 @NoTakeReason,
					 @CreativeSignature          
          FROM   [dbo].[PatternStaging] 
          WHERE  [CreativeSignature] = @CreativeSignature

                --PRINT( 'patternmaster - inserted' ) 
                SET @PatternMasterID=Scope_identity(); 
               -- PRINT( 'patternmasterid-'+ Cast(@PatternMasterID AS VARCHAR) ) 
                --PRINT( 'creative signature-' + @creativesignature ) 

			End
				ELSE
				 BEGIN

			 		UPDATE [Pattern]  
					SET [CreativeID]=@CreativeMasterID, [Pattern].[Exception]=[PatternStaging].[Exception],
						[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid',
						ModifiedBy=@UserID, ModifyDate=Getdate(),[Priority]=5
					FROM [Pattern]  
					INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
					where [Pattern].PatternID =@PatternMasterID

				 END

			--WHILE @RowCount <= @NumberRecords 
   --          BEGIN 
   --             --- Get OccurrenceID's from Temporary table  
   --             SELECT @OccurrenceID = [occurrenceid] FROM   #tempoccurencesforcreativesignature WHERE  rowid = @RowCount 
   --            -- PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) ) 

   --             ----Update PatternMasterID into OCCURRENCEDETAILCIN Table				    
   --             UPDATE [dbo].[OccurrenceDetailCIN] SET [PatternID] = @PatternMasterID WHERE  [OccurrenceDetailCINID] = @OccurrenceID 
			--	--PRINT ('Occurrence Id-Updated')
			--	--PRINT( 'Occurrence Id-' +Cast(@OccurrenceID AS VARCHAR))

   --             SET @RowCount=@rowcount + 1 
   --             PRINT ( '-----------' ) 	
   --          END 
		   
			 UPDATE a SET a.[PatternID] = @PatternMasterID
			 FROM [dbo].[OccurrenceDetailCIN] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailCINID]=b.occurrenceid

			 --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster 						
			 DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
			 DELETE FROM [dbo].[CreativeDetailStagingCIN] WHERE [CreativeStagingID] = @CreativeStagingID 
			 DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

			-- Deleting Creative Signature from PatternMasterStagingCIN
			Exec sp_CinemaDeleteCreativeSignaturefromQueue @CreativeSignature
			DROP TABLE #tempoccurencesforcreativesignature
          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          ROLLBACK TRANSACTION 
          RAISERROR ('sp_CinemaMarkCreativeSignatureasNoTake: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH 
  END