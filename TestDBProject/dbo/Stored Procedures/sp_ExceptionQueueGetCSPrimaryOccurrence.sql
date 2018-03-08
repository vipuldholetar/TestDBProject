-- =========================================================================================================================
-- Author		:	Karunakar	
-- Create date	:	15th October 2015
-- Description	:	This Procedure is return mimimum occurrence of Creative Signature in Non Print Media Streams
-- Execution	:	sp_ExceptionQueueGetCSPrimaryOccurrence '515f9a3b5e2cc09f2326bfde64b6fe254f802543',150
-- Updated By	:	Arun Nair on 10/15/2015 - Removed Transactions 
-- ========================================================================================================================
CREATE PROCEDURE [dbo].[sp_ExceptionQueueGetCSPrimaryOccurrence]
	@CreativeSignature as Nvarchar(100),
	@MediaStreamId as int
AS
BEGIN
	
	SET NOCOUNT ON;
		BEGIN TRY
				DECLARE @MediaStream As Nvarchar(max)=''
				SELECT @MediaStream=Value  FROM   [dbo].[Configuration] WHERE ConfigurationID=@MediaStreamID 				
					IF(@MediaStream='RAD')
						BEGIN
								Select min([OccurrenceDetailRAID]) AS OccurrenceID from RCSACIDTORCSCREATIVEIDMAP 
								inner join [OccurrenceDetailRA]
								on  [OccurrenceDetailRA].[RCSAcIdID]=[RCSACIDTORCSCREATIVEIDMAP].[RCSAcIdToRCSCreativeIdMapID] 
								WHERE RCSACIDTORCSCREATIVEIDMAP.[RCSCreativeID]=@CreativeSignature
						END
					IF(@MediaStream='CIN')
					BEGIN
							Select MIN([OccurrenceDetailCIN].[OccurrenceDetailCINID]) AS OccurrenceID 
							FROM [dbo].[OccurrenceDetailCIN]  INNER JOIN [dbo].[PatternStaging] 
							ON [dbo].[PatternStaging].[CreativeSignature]=[dbo].[OccurrenceDetailCIN].[CreativeID]
							Where [OccurrenceDetailCIN].[CreativeID]=@CreativeSignature
							
					END
					IF(@MediaStream='OD')
					BEGIN
							Select MIN([OccurrenceDetailODR].[OccurrenceDetailODRID]) AS OccurrenceID
							from [dbo].[OccurrenceDetailODR]
							INNER JOIN [Market] ON [Market].[MarketID]=[dbo].[OccurrenceDetailODR].[MTMarketID] 
							INNER JOIN [dbo].[PatternStaging] ON [PatternStaging].[CreativeSignature]=[dbo].[OccurrenceDetailODR].[ImageFileName]
							WHERE [OccurrenceDetailODR].[ImageFileName]=@CreativeSignature
							
					END
					IF(@MediaStream='TV')
					BEGIN
							Select MIN([OccurrenceDetailTV].[OccurrenceDetailTVID]) AS OccurrenceID
							FROM    [OccurrenceDetailTV] 
							INNER JOIN  [PatternTVStg] ON [PatternTVStg].[CreativeSignature] = [OccurrenceDetailTV].[PRCODE]
							WHERE [OccurrenceDetailTV].[PRCODE]=@CreativeSignature
							
					END
					IF(@MediaStream='OND')
					BEGIN
							Select MIN([OccurrenceDetailOND].[OccurrenceDetailONDID]) AS OccurrenceID
							FROM  dbo.[OccurrenceDetailOND]
							INNER  JOIN dbo.[PatternStaging] ON dbo.[PatternStaging].[PatternStagingID]=dbo.[OccurrenceDetailOND].[PatternStagingID]
							WHERE [OccurrenceDetailOND].CreativeSignature=@CreativeSignature
							
					END
					IF(@MediaStream='ONV')
					BEGIN
							Select MIN([OccurrenceDetailONV].[OccurrenceDetailONVID]) AS OccurrenceID
							FROM  dbo.[OccurrenceDetailONV]
							INNER  JOIN dbo.[PatternStaging] ON dbo.[PatternStaging].[PatternStagingID]=dbo.[OccurrenceDetailONV].[PatternStagingID]
							WHERE [OccurrenceDetailONV].CreativeSignature=@CreativeSignature
							
					END
					IF(@MediaStream='MOB')
					BEGIN
							Select MIN([OccurrenceDetailMOB].[OccurrenceDetailMOBID]) AS OccurrenceID
							FROM  dbo.[OccurrenceDetailMOB]
							INNER  JOIN dbo.[PatternStaging] ON dbo.[PatternStaging].[PatternStagingID]=dbo.[OccurrenceDetailMOB].[PatternStagingID]
							WHERE [OccurrenceDetailMOB].CreativeSignature=@CreativeSignature
							
					END
					
		END TRY
		BEGIN CATCH 
				DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
				SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				RAISERROR ('[sp_ExceptionQueueGetCSPrimaryOccurrence]: %d: %s',16,1,@error,@message,@lineNo);				
		END CATCH 
END