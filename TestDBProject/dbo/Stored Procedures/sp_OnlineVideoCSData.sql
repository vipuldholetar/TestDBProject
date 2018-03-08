
-- ======================================================================== 
-- Author    : Ramesh Bangi  
-- Create date  : 9/18/2015 
-- Description  : Get Creative Signature Data for Online Video Work Queue  
-- Execution  : [dbo].[sp_OnlineVideoCSData]  1,'','Ingestion','9/1/2015 12:00:00 AM' 
-- Updated By  :  
--        : Karunakar on 30th Nov 2015,Removing Selection of Minimum OccurrenceID. 
--========================================================================= 
CREATE PROCEDURE [dbo].[sp_OnlineVideoCSData] (@LanguageId  AS INTEGER, 
                                              @MediaOutlet VARCHAR(max), 
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
          SET @Where=' where (1=1) ' 

          IF( @CaptureDate IS NOT NULL ) 
            BEGIN 
                SET @Where= @Where + ' AND	CaptureDate=''' 
                            + CONVERT(VARCHAR, Cast(@CaptureDate AS DATE)) 
                            + '''' 
            END 

          SET @SelectStmnt= 
          'SELECT ScoreQ,CreativeSignature,MediaOutlet,count(b.OccurrenceId) as OccurrenceCount,'''' AS Occurrencelist   FROM [dbo].[vw_OnlineVideoWorkQueueSessionData] b' 

          IF( @LanguageId IS NOT NULL ) 
            BEGIN 
                SET @Where= @Where + ' AND	LanguageId= ' 
                            + CONVERT(VARCHAR, @LanguageId) + '' 
            END 

          IF( @MediaOutlet <> '' ) 
            BEGIN 
                SET @Where= @Where + ' AND	MediaOutlet= ''' 
                            + CONVERT(VARCHAR, @MediaOutlet) + '''' 
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

          RAISERROR ('[dbo].[sp_OnlineVideoCSData] : %d: %s',16,1,@error, 
                     @message, 
                     @lineNo); 
      END catch 
  END
