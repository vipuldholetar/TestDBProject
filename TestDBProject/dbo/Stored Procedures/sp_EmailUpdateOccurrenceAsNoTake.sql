-- =============================================================================
-- Author			: Arun Nair 
-- Create date		: 11/02/2015
-- Execution		: [dbo].[sp_EmailUpdateOccurrenceAsNoTake] 2
-- Description		: Mark Email Occurrences as NoTake
-- Updated By		: 
--					: 
--================================================================================
CREATE PROCEDURE [dbo].[sp_EmailUpdateOccurrenceAsNoTake]
 ( 
 @ParentOccurrenceId AS INTEGER,
 @Configurationid AS INTEGER,
 @UserId as INTEGER
 ) 
AS 
  BEGIN 
    SET NOCOUNT ON;
    BEGIN TRY 
				BEGIN TRANSACTION 
					--Updating ChildOccurences for PrimaryOccurrence
					declare @NoTakeStatusID int
					select @NoTakeStatusID = os.[OccurrenceStatusID] 
					from OccurrenceStatus os
					inner join Configuration c on os.[Status] = c.ValueTitle
					where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 

					UPDATE [dbo].[OccurrenceDetailEM] 
					SET OccurrenceStatusID = @NoTakeStatusID, 
					NoTakeReason=(SELECT value FROM [Configuration] WHERE Configurationid=@Configurationid) 
					WHERE [ParentOccurrenceID] =@ParentOccurrenceId 

					--Update PrimaryOccurrence
					UPDATE [dbo].[OccurrenceDetailEM] 
					SET OccurrenceStatusID = @NoTakeStatusID, 
					NoTakeReason=(SELECT value FROM [Configuration] WHERE Configurationid=@Configurationid) 
					WHERE [OccurrenceDetailEMID] =@ParentOccurrenceId 

					--Mark added 

							
          DECLARE @CreativeMasterID AS INT=0 
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @CreativeStagingID AS INT=0
          DECLARE @MediaStream AS INT=0 
		  Declare @PrimaryParentOccurrenceID as NVARCHAR(Max)

          SELECT @mediastream = configurationid FROM   [Configuration] WHERE  systemname = 'ALL' AND componentname = 'media stream' AND valuetitle = 'Email' 


          --Index the creative signature to ad 
      
	     DECLARE @primaryOccurrenceID AS INTEGER 
		       
	     SELECT @primaryOccurrenceID = @ParentOccurrenceId

          IF EXISTS(SELECT * FROM   [CreativeStaging]  WHERE  [OccurrenceID] = @primaryOccurrenceID) 
            BEGIN 
                --- Get data from [CREATIVEMASTER]  
                INSERT INTO [Creative] 
                            (
                             [SourceOccurrenceId], 
                             CheckInOccrncs, 
                             PrimaryIndicator) 
                SELECT  
                       @primaryOccurrenceID, 
                       1, 
                       0 

                PRINT( 'creativemaster - inserted' ) 

                SELECT @CreativeMasterID = Scope_identity() 

                PRINT( 'creativemaster id-'  + Cast(@CreativeMasterID AS VARCHAR) ) 

                ---Get data from [CREATIVEMASTERSTAGING]
				
				SELECT distinct @CreativeStagingID = [CreativeStaging].[CreativeStagingID]  FROM   [CreativeStaging] 
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

            END 
			         	
			SELECT @PatternMasterID=PatternID FROM [dbo].[PatternStaging] WHERE  CreativeStgID = @CreativeStagingID
			--L.E. on 1/31/2017
			IF EXISTS (SELECT TOP 1 * FROM PATTERN WHERE PATTERNID=@PatternMasterID)
			BEGIN 
				UPDATE [Pattern]  
				SET [CreativeID]=@CreativeMasterID, MediaStream=@MediaStream, [Pattern].[Exception]=[PatternStaging].[Exception],
					[Pattern].[Query]=[PatternStaging].[Query], [status]= 'Valid', NoTakeReasonCode=@NoTakeStatusID,
					ModifiedBy=@UserID, ModifyDate=Getdate(),[Priority]=5
				FROM [Pattern]  
				INNER JOIN [PatternStaging] on [Pattern].PatternID= [PatternStaging].PatternID
				where [Pattern].PatternID =@PatternMasterID
			END 
			ELSE 
			BEGIN 
			  INSERT INTO [Pattern] 
						  ([CreativeID],
						   MediaStream, 
						   [Exception],  
						   [Query], 
						   Status, 
						   CreateBy,
						   CreateDate,
						   ModifiedBy, 
						   ModifyDate) 
			  SELECT @CreativeMasterID, 
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

				SET @PatternMasterID=Scope_identity();  --get new patternid
			END

				-- update QueryDetail
				update [QueryDetail]
				set [PatternMasterId] = @PatternMasterID, [PatternStgId] = null
				where [PatternStgId] = (select [PatternStagingId] from [PatternStaging] where [PatternId] = @PatternMasterID)
						
				--Remove record from PatternDetailsRAStaging and CreativeDetailsRAStaging which are moved to PatternMaster and CreativeMaster 						
				DELETE FROM [dbo].[PatternStaging] WHERE [CreativeStgID] = @CreativeStagingID 
				DELETE FROM [dbo].[CreativeDetailStagingEM] WHERE CreativeStagingID = @CreativeStagingID 
				DELETE FROM [dbo].[CreativeStaging] WHERE [CreativeStagingID] = @CreativeStagingID
               		
		COMMIT TRANSACTION 
    END TRY 
    BEGIN CATCH 
				DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_EmailUpdateOccurrenceAsNoTake]: %d: %s',16,1,@error,@message,@lineNo); 
				ROLLBACK TRANSACTION 
    END CATCH 
  END