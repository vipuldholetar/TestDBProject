
-- ======================================================================== 
-- Author    : Ramesh Bangi  
-- Create date  : 9/7/2015 
-- Description  : Get Creative Signature Data for Online Display Work Queue  
-- Execution  : [dbo].[sp_OnlineDisplayCSData] 1,-1,0,'Ingestion','8/31/2015 12:00:00 AM' 
-- Updated By  : Updated By Karunakar on 16th Sep 2015,Adding ScoreQ and MediaOutlet. 
--        : Karunakar on 30th Nov 2015,Removing Selection of Minimum OccurrenceID. 
--========================================================================= 
CREATE PROCEDURE [dbo].[sp_OnlineDisplayCSData] (@LanguageId  AS INTEGER, 
                                                @Websiteid   AS INTEGER, 
                                                @RichMedia   BIT, 
                                                @WorkType    VARCHAR(200), 
                                                @CaptureDate VARCHAR(30)) 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @Stmnt AS NVARCHAR(4000)='' 
      DECLARE @SelectStmnt AS VARCHAR(max)='' 
      DECLARE @Where AS VARCHAR(max)='' 
      DECLARE @Groupby AS VARCHAR(max)='' 
      DECLARE @Orderby AS VARCHAR(max)='' 
      DECLARE @CSOccCntStmnt AS VARCHAR(max)='' 

      BEGIN try 
          --SET @CSOccCntStmnt='(SELECT COUNT(a.OccurrenceId) as OccurrenceCount From  [dbo].[vw_OnlineDisplayWorkQueueSessionData] a Where a.CreativeSignature=b.CreativeSignature ' --AND a.MarketId=b.MarketId '   
          SET @Where=' where (1=1) ' 

          IF( @CaptureDate IS NOT NULL ) 
            BEGIN 
                SET @Where= @Where + ' AND	CaptureDate=''' 
                            + CONVERT(VARCHAR, Cast(@CaptureDate AS DATE)) 
                            + '''' 
            --SET @CSOccCntStmnt=@CSOccCntStmnt + ' AND CaptureDate ='''+ Convert(varchar,@CaptureDate) + ''') AS OccurrenceCount' 
            END 

          SET @SelectStmnt= 
          'SELECT ScoreQ,CreativeSignature,MediaOutlet,count(b.OccurrenceId) as OccurrenceCount,''''  AS Occurrencelist   FROM [dbo].[vw_OnlineDisplayWorkQueueSessionData] b' 

          IF( @LanguageId IS NOT NULL ) 
            BEGIN 
                SET @Where= @Where + ' AND	LanguageId= ' 
                            + CONVERT(VARCHAR, @LanguageId) + '' 
            END 

          IF( @Websiteid <>- 1 ) 
            BEGIN 
                SET @Where= @Where + ' AND	WebsiteId= ''' 
                            + CONVERT(VARCHAR, @Websiteid) + '''' 
            --SET @CSOccCntStmnt=@CSOccCntStmnt+ ' AND WebsiteId= '''+Convert(NVARCHAR,@Websiteid)+'''' 
            END 

          SET @Groupby= ' GROUP BY CreativeSignature,ScoreQ,MediaOutlet ' 
          --,MediaOutlet' 
          SET @Orderby='Order By CreativeSignature ASC' 
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

          RAISERROR ('[dbo].[sp_OnlineDisplayCSData]: %d: %s',16,1,@error, 
                     @message 
                     , 
                     @lineNo); 
      END catch 
  END
