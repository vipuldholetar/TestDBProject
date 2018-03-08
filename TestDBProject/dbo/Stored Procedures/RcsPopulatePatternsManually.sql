-- ============================================= 

-- Author: Govardhan.R 

-- Create date: 08/15/2015 

-- Description: Create patterns data manually 

-- Query : exec [RcsPopulatePatternsManually]

-- ============================================= 
CREATE PROCEDURE [dbo].[RcsPopulatePatternsManually] 
AS 
  BEGIN 
      DECLARE @PatternMasterStagingID INT, 
              @RCSCreativeID          VARCHAR(250), 
              @occuranceid            AS INT, 
              @creativemasteridentity AS INT 

      DECLARE autoindexingcursor CURSOR -- Declare cursor  
      local scroll static FOR 
        SELECT [PatternStagingID] 
        FROM   [PatternStaging] 
        WHERE  [CreativeStgID] IS NULL 

      OPEN autoindexingcursor -- open the cursor  
      FETCH next FROM autoindexingcursor INTO @PatternMasterStagingID 

      WHILE @@FETCH_STATUS = 0 
        BEGIN 
            SELECT @RCSCreativeID = [RCSCreativeID] 
            FROM   [PatternDetailRAStaging]
            WHERE  [PatternStgID] = @PatternMasterStagingID 

            SELECT @occuranceid = (SELECT TOP 1 [OccurrenceDetailRAID] 
                                   FROM   [dbo].[OccurrenceDetailRA] 
                                   WHERE  [RCSAcIdID] IN 
                   (SELECT [RCSAcIdToRCSCreativeIdMapID] 
                    FROM   [dbo].[rcsacidtorcscreativeidmap] 
                    WHERE  [RCSCreativeID] = @RCSCreativeID) 
                                   ORDER  BY [OccurrenceDetailRAID]); 

            INSERT INTO [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID])
            VALUES      ( 0, 
                          Getdate(),
                          @occuranceid) 

            SELECT @creativemasteridentity = @@identity 

            INSERT INTO [CreativeDetailStagingRA] ([CreativeStgID],MediaFormat,MediaFilePath,MediaFileName,FileSize)
            VALUES      (@creativemasteridentity, 
                         'wav', 
                         '\RAD\'+convert(varchar,@creativemasteridentity)+'\Original\', 
                         @creativemasteridentity, 
                         100) 

            UPDATE [PatternStaging] 
            SET    [CreativeStgID] = @creativemasteridentity 
            WHERE  [PatternStagingID] = @PatternMasterStagingID 
            
            FETCH next FROM autoindexingcursor INTO @PatternMasterStagingID 
        END 

      CLOSE autoindexingcursor -- close the cursor  
  END