



-- =================================================================================================
-- Author			:	Arun Nair
-- Create date		:	08/04/2015
-- Description		:	Q&A Query Queue
-- Execution Process:  [sp_QueryQueueQ&A]
-- Updated By		:  Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value/
--					:  Ramesh Bangi on 09/15/2015 -Online Display,
--					:  Ramesh Bangi on 09/15/2015 -Online Video,
--					:  Ramesh Bangi on 10/13/2015 -Mobile
--					:  Ramesh Bangi on 10/30/2015 -Email
--					:  Ramesh Bangi on 11/5/2015  -Website
--					:  Ramesh Bangi on 11/18/2015 -Social
--					: Lisa East on 3.16.2017 - Publication

-- ================================================================================================

CREATE PROCEDURE [dbo].[sp_QueryQueueQandA]
(

@Answer  AS NVARCHAR(MAX),
@MediaStream AS NVARCHAR(20),
@QueryId AS INTEGER,
@UserId AS INTEGER,
@KeyId AS BIGINT
)
AS
SET NOCOUNT ON 
BEGIN

			BEGIN TRY 
					BEGIN TRANSACTION
						UPDATE [QueryDetail] SET [QryAnswer]=@Answer,[QryAnsweredBy]=@UserId,[QryAnsweredOn]=GETDATE() WHERE [QueryID]=@QueryId

						IF(@MediaStream='TV')
							BEGIN
									UPDATE [dbo].[PatternStaging] SET [Query]=0 WHERE [PatternStaging].[PatternStagingID] = @KeyId
							END
						ELSE IF (@MediaStream='OD')
							BEGIN
									UPDATE [dbo].[PatternStaging] SET [Query]=0 WHERE [PatternStaging].[PatternStagingID] = @KeyId
							END
						ELSE IF (@MediaStream='CIN')
							BEGIN	
									UPDATE [dbo].[PatternStaging] SET Query=0 WHERE [dbo].[PatternStaging].[PatternStagingID]=@KeyId
							END
						ELSE IF (@MediaStream='RAD')
							BEGIN	
									UPDATE [dbo].[PatternStaging]  SET [Query]=0 WHERE [dbo].[PatternStaging].[PatternStagingID] = @KeyId
							END
						ELSE IF (@MediaStream='PUB')
							BEGIN	
							--L.E. 3/8/2017 MI-977
								IF EXISTS (SELECT 1 FROM [dbo].[PubIssue] WHERE [PubIssueID]=@KeyId ) 
								BEGIN
									Declare @PubIssueStatus as nvarchar(max)
			
									SELECT @PubIssueStatus = valuetitle 
									FROM   [Configuration] 
									WHERE  systemname = 'All' 
											AND componentname = 'Published Issue Status' 
											AND value = 'P' 
									UPDATE  [dbo].[PubIssue] SET IsQuery=0, [status]=@PubIssueStatus WHERE [PubIssueID]=@KeyId 
								END
								ELSE
								BEGIN
									Declare @OccurrenceStatusID as integer
			
									SELECT @OccurrenceStatusID = os.[OccurrenceStatusID] 
									FROM OccurrenceStatus OS
									inner join Configuration c on os.[Status] = c.ValueTitle
									where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'P'  

									Update [dbo].[OccurrencedetailPUB] SET Query=0, [OccurrenceStatusID]=@OccurrenceStatusID WHERE [occurrencedetailPUBID]=@KeyId 
								END  									
							END
						ELSE IF (@MediaStream='CIR')
							BEGIN	
									UPDATE [dbo].[OccurrenceDetailCIR] SET [Query]=0 WHERE [OccurrenceDetailCIRID]=@KeyId
							END
						ELSE IF (@MediaStream='OND')
							BEGIN	
									UPDATE [dbo].[PatternStaging] SET [Query]=0 WHERE [PatternStagingID]=@KeyId
							END
						ELSE IF (@MediaStream='ONV')
							BEGIN		
									UPDATE [dbo].[PatternStaging] SET [Query]=0 WHERE [PatternStagingID]=@KeyId
							END

						ELSE IF (@MediaStream='MOB')
							BEGIN
									UPDATE [dbo].[PatternStaging] SET [Query]=0 WHERE [PatternStagingID]=@KeyId
							END
						ELSE IF (@MediaStream='EM')
							BEGIN	
									UPDATE [dbo].[OccurrenceDetailEM] SET [Query]=0 WHERE [OccurrenceDetailEMID]=@KeyId
							END
						ELSE IF (@MediaStream='WEB')
							BEGIN			
									UPDATE [dbo].[OccurrenceDetailWEB] SET [Query]=0 WHERE [OccurrenceDetailWEBID]=@KeyId
							END
						ELSE IF (@MediaStream='SOC')
							BEGIN	
									UPDATE [dbo].[OccurrenceDetailSOC] SET [Query]=0 WHERE [OccurrenceDetailSOCID]=@KeyId
							END
					COMMIT TRANSACTION 
				END TRY 


				BEGIN CATCH
					ROLLBACK TRANSACTION 
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[dbo].[sp_QueryQueueQ&A]: %d: %s',16,1,@error,@message,@lineNo); 					 
				END CATCH

END