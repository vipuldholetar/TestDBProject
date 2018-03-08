
-- ============================================= 
-- Author:    Monika 
-- Create date: 1/14/15 
-- Description: To get Creative File Date in Ad class form 
-- Excecution: sp_CPGetCreativeFileDateInAdClassForm  
-- ============================================= 
CREATE PROCEDURE [dbo].[sp_CPGetCreativeFileDateInAdClassForm] (@MediaStream AS 
NVARCHAR(max), 
                                                                @AdID        AS 
INT) 
AS 
  BEGIN 
      DECLARE @MediaStreamValue AS NVARCHAR(max)='' 
      DECLARE @CreativeDate AS NVARCHAR(max) 

      SELECT @MediaStreamValue = value 
      FROM   [dbo].[Configuration] 
      WHERE  valuetitle = @MediaStream 

      BEGIN try 
          --IF(@MediaStreamValue='RAD') 
          --                BEGIN 
          --                  --Select * from CreativeDetailsRa 
          --   --Select @CreativeDate as CreativeFileDate 
          --                END 
          --IF(@MediaStreamValue='TV') 
          --                BEGIN 
          --                   --select * from CreativeDetailTV 
          --   --Select @CreativeDate as CreativeFileDate 
          --                END 
          --IF(@MediaStreamValue='OD') 
          --                BEGIN 
          --                    --select * from CreativeDetailODR 
          --  -- Select @CreativeDate as CreativeFileDate 
          --                END            
          --IF(@MediaStreamValue='CIN') 
          --                BEGIN 
          --                   --Select * from CreativeDetailCIN 
          --  -- Select @CreativeDate as CreativeFileDate 
          --                END     
          IF( @MediaStreamValue = 'OND' ) --Online Display 
            BEGIN 
                SELECT TOP 1 b.[CreativeFileDT] 
                FROM   [Creative] a, 
                       creativedetailond b 
                WHERE  a.[AdId] = @AdID 
                       AND a.primaryindicator = 1 
                       AND b.[CreativeMasterID] = a.pk_id 
            END 

          IF( @MediaStreamValue = 'ONV' ) --Online Video 
            BEGIN 
                SELECT TOP 1 b.[CreativeFileDT] 
                FROM   [Creative] a, 
                       creativedetailonv b 
                WHERE  a.[AdId] = @AdID 
                       AND a.primaryindicator = 1 
                       AND b.[CreativeMasterID] = a.pk_id 
            END 

          IF( @MediaStreamValue = 'MOB' ) --Mobile 
            BEGIN 
                SELECT TOP 1 b.[CreativeFileDT] 
                FROM   [Creative] a, 
                       creativedetailmob b 
                WHERE  a.[AdId] = @AdID 
                       AND a.primaryindicator = 1 
                       AND b.[CreativeMasterID] = a.pk_id 
            END 

          --IF(@MediaStreamValue='CIR')             --Circular 
          --                BEGIN 
          --                      --Select * from CreativeDetailCIR 
          --   Select @CreativeDate as CreativeFileDate 
          --                END      
          --IF(@MediaStreamValue='PUB')             --Mobile 
          --                BEGIN 
          --                      Select * from CreativeDetailPUB 
          --                END    
          IF( @MediaStreamValue = 'WEB' ) --Web 
            BEGIN 
                SELECT TOP 1 b.creativefiledate 
                FROM   [Creative] a, 
                       creativedetailweb b 
                WHERE  a.[AdId] = @AdID 
                       AND a.primaryindicator = 1 
                       AND b.creativemasterid = a.pk_id 
            END 

          IF( @MediaStreamValue = 'SOC' ) --Social 
            BEGIN 
                SELECT TOP 1 b.creativefiledate 
                FROM   [Creative] a, 
                       creativedetailsoc b 
                WHERE  a.[AdId] = @AdID 
                       AND a.primaryindicator = 1 
                       AND b.creativemasterid = a.pk_id 
            END 

          IF( @MediaStreamValue = 'EM' ) --Email 
            BEGIN 
                SELECT TOP 1 b.creativefiledate 
                FROM   [Creative] a, 
                       creativedetailem b 
                WHERE  a.[AdId] = @AdID 
                       AND a.primaryindicator = 1 
                       AND b.creativemasterid = a.pk_id 
            END 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_CPGetCreativeFileDateInAdClassForm: %d: %s',16,1,@error 
                     , 
                     @message,@lineNo); 
      END catch 
  END
