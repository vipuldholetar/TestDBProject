-- ===========================================================================
-- Author			: Mark
-- Create date		: 09/14/17
-- Description		: This Procedure is Used to Getting Creatives to be transfered
-- Execution		: sp_GetCreativesForAws 
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--					  Karunakar on 7th Sep 2015
--=============================================================================
CREATE PROCEDURE [dbo].[sp_GetCreativesForAws]
(@Descrip varchar(100)='')
AS
BEGIN

	SET NOCOUNT ON;
		 BEGIN TRY
  DECLARE @BasePath AS VARCHAR(MAX)
		DECLARE @RemoteBasePath AS VARCHAR(MAX) 
	   
		select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'

			--  SELECT distinct top 5  'RAD' MediaType, [Creative].PK_Id As CreativeId,[CreativeDetailRA].[CreativeDetailRAID] AS Creativedetailid,Adid, [Creative].PrimaryIndicator,
			--@BasePath + [CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+RTRIM(LTRIM([CreativeDetailRA].FileType)) As LocalCreativeFilePath,
			--@RemoteBasePath + [CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+RTRIM(LTRIM([CreativeDetailRA].FileType)) As RemoteCreativeFilePath,
			--@RemoteBasePath + [CreativeDetailRA].Rep+[Creative].AssetThmbnlName+'.'+RTRIM(LTRIM([Creative].ThmbnlFileType)) As RemoteCreativeThumbFilePath, [CreativeDetailRA].FileType,
			--CAST([CreativeDetailRA].[CreativeDetailRAID] as varchar)+'-'+[CreativeDetailRA].Rep + 
			--	[CreativeDetailRA].AssetName+'.'+RTRIM(LTRIM([CreativeDetailRA].FileType)) AS DetailIDwithFilepath,
			--[Creative].SourceOccurrenceId OccurrenceID
		 -- FROM [Creative] INNER JOIN [CreativeDetailRA] on [Creative].PK_Id=[CreativeDetailRA].[CreativeID] and [CreativeDetailRA].CreativeDetailRAID not in (select creativeDetailid from CreativesSentToAWS)  and [CreativeDetailRA].AssetName is not Null-- and StatusId =1
		  
--SELECT top 5 'ODR' MediaType, creativedetailodr.CreativeDetailODRID OccurrenceID, [Creative].AdId, creativedetailodr.[CreativeDetailODRID] AS CreativeDetailID, 
--                    creativedetailodr.creativemasterid AS CreativeId, 
--				CASE WHEN CreativeAssetName IS NULL 
--					   THEN LegacyCreativeAssetName + '.' + creativefiletype  
--						  ELSE creativeassetname END as creativename,
--				CASE WHEN CreativeAssetName IS NULL 
--							THEN @BasePath + CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
--								ELSE @BasePath + CreativeRepository + CreativeAssetName END AS LocalCreativeFilePath,
--				CASE WHEN CreativeAssetName IS NULL 
--							THEN CreativeRepository + LegacyCreativeAssetName + '.' + creativefiletype 
--								ELSE @RemoteBasePath + CreativeRepository + CreativeAssetName END AS RemoteCreativeFilePath,
				
--				    CASE WHEN AssetThmbnlName IS NULL 
--						THEN @BasePath + ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
--							ELSE @BasePath + ThmbnlRep +AssetThmbnlName END AS LocalThumbnailPath,
--				CASE WHEN AssetThmbnlName IS NULL 
--						THEN ThmbnlRep + LegacyThmbnlAssetName + '.' + ThmbnlFileType 
--							ELSE @RemoteBasePath + ThmbnlRep +AssetThmbnlName END AS RemoteThumbnailPath,
--                    creativerepository + creativeassetname AS CreativeRepository 
        
--                FROM   [Creative] 
--                       INNER JOIN creativedetailodr 
--                               ON [Creative].pk_id = 
--                                  creativedetailodr.creativemasterid and creativedetailodr.CreativeDetailODRID not in (select creativeDetailid from CreativesSentToAWS) -- and StatusId =1
                                 
		  
		select @RemoteBasePath = Value from Configuration WHERE ComponentName='Creative Repository'
  SELECT distinct top 5  'TV' MediaType, [Creative].PK_Id As CreativeId,[CreativeDetailTV].[CreativeDetailTVID] AS Creativedetailid,[Creative].Adid, [Creative].PrimaryIndicator,
			@BasePath + [CreativeDetailTV].CreativeRepository+[CreativeDetailTV].CreativeAssetName+'.'+RTRIM(LTRIM([CreativeDetailTV].CreativeFileType)) As LocalCreativeFilePath,
			 CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName AS RemoteCreativeFilePath,
			@RemoteBasePath + [CreativeDetailTV].CreativeRepository+[Creative].AssetThmbnlName+'.'+RTRIM(LTRIM([Creative].ThmbnlFileType)) As RemoteCreativeThumbFilePath, [CreativeDetailTV].CreativeFileType FileType,
			CAST([CreativeDetailTV].[CreativeDetailTVID] as varchar)+'-'+[CreativeDetailTV].CreativeRepository + 
				[CreativeDetailTV].CreativeAssetName+'.'+RTRIM(LTRIM([CreativeDetailTV].CreativeFileType)) AS DetailIDwithFilepath,
			[Creative].SourceOccurrenceId OccurrenceID, Pattern.CreativeSignature		
		  FROM [Creative] INNER JOIN [CreativeDetailTV] on [Creative].PK_Id=[CreativeDetailTV].[CreativeMasterID]
		    inner join Pattern on Pattern.CreativeId = [CreativeDetailTV].[CreativeMasterID]
		  where [CreativeDetailTV].CreativeDetailTVID not in (select creativeDetailid from CreativesSentToAWS)  and [CreativeDetailTV].CreativeAssetName is not Null-- and StatusId =1
		
		END  TRY
		BEGIN CATCH
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_GetCreativesForAws]: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH
END