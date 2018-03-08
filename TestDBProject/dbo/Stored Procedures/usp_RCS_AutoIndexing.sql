
-- =============================================     
-- Author:    Nagarjuna     
-- Create date: 04/16/2015     
-- Description:  RCS Auto Indexing main procedure     
-- Query : exec Usp_rcs_autoindexing  
-- =============================================    
CREATE PROCEDURE [dbo].[usp_RCS_AutoIndexing] 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          DECLARE @tempautoindexingcreativestagingids TABLE 
            ( 
               [rowid]                   INT IDENTITY (1, 1), 
               [patternmasterstagingid]  INT NULL, 
               [CreativeStagingID] INT NULL, 
               [autoindexing]            BIT NULL, 
               [usecase]                 CHAR(2) NULL, 
               [status]                  VARCHAR(max) NULL 
            ) 
          DECLARE @COUNTCREATIVEIDS        INT, 
                  @PTR                     INT, 
                  @CreativeStagingID INT, 
                  @PatternMasterStagingID  INT, 
                  @RCSCreativeID           VARCHAR(50), 
                  @AutoIndexing            BIT, 
                  @UseCase                 CHAR(2), 
                  @CreativeMasterID        INT, 
                  @PatterMasterID          INT, 
                  @Status                  VARCHAR(max), 
                  @CustomMessage           VARCHAR(100) 

          --@tempautoindexingcreativestagingids Table for getting all records for Auto Indexing needs to be done.
          -- Inserting values to @tempautoindexingcreativestagingids table     
          INSERT INTO @tempautoindexingcreativestagingids 
                      ([patternmasterstagingid], 
                       [CreativeStagingID], 
                       [autoindexing], 
                       [usecase], 
                       [status]) 
          SELECT patternmasterstagingid, 
                 CreativeStagingID, 
                 autoindexing, 
                 creativeidacidusecase, 
                 NULL 
          FROM   [patternmasterstaging] 
          WHERE  CreativeStagingID IS NOT NULL 
                 AND autoindexing = 1 

          SELECT @COUNTCREATIVEIDS = 0, 
                 @PTR = 1 

          SELECT @COUNTCREATIVEIDS = Count(CreativeStagingID) 
          FROM   @tempautoindexingcreativestagingids 

          -- Looping through CreativeStagingID's count     
          WHILE ( @COUNTCREATIVEIDS > 0 ) 
            BEGIN 
                BEGIN try 
                    SELECT @COUNTCREATIVEIDS = @COUNTCREATIVEIDS - 1 

                    -- Get PatternMasterStagingID from @tempautoindexingcreativestagingids   
                    SELECT @PatternMasterStagingID = patternmasterstagingid 
                    FROM   @tempautoindexingcreativestagingids 
                    WHERE  rowid = @PTR 

                    -- Get CreativeStagingID from @tempautoindexingcreativestagingids  
                    SELECT @CreativeStagingID = CreativeStagingID 
                    FROM   @tempautoindexingcreativestagingids 
                    WHERE  rowid = @PTR 

                    -- Get AutoIndexing from @tempautoindexingcreativestagingids     
                    SELECT @AutoIndexing = autoindexing 
                    FROM   @tempautoindexingcreativestagingids 
                    WHERE  rowid = @PTR 

                    -- Get UseCase from @tempautoindexingcreativestagingids     
                    SELECT @UseCase = usecase 
                    FROM   @tempautoindexingcreativestagingids 
                    WHERE  rowid = @PTR 

                    SELECT 
                @Status = 
                'Auto Indexing not processed due to usecase not matched' 

                    SELECT @CustomMessage = '' 

                    IF ( @UseCase = 'NN' ) 
                      BEGIN 
                          EXEC Usp_rcsaui_case_nn 
                            @CreativeStagingID, 
                            @PatternMasterStagingID, 
                            @AutoIndexing, 
                            @CustomMessage output 

                          PRINT( 'CustomMessage- ' + @CustomMessage ) 
                      END 

                    IF( @UseCase = 'NE' ) 
                      BEGIN 
                          EXEC Usp_rcsaui_case_ne 
                            @CreativeStagingID, 
                            @PatternMasterStagingID, 
                            @AutoIndexing, 
                            @CustomMessage output 

                          PRINT( 'CustomMessage- ' + @CustomMessage ) 
                      END 

                    IF( @UseCase = 'EN' ) 
                      BEGIN 
                          EXEC Usp_rcsaui_case_en 
                            @CreativeStagingID, 
                            @PatternMasterStagingID, 
                            @AutoIndexing, 
                            @CustomMessage output 

                          PRINT( 'CustomMessage- ' + @CustomMessage ) 
                      END 

                    IF( @UseCase = 'EE' ) 
                      BEGIN 
                          EXEC Usp_rcsaui_case_ee 
                            @CreativeStagingID, 
                            @PatternMasterStagingID, 
                            @AutoIndexing, 
                            @CustomMessage output 

                          PRINT( 'CustomMessage- ' + @CustomMessage ) 
                      END 

                    --Update the status in @tempautoindexingcreativestagingidstable     
                    IF ( @CustomMessage IS NULL 
                          OR @CustomMessage = '' ) 
                      BEGIN 
                          UPDATE @tempautoindexingcreativestagingids 
                          SET    status = @Status 
                          WHERE  rowid = @PTR 
                      END 
                    ELSE 
                      BEGIN 
                          UPDATE @tempautoindexingcreativestagingids 
                          SET    status = @CustomMessage 
                          WHERE  rowid = @PTR 
                      END 

                    SET @PTR = @PTR + 1 
                END try 

                BEGIN catch 
                    PRINT( @CustomMessage ) 

                    UPDATE @tempautoindexingcreativestagingids 
                    SET    status = @CustomMessage 
                    WHERE  rowid = @PTR 

                    SET @PTR = @PTR + 1 
                END catch 
            END 

          SELECT * 
          FROM   @tempautoindexingcreativestagingids 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('Usp_rcs_autoindexing: %d: %s',16,1,@error,@message,@lineNo); 
      END catch; 
  END;