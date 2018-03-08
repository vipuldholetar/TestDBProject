
-- =============================================================================================================================
-- Author			: Arun Nair
-- Create date		: 08/03/2015
-- Description		: This stored procedure is used to Getting Exception Queue View Data
-- Execution Process: [dbo].[sp_QueryQueueViewCreative] '12294','ISS',0,12294,9195
-- Updated By		: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value/
--					: Updated for Online Display By Ramesh Bangi
--  				: Updated for Online Video By Ramesh Bangi
--					: Updated for Mobile By Ramesh Bangi on 10/13/2015
--					: Updated for Email By Ramesh Bangi on 10/30/2015
--					: Updated for Website By Ramesh Bangi on 11/05/2015
--					: Updated for Social By Ramesh Bangi on 11/18/2015
--					: Arun Nair on 11/27/2015 - Query View Creative MI- 317,Adding CreativeRepository Check for All Media Streams 
--					: Arun Nair on 12/18/2015 - Added CreativeMasterid for View Creative in Print Media
--					: Lisa East on 8/30/2017 - Added check for Creative Master in Staging tables for View Creative in Print Media
-- ===============================================================================================================================

CREATE PROCEDURE [dbo].[sp_QueryQueueViewCreative]  
(
 @CreativeSignature AS NVARCHAR(MAX),
 @MediaStreamId AS NVARCHAR(MAX),
 @AdID AS INT,
 @OccurrenceID AS BIGINT,
 @QueryId AS INT    
)

AS
BEGIN

		DECLARE @PaternMasterID AS INT
		DECLARE @CreativemasterID AS INT
		DECLARE @pk_id VARCHAR(MAX)
		DECLARE @MediaStream  VARCHAR(MAX)

		IF(@MediaStreamId='PUB' or @MediaStreamId='ISS')
			BEGIN
				SET @MediaStream='PUB'
			END
		ELSE
			BEGIN
				SELECT @MediaStream=Value from [Configuration] where ValueTitle=@MediaStreamId
			END
		PRINT(@MediaStream)
		BEGIN TRY
		IF(@MediaStream='CIN')
			BEGIN
			IF EXISTS  --Check if Creative Exists else take from Query
				(
				   SELECT  [dbo].[CreativeDetailStagingCIN].[CreativeRepository]+	[dbo].[CreativeDetailStagingCIN].[CreativeAssetName] AS PrimarySource	
				   FROM  [dbo].[PatternStaging] INNER JOIN [dbo].[CreativeDetailStagingCIN] ON 
				   [dbo].[CreativeDetailStagingCIN].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
				    WHERE [dbo].[PatternStaging].[CreativeSignature]=@CreativeSignature and [dbo].[CreativeDetailStagingCIN].[CreativeRepository] Is Not Null
				)
				BEGIN
					SELECT  [dbo].[CreativeDetailStagingCIN].[CreativeRepository]+	[dbo].[CreativeDetailStagingCIN].[CreativeAssetName] AS PrimarySource	
					FROM  [dbo].[PatternStaging] INNER JOIN [dbo].[CreativeDetailStagingCIN] ON 
					[dbo].[CreativeDetailStagingCIN].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
					WHERE [dbo].[PatternStaging].[CreativeSignature]=@CreativeSignature and [dbo].[CreativeDetailStagingCIN].[CreativeRepository] Is Not Null
				END
			ELSE
				BEGIN
					SELECT QryCreativeRepository+QryCreativeAssetName AS [PrimarySource] FROM  [QueryDetail] WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='CIN'
				END
			END

		IF(@MediaStream='TV')
			BEGIN
			IF EXISTS  --Check if Creative Exists else take from Query
				(
				SELECT [dbo].[CreativeDetailStagingTV].[MediaFilePath]+	[dbo].[CreativeDetailStagingTV].[MediaFileName] AS [PrimarySource]
				FROM  [dbo].[PatternStaging] INNER JOIN [dbo].[CreativeDetailStagingTV] ON 
			    [dbo].[CreativeDetailStagingTV].[CreativeStgMasterID]=[dbo].[PatternStaging].[CreativeStgID]
			    WHERE [dbo].[PatternStaging].[CreativeSignature]= @CreativeSignature and [dbo].[CreativeDetailStagingTV].[MediaFilePath] Is Not Null
				)
				BEGIN
					SELECT [dbo].[CreativeDetailStagingTV].[MediaFilePath]+	[dbo].[CreativeDetailStagingTV].[MediaFileName] AS [PrimarySource]
					FROM  [dbo].[PatternStaging] INNER JOIN [dbo].[CreativeDetailStagingTV] ON 
					[dbo].[CreativeDetailStagingTV].[CreativeStgMasterID]=[dbo].[PatternStaging].[CreativeStgID]
					WHERE [dbo].[PatternStaging].[CreativeSignature]= @CreativeSignature and [dbo].[CreativeDetailStagingTV].[MediaFilePath] Is Not Null
				END
			ELSE
				BEGIN
					SELECT QryCreativeRepository+QryCreativeAssetName AS [PrimarySource] FROM  [QueryDetail] WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='TV'
				END
			END
         IF(@MediaStream='OD')
			BEGIN
			IF EXISTS
				(
					SELECT	[dbo].[CreativeDetailStagingODR].[CreativeRepository]+ [dbo].[CreativeDetailStagingODR].[CreativeAssetName] AS [PrimarySource]
					FROM  [dbo].[PatternStaging] INNER JOIN [dbo].[CreativeDetailStagingODR] ON 
					[dbo].[CreativeDetailStagingODR].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
					WHERE [dbo].[PatternStaging].[CreativeSignature]=  @CreativeSignature and [dbo].[CreativeDetailStagingODR].[CreativeRepository] Is Not Null 
				)
				BEGIN
					SELECT		[dbo].[CreativeDetailStagingODR].[CreativeRepository]+ [dbo].[CreativeDetailStagingODR].[CreativeAssetName] AS [PrimarySource],[CreativeStagingID] AS CreativeMasterid
					FROM  [dbo].[PatternStaging] INNER JOIN [dbo].[CreativeDetailStagingODR] ON 
					[dbo].[CreativeDetailStagingODR].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
					WHERE [dbo].[PatternStaging].[CreativeSignature]=  @CreativeSignature and [dbo].[CreativeDetailStagingODR].[CreativeRepository] Is Not Null 
				END
			ELSE
				BEGIN
					SELECT QryCreativeRepository+QryCreativeAssetName AS [PrimarySource],[QueryDetail].[QueryID] AS CreativeMasterid  FROM  [QueryDetail] 
					WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='OD'
				END
			END
			
		IF(@MediaStream='OND')
			BEGIN
			 SELECT DISTINCT @pk_id=[PatternStagingID] FROM [OccurrenceDetailOND] WHERE creativesignature=@CreativeSignature and [PatternStagingID] is not null
			IF EXISTS
				(
				SELECT		[dbo].[CreativeDetailStagingOND].[CreativeRepository]+[dbo].[CreativeDetailStagingOND].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource]
				FROM  [dbo].[PatternStaging] INNER JOIN [dbo].[CreativeDetailStagingOND] ON 
			    [dbo].[CreativeDetailStagingOND].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
			    WHERE [dbo].[PatternStaging].[PatternStagingID]=  @pk_id
				 and CreativeDetailStagingOND.CreativeDownloaded=1 and CreativeDetailStagingOND.FileSize>0 
				 and CreativeDetailStagingOND.CreativeFileType='jpg' and [dbo].[CreativeDetailStagingOND].[CreativeRepository] Is Not Null
				 )
				 BEGIN
					--SELECT DISTINCT @pk_id=FK_PatternMasterStagingID FROM occurrencedetailsond WHERE creativesignature=@CreativeSignature
					SELECT		[dbo].[CreativeDetailStagingOND].[CreativeRepository]+[dbo].[CreativeDetailStagingOND].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource]
					FROM  [dbo].[PatternStaging] INNER JOIN [dbo].[CreativeDetailStagingOND] ON 
					[dbo].[CreativeDetailStagingOND].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
					WHERE [dbo].[PatternStaging].[PatternStagingID]=  @pk_id
					 and CreativeDetailStagingOND.CreativeDownloaded=1 and CreativeDetailStagingOND.FileSize>0 
					 and CreativeDetailStagingOND.CreativeFileType='jpg' and [dbo].[CreativeDetailStagingOND].[CreativeRepository] Is Not Null
				 END
			ELSE
				BEGIN
					SELECT QryCreativeRepository+QryCreativeAssetName AS [PrimarySource] FROM  [QueryDetail] WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='OND'
				END
			END
		IF(@MediaStream='ONV')
			BEGIN
			    SELECT DISTINCT @pk_id=[PatternStagingID] FROM [OccurrenceDetailONV] WHERE creativesignature=@CreativeSignature
				IF EXISTS
				(
					SELECT		[dbo].[CreativeDetailStagingONV].[CreativeRepository]+[dbo].[CreativeDetailStagingONV].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource]
					FROM  [dbo].[PatternStaging]  INNER JOIN [dbo].[CreativeDetailStagingONV] ON 
					[dbo].[CreativeDetailStagingONV].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
					WHERE [dbo].[PatternStaging].[PatternStagingID]=  @pk_id
					and CreativeDetailStagingonv.CreativeDownloaded=1 and CreativeDetailStagingonv.FileSize>0 and CreativeDetailStagingonv.CreativeFileType='MP4' and [dbo].[CreativeDetailStagingONV].[CreativeRepository] Is Not Null
				)
				BEGIN
					SELECT DISTINCT @pk_id=[PatternStagingID] FROM [OccurrenceDetailONV] WHERE creativesignature=@CreativeSignature
					SELECT		[dbo].[CreativeDetailStagingONV].[CreativeRepository]+[dbo].[CreativeDetailStagingONV].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource]
					FROM  [dbo].[PatternStaging]  INNER JOIN [dbo].[CreativeDetailStagingONV] ON 
					[dbo].[CreativeDetailStagingONV].[CreativeStagingID]=[dbo].[PatternStaging].[CreativeStgID]
					WHERE [dbo].[PatternStaging].[PatternStagingID]=  @pk_id
					and CreativeDetailStagingonv.CreativeDownloaded=1 and CreativeDetailStagingonv.FileSize>0 and CreativeDetailStagingonv.CreativeFileType='MP4' and [dbo].[CreativeDetailStagingONV].[CreativeRepository] Is Not Null
				END
			ELSE
				BEGIN
					SELECT QryCreativeRepository+QryCreativeAssetName AS [PrimarySource] FROM  [QueryDetail] WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='ONV'
				END
			END
		IF(@MediaStream='MOB')
			BEGIN
				IF EXISTS
					(
					  SELECT [dbo].[CreativeDetailStagingMOB].[CreativeRepository]+[dbo].[CreativeDetailStagingMOB].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource],
					  [dbo].[CreativeDetailStagingMOB].CreativeFileType FROM  [dbo].[CreativeDetailStagingMOB] WHERE SignatureDefault=@CreativeSignature
					  AND CreativeDownloaded=1 and FileSize>0 --ORDER BY PK_CreativeDetailStagingID
					  AND [dbo].[CreativeDetailStagingMOB].[CreativeRepository] Is Not Null
					)
				   BEGIN
						SELECT	[dbo].[CreativeDetailStagingMOB].[CreativeRepository]+[dbo].[CreativeDetailStagingMOB].[SignatureDefault]+'.'+CreativeFileType AS [PrimarySource],
					   [dbo].[CreativeDetailStagingMOB].CreativeFileType FROM  [dbo].[CreativeDetailStagingMOB] WHERE SignatureDefault=@CreativeSignature
						AND CreativeDownloaded=1 and FileSize>0 
						AND [dbo].[CreativeDetailStagingMOB].[CreativeRepository] Is Not Null
						ORDER BY [CreativeDetailStagingID] 
				   END
				ELSE
					BEGIN
						SELECT QryCreativeRepository+QryCreativeAssetName AS [PrimarySource] FROM  [QueryDetail] WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='MOB'
					END
			END

	     IF(@MediaStream='RAD')
			BEGIN
				IF EXISTS
					(
					  SELECT  [CreativeDetailStagingRA].MediaFilepath+[CreativeDetailStagingRA].MediaFileName+'.'+rtrim(ltrim([CreativeDetailStagingRA].mediaformat))  AS PrimarySource
					  FROM [PatternStaging]       inner join [CreativeStaging] ON [PatternStaging].[CreativeStgID]=[CreativeStaging].[CreativeStagingID]
					  inner join [CreativeDetailStagingRA] ON [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingRA].[CreativeStgID] 
					  --inner join [PatternDetailRAStaging] ON  [PatternDetailRAStaging].[PatternStgID]=[PatternStaging].[PatternStagingID]   
					  AND [PatternStaging].CreativeSignature=@CreativeSignature 
					  and  [CreativeDetailStagingRA].MediaFilepath Is Not Null
					)
					BEGIN
					  SELECT  [CreativeDetailStagingRA].MediaFilepath+[CreativeDetailStagingRA].MediaFileName+'.'+rtrim(ltrim([CreativeDetailStagingRA].mediaformat))  AS PrimarySource
					  FROM [PatternStaging]       inner join [CreativeStaging] ON [PatternStaging].[CreativeStgID]=[CreativeStaging].[CreativeStagingID]
					  inner join [CreativeDetailStagingRA] ON [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingRA].[CreativeStgID] 
					  --inner join [PatternDetailRAStaging] ON  [PatternDetailRAStaging].[PatternStgID]=[PatternStaging].[PatternStagingID]   
					  AND [PatternStaging].CreativeSignature=@CreativeSignature 
					  and [CreativeDetailStagingRA].MediaFilepath Is Not Null
					END

				ELSE
					BEGIN
						SELECT QryCreativeRepository+QryCreativeAssetName AS [PrimarySource] FROM  [QueryDetail] WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='RAD'
					END

			END			
	     IF(@MediaStream='PUB')
			BEGIN
				SELECT QryCreativeRepository+QryCreativeAssetName As [PrimarySource],[QueryDetail].[QueryID] AS CreativeMasterId FROM  [QueryDetail] 
				WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='PUB'
			END

	     IF(@MediaStream='CIR')
			BEGIN
					SELECT  @PaternMasterID=[PatternID] FROM [OccurrenceDetailCIR] WHERE [OccurrenceDetailCIRID]=@OccurrenceID
					SELECT  @CreativemasterID=[CreativeID] FROM [Pattern] WHERE [PatternID]=@PaternMasterID
				IF EXISTS
					(					
						SELECT 	CreativeRepository + CreativeAssetName AS [PrimarySource] FROM  CreativedetailCir  
						WHERE Creativemasterid=@CreativemasterID and CreativedetailCir.CreativeRepository Is Not Null
					)
					BEGIN
						--SELECT  @PaternMasterID=FK_PatternMasterID FROM occurrencedetailscir Where PK_OccurrenceID=@OccurrenceID
						--SELECT  @CreativemasterID=FK_CreativeId from patternmaster Where PK_Id=@PaternMasterID
						SELECT 	CreativeRepository + CreativeAssetName AS [PrimarySource],CreativeMasterID FROM  CreativedetailCir  
						WHERE Creativemasterid=@CreativemasterID and CreativedetailCir.CreativeRepository Is Not Null
					END
				ELSE
					BEGIN						
						SELECT QryCreativeRepository+QryCreativeAssetName As [PrimarySource],[QueryDetail].[QueryID] AS CreativeMasterID  FROM  [QueryDetail] 
						WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='CIR'
					END
			END

	     IF(@MediaStream='EM')
			BEGIN
				  SELECT  @PaternMasterID=[PatternID] FROM [OccurrenceDetailEM] WHERE [OccurrenceDetailEMID]=@OccurrenceID
				  SELECT  @CreativemasterID=[CreativeID] FROM [Pattern] WHERE [PatternID]=@PaternMasterID
				IF EXISTS
					(	
					 SELECT CreativeRepository + CreativeAssetName AS [PrimarySource] FROM  CreativedetailEM  
					 WHERE Creativemasterid=@CreativemasterID and CreativedetailEM.CreativeRepository Is Not Null
				    )
					BEGIN
						 SELECT CreativeRepository + CreativeAssetName AS [PrimarySource],CreativeMasterID FROM  CreativedetailEM  
						 WHERE Creativemasterid=@CreativemasterID and CreativedetailEM.CreativeRepository Is Not Null
					END
					----Updated 8.30.17 L.E
				ELSE IF EXISTS
					(	
					 SELECT TOP 1 C.creativestagingID from  [QueryDetail] Q INNER JOIN [PatternStaging] P ON P.patternstagingID=Q.patternStgID
					 INNER JOIN [CREATIVESTAGING] C ON C.creativestagingID=P.creativeSTGID WHERE Q.QUERYID= @QueryId and [MediaStreamID]='EM'
					 )
					BEGIN 
						SELECT  QryCreativeRepository+QryCreativeAssetName As [PrimarySource],C.creativestagingID AS CreativeMasterID 
						FROM  [QueryDetail] Q 
						INNER JOIN [PatternStaging] P on P.patternstagingID=Q.patternStgID
						INNER JOIN [CREATIVESTAGING] C on C.creativestagingID=P.creativeSTGID
						WHERE Q.QUERYID= @QueryId and [MediaStreamID]='EM'
					END 
				ELSE
					BEGIN
						SELECT QryCreativeRepository+QryCreativeAssetName As [PrimarySource],[QueryDetail].[QueryID] AS CreativeMasterID FROM  [QueryDetail] 
						WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='EM'
					END
			END
		IF(@MediaStream='WEB')
			BEGIN

				SELECT  @PaternMasterID=[PatternID] FROM [OccurrenceDetailWEB] Where [OccurrenceDetailWEBID]=@OccurrenceID
				SELECT  @CreativemasterID=[CreativeID] from [Pattern] Where [PatternID]=@PaternMasterID
				IF EXISTS
					(
						SELECT 	CreativeRepository + CreativeAssetName AS [PrimarySource] FROM  CreativedetailWEB  
						WHERE Creativemasterid=@CreativemasterID and CreativedetailWEB.CreativeRepository Is Not Null
					)
					BEGIN
						--SELECT  @PaternMasterID=FK_PatternMasterID FROM occurrencedetailsWEB Where PK_ID=@OccurrenceID
						--SELECT  @CreativemasterID=FK_CreativeId from patternmaster Where PK_Id=@PaternMasterID
						SELECT 	CreativeRepository + CreativeAssetName AS [PrimarySource],CreativeMasterID FROM  CreativedetailWEB  
						WHERE Creativemasterid=@CreativemasterID and CreativedetailWEB.CreativeRepository Is Not Null
					END
				ELSE
					BEGIN
						SELECT QryCreativeRepository+QryCreativeAssetName As [PrimarySource],[QueryDetail].[QueryID] AS CreativeMasterID FROM  [QueryDetail] 
						WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='WEB'
					END
			END

		IF(@MediaStream='SOC')
			BEGIN
				SELECT  @PaternMasterID=[PatternID] FROM [OccurrenceDetailSOC] WHERE [OccurrenceDetailSOCID]=@OccurrenceID
				SELECT  @CreativemasterID=[CreativeID] FROM [Pattern] WHERE [PatternID]=@PaternMasterID
				IF EXISTS
						(
							SELECT 	CreativeRepository + CreativeAssetName AS [PrimarySource] FROM  CreativedetailSOC  WHERE Creativemasterid=@CreativemasterID and CreativedetailSOC.CreativeRepository is not null
						)
						BEGIN
								--SELECT  @PaternMasterID=FK_PatternMasterID FROM occurrencedetailsSOC WHERE PK_OccurrenceID=@OccurrenceID
								--SELECT  @CreativemasterID=FK_CreativeId FROM patternmaster WHERE PK_Id=@PaternMasterID
								SELECT 	CreativeRepository + CreativeAssetName AS [PrimarySource] ,CreativeMasterID FROM  CreativedetailSOC  
								WHERE Creativemasterid=@CreativemasterID  and CreativedetailSOC.CreativeRepository is not null
						END
				ELSE
						BEGIN
							SELECT QryCreativeRepository+QryCreativeAssetName As [PrimarySource],[QueryDetail].[QueryID] AS CreativeMasterID FROM  [QueryDetail] 
							WHERE [QueryDetail].[QueryID]=@QueryId and [MediaStreamID]='SOC' 
						END
			END
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('sp_ExceptionQueueViewCreative: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH

END