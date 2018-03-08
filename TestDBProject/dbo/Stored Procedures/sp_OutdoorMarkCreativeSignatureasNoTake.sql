-- ========================================================================================================================= 
-- Author			: Karunakar
-- Create date		: 7/6/2015
-- Description		: This Procedure is Used to Mark Creative Signature As No Take
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB 
--					  Arun Nair on 09/02/2015 - Patternmaster,Creativemaster Bug correction,Delete Data Script for Core table 
--					:L.E. on 1/31/2017 - Added check to update Pattern table if record exists MI-953
-- ===========================================================================================================================


CREATE PROCEDURE [dbo].[sp_OutdoorMarkCreativeSignatureasNoTake]
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

      DECLARE @OccurrenceID AS INT=0 
      DECLARE @CreativeMasterID AS INT=0 
      DECLARE @PatternMasterID AS INT=0 
      DECLARE @CreativeStagingID AS INT=0 
      DECLARE @NoTakeReason AS VARCHAR(100) 
      DECLARE @NumberRecords AS INT=0 
      DECLARE @RowCount AS INT=0 
	  Declare @Mediastreamid as int
	  	  Declare @primaryOccurrenceID as int=0

      BEGIN TRY 
          BEGIN TRANSACTION 

		  Select @Mediastreamid=ConfigurationID  from   [dbo].[Configuration] Where Value='OD'
		  --Per ticket MI-1057 update with the codeid
          --SELECT @NoTakeReason = valuetitle FROM   [Configuration] WHERE  configurationid = @NoTakeReasonID 

          ----create temp table           
          CREATE TABLE #tempoccurencesforcreativesignature 
            ( 
               rowid        INT IDENTITY(1, 1), 
               occurrenceid INT 
            ) 

          INSERT INTO #tempoccurencesforcreativesignature 
          SELECT [OccurrenceDetailODRID] FROM    [dbo].[OccurrenceDetailODR]
          WHERE [OccurrenceDetailODR].ImageFileName= @CreativeSignature 

       select @primaryOccurrenceID =  [OccurrenceDetailODRID] FROM    [dbo].[OccurrenceDetailODR]
          WHERE [OccurrenceDetailODR].ImageFileName= @CreativeSignature 

        
              

                PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) ) 

                --- Get data from [CREATIVEMASTER]  
                INSERT INTO [Creative] 
                            ([AdId], 
                             [SourceOccurrenceId], 
                             CheckInOccrncs
                             ) 
                SELECT null, 
                       @primaryOccurrenceID, 
                       1 
                        

                PRINT( 'creativemster - inserted' ) 

                SELECT @CreativeMasterID = Scope_identity() 

                PRINT( 'creativemasterid-' + Cast(@CreativeMasterID AS VARCHAR) ) 

                ---Get data from [CREATIVEMASTERSTAGING]  
               
				SELECT @CreativeStagingID = [CreativeStaging].[CreativeStagingID]  FROM   [CreativeStaging] 
				inner join [CreativeDetailStagingODR] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingODR].CreativeStagingID 
				WHERE [CreativeStaging].[OccurrenceID] = @primaryOccurrenceID


                 INSERT INTO creativedetailODR 
                            (creativemasterid, 
                             creativeassetname, 
                             creativerepository, 
                             legacycreativeassetname, 
                             creativefiletype,
							 AdFormatId) 
                SELECT @CreativeMasterID, 
                       [CreativeAssetName], 
                       [CreativeRepository], 
                       null, 
                       [CreativeFileType] ,
					   [AdFormatId]
                FROM   [CreativeDetailStagingODR]
                WHERE  [CreativeStagingID]= @CreativeStagingID 

                PRINT ( 'creativedetailodr - inserted' ) 


   			 ---Get Pattern ID into @PatternMasterID from [PATTERNSTAGING] used for OccuranceDetailODR update as well 
			
			SELECT @PatternMasterID=PatternID FROM [dbo].[PatternStaging] WHERE  [CreativeSignature] = @CreativeSignature
			--L.E. on 1/31/2017
			IF EXISTS (SELECT TOP 1 * FROM PATTERN WHERE PATTERNID=@PatternMasterID)
			BEGIN 
				UPDATE [Pattern]  
				SET [CreativeID]=@CreativeMasterID, [AdID]=NULL, MediaStream=@Mediastreamid, [Pattern].[Exception]=[PatternStaging].[Exception],
					[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid', ModifiedBy=@UserID, ModifyDate=Getdate(),NoTakeReasonCode=@NoTakeReasonID
					,CreativeSignature=@CreativeSignature,[Priority]=5
				FROM [Pattern]  
				INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
				where [Pattern].PatternID =@PatternMasterID and [Pattern].[CreativeSignature] = @CreativeSignature 
			END 
			ELSE 
			BEGIN    
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
					   CreativeSignature,
					   [Priority]
						   ) 
			  SELECT @CreativeMasterID, 
					 null, 
					 @Mediastreamid, 
					 [Exception], 
					 [Query],  
					 'Valid',
					 @UserId,                          -- Status Value HardCoded
					 Getdate(), 
					 @NoTakeReasonID,
					 @CreativeSignature,
					 5
			  FROM   [dbo].[PatternStaging] 
			  WHERE  [CreativeSignature] = @CreativeSignature

                PRINT( 'patternmaster - inserted' ) 

                SET @PatternMasterID=Scope_identity(); 
			END 

                PRINT( 'patternmasterid-' + Cast(@PatternMasterID AS VARCHAR) ) 
                PRINT( 'creative signature-' + @creativesignature ) 

    --            SELECT @NumberRecords = Count(*) FROM   #tempoccurencesforcreativesignature 
				--SET @RowCount = 1 
				--  WHILE @RowCount <= @NumberRecords 
				--	BEGIN     
				--	  --- Get OccurrenceID's from Temporary table  
				--		SELECT @OccurrenceID = [occurrenceid] FROM   #tempoccurencesforcreativesignature WHERE  rowid = @RowCount 
				--		UPDATE [dbo].[OccurrenceDetailODR] SET    [PatternID] = @PatternMasterID WHERE  [OccurrenceDetailODRID] = @OccurrenceID 

					

				--		SET @RowCount=@rowcount + 1 
				--		PRINT ( '-----------' ) 
				--	END 

			UPDATE a SET    a.[PatternID] = @PatternMasterID 
			FROM [dbo].[OccurrenceDetailODR] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailODRID]=b.[occurrenceid]

			-- update QueryDetail
		    update [QueryDetail]
		    set [PatternMasterId] = @PatternMasterID, [PatternStgId] = null
		    where [PatternStgId] = (select [PatternStagingId] from [PatternStaging] where [PatternId] = @PatternMasterID)

			 --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster 						
			 DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
			 DELETE FROM [dbo].[CreativeDetailStagingODR] WHERE CreativeStagingID = @CreativeStagingID 
			 DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

			-- Deleting Creative Signature from PatternMasterStagingODR
			EXEC sp_OutdoorDeleteCreativeSignaturefromQueue @CreativeSignature
			DROP TABLE #tempoccurencesforcreativesignature

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,  @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
          ROLLBACK TRANSACTION 
          RAISERROR ('sp_OutdoorMarkCreativeSignatureasNoTake: %d: %s',16,1,@error , @message,@lineNo); 
      END CATCH 
  END