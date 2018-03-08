
-- ============================================================================================== 
-- Author      : Arun Nair 
-- Create date    : 12/14/2015 
-- Description    : Delete Creative Details 
-- Execution Process:  sp_DeleteImage 13386,'CIR' 
-- Updated By    :  
--       
-- ============================================================================================= 
CREATE PROCEDURE [dbo].[sp_DeleteImage] (@CreativeDetailId AS INT, 
                                         @Mediastream      AS NVARCHAR(5),
										  @isStaging as bit = 0) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @CreativeMasterid INT 
      DECLARE @TempCreativeDetailid INT 
      DECLARE @TempRowid INT 
      DECLARE @CountOriginal INT 
      DECLARE @Counter INT=1 

      BEGIN try 
          BEGIN TRANSACTION 

          IF( @Mediastream = 'CIR' ) --Circular CreativeDetail Delete 
            BEGIN 
                SELECT @CreativeMasterid = creativemasterid 
                FROM   creativedetailcir 
                WHERE  creativedetailid = @CreativeDetailId 

                UPDATE creativedetailcir 
                SET    deleted = 1 
                WHERE  creativedetailid = @CreativeDetailId 

                CREATE TABLE #tempcreativedetailcir 
                  ( 
                     rowid            INT IDENTITY(1, 1) NOT NULL, 
                     creativedetailid INT NOT NULL, 
                     creativemasterid INT NOT NULL, 
                     pagenumber       INT NULL, 
                  ) 

                INSERT INTO #tempcreativedetailcir 
                            (creativedetailid, 
                             creativemasterid, 
                             pagenumber) 
                SELECT creativedetailid, 
                       creativemasterid, 
                       pagenumber 
                FROM   creativedetailcir 
                WHERE  creativemasterid = @CreativeMasterid 
                       AND deleted = 0 

                SELECT @CountOriginal = Count(*) 
                FROM   #tempcreativedetailcir 

                WHILE ( @Counter <= @CountOriginal ) 
                  BEGIN 
                      SELECT @TempCreativeDetailid = creativedetailid, 
                             @TempRowid = [rowid] 
                      FROM   #tempcreativedetailcir 
                      WHERE  [rowid] = @Counter 

                      UPDATE creativedetailcir 
                      SET    pagenumber = @TempRowid, 
                             deleted = 0 
                      WHERE  creativedetailid = @TempCreativeDetailid 

                      SET @Counter=@Counter + 1 
                  END 

                DROP TABLE #tempcreativedetailcir 
            END 

          IF( @Mediastream = 'PUB' ) --Publication CreativeDetail Delete 
            BEGIN 
                SELECT @CreativeMasterid = creativemasterid 
                FROM   creativedetailpub 
                WHERE  creativedetailid = @CreativeDetailId 

                UPDATE creativedetailpub 
                SET    deleted = 1 
                WHERE  creativedetailid = @CreativeDetailId 

                CREATE TABLE #tempcreativedetailpub 
                  ( 
                     rowid            INT IDENTITY(1, 1) NOT NULL, 
                     creativedetailid INT NOT NULL, 
                     creativemasterid INT NOT NULL, 
                     pagenumber       INT NULL, 
                  ) 

                INSERT INTO #tempcreativedetailpub 
                            (creativedetailid, 
                             creativemasterid, 
                             pagenumber) 
                SELECT creativedetailid, 
                       creativemasterid, 
                       pagenumber 
                FROM   creativedetailpub 
                WHERE  creativemasterid = @CreativeMasterid 
                       AND deleted = 0 

                SELECT @CountOriginal = Count(*) 
                FROM   #tempcreativedetailpub 

                WHILE ( @Counter <= @CountOriginal ) 
                  BEGIN 
                      SELECT @TempCreativeDetailid = creativedetailid, 
                             @TempRowid = [rowid] 
                      FROM   #tempcreativedetailpub 
                      WHERE  [rowid] = @Counter 

                      UPDATE creativedetailpub 
                      SET    pagenumber = @TempRowid, 
                             deleted = 0 
                      WHERE  creativedetailid = @TempCreativeDetailid 

                      SET @Counter=@Counter + 1 
                  END 

                DROP TABLE #tempcreativedetailpub 
            END 

          IF( @Mediastream = 'EM' ) --Email CreativeDetail Delete 
            BEGIN 

			-- MI-1194  L.E. 10.11.17
			IF(@isStaging =0)
			BEGIN
				SELECT @CreativeMasterid = creativemasterid 
                FROM   creativedetailem 
                WHERE  [CreativeDetailsEMID] = @CreativeDetailId 

                UPDATE creativedetailem 
                SET    deleted = 1 
                WHERE  [CreativeDetailsEMID] = @CreativeDetailId 

                CREATE TABLE #tempcreativedetailemail 
                  ( 
                     rowid            INT IDENTITY(1, 1) NOT NULL, 
                     creativedetailid INT NOT NULL, 
                     creativemasterid INT NOT NULL, 
                     pagenumber       INT NULL, 
                  ) 

                INSERT INTO #tempcreativedetailemail 
                            (creativedetailid, 
                             creativemasterid, 
                             pagenumber) 
                SELECT [CreativeDetailsEMID], 
                       creativemasterid, 
                       pagenumber 
                FROM   creativedetailem 
                WHERE  creativemasterid = @CreativeMasterid 
                       AND deleted = 0 

                SELECT @CountOriginal = Count(*) 
                FROM   #tempcreativedetailemail 

                WHILE ( @Counter <= @CountOriginal ) 
                  BEGIN 
                      SELECT @TempCreativeDetailid = creativedetailid, 
                             @TempRowid = [rowid] 
                      FROM   #tempcreativedetailemail 
                      WHERE  [rowid] = @Counter 

                      UPDATE creativedetailem 
                      SET    pagenumber = @TempRowid, 
                             deleted = 0 
                      WHERE  [CreativeDetailsEMID] = @TempCreativeDetailid 

                      SET @Counter=@Counter + 1 
                  END 

                DROP TABLE #tempcreativedetailemail
			END
			ELSE
			BEGIN
				SELECT @CreativeMasterid = CreativestagingID 
                FROM   CreativeDetailStagingEM 
                WHERE  [CreativeDetailStagingEMID] = @CreativeDetailId 

                UPDATE CreativeDetailStagingEM 
                SET    deleted = 1 
                WHERE  [CreativeDetailStagingEMID] = @CreativeDetailId 

                CREATE TABLE #tempcreativedetailStagingemail 
                  ( 
                     rowid            INT IDENTITY(1, 1) NOT NULL, 
                     creativedetailid INT NOT NULL, 
                     creativemasterid INT NOT NULL, 
                     pagenumber       INT NULL, 
                  ) 

                INSERT INTO #tempcreativedetailStagingemail 
                            (creativedetailid, 
                             creativemasterid, 
                             pagenumber) 
                SELECT [CreativeDetailStagingEMID], 
                       CreativestagingID, 
                       pagenumber 
                FROM   CreativeDetailStagingEM 
                WHERE  CreativestagingID = @CreativeMasterid 
                       AND deleted = 0 

                SELECT @CountOriginal = Count(*) 
                FROM   #tempcreativedetailStagingemail 

                WHILE ( @Counter <= @CountOriginal ) 
                  BEGIN 
                      SELECT @TempCreativeDetailid = creativedetailid, 
                             @TempRowid = [rowid] 
                      FROM   #tempcreativedetailStagingemail 
                      WHERE  [rowid] = @Counter 

                      UPDATE CreativeDetailStagingEM 
                      SET    pagenumber = @TempRowid, 
                             deleted = 0 
                      WHERE  [CreativeDetailStagingEMID] = @TempCreativeDetailid 

                      SET @Counter=@Counter + 1 
                  END 

                DROP TABLE #tempcreativedetailStagingemail
			END
                 
            END 

          IF( @Mediastream = 'SOC' ) --Social CreativeDetail Delete 
            BEGIN 
                SELECT @CreativeMasterid = creativemasterid 
                FROM   creativedetailsoc 
                WHERE  [CreativeDetailSOCID] = @CreativeDetailId 

                UPDATE creativedetailsoc 
                SET    deleted = 1 
                WHERE  [CreativeDetailSOCID] = @CreativeDetailId 

                CREATE TABLE #tempcreativedetailsocial 
                  ( 
                     rowid            INT IDENTITY(1, 1) NOT NULL, 
                     creativedetailid INT NOT NULL, 
                     creativemasterid INT NOT NULL, 
                     pagenumber       INT NULL, 
                  ) 

                INSERT INTO #tempcreativedetailsocial 
                            (creativedetailid, 
                             creativemasterid, 
                             pagenumber) 
                SELECT [CreativeDetailSOCID], 
                       creativemasterid, 
                       pagenumber 
                FROM   creativedetailsoc 
                WHERE  creativemasterid = @CreativeMasterid 
                       AND deleted = 0 

                SELECT @CountOriginal = Count(*) 
                FROM   #tempcreativedetailsocial 

                WHILE ( @Counter <= @CountOriginal ) 
                  BEGIN 
                      SELECT @TempCreativeDetailid = creativedetailid, 
                             @TempRowid = [rowid] 
                      FROM   #tempcreativedetailsocial 
                      WHERE  [rowid] = @Counter 

                      UPDATE creativedetailsoc 
                      SET    pagenumber = @TempRowid, 
                             deleted = 0 
                      WHERE  [CreativeDetailSOCID] = @TempCreativeDetailid 

                      SET @Counter=@Counter + 1 
                  END 

                DROP TABLE #tempcreativedetailsocial 
            END 

          IF( @Mediastream = 'WEB' ) --Web CreativeDetail Delete 
            BEGIN 
                SELECT @CreativeMasterid = creativemasterid 
                FROM   creativedetailweb 
                WHERE  [CreativeDetailWebID] = @CreativeDetailId 

                UPDATE creativedetailweb 
                SET    deleted = 1 
                WHERE  [CreativeDetailWebID] = @CreativeDetailId 

                CREATE TABLE #tempcreativedetailweb 
                  ( 
                     rowid            INT IDENTITY(1, 1) NOT NULL, 
                     creativedetailid INT NOT NULL, 
                     creativemasterid INT NOT NULL, 
                     pagenumber       INT NULL, 
                  ) 

                INSERT INTO #tempcreativedetailweb 
                            (creativedetailid, 
                             creativemasterid, 
                             pagenumber) 
                SELECT [CreativeDetailWebID], 
                       creativemasterid, 
                       pagenumber 
                FROM   creativedetailweb 
                WHERE  creativemasterid = @CreativeMasterid 
                       AND deleted = 0 

                SELECT @CountOriginal = Count(*) 
                FROM   #tempcreativedetailweb 

                WHILE ( @Counter <= @CountOriginal ) 
                  BEGIN 
                      SELECT @TempCreativeDetailid = creativedetailid, 
                             @TempRowid = [rowid] 
                      FROM   #tempcreativedetailweb 
                      WHERE  [rowid] = @Counter 

                      UPDATE creativedetailweb 
                      SET    pagenumber = @TempRowid, 
                             deleted = 0 
                      WHERE  [CreativeDetailWebID] = @TempCreativeDetailid 

                      SET @Counter=@Counter + 1 
                  END 

                DROP TABLE #tempcreativedetailweb 
            END 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_DeleteImage: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 
      END catch 
  END
