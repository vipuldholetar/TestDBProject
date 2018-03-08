
-- =================================================================================================
-- Author			: Arun Nair 
-- Create date		: 07/13/2015 
-- Description		: Stored procedure to Preview Creative Signature data 
-- Execution Process: sp_TelevisionWorkQueueCreativeSignaturePreviewData 'BZF7MRYG.PA0','JSNV'
-- Updated By		: Karunakar on 14th Sep 2015 
--					: Arun Nair on 09/14/2015 - CS Preview Query Optimised  
--					: Arun Nair on 11/24/2015 - Added AuditBy,AuditDTM Columns 
--					: Arun Nair on 01/20/2016 - Changed NVARCHAR to VARCHAR 
--					: Lisa East on 03/27/2017 -- Updates to view all query assigned to an occurrence
-- ====================================================================================================
CREATE PROCEDURE [dbo].[sp_TelevisionWorkQueueCreativeSignaturePreviewData] ( 
@CreativeSignatureId AS VARCHAR(50), 
@MediaOutlet         AS VARCHAR(50)) 
AS 
  BEGIN 
      SET nocount ON; 

      BEGIN try 
          SELECT [OccurrenceDetailTV].adlength                                AS 
                 [Length], 
                 ''                                                      AS 
                 Advertiser 
                 , 
                 [TVStation].stationfullname 
                 AS 
                 MarketMediaOutlet, 
                 [PatternStaging].[LanguageID], 
                 [dbo].[Language].[description]                    AS 
                 Language, 
                 [CreativeDetailStagingTV].mediaformat                         AS 
                 CreativeFileType, 
                 [CreativeDetailStagingTV].filesize                            AS 
                 CreativeFileSize, 
                 --( [dbo].[QueryDetail].querytext ) + ' | ' + 
                 --CONVERT(VARCHAR(max), [dbo].[QueryDetail].[QryAnswer]) AS 
                 --QAndA,  --L.E. 3.27.17 MI-918
				 [dbo].[QueryDetail].[QueryText],
                 [dbo].[QueryDetail].[QryAnswer],
                 ( [dbo].[user].fname + ' ' + [dbo].[user].lname )       AS 
                 AuditBy, 
                 CONVERT(VARCHAR(30), [PatternStaging].AuditedDT, 101)  AS 
                 AuditDTM 
          FROM   [OccurrenceDetailTV] 
                 INNER JOIN tvrecordingschedule 
                         ON [OccurrenceDetailTV].[TVRecordingScheduleID] = 
                            tvrecordingschedule.[TVRecordingScheduleID] 
                 INNER JOIN [TVStation] 
                         ON [tvrecordingschedule].[TVStationID] = 
                            [TVStation].[TVStationID] 
                 INNER JOIN [Market] 
                         ON [TVStation].[MarketID] = [Market].[MarketID] 
                 INNER JOIN [PatternStaging] 
                         ON [PatternStaging].[CreativeSignature] = 
                            [OccurrenceDetailTV].[PRCODE] and MediaStream = 144
                 LEFT JOIN [Language] 
                         ON [dbo].[Language].[languageid] = 
                            [dbo].[PatternStaging].[LanguageID] 
                 LEFT JOIN [QueryDetail] 
                        ON [dbo].[QueryDetail].[PatternStgID] = 
                           [PatternStaging].[PatternStagingID] 
                 INNER JOIN [dbo].[CreativeStaging] 
                         ON [dbo].[CreativeStaging].[CreativeStagingID] = 
                 [dbo].[PatternStaging].[CreativeStgID] 
                 INNER JOIN [dbo].[CreativeDetailStagingTV] 
                         ON 
                 [dbo].[CreativeDetailStagingTV].[CreativeStgMasterID] = 
                 [dbo].[CreativeStaging].[CreativeStagingID] and MediaFormat = 'mpg'
                 LEFT JOIN [dbo].[user] 
                        ON [dbo].[user].userid = [PatternStaging].AuditedByID 
          WHERE  [PRCODE] = @CreativeSignatureId 
                 AND stationfullname = @MediaOutlet 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ( 
          'sp_TelevisionWorkQueueCreativeSignaturePreviewData: %d: %s', 
          16,1 
          ,@error, 
          @message,@lineNo); 
      END catch 
  END