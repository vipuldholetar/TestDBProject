
-- ===================================================================================================== 
-- Author    :  Karunakar 
-- Create date  :  15th December 2015 
-- Execution  :  sp_updatedPageNumbers 25005,'13633,13634,13635','3,2,1','CIRCULAR' 
-- Description  :  This Procedure is used to Updating Re Sequence of Page Numbers into CreativeDetails table 
-- Updated By  :   
-- ======================================================================================================= 
CREATE PROCEDURE [dbo].[sp_UpdatedPageNumbers] @CreativeMasterID     AS INT, 
                                               @creativeDetailIDList AS NVARCHAR (max), 
                                               @PageNumberList       AS NVARCHAR (max), 
                                               @MediaStream          AS NVARCHAR (50),
											   @isStaging as bit = 0 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 

          DECLARE @Counter AS INTEGER 
          DECLARE @RecordsCount AS INTEGER 
          DECLARE @PageNumberID AS INTEGER 
          DECLARE @CreativeTotalCounter AS INTEGER 
          DECLARE @CreativeTotalRecordsCount AS INTEGER 
          DECLARE @CreativeDetailID AS INTEGER 
          DECLARE @CreativeDetailPageNumber AS INTEGER 

          --Creating tempCreativeDetails table for Storing Initial CreativeDetails Lists 
          CREATE TABLE #tempcreativedetails 
            ( 
               id                   INT IDENTITY(1, 1), 
               creativedetailidtemp NVARCHAR(max) NOT NULL, 
               pagenumber           NVARCHAR(30) NULL 
            ) 

          --Creating tempPageDetails table for Storing Initial Page Number Lists 
          CREATE TABLE #temppagedetails 
            ( 
               id         INT IDENTITY(1, 1), 
               pagenumber NVARCHAR(30) NOT NULL 
            ) 

          --Inserting CreativeDetailID Lists 
          INSERT INTO #tempcreativedetails 
                      (creativedetailidtemp) 
          SELECT item 
          FROM   Splitstring('' + @creativeDetailIDList + '', ',') 

          --Inserting PageNumber Lists 
          INSERT INTO #temppagedetails 
                      (pagenumber) 
          SELECT item 
          FROM   Splitstring('' + @PageNumberList + '', ',') 

          --Counting total Records in tempPageDetails 
          SELECT @RecordsCount = Count(pagenumber) 
          FROM   #temppagedetails 

          SET @Counter=1 

          WHILE @Counter <= @RecordsCount 
            BEGIN 
                SELECT @PageNumberID = pagenumber 
                FROM   #temppagedetails 
                WHERE  id = @Counter 

                UPDATE #tempcreativedetails 
                SET    pagenumber = @PageNumberID 
                WHERE  id = @Counter 

                SET @Counter=@Counter + 1 
            END 

          --Droping   #tempPageDetails Data 
          DROP TABLE #temppagedetails 

          --Updating CreativeDetails Records with Re Sequence Page Numbers  
          IF( @MediaStream = 'CIR' ) --Circular 
            BEGIN 
                SELECT @CreativeTotalRecordsCount = Count(pagenumber) 
                FROM   #tempcreativedetails 

                SET @CreativeTotalCounter=1 

                WHILE @CreativeTotalCounter <= @CreativeTotalRecordsCount 
                  BEGIN 
                      SELECT @CreativeDetailID = creativedetailidtemp, 
                             @CreativeDetailPageNumber = pagenumber 
                      FROM   #tempcreativedetails 
                      WHERE  id = @CreativeTotalCounter 

                      UPDATE creativedetailcir 
                      SET    pagenumber = @CreativeDetailPageNumber 
                      WHERE  creativedetailid = @CreativeDetailID 

                      SET @CreativeTotalCounter=@CreativeTotalCounter + 1 
                  END 
            END 

          IF( @MediaStream = 'PUB' ) --Publication 
            BEGIN 
                SELECT @CreativeTotalRecordsCount = Count(pagenumber) 
                FROM   #tempcreativedetails 

                SET @CreativeTotalCounter=1 

                WHILE @CreativeTotalCounter <= @CreativeTotalRecordsCount 
                  BEGIN 
                      SELECT @CreativeDetailID = creativedetailidtemp, 
                             @CreativeDetailPageNumber = pagenumber 
                      FROM   #tempcreativedetails 
                      WHERE  id = @CreativeTotalCounter 

                      UPDATE creativedetailpub 
                      SET    pagenumber = @CreativeDetailPageNumber 
                      WHERE  creativedetailid = @CreativeDetailID 

                      SET @CreativeTotalCounter=@CreativeTotalCounter + 1 
                  END 
            END 

          IF( @MediaStream = 'EM' ) --Email 
            BEGIN 
                SELECT @CreativeTotalRecordsCount = Count(pagenumber) 
                FROM   #tempcreativedetails 

                SET @CreativeTotalCounter=1 

                WHILE @CreativeTotalCounter <= @CreativeTotalRecordsCount 
                  BEGIN 
                      SELECT @CreativeDetailID = creativedetailidtemp, 
                             @CreativeDetailPageNumber = pagenumber 
                      FROM   #tempcreativedetails 
                      WHERE  id = @CreativeTotalCounter 

					  iF @isStaging= 0 
					  BEGIN
						   UPDATE creativedetailem 
						  SET    pagenumber = @CreativeDetailPageNumber 
						  WHERE  [CreativeDetailsEMID] = @CreativeDetailID 
					  END 
					  ELSE
					  BEGIN
						   UPDATE CreativeDetailStagingEM 
						  SET    pagenumber = @CreativeDetailPageNumber 
						  WHERE  [CreativeDetailStagingEMID] = @CreativeDetailID 
					  END
                     



                      SET @CreativeTotalCounter=@CreativeTotalCounter + 1 
                  END 
            END 

          IF( @MediaStream = 'SOC' ) --Social 
            BEGIN 
                SELECT @CreativeTotalRecordsCount = Count(pagenumber) 
                FROM   #tempcreativedetails 

                SET @CreativeTotalCounter=1 

                WHILE @CreativeTotalCounter <= @CreativeTotalRecordsCount 
                  BEGIN 
                      SELECT @CreativeDetailID = creativedetailidtemp, 
                             @CreativeDetailPageNumber = pagenumber 
                      FROM   #tempcreativedetails 
                      WHERE  id = @CreativeTotalCounter 

                      UPDATE creativedetailsoc 
                      SET    pagenumber = @CreativeDetailPageNumber 
                      WHERE  [CreativeDetailSOCID] = @CreativeDetailID 

                      SET @CreativeTotalCounter=@CreativeTotalCounter + 1 
                  END 
            END 

          IF( @MediaStream = 'WEB' ) --Wenbsite 
            BEGIN 
                SELECT @CreativeTotalRecordsCount = Count(pagenumber) 
                FROM   #tempcreativedetails 

                SET @CreativeTotalCounter=1 

                WHILE @CreativeTotalCounter <= @CreativeTotalRecordsCount 
                  BEGIN 
                      SELECT @CreativeDetailID = creativedetailidtemp, 
                             @CreativeDetailPageNumber = pagenumber 
                      FROM   #tempcreativedetails 
                      WHERE  id = @CreativeTotalCounter 

                      UPDATE creativedetailweb 
                      SET    pagenumber = @CreativeDetailPageNumber 
                      WHERE  [CreativeDetailWebID] = @CreativeDetailID 

                      SET @CreativeTotalCounter=@CreativeTotalCounter + 1 
                  END 
            END 

          --Droping   #tempCreativeDetails Data 
          DROP TABLE #tempcreativedetails 

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_updatedPageNumbers: %d: %s',16,1,@error,@message, 
                     @lineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END catch 
  END
