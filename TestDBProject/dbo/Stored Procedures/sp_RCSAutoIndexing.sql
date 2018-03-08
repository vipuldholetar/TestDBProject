
-- =============================================     
-- Author:    Nagarjuna     
-- Create date: 04/16/2015     
-- Description:  RCS Auto Indexing main procedure     
-- Query : exec sp_RCSAutoIndexing  
-- =============================================    
CREATE PROCEDURE [sp_RCSAutoIndexing] 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          DECLARE @TempAutoIndexingCreativeStgIds TABLE 
            ( 
               [RowId]                   INT IdENTITY (1, 1), 
               [PatternMasterStgId]  INT NULL, 
               [CreativeMasterStgId] INT NULL, 
               [AutoIndexing]            BIT NULL, 
               [UseCase]                 CHAR(2) NULL, 
               [Status]                  VARCHAR(max) NULL 
            ) 
          DECLARE @CountCreativeIds        INT, 
                  @PTR                     INT, 
                  @CreativeMasterStgId INT, 
                  @PatternMasterStgId  INT, 
                  @RCSCreativeId           VARCHAR(50), 
                  @AutoIndexing            BIT, 
                  @UseCase                 CHAR(2), 
                  @CreativeMasterId        INT, 
                  @PatterMasterId          INT, 
                  @Status                  VARCHAR(max), 
                  @CustomMessage           VARCHAR(100) 

          --@TempAutoIndexingCreativeStgIds Table for getting all records for Auto Indexing needs to be done.
          -- Inserting values to @TempAutoIndexingCreativeStgIds table     
          INSERT INTO @TempAutoIndexingCreativeStgIds 
                      ([PatternMasterStgId], 
                       [CreativeMasterStgId], 
                       [AutoIndexing], 
                       [usecase], 
                       [status]) 
          SELECT [PatternStagingID], 
                 [CreativeStgID], 
                 AutoIndexing, 
                 CreativeIdAcIdUseCase, 
                 NULL 
          FROM   [PatternStaging] 
          WHERE  [CreativeStgID] IS NOT NULL 
                 AND AutoIndexing = 1 

          SELECT @COUNTCREATIVEIdS = 0, 
                 @PTR = 1 

          SELECT @CountCreativeIds = Count([CreativeMasterStgId]) 
          FROM   @TempAutoIndexingCreativeStgIds 

          -- Looping through CreativeStgId's count     
          WHILE ( @CountCreativeIds > 0 ) 
            BEGIN 
                BEGIN try 
                    SELECT @CountCreativeIds = @CountCreativeIds - 1 

                    -- Get PatternMasterStgId from @TempAutoIndexingCreativeStgIds   
                    SELECT @PatternMasterStgId = [PatternMasterStgId] 
                    FROM   @TempAutoIndexingCreativeStgIds 
                    WHERE  rowId = @PTR 

                    -- Get CreativeMasterStgId from @TempAutoIndexingCreativeStgIds  
                    SELECT @CreativeMasterStgId = [CreativeMasterStgId] 
                    FROM   @TempAutoIndexingCreativeStgIds 
                    WHERE  rowId = @PTR 

                    -- Get AutoIndexing from @TempAutoIndexingCreativeStgIds     
                    SELECT @AutoIndexing = AutoIndexing 
                    FROM   @TempAutoIndexingCreativeStgIds 
                    WHERE  rowId = @PTR 

                    -- Get UseCase from @TempAutoIndexingCreativeStgIds     
                    SELECT @UseCase = usecase 
                    FROM   @TempAutoIndexingCreativeStgIds 
                    WHERE  rowId = @PTR 

                    SELECT 
                @Status = 
                'Auto Indexing not processed due to usecase not matched' 

                    SELECT @CustomMessage = '' 

                    IF ( @UseCase = 'NN' ) 
                      BEGIN 
                          EXEC sp_RCSAutoIndexingNN 
                            @CreativeMasterStgId, 
                            @PatternMasterStgId, 
                            @AutoIndexing, 
                            @CustomMessage output 

                          PRINT( 'CustomMessage- ' + @CustomMessage ) 
                      END 

                    IF( @UseCase = 'NE' ) 
                      BEGIN 
                          EXEC sp_RCSAutoIndexingNE 
                            @CreativeMasterStgId, 
                            @PatternMasterStgId, 
                            @AutoIndexing, 
                            @CustomMessage output 

                          PRINT( 'CustomMessage- ' + @CustomMessage ) 
                      END 

                    IF( @UseCase = 'EN' ) 
                      BEGIN 
                          EXEC sp_RCSAutoIndexingEN 
                            @CreativeMasterStgId, 
                            @PatternMasterStgId, 
                            @AutoIndexing, 
                            @CustomMessage output 

                          PRINT( 'CustomMessage- ' + @CustomMessage ) 
                      END 

                    IF( @UseCase = 'EE' ) 
                      BEGIN 
                          EXEC sp_RCSAutoIndexingEE 
                            @CreativeMasterStgId, 
                            @PatternMasterStgId, 
                            @AutoIndexing, 
                            @CustomMessage output 

                          PRINT( 'CustomMessage- ' + @CustomMessage ) 
                      END 

                    --Update the status in @TempAutoIndexingCreativeStgIdstable     
                    IF ( @CustomMessage IS NULL 
                          OR @CustomMessage = '' ) 
                      BEGIN 
                          UPDATE @TempAutoIndexingCreativeStgIds 
                          SET    [Status] = @Status 
                          WHERE  RowId = @PTR 
                      END 
                    ELSE 
                      BEGIN 
                          UPDATE @TempAutoIndexingCreativeStgIds 
                          SET    [Status] = @CustomMessage 
                          WHERE  RowId = @PTR 
                      END 

                    SET @PTR = @PTR + 1 
                END try 

                BEGIN catch 
                    PRINT( @CustomMessage ) 

                    UPDATE @TempAutoIndexingCreativeStgIds 
                    SET    [Status] = @CustomMessage 
                    WHERE  RowId = @PTR 

                    SET @PTR = @PTR + 1 
                END catch 
            END 

          SELECT * 
          FROM   @TempAutoIndexingCreativeStgIds 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_RCSAutoIndexing: %d: %s',16,1,@Error,@Message,@LineNo); 
      END catch; 
  END;