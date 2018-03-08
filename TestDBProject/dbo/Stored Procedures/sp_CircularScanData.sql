
--[dbo].[sp_CircularScanData] '<ScanData>
--  <OccurrenceImage ID="1" OccurrenceID="500002" CreativeMasterID="0" OldImageName="001.jpg" NewImageName="" PageNumber="1" OldPath="D:\Scantracker\500002\001.jpg" NewPath="" RecordStatus="Unprocessed" FileType="jpg" />
--  <OccurrenceImage ID="2" OccurrenceID="500002" CreativeMasterID="0" OldImageName="002.jpg" NewImageName="" PageNumber="2" OldPath="D:\Scantracker\500002\002.jpg" NewPath="" RecordStatus="Unprocessed" FileType="jpg" />
--</ScanData>'

-- Author		: RP     
-- Create date  : Dec 08, 2015    
-- Description  : Process Scanned Files for Circular  
CREATE PROCEDURE [dbo].[sp_CircularScanData] 
(
@parameter AS XML
) 
AS 
  BEGIN 
    
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
          DECLARE @IsvalidOccurrenceID AS BIT 
          DECLARE @ExistingCreativeMaster AS BIT 
          DECLARE @PatternMasterID AS INT=0 
          DECLARE @basePath AS NVARCHAR(max)='' 


          DECLARE @mediaStream AS NVARCHAR(max)='CIR' 
          DECLARE @AdId AS INT=0 
          DECLARE @isprimary AS INT 

          -- Read XML and insert into Temporary table   
          SELECT scandata.value('(@ID)[1]', 'int')                     AS [ID], 
                 scandata.value('(@OccurrenceID)[1]', 'BIGINT')        AS [OccurrenceID], 
                 scandata.value('(CreativeMasterID)[1]', 'int')        AS creativemasterid , 
                 scandata.value('(@OldImageName)[1]', 'nvarchar(max)') AS [OldImageName], 
                 scandata.value('(@NewImageName)[1]', 'nvarchar(max)') AS [NewImagename], 
                 scandata.value('(@PageNumber)[1]', 'nvarchar(max)')   AS [PageNumber], 
                 scandata.value('(@OldPath)[1]', 'nvarchar(max)')      AS  [OldPath], 
                 scandata.value('(@RecordStatus)[1]', 'nvarchar(max)') AS [RecordStatus], 
                 scandata.value('(@FileType)[1]', 'nvarchar(max)')     AS [Filetype], 
                 scandata.value('(@NewPath)[1]', 'nvarchar(max)')      AS  [NewPath] 
          INTO   #tempscandata 
          FROM   @parameter.nodes('ScanData/OccurrenceImage') AS scandataproc( 
                 scandata 
                 ) 

          -- Iterate through temporary table   
          SELECT @NumberRecords = Count(*) 
          FROM   #tempscandata 

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
                SELECT @PatternMasterID = [PatternID] 
                FROM   [OccurrenceDetailCIR] 
                WHERE  [OccurrenceDetailCIRID] = @OccurrenceiD; 

                IF @Patternmasterid > 0 
                  BEGIN 
                      SET @IsvalidOccurrenceID=1 
                  END 
                ELSE 
                  BEGIN 
                      SET @IsvalidOccurrenceID=0 
                  END 

                IF EXISTS (SELECT 1 
                           FROM   [Pattern] 
                           WHERE  [Pattern].[PatternID] = @PatternMasterID 
                                  AND [CreativeID] IS NOT NULL) 
                  BEGIN 
                      -- Set Creative master   
                      SELECT @creativemasterid = [CreativeID] 
                      FROM   [Pattern] 
                      WHERE  [Pattern].[PatternID] = @PatternMasterID 

                      SET @ExistingCreativeMaster=1 
                  END 
                ELSE 
                  BEGIN 
                      -- Creative master record does not exist  
                      SET @creativemasterid=0 
                      SET @ExistingCreativeMaster=0 
                  END 

                IF @IsvalidOccurrenceID = 1 
                   AND @ExistingCreativeMaster = 0 
                  BEGIN 
                      SELECT @adid = [AdID] 
                      FROM   [OccurrenceDetailCIR] 
                      WHERE  [OccurrenceDetailCIRID] = @OccurrenceiD 

                      IF EXISTS(SELECT 1 
                                FROM   [Creative] 
                                WHERE  [AdId] = @adid 
                                       AND primaryindicator = 1 
                                       AND [SourceOccurrenceId] IS NOT NULL) 
                        BEGIN 
                            SET @isPrimary=0 
                        END 
                      ELSE 
                        BEGIN 
                            SET @isprimary=1 
                        END 

                      INSERT INTO [Creative] 
                                  ([AdId], 
                                   [SourceOccurrenceId], 
                                   primaryindicator, 
                                   creativetype) 
                      VALUES      ( @adid, 
                                    @OccurrenceiD, 
                                    @isprimary, 
                                    @FileType ) 

                      SET @CreativemasterID=Scope_identity(); 

                      PRINT @creativemasterid 

                      -- Update pattern master with newly created creative master record   
                      UPDATE [Pattern] 
                      SET    [CreativeID] = @CreativemasterID 
                      WHERE  [Pattern].[PatternID] = @PatternMasterID 
                             AND [CreativeID] IS NULL 
                  END 
                ELSE IF @IsvalidOccurrenceID = 0 
                  BEGIN 
                      UPDATE #tempscandata 
                      SET    recordstatus = 'Invalid Occurrence' 
                      WHERE  id = @Index 
                  END 

                IF @IsvalidOccurrenceID = 1 
                  BEGIN 
                      IF NOT EXISTS(SELECT 1 
                                    FROM   creativedetailcir 
                                    WHERE  creativemasterid = @CreativemasterID 
                                           AND pagenumber = @PageNumber) 
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

                            UPDATE creativedetailcir 
                            SET    creativeassetname = Cast( 
                                   @CreativeDetailsCIRID 
                                                       AS 
                                                       VARCHAR 
                                                       ) 
                                                       + '.' + @FileType, 
                                   creativerepository = @mediaStream + '\' 
                                                        + Cast(@CreativemasterID 
                                                        AS 
                                                        VARCHAR) 
                                                        + '\Original\', 
                                   creativefiletype = @FileType 
                            WHERE  creativedetailid = @CreativeDetailsCIRID 

                            UPDATE #tempscandata 
                            SET    creativemasterid = @CreativemasterID, 
                                   newimagename = Cast(@CreativeDetailsCIRID AS 
                                                  VARCHAR) 
                                                  + '.' + @FileType, 
                                   newpath = @basePath + '\' + @mediaStream + 
                                             '\' 
                                             + Cast(@CreativemasterID AS VARCHAR 
                                             ) 
                                             + '\Original\' 
                                             + Cast(@CreativeDetailsCIRID AS 
                                             VARCHAR) 
                                             + '.' + @FileType, 
                                   recordstatus = 'Pending' 
                            WHERE  id = @Index 
                        END 
                      ELSE 
                        BEGIN 
                            SELECT @CreativeDetailsCIRID = creativedetailid 
                            FROM   creativedetailcir 
                            WHERE  creativemasterid = @CreativemasterID 
                                   AND pagenumber = @PageNumber 

                            UPDATE creativedetailcir 
                            SET    creativeassetname = Cast( 
                                   @CreativeDetailsCIRID 
                                                       AS 
                                                       VARCHAR 
                                                       ) 
                                                       + '.' + @FileType, 
                                   creativerepository = @mediaStream + '\' 
                                                        + Cast(@CreativemasterID 
                                                        AS 
                                                        VARCHAR) 
                                                        + '\Original\', 
                                   creativefiletype = @FileType 
                            WHERE  creativedetailid = @CreativeDetailsCIRID 

                            UPDATE #tempscandata 
                            SET    creativemasterid = @CreativemasterID, 
                                   newimagename = Cast(@CreativeDetailsCIRID AS 
                                                  VARCHAR) 
                                                  + '.' + @FileType, 
                                   newpath = @basePath + '\' + @mediaStream + 
                                             '\' 
                                             + Cast(@CreativemasterID AS VARCHAR 
                                             ) 
                                             + '\Original\' 
                                             + Cast(@CreativeDetailsCIRID AS 
                                             VARCHAR) 
                                             + '.' + @FileType, 
                                   recordstatus = 'Pending' 
                            WHERE  id = @Index 
                        END 
                  END 

                -- Update Status for OccurrenceDetailsCIR or OccurrenceDetailsPUB   
                EXEC Sp_updateoccurrencestagestatus 
                  @OccurrenceID, 
                  3 

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
          RAISERROR ('sp_CircularScanData: %d: %s',16,1,@error,@message,@lineNo); 
      END CATCH 
  END
