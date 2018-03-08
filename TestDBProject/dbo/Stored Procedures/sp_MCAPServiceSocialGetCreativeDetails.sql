CREATE PROCEDURE [dbo].[sp_MCAPServiceSocialGetCreativeDetails] 
( 
@LocationId AS INT,
@OccurrenceID AS INT,
@AdId AS INT 
)
AS
BEGIN
	   DECLARE @BasePath AS VARCHAR(100)
	   DECLARE @RemoteBasePath AS VARCHAR(100)
	   
	   IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='SOC',@Mediatype='SOC',@Ext=0
	   ELSE IF @LocationId = 2200
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='SOC',@Mediatype='SOC',@Ext=0
		  
	   --set @RemoteBasePath  = '\\192.168.3.126\UATAssets\'
	   select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

	   IF @OccurrenceID > 0
	   BEGIN
			 DECLARE @PatternMasterId AS INTEGER
			 DECLARE @CreativeMasterId AS INTEGER

			 SELECT @PatternMasterId=[PatternID] FROM [OccurrenceDetailSOC] WHERE [OccurrenceDetailSOCID]=@OccurrenceID
			 SELECT @CreativeMasterId=[CreativeID] FROM [Pattern] WHERE [PatternID]=@PatternMasterId

			 SELECT  [CreativeDetailSOCID] AS CreativeDetailID,
				    CreativeMasterID as CreativeID  ,
				    CreativeDetailSOC.PageNumber,					
				    @BasePath + [dbo].[CreativeDetailSOC].[CreativeRepository]+[dbo].[CreativeDetailSOC].CreativeAssetName AS LocalCreativeFilePath,
				    @RemoteBasePath + [dbo].[CreativeDetailSOC].[CreativeRepository]+[dbo].[CreativeDetailSOC].CreativeAssetName AS RemoteCreativeFilePath,
				    @BasePath + [Creative].AssetThmbnlName as [LocalThumbnailPath], 
				    @RemoteBasePath + [Creative].AssetThmbnlName as [RemoteThumbnailPath], 
				    [dbo].[CreativeDetailSOC].[CreativeFileSize] AS [CreativeFileSize],
				    [dbo].[CreativeDetailSOC].[CreativeFileType] AS [Format]
			 FROM  [dbo].[CreativeDetailSOC] 
				INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailSOC].CreativeMasterID =[dbo].[Creative].PK_Id
			 WHERE [dbo].[CreativeDetailSOC].[CreativeMasterID]= @CreativeMasterId
				AND [dbo].[CreativeDetailSOC].[CreativeRepository] is not null
				AND [dbo].[CreativeDetailSOC].[CreativeAssetName] is not null
	   END	 
	   ELSE IF @AdId > 0
	   BEGIN
			 Declare @PrimaryOccurrenceID as BIGINT	
			 SET @PrimaryOccurrenceID=(SELECT [PrimaryOccurrenceID] FROM  AD WHERE AD.[AdID]=@AdID)

			 SELECT  AD.[AdID] as AdId,
				    [dbo].[OccurrenceDetailSOC].[OccurrenceDetailSOCID] AS OccurrenceID,
				    [Creative].PK_Id AS CreativeID,
				    CreativeDetailSOC.[CreativeDetailSOCID] AS CreativeDetailID,
				    CreativeDetailSOC.PageNumber,
				    @BasePath + CreativeDetailSOC.CreativeRepository +CreativeDetailSOC.CreativeAssetName AS LocalCreativeFilePath,
				    @RemoteBasePath + CreativeDetailSOC.CreativeRepository +CreativeDetailSOC.CreativeAssetName AS RemoteCreativeFilePath,
				    @BasePath + [Creative].AssetThmbnlName as [LocalThumbnailPath], 
				    @RemoteBasePath + [Creative].AssetThmbnlName as [RemoteThumbnailPath], 
				    CreativeDetailSOC.Deleted as isDeleted					 
			 FROM  [dbo].[CreativeDetailSOC] 
			 INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailSOC].CreativeMasterID =[dbo].[Creative].PK_Id
			 INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailSOC].CreativeMasterID=[dbo].[Pattern].[CreativeID]
			 INNER join [dbo].[OccurrenceDetailSOC] on dbo.[OccurrenceDetailSOC].[PatternID]=[Pattern].[PatternID]
			 INNER JOIN [dbo].ad ON [dbo].[OccurrenceDetailSOC].[OccurrenceDetailSOCID]=[dbo].[AD].[PrimaryOccurrenceID]
			 WHERE AD.[AdID]=@AdID AND CreativeDetailSOC.Deleted=0  and [Creative].PrimaryIndicator=1 AND AD.[PrimaryOccurrenceID]=@PrimaryOccurrenceID
			 ORDER BY Pagenumber ASC, CreativeDetailSOC.[CreativeDetailSOCID]
	   END
	   
END