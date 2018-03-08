

CREATE PROCEDURE [dbo].[RCSPopulateAutoIndexingdata] 

AS 

  BEGIN 

      DECLARE @PatternMasterStagingID INT, 

              @RCSCreativeID          VARCHAR(250), 

              @occuranceid            AS INT, 

              @creativemasteridentity AS INT 

      DECLARE autoindexingcursor CURSOR -- Declare cursor 

      local scroll static FOR 

        SELECT TOP 5 [PatterStagingId] 

        FROM   [PatterStaging] 

        WHERE  [CreativeStgID] IS NULL 



      OPEN autoindexingcursor -- open the cursor 

      FETCH next FROM autoindexingcursor INTO @PatternMasterStagingID 



      --PRINT @PatternMasterStagingID -- print the name 

      WHILE @@FETCH_STATUS = 0 

        BEGIN 

            SELECT @RCSCreativeID = [rcscreativeid] 

            FROM   [patterndetailrastaging ]

            WHERE  [PatternStgId] = @PatternMasterStagingID 



            SELECT @occuranceid = (SELECT TOP 1 [OccurrenceDetailRAID] 

                                   FROM   [dbo].[OccurrenceDetailRA] 

                                   WHERE  [RCSAcIdID] IN 

                   (SELECT [RCSAcIdID] 

                    FROM   [dbo].[rcsacidtorcscreativeidmap] 

                    WHERE  [RCSCreativeID] = @RCSCreativeID) 

                                   ORDER  BY [OccurrenceDetailRAID]); 



            INSERT INTO [CreativeStaging] 

            VALUES     ( NULL, 

                         0, 

                         NULL, 

                         NULL, 

                         NULL, 

                         NULL, 

                         NULL, 

                         NULL, 

                         Getdate(), 

                         NULL, 

                         @occuranceid,
						 
						 null,
						 
						 null,
						 
						 null) 



            SELECT @creativemasteridentity = @@identity 



            INSERT INTO [creativedetailsrastaging] 

            VALUES     (@creativemasteridentity, 

                        'wav', 

                        'D:\MCAP_Assets\Radio\', 

                        '6.mp3', 

                        100) 



            UPDATE [PatternStaging] 

            SET    [CreativeStgID] = @creativemasteridentity 

            WHERE  [PatternStagingId] = @PatternMasterStagingID 



            --PRINT @PatternMasterStagingID; 

            --print @occuranceid; 

            --print @RCSCreativeID; 

            --print @creativemasteridentity; 

            --print'----------------------------'; 

            FETCH next FROM autoindexingcursor INTO @PatternMasterStagingID 

        END 



      CLOSE autoindexingcursor -- close the cursor 

  END