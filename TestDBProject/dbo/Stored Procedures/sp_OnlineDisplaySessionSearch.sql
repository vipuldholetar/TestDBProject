

-- ======================================================================================================
-- Author            : Ramesh Bangi  
-- Create date       : 9/7/2015 
-- Description       : Get Session Data for Online Display Work Queue  
-- Execute           : [sp_OnlineDisplaySessionSearch] 1,-1,0,'08/02/2015','09/09/2015' 
-- Updated By        : Arun Nair on 01/20/2016 - Changed Capturefromdate-Todate NVARCHAR to VARCHAR                          
--=======================================================================================================
CREATE PROCEDURE [dbo].[sp_OnlineDisplaySessionSearch] (@LanguageId  AS INT, 
                                                       @WebsiteId   AS INT, 
                                                       @RichMedia   AS BIT, 
                                                       @CaptureFrom AS VARCHAR( 
30), 
                                                       @CaptureTo   AS VARCHAR( 
30)) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @Stmnt AS NVARCHAR(4000)='' 
      DECLARE @SelectStmnt AS VARCHAR(max)='' 
      DECLARE @Where AS VARCHAR(max)='' 
      DECLARE @Groupby AS VARCHAR(max)='' 
      DECLARE @Orderby AS VARCHAR(max)='' 
      DECLARE @MediaStream AS VARCHAR(max) 

      --DECLARE @CSCountStmnt AS NVARCHAR(MAX) 
      BEGIN try 
          SELECT @MediaStream = configurationid 
          FROM   [Configuration] 
          WHERE  systemname = 'ALL' 
                 AND componentname = 'Media Stream' 
                 AND valuetitle = 'Online Display' 

          SET @SelectStmnt= 
          ' SELECT    WorkType,CaptureDate,Count(distinct CreativeSignature) AS CreativeSignatureCount,TotalQScore,LanguageId FROM [dbo].[vw_OnlineDisplayWorkQueueSessionData] ' 
          SET @Where=' WHERE (1=1) AND  MediaStream=''' 
                     + @MediaStream + '''' 

          IF( @LanguageId IS NOT NULL ) 
            BEGIN 
                SET @Where=@where + ' AND [LanguageId]=' 
                           + CONVERT(VARCHAR, @LanguageId) + '' 
            END 

          IF( @WebsiteId <>- 1 ) 
            BEGIN 
                SET @Where=@where + ' AND WebsiteId=' 
                           + CONVERT(VARCHAR, @WebsiteId) + '' 
            END 

          --IF(@RichMedia <> 0) 
          --  BEGIN 
          --     SET @Where=' AND RichMedia='+@RichMedia 
          --  END 
          IF( @CaptureFrom <> '' 
              AND @CaptureTo <> '' ) 
            BEGIN 
                SET @Where= @where 
                            + ' AND CaptureDate Between  ''' 
                            + CONVERT(VARCHAR, Cast(@CaptureFrom AS DATE), 101) 
                            + ''' AND  ''' 
                            + CONVERT(VARCHAR, Cast(@CaptureTo AS DATE), 101) 
                            + '''' 
            END 

          SET @Groupby=' GROUP BY WorkType,CaptureDate,TotalQScore,LanguageId' 
          SET @Orderby=' Order BY WorkType ASC,CaptureDate DESC ' 
          SET @Stmnt=@SelectStmnt + @Where + @Groupby + @Orderby 

          PRINT @Stmnt 

          EXECUTE Sp_executesql 
            @Stmnt 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('[sp_OnlineDisplaySessionSearch]: %d: %s',16,1,@error, 
                     @message, 
                     @lineNo); 
      END catch 
  END