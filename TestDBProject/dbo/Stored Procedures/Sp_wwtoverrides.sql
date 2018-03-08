
-- ===========================================================================================
-- Author                         :      Ganesh prasad  
-- Create date                    :      10/16/2015  
-- Description                    :      This stored procedure is used for getting Data to "WWT Overrides" Report Dataset
-- Execution Process              :      [dbo].[sp_WWTOverrides]  
-- Updated By                     :        
-- ============================================================================================
CREATE PROCEDURE [dbo].[Sp_wwtoverrides] 
AS 
    IF 1 = 0 
      BEGIN 
          SET fmtonly OFF 
      END 

  BEGIN 
      SET nocount ON; 

      BEGIN try 
          IF Object_id('tempdb..#TempWWT') IS NOT NULL 
            DROP TABLE #tempwwt 

          CREATE TABLE #tempwwt 
            ( 
               id INT IDENTITY (1, 1),advertiser VARCHAR(max),adcode INT, 
               mediatype VARCHAR(max),creator VARCHAR(max), 
               cooppartner1 VARCHAR(max), 
               cooppartner2 VARCHAR(max),cooppartner3 VARCHAR(max) 
            ) 

          INSERT INTO #tempwwt 
          SELECT DISTINCT [dbo].[Advertiser].descrip AS Advertiser, 
                          [dbo].ad.[AdID] AS 
                          AdCode,[dbo].[Configuration].valuetitle AS 
                                 MediaType 
                          , 
                          [dbo].[user].fname + ' ' + [dbo].[user].lname AS 
                          Creator 
                          , 
                          [dbo].ad.coop1advid,[dbo].ad.coop2advid, 
                          [dbo].ad.coop3advid 
          FROM   [dbo].ad 
                 INNER JOIN [dbo].[Advertiser] 
                         ON [dbo].ad.[AdvertiserID] = [dbo].[Advertiser].advertiserid 
                 INNER JOIN [dbo].[Pattern] 
                         ON [dbo].[Pattern].[AdID] = [dbo].ad.[AdID] 
                 INNER JOIN [dbo].[user] 
                         ON [dbo].ad.createdby = [dbo].[user].userid 
                 INNER JOIN [dbo].[Configuration] 
                         ON [dbo].[Pattern].mediastream = 
                            [dbo].[Configuration].configurationid 
                 INNER JOIN adcoopcomp 
                         ON [dbo].adcoopcomp.[AdvertiserID] = [dbo].ad.[AdvertiserID] 
                            AND [dbo].adcoopcomp.coopcompcode = 'c' 

          --where convert(Date,Ad.Createdate )= convert(Date,GetDate() -1) --filters the records of previous day  
          --select * from #tempwwt  
          DECLARE @Count AS INTEGER=1 
          DECLARE @REcordCount AS INTEGER 
          DECLARE @AdidTemp AS INTEGER 
          DECLARE @CoopCompCodeCount AS INTEGER 

          SET @REcordCount=(SELECT Count(*) 
                            FROM   #tempwwt) 

          WHILE ( @Count <= @REcordCount ) 
            BEGIN 
                SELECT @AdidTemp = adcode 
                FROM   #tempwwt 
                WHERE  id = @Count 

                SELECT @CoopCompCodeCount = Count(coopcompcode) 
                FROM   adcoopcomp 
                WHERE  [AdCoopID] = @AdidTemp 
                       AND coopcompcode = 'C' 

                IF( @CoopCompCodeCount = 1 ) 
                  BEGIN 
                      UPDATE #tempwwt 
                      SET    cooppartner1 = 'C' 
                      WHERE  adcode = @AdidTemp 
                  END 
                ELSE IF ( @CoopCompCodeCount = 2 ) 
                  BEGIN 
                      UPDATE #tempwwt 
                      SET    [cooppartner1] = 'C',cooppartner2 = 'C' 
                      WHERE  adcode = @AdidTemp 
                  END 
                ELSE IF ( @CoopCompCodeCount = 3 ) 
                  BEGIN 
                      UPDATE #tempwwt 
                      SET    cooppartner1 = 'C',cooppartner2 = 'C', 
                             cooppartner3 = 'C' 
                      WHERE  adcode = @AdidTemp 
                  END 
                ELSE 
                  BEGIN 
                      UPDATE #tempwwt 
                      SET    cooppartner1 = NULL,cooppartner2 = NULL, 
                             cooppartner3 = NULL 
                      WHERE  adcode = @AdidTemp 
                  END 

                SET @Count=@Count + 1 
            END 

          SELECT * 
          FROM   #tempwwt 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(),@message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_TakeAsCoOp]: %d: %s',16,1,@error,@message,@lineNo); 
      END catch 
  END
