CREATE PROCEDURE [dbo].[sp_MCAPServiceEmailGetThumbnailPreview] 
( 
@LocationId AS INT,
@AdId AS BIGINT
)
AS
BEGIN
		DECLARE @BasePath AS VARCHAR(MAX)
		DECLARE @RemoteBasePath AS VARCHAR(MAX)

		select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

		IF @LocationId = 58
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='EML',@Mediatype='EM',@Ext=0
		ELSE IF @LocationId = 4126
		  exec @BasePath = dbo.fn_GetLocalServerPath @LocationId=@locationId,@SubMainFolder='EML',@Mediatype='EM',@Ext=0
		ELSE	
			SET @BasePath = @RemoteBasePath
		
		IF @BasePath IS NULL OR @BasePath = ''
			SET @BasePath = 'C:\MCAPCreatives\' 
			  

		  IF @AdId > 0 
		  BEGIN
				Declare @PrimaryOccurrenceID as BIGINT	
				SET @PrimaryOccurrenceID=(SELECT [PrimaryOccurrenceID] FROM  AD WHERE AD.[AdID]=@AdID)

				SELECT top 1 AD.[AdID],
					   [dbo].[Pattern].PatternId,
					   [dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID] AS OccurrenceID,
					   [Creative].PK_Id AS CreativeID,
					   CreativeDetailEM.[CreativeDetailsEMID] AS CreativeDetailID,
					   CreativeDetailEM.PageNumber,
					   creativefiletype, 
					   CreativeDetailEM.Deleted as IsDeleted,
					   isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,
					   isnull(ContentDetailID,0) ContentDetailID,
					   isnull(CreativeForCropStagingID,0) CreativeForCropStagingID,					
					   CASE WHEN CreativeAssetName IS NULL 
							THEN @BasePath + CreativeRepository + LegacyAssetName + '.' + creativefiletype  
								ELSE @BasePath + CreativeDetailEM.CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
					   CASE WHEN CreativeAssetName IS NULL 
							THEN CreativeRepository + LegacyAssetName + '.' + creativefiletype  
								ELSE @RemoteBasePath + CreativeDetailEM.CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,

					   CASE WHEN AssetThmbnlName IS NULL 
					   THEN 
							CASE WHEN (@BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType)  is null 
							THEN 
								CASE WHEN CreativeAssetName IS NULL 
								THEN @BasePath + REPLACE(CreativeRepository,'Original','Thumb') + LegacyAssetName + '.' + creativefiletype  
								ELSE @BasePath + REPLACE(CreativeDetailEM.CreativeRepository,'Original','Thumb') + CreativeAssetName 
								END
							ELSE @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
							END
						ELSE @BasePath + ThmbnlRep +AssetThmbnlName  
						END  AS LocalThumbnailPath,

					   CASE WHEN AssetThmbnlName IS NULL 
					   THEN 
							CASE WHEN ( ThmbnlRep + LegacyThmbnlAssetName + '.' + creativefiletype ) is null 
							THEN 
								CASE WHEN CreativeAssetName IS NULL 
								THEN REPLACE(CreativeRepository,'Original','Thumb') + LegacyAssetName + '.' + creativefiletype 	
								ELSE @RemoteBasePath + REPLACE(CreativeDetailEM.CreativeRepository,'Original','Thumb') + CreativeAssetName 
								END
							ELSE ThmbnlRep + LegacyThmbnlAssetName + '.' + creativefiletype 
							END 
						ELSE @RemoteBasePath + ThmbnlRep +AssetThmbnlName 
						END AS RemoteThumbnailPath 

				FROM  [dbo].[CreativeDetailEM] 
				INNER JOIN [dbo].[Creative] ON [dbo].[CreativeDetailEM].CreativeMasterID =[dbo].[Creative].PK_Id
				INNER JOIN [dbo].[Pattern] ON  [dbo].[CreativeDetailEM].CreativeMasterID=[dbo].[Pattern].[CreativeID]
				INNER join [dbo].[OccurrenceDetailEM] on dbo.[OccurrenceDetailEM].[PatternID]=[Pattern].[PatternID]
				INNER JOIN [dbo].ad ON [dbo].[OccurrenceDetailEM].[OccurrenceDetailEMID]=[dbo].[AD].[PrimaryOccurrenceID]
				left join CreativeForCropStaging on [Creative].PK_Id = CreativeForCropStaging.CreativeMasterStagingID
				left join CreativeContentDetailStaging on [CreativeDetailEM].CreativeDetailsEMID = CreativeContentDetailStaging.CreativeDetailID

				where AD.[AdID]=@AdID AND (CreativeDetailEM.Deleted=0 or CreativeDetailEM.Deleted is null)
				and [Creative].PrimaryIndicator=1 AND AD.[PrimaryOccurrenceID]=@PrimaryOccurrenceID
				ORDER BY Pagenumber ASC, CreativeDetailEM.[CreativeDetailsEMID]
		  END
END