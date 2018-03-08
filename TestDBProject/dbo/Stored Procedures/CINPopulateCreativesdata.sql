

CREATE PROCEDURE [dbo].[CINPopulateCreativesdata] 

AS 

  BEGIN 

      DECLARE @PatternMasterStagingID INT, 

              @CINCreativeID          VARCHAR(250), 

              @occuranceid            AS INT, 

              @creativemasteridentity AS INT 

      DECLARE autoindexingcursor CURSOR -- Declare cursor 

      local scroll static FOR 

        SELECT [PatternStagingID] 

        FROM   [PatternStaging] 

        WHERE  [CreativeStgID] IS NULL 



      OPEN autoindexingcursor -- open the cursor 

      FETCH next FROM autoindexingcursor INTO @PatternMasterStagingID 



      --PRINT @PatternMasterStagingID -- print the name 

      WHILE @@FETCH_STATUS = 0 

        BEGIN 

            SELECT @CINCreativeID = [CreativeSignature] 

            FROM   [PatternStaging] 

            WHERE  [PatternStagingID] = @PatternMasterStagingID 



            SELECT @occuranceid = (SELECT TOP 1 [OccurrenceDetailCINID] 

                                   FROM   [dbo].[OccurrenceDetailCIN] 

                                   WHERE  [CreativeID]= @CINCreativeID 

                                   ORDER  BY [OccurrenceDetailCINID]); 



            INSERT INTO [CreativeStaging] ([CreatedDT],Deleted,[OccurrenceID])

            VALUES     ( Getdate(), 

                         0, 
                         @occuranceid) 



            SELECT @creativemasteridentity = @@identity 



            INSERT INTO [CreativeDetailStagingCIN] ([CreativeStagingID],CreativeFileType,CreativeRepository,CreativeAssetName,CreativeFileSize)

            VALUES     (@creativemasteridentity, 

                        'flv', 

                        '\CIN\'+convert(varchar,@creativemasteridentity)+'\', 

                        convert(varchar,@CINCreativeID)+'.flv', 

                        100) 



            UPDATE [PatternStaging] 

            SET    [CreativeStgID] = @creativemasteridentity 

            WHERE  [PatternStagingID] = @PatternMasterStagingID 



            --PRINT @PatternMasterStagingID; 

            --print @occuranceid; 

            --print @RCSCreativeID; 

            --print @creativemasteridentity; 

            --print'----------------------------'; 

            FETCH next FROM autoindexingcursor INTO @PatternMasterStagingID 

        END 



      CLOSE autoindexingcursor -- close the cursor 

  END