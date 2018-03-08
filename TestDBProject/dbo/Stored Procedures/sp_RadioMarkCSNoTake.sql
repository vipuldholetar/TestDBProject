

-- ================================================================================================
-- Author			:   Arun Nair  
-- Create date		: <04/15/2015 3:32:00 PM> 
-- Description		: sp_RadioMarkCSNoTake  'M2005705-20440997' 44
-- Execution Process: [sp_RadioMarkCSNoTake]
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMT
-- ===========================================================================================
CREATE PROCEDURE [dbo].[sp_RadioMarkCSNoTake]
(
@CreativeSignature NVARCHAR(max),
@NoTakeReasonID INT,
@UserId as Int
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


		  Select @Mediastreamid=ConfigurationID  from   [dbo].[Configuration] Where Value='RAD'

			SELECT @NoTakeReason = valuetitle FROM   [Configuration] WHERE  configurationid = @NoTakeReasonID 
			  ----create Temp Table            
			  CREATE TABLE #tempoccurencesforcreativesignature 
				( 
				   rowid        INT IDENTITY(1, 1), 
				   occurrenceid INT 
				) 
			  INSERT INTO #tempoccurencesforcreativesignature 
			  SELECT [OccurrenceDetailRAID] FROM   [dbo].[OccurrenceDetailRA]  INNER JOIN RCSAcIdToRCSCreativeIdMap ON RCSAcIdToRCSCreativeIdMap.[RCSAcIdToRCSCreativeIdMapID] =[OccurrenceDetailRA].[RCSAcIdID] 
			  INNER JOIN [RCSCreative] ON [RCSCreative].[RCSCreativeID] = RCSAcIdToRCSCreativeIdMap.[RCSCreativeID] AND [RCSCreative].[RCSCreativeID] = @CreativeSignature 

		set @primaryOccurrenceID =(select dbo.fn_GetPrimaryOccurrenceId(@CreativeSignature))

		--- Get data from [CREATIVEMASTER]  
                INSERT INTO [Creative] 
                            ([AdId], 
                             [SourceOccurrenceId], 
                             CheckInOccrncs
                             ) 
                SELECT null, @primaryOccurrenceID,1 
                SELECT @CreativeMasterID = Scope_identity() 
				PRINT( 'creativemasterid-' 
                       + Cast(@CreativeMasterID AS VARCHAR) ) 
 
 
                
                ---Get data from [CREATIVEMASTERSTAGING]  
                SELECT @CreativeStagingID = [CreativeStagingID] FROM   [CreativeStaging] WHERE  [CreativeStaging].[OccurrenceID] = @primaryOccurrenceID 

                INSERT INTO [CreativeDetailRA] 
                            ([CreativeID], 
                             AssetName, 
                             Rep, 
                             LegacyAssetName, 
                             FileType) 
                SELECT @CreativeMasterID, 
                       mediafilename, 
                       mediafilepath, 
                       '', 
                       mediaformat 
                FROM   [CreativeDetailStagingRA] 
                WHERE  [CreativeStgID] = @CreativeStagingID 

                PRINT ( 'creativedetailsra - inserted' ) 

			 SELECT @PatternMasterID = p.Patternid FROM Pattern p inner join [PatternStaging] ps on p.PatternID=ps.PatternID
			 WHERE  ps.[CreativeStgID] = @CreativeStagingID

			 IF @PatternMasterID IS NULL OR @PatternMasterID = 0
			 BEGIN
				INSERT INTO [Pattern] 
                            (
							 [CreativeID], 
                             [AdID], 
                             priority, 
                             MediaStream, 
                             [Exception], 
                             ExceptionText, 
                             [Query], 
                             QueryCategory, 
                             QueryText, 
                             QueryAnswer, 
                             TakeReasonCode, 
                             NoTakeReasonCode, 
                             Status, 
					    CreateBy,
                             CreateDate, 
                             ModifyDate,
							 CreativeSignature) 
				SELECT @CreativeMasterID, 
                       null, 
                       priority, 
                       @Mediastreamid ,
                       [Exception], 
                       exceptiontext, 
                       [Query], 
                       querycategory, 
                       querytext, 
                       queryanswer, 
                       [TakeReasonCODE], 
                       @NoTakeReason, 
                       status,
					   @UserId, 
                       Getdate(), 
                       Getdate(),
					   @CreativeSignature
				FROM   [PatternStaging] 
				WHERE  [PatternStaging].[CreativeStgID] = @CreativeStagingID 

				PRINT( 'patternmaster - inserted' ) 
				SET @PatternMasterID=Scope_identity(); 
			 END
			 ELSE
			 BEGIN
				UPDATE p set p.CreativeID=@CreativeMasterID,AdID = NULL, p.MediaStream = @Mediastreamid
				    ,[Exception] = ps.[Exception], ExceptionText = ps.exceptiontext, [Query] = ps.[Query], QueryCategory = ps.querycategory
				    ,QueryText = ps.querytext, QueryAnswer = ps.queryanswer, TakeReasonCode = ps.[TakeReasonCODE], 
				    NoTakeReasonCode = @NoTakeReasonID, [Status] = ps.[Status], p.[Priority]=5,
				    p.ModifiedBy=@UserId, ModifyDate = GETDATE(), CreativeSignature = @CreativeSignature
				FROM Pattern p INNER JOIN [PatternStaging] ps on p.PatternID = ps.PatternID
				WHERE ps.PatternId = @PatternMasterID

			 END

                PRINT( 'patternmasterid-' 
                       + Cast(@PatternMasterID AS VARCHAR) ) 
                PRINT( 'creative signature-' + @creativesignature ) 
                INSERT INTO PatternDetailRA 
                            ([PatternID], 
                             [RCSCreativeID])
                VALUES      (@PatternMasterID, 
                             @creativesignature) 

			  SELECT @NumberRecords = Count(*) FROM   #tempoccurencesforcreativesignature 
			  --SET @RowCount = 1 

     --     WHILE @RowCount <= @NumberRecords 
     --       BEGIN 
     --           --- Get OccurrenceID's from Temporary table  
     --           SELECT @OccurrenceID = [occurrenceid] FROM   #tempoccurencesforcreativesignature WHERE  rowid = @RowCount
     --           PRINT( 'occurrenceid-' + Cast(@OccurrenceID AS VARCHAR) )                
     --           ----Update PatternMasterID into OCCURRENCEDETAILSRA Table    
     --           UPDATE [dbo].[OccurrenceDetailRA] SET    [PatternID] = @PatternMasterID  WHERE  [OccurrenceDetailRAID] = @OccurrenceID

				
				 
     --           SET @RowCount=@rowcount + 1 
     --           PRINT ( '-----------' ) 
     --       END 

			 UPDATE a SET a.[PatternID] = @PatternMasterID
			 FROM [dbo].[OccurrenceDetailRA] a INNER JOIN #tempoccurencesforcreativesignature b on a.OccurrenceDetailRAID = b.occurrenceid

			 --Remove record from PatternDetailsRAStaging and CreativeDetailsRAStaging which are moved to PatternMaster and CreativeMaster 
			 --DELETE FROM PatternDetailRAStaging WHERE [PatternStgID] in   (select [PatternStgID]   FROM   [PatternStaging]  WHERE  [CreativeStgID] = @CreativeStagingID ) 
                DELETE FROM [PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
                DELETE FROM [CreativeDetailStagingRA] WHERE [CreativeStgID] = @CreativeStagingID        
                DELETE FROM [CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID  

          COMMIT TRANSACTION 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()          
          RAISERROR ('[sp_RadioMarkCSNoTake]: %d: %s',16,1,@error ,@message,@lineNo); 
		  ROLLBACK TRANSACTION 
      END CATCH 
  END