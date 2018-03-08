
-- ============================================================================================
-- Author			: Murali	
-- Create date		: 7/15/2015
-- Description		: This Procedure is Used to Mark Creative Signature As No Take
-- Updated By		: Arun Nair on 08/13/2015 -Cleanup OnemT 
--					  Arun Nair on 09/02/2015 -Patternmaster,Creativemaster Bug Corrected
--					  Karunakar on 8th Sep 2015,Adding MediaFormat Check
-- =============================================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionMarkCreativeSignatureasNoTake]
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
      SET NOCOUNT ON; 

      DECLARE @OccurrenceID AS INT=0 
      DECLARE @CreativeMasterID AS INT=0 
      DECLARE @PatternMasterID AS INT=0 
      DECLARE @CreativeStagingID AS INT=0 
      DECLARE @NoTakeReason AS VARCHAR(100) 
      DECLARE @NumberRecords AS INT=0 
      DECLARE @RowCount AS INT=0
	  Declare @Mediastreamid as int 

      BEGIN TRY 
          BEGIN TRANSACTION 

		  Select @Mediastreamid=ConfigurationID  from   [dbo].[Configuration] Where Value='TV'
          SELECT @NoTakeReason = valuetitle FROM   [Configuration] WHERE  configurationid = @NoTakeReasonID 

          ----create temp table  select * from [OccurrenceDetailsTV]
          
          CREATE TABLE #tempoccurencesforcreativesignature 
            ( 
               rowid        INT IDENTITY(1, 1), 
               occurrenceid INT 
            ) 

           INSERT INTO #tempoccurencesforcreativesignature 
           SELECT  [OccurrenceDetailTVID] FROM    [dbo].[OccurrenceDetailTV] inner join  [Pattern] on [Pattern].[CreativeSignature]=[OccurrenceDetailTV].[PRCODE] 
		   Where [OccurrenceDetailTV].[PRCODE]= @CreativeSignature 

      

                --- Get data from [CREATIVEMASTER]  
                INSERT INTO [Creative] 
                            (
							[AdId], 
                             [SourceOccurrenceId], 
                             CheckInOccrncs
                             ) 
                SELECT null,@OccurrenceID,1 
                        

                PRINT( 'creativemster - inserted' ) 

                SELECT @CreativeMasterID = Scope_identity() 

                PRINT( 'creativemasterid-' 
                       + Cast(@CreativeMasterID AS VARCHAR) ) 

                ---Get data from [CREATIVEMASTERSTAGING]  
               SELECT @CreativeStagingID = [CreativeStgID] 
                 from   [PatternStaging] 		    
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
                FROM   [CreativeDetailStagingTV] 
                WHERE  [CreativeStgMasterID]= @CreativeStagingID and [CreativeDetailStagingTV].MediaFormat='mpg' --Hard Coded Value,to be removed

                PRINT ( 'creativedetailtv - inserted' ) 

		  SELECT @PatternMasterID = p.Patternid FROM Pattern p inner join [PatternStaging] ps on p.PatternID=ps.PatternID
			 WHERE  ps.[CreativeStgID] = @CreativeStagingID

			 IF @PatternMasterID IS NULL OR @PatternMasterID = 0
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
					   CreativeSignature) 
          SELECT @CreativeMasterID, 
                 null, 
                 @Mediastreamid, 
                 [Exception], 
                 [Query],  
                 'Valid',
				 @UserId,                         -- Status Value HardCoded
                 Getdate(),
				 @NoTakeReason,
				 @CreativeSignature
           FROM  [dbo].[PatternStaging]
          WHERE  [CreativeSignature] = @CreativeSignature

                PRINT( 'patternmaster - inserted' ) 

                SET @PatternMasterID=Scope_identity(); 
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

                PRINT( 'patternmasterid-' 
                       + Cast(@PatternMasterID AS VARCHAR) ) 

                PRINT( 'creative signature-' + @creativesignature ) 

		 --SELECT @NumberRecords = Count(*) FROM   #tempoccurencesforcreativesignature 
   --      SET @RowCount = 1 
   --       WHILE @RowCount <= @NumberRecords 
   --         BEGIN			
   --             --- Get OccurrenceID's from Temporary table  
   --             SELECT @OccurrenceID = [occurrenceid] FROM   #tempoccurencesforcreativesignature WHERE  rowid = @RowCount 
   --             PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) )  
   --             ----Update PatternMasterID into OCCURRENCEDETAILODR Table				    
   --             UPDATE [dbo].[OccurrenceDetailTV] SET    [PatternID] = @PatternMasterID WHERE  [OccurrenceDetailTVID] = @OccurrenceID 
			
   --             SET @RowCount=@rowcount + 1 
   --             PRINT ( '-----------' ) 
   --         END 
		  
		  UPDATE a SET a.[PatternID] = @PatternMasterID
		  FROM [dbo].[OccurrenceDetailTV] a inner join #tempoccurencesforcreativesignature b on a.[OccurrenceDetailTVID]=b.[occurrenceid]
			
		  --Remove record from PatternStaging and CreativeDetailsStaging which are moved to PatternMaster and CreativeMaster 
		  DELETE FROM [dbo].[PatternDetailTVStg] WHERE [PatternStagingID] IN (SELECT [PatternStagingID]   FROM   [dbo].[PatternStaging]  WHERE  [CreativeStgID] = @CreativeStagingID ) 						
		  DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
		  DELETE FROM [dbo].[CreativeDetailStagingTV] WHERE [CreativeStgMasterID] = @CreativeStagingID 
		  DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),  @lineNo  INT 
          SELECT @error = Error_number(), @message = Error_message(), @lineNo = Error_line() 
          ROLLBACK TRANSACTION 
          RAISERROR ('sp_TelevisionMarkCreativeSignatureasNoTake: %d: %s',16,1,@error , @message,@lineNo); 
      END CATCH 
  END