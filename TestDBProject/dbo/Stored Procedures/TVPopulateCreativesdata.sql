

CREATE PROCEDURE [dbo].[TVPopulateCreativesdata] 

AS 

  BEGIN 

      DECLARE @PatternMasterStagingID INT, 

              @TVCreativeID          VARCHAR(250), 

              @occuranceid            AS INT, 

              @creativemasteridentity AS INT 

      DECLARE autoindexingcursor CURSOR -- Declare cursor 

      local scroll static FOR 

        SELECT  [PatternStagingID] 

        FROM   [PatternStaging]

        inner join [TVPattern] on [TVPattern].[TVPatternCODE]=[PatternStaging].[CreativeSignature] WHERE [CreativeStgID] IS NULL 



      OPEN autoindexingcursor -- open the cursor 

      FETCH next FROM autoindexingcursor INTO @PatternMasterStagingID 



      --PRINT @PatternMasterStagingID -- print the name 

      WHILE @@FETCH_STATUS = 0 

        BEGIN 

            SELECT @TVCreativeID = [CreativeSignature] 

            FROM   [PatternTVStaging] 

            WHERE  [PatternStagingTVID] = @PatternMasterStagingID 



            SELECT @occuranceid = (SELECT TOP 1 [OccurrenceDetailTVID] 

                                   FROM   [dbo].[OccurrenceDetailTV]

                                   WHERE  [PRCODE]= @TVCreativeID 

                                   ORDER  BY [OccurrenceDetailTVID]); 



            INSERT INTO [CreativeStaging] ([CreatedDT],Deleted,[OccurrenceID])

            VALUES     ( Getdate(), 

                         0, 
                         null) 



            SELECT @creativemasteridentity = @@identity 



           INSERT INTO [CreativeDetailStagingTV]( 
                                [CreativeStgMasterID], 
                                MediaFormat, 
                                MediaFilepath, 
                                MediaFileName, 
                                FileSize 
                                )

            VALUES     (@creativemasteridentity, 

                        'mpg', 

                        '\TV\'+convert(varchar,@creativemasteridentity)+'\', 

                        convert(varchar,dbo.TVGetSplitStringByRowNo(@TVCreativeID,'.',1))+'.mpg', 

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