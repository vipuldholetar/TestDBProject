CREATE PROCEDURE [dbo].[sp_MCAPServiceRadioGetCreativeDetails] 
( 
@LocationId AS INT,
@CreativeSignature AS varchar(100)='',
@PatternId AS INT=0,
@AdId AS INT =0,
@PromotionID  AS INT = 0
)
AS
BEGIN
	   DECLARE @BasePath AS VARCHAR(100)
	   DECLARE @RemoteBasePath AS VARCHAR(100)
	   
	   SELECT @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'
	   
	   IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='RAD',@Mediatype='RAD',@Ext=0
	   ELSE IF @LocationId = 4126
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='RAD',@Mediatype='RAD',@Ext=0
	   ELSE	
		  SET @BasePath = @RemoteBasePath
		  
	   IF @BasePath IS NULL OR @BasePath = ''
		  SET @BasePath = 'C:\MCAPCreatives\' 

	   IF @CreativeSignature <> '' and @CreativeSignature IS NOT NULL
	   BEGIN
		  IF EXISTS(SELECT TOP 1 * FROM [PatternStaging] WHERE CreativeSignature = @CreativeSignature)
		  BEGIN
			 SELECT [PatternStaging].[PatternStagingID],[PatternStaging].PatternID,
			    @BasePath + [CreativeDetailStagingRA].MediaFilepath+[CreativeDetailStagingRA].MediaFileName+'.'+rtrim(ltrim([CreativeDetailStagingRA].MediaFormat))  AS LocalCreativeFilePath,
			    @RemoteBasePath + [CreativeDetailStagingRA].MediaFilepath+[CreativeDetailStagingRA].MediaFileName+'.'+rtrim(ltrim([CreativeDetailStagingRA].MediaFormat))  AS RemoteCreativeFilePath 
			 FROM [PatternStaging]	INNER JOIN [CreativeStaging] on [PatternStaging].[CreativeStgID]=[CreativeStaging].[CreativeStagingID]
			 inner join [CreativeDetailStagingRA] on [CreativeStaging].[CreativeStagingID]=[CreativeDetailStagingRA].[CreativeStgID] 
			 WHERE [PatternStaging].CreativeSignature=@CreativeSignature
		  END
		  ELSE
		  BEGIN
			 SELECT  Pattern.PatternID,[CreativeDetailRA].[CreativeDetailRAID] AS Creativedetailid,
				@BasePath + [CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+FileType As LocalCreativeFilePath,
				@RemoteBasePath + [CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+FileType As RemoteCreativeFilePath
			 FROM            [Pattern] 
			 INNER JOIN   [CreativeDetailRA] 
			 ON [Pattern].[CreativeID] = [CreativeDetailRA].[CreativeID]
			 Where [Pattern].CreativeSignature = @CreativeSignature
		  END
	   END	
	   ELSE IF @AdId > 0 
	   BEGIN

		  SELECT [Creative].PK_Id As CreativeId,[CreativeDetailRA].[CreativeDetailRAID] AS Creativedetailid, [Creative].PrimaryIndicator,
			@BasePath + [CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+RTRIM(LTRIM([CreativeDetailRA].FileType)) As LocalCreativeFilePath,
			@RemoteBasePath + [CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+RTRIM(LTRIM([CreativeDetailRA].FileType)) As RemoteCreativeFilePath,
			CAST([CreativeDetailRA].[CreativeDetailRAID] as varchar)+'-'+[CreativeDetailRA].Rep + 
				[CreativeDetailRA].AssetName+'.'+RTRIM(LTRIM([CreativeDetailRA].FileType)) AS DetailIDwithFilepath,
			[Creative].SourceOccurrenceId
		  FROM [Creative] INNER JOIN [CreativeDetailRA] on [Creative].PK_Id=[CreativeDetailRA].[CreativeID] 
		  WHERE [Creative].[AdId]=@Adid AND [Creative].PrimaryIndicator=1

        END  
	   ELSE IF @PatternId > 0
	   BEGIN
		  SELECT  Pattern.PatternID,[CreativeDetailRA].CreativeDetailRAID AS CreativeDetailID,
				@BasePath + [CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+FileType As LocalCreativeFilePath,
				@RemoteBasePath + [CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+FileType As RemoteCreativeFilePath
		  FROM            [Pattern] 
		  INNER JOIN   [CreativeDetailRA] 
		  ON [Pattern].[CreativeID] = [CreativeDetailRA].[CreativeID]
		  Where [Pattern].[PatternID]=@PatternId
	   END

END