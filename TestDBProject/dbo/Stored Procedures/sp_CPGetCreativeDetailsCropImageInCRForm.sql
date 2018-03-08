CREATE PROCEDURE [dbo].[sp_CPGetCreativeDetailsCropImageInCRForm]  
(
@MediaStream AS NVARCHAR(MAX),
@CropID AS INT  ,
@AdID AS INT  
)
AS
BEGIN
              DECLARE @MediaStreamValue As Nvarchar(max)=''			   
              SELECT @MediaStreamValue=Value  FROM   [dbo].[Configuration] WHERE ValueTitle=@MediaStream
			  DECLARE @MediaStreamBasePath As Nvarchar(max)=''
			  select @MediaStreamBasePath=VALUE from [Configuration] where SystemName='All' and ComponentName='Creative Repository';
			  --SELECT @MediaStreamValue as MS,@MediaStreamBasePath as path
              BEGIN TRY
              IF(@MediaStreamValue='RAD')
                     BEGIN                                  
								  SELECT DISTINCT a.FileType, a.Rep  + a.AssetName AS PrimarySource,@MediaStreamBasePath[BasePath]
									FROM [CreativeDetailRA] a 
									INNER JOIN CreativeContentDetail b ON a.[CreativeDetailRAID]  = b.[CreativeDetailID]
									INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
									where c.FK_CropID = @CropID
								  
                     END
              IF(@MediaStreamValue='TV')
                     BEGIN                                  
								  SELECT DISTINCT a.CreativeFileType, a.CreativeRepository  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath]
									FROM CreativeDetailTV a 
									INNER JOIN CreativeContentDetail b ON a.[CreativeDetailTVID]  = b.[CreativeDetailID]
									INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
									where c.FK_CropID = @CropID
                           END
			IF(@MediaStreamValue='OD')
                     BEGIN

					   
									SELECT distinct B.CreativeFileType,a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS PrimarySource , @MediaStreamBasePath [BasePath],
										isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,isnull(ContentDetailID,0) ContentDetailID,isnull(c.CreativeForCropStagingID,0) CreativeForCropStagingID,
										b.CreativeDetailODRID as CreativeDetailId
								    FROM [Creative] a inner join CreativeDetailODR b on b.[CreativeMasterID] = a.PK_ID
									   inner join CreativeForCropStaging c on a.PK_Id = c.CreativeMasterStagingID
									   left join CreativeContentDetailStaging D on b.CreativeDetailODRID = D.CreativeDetailID
								    WHERE a.[AdId] = @AdId
								    AND b.[CreativeMasterID] = a.PK_ID
								    AND B.CreativeFileType IS NOT NULL

         --                        SELECT DISTINCT a.CreativeFileType, a.CreativeRepository + '/' + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath]
									--FROM CreativeDetailODR a 
									--INNER JOIN CreativeContentDetail b ON a.[CreativeDetailODRID]  = b.[CreativeDetailID]
									--INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
									--where c.FK_CropID = @CropID
                     END           
            IF(@MediaStreamValue='CIN')
                     BEGIN  
								   SELECT DISTINCT a.CreativeFileType, a.CreativeRepository  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath]
									FROM CreativeDetailCIN a 
									INNER JOIN CreativeContentDetail b ON a.[CreativeDetailCINID]  = b.[CreativeDetailID]
									INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
									where c.FK_CropID = @CropID
                     END    
              IF(@MediaStreamValue='OND')             --Online Display
                     BEGIN                
						  
									SELECT distinct B.CreativeFileType,a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS PrimarySource , @MediaStreamBasePath [BasePath],
										isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,isnull(ContentDetailID,0) ContentDetailID,isnull(c.CreativeForCropStagingID,0) CreativeForCropStagingID,
										b.CreativeDetailONDID as CreativeDetailId
								    FROM [Creative] a inner join CreativeDetailOND b on b.[CreativeMasterID] = a.PK_ID
									   inner join CreativeForCropStaging c on a.PK_Id = c.CreativeMasterStagingID
									   left join CreativeContentDetailStaging D on b.CreativeDetailONDID = D.CreativeDetailID
								    WHERE a.[AdId] = @AdId
								    AND b.[CreativeMasterID] = a.PK_ID
								    AND B.CreativeFileType IS NOT NULL
          
								 --  SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath]
									--FROM CreativeDetailOND a 
									--INNER JOIN CreativeContentDetail b ON a.[CreativeDetailONDID]  = b.[CreativeDetailID]
									--INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
									--where c.FK_CropID = @CropID
                     END    
              IF(@MediaStreamValue='ONV')             --Online Video
                     BEGIN  
								   SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath]
									FROM CreativeDetailONV a 
									INNER JOIN CreativeContentDetail b ON a.[CreativeDetailONVID]  = b.[CreativeDetailID]
									INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
									where c.FK_CropID = @CropID
                     END    
               IF(@MediaStreamValue='MOB')             --Mobile
                     BEGIN
								   SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath]
									FROM CreativeDetailMOB a 
									INNER JOIN CreativeContentDetail b ON a.[CreativeDetailMOBID]  = b.[CreativeDetailID]
									INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
									where c.FK_CropID = @CropID
                     END 

					   IF(@MediaStreamValue='EM') -- Email
					   BEGIN
					   
							
								    SELECT distinct B.CreativeFileType,a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS PrimarySource , @MediaStreamBasePath [BasePath],
									   isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,isnull(ContentDetailID,0) ContentDetailID,isnull(c.CreativeForCropStagingID,0) CreativeForCropStagingID,
									   b.CreativeDetailsEMID as CreativeDetailId
								FROM [Creative] a inner join CreativeDetailEM b on b.[CreativeMasterID] = a.PK_ID
								    inner join CreativeForCropStaging c on a.PK_Id = c.CreativeMasterStagingID
								    left join CreativeContentDetailStaging D on b.CreativeDetailsEMID = D.CreativeDetailID
								WHERE a.[AdId] = @AdId
								AND b.[CreativeMasterID] = a.PK_ID
								AND B.CreativeFileType IS NOT NULL

					    --  SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath],
									--isnull(CreativeContentDetailID,0) as CreativeContentDetailID,isnull(c.FK_ContentDetailID,0) as ContentDetailID,
									--isnull(d.CreativeForCropStagingId,0) as CreativeForCropStagingId,a.CreativeDetailsEMID as CreativeDetailId
									--FROM CreativeDetailEM a 
									--INNER JOIN CreativeContentDetail b ON a.CreativeDetailsEMID  = b.[CreativeDetailID]
									--INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
									--LEFT JOIN CreativeForCropStaging d on b.CreativeCropID = d.CreativeCropId
									--where c.FK_CropID = @CropID and a.Deleted= 0	
					   END	
					   IF(@MediaStreamValue='CIR')             --Mobile
                     BEGIN
								    
									
							--IF(@CropID IS NULL OR @CropID='' or @CropID =0)
							--	BEGIN
								--SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath],
								--	isnull(CreativeContentDetailID,0) as CreativeContentDetailID,isnull(c.FK_ContentDetailID,0) as ContentDetailID,
								--	isnull(d.CreativeForCropStagingId,0) as CreativeForCropStagingId,a.CreativeDetailId
								--	FROM CreativeDetailCIR a 
								--	LEFT JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.[CreativeDetailID]
								--	LEFT JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
								--	LEFT JOIN CreativeForCropStaging d on b.CreativeCropID = d.CreativeCropId
								--	where d.ADID=@AdID --AND a.CreativeFileType IS NOT NULL and a.Deleted = 0

									
									SELECT distinct B.CreativeFileType,a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS PrimarySource , @MediaStreamBasePath [BasePath],
										isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,isnull(ContentDetailID,0) ContentDetailID,isnull(c.CreativeForCropStagingID,0) CreativeForCropStagingID,
										b.CreativeDetailID as CreativeDetailId
								    FROM [Creative] a inner join CreativeDetailCIR b on b.[CreativeMasterID] = a.PK_ID
									   inner join CreativeForCropStaging c on a.PK_Id = c.CreativeMasterStagingID
									   left join CreativeContentDetailStaging D on b.CreativeDetailID = D.CreativeDetailID
								    WHERE a.[AdId] = @AdId
								    AND b.[CreativeMasterID] = a.PK_ID
								    AND B.CreativeFileType IS NOT NULL
								    
									-- SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath]
									--FROM CreativeDetailCIR a 
									--INNER JOIN CreativeMaster d ON a.CreativeMasterID=d.Pk_ID
									--LEFT JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.FK_CreativeDetailID
									--LEFT JOIN CreativeDetailInclude c ON b.PK_ID = c.FK_ContentDetailID 
									--where  d.FK_ADID=@AdID AND a.CreativeFileType IS NOT NULL
								--END
							--ELSE
							--	BEGIN
							--	SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath],
							--		isnull(CreativeContentDetailID,0) as CreativeContentDetailID,isnull(c.FK_ContentDetailID,0) as ContentDetailID,
							--		isnull(d.CreativeForCropStagingId,0) as CreativeForCropStagingId,a.CreativeDetailId
							--		FROM CreativeDetailCIR a 
							--		LEFT JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.[CreativeDetailID]
							--		LEFT JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
							--		LEFT JOIN CreativeForCropStaging d on b.CreativeCropID = d.CreativeCropId
							--		where c.FK_CropID = @CropID	and a.Deleted = 0
							--		--SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath]
							--		--FROM CreativeDetailCIR a 
							--		--INNER JOIN CreativeMaster d ON a.CreativeMasterID=d.Pk_ID
							--		--LEFT JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.FK_CreativeDetailID
							--		--LEFT JOIN CreativeDetailInclude c ON b.PK_ID = c.FK_ContentDetailID 
							--		--where  d.FK_ADID=@AdID AND a.CreativeFileType IS NOT NULL AND c.FK_CropID = @CropID
							--	END					
                     END     
				IF(@MediaStreamValue='PUB')             --Mobile
                     BEGIN
				 --IF(@CropID IS NULL OR @CropID='' or @CropID =0)
				 --   BEGIN
						  --SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'') + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath],
					   --isnull(CreativeContentDetailID,0) as CreativeContentDetailID,isnull(c.FK_ContentDetailID,0) as ContentDetailID,
						  --isnull(d.CreativeForCropStagingId,0) as CreativeForCropStagingId,a.CreativeDetailId
						  --FROM CreativeDetailPUB a 
						  --LEFT JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.[CreativeDetailID]
						  --LEFT JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
						  --LEFT JOIN CreativeForCropStaging d on b.CreativeCropID = d.CreativeCropId
						  --where d.ADID=@AdID
						  
						  SELECT distinct B.CreativeFileType,a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS PrimarySource , @MediaStreamBasePath [BasePath],
								isnull(CreativeContentDetailStagingID,0) as CreativeContentDetailID,isnull(ContentDetailID,0) ContentDetailID,isnull(c.CreativeForCropStagingID,0) CreativeForCropStagingID,
								b.CreativeDetailID as CreativeDetailId
						  FROM [Creative] a inner join CreativeDetailPUB b on b.[CreativeMasterID] = a.PK_ID
							 inner join CreativeForCropStaging c on a.PK_Id = c.CreativeMasterStagingID
							 left join CreativeContentDetailStaging D on b.CreativeDetailID = D.CreativeDetailID
						  WHERE a.[AdId] = @AdId
						  AND b.[CreativeMasterID] = a.PK_ID
						  AND B.CreativeFileType IS NOT NULL
				--    END
				--ELSE
				--    BEGIN
				--    SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'') + a.CreativeAssetName AS PrimarySource,@MediaStreamBasePath[BasePath],
				--	   isnull(CreativeContentDetailID,0) as CreativeContentDetailID,isnull(c.FK_ContentDetailID,0) as ContentDetailID,
				--		  isnull(d.CreativeForCropStagingId,0) as CreativeForCropStagingId,a.CreativeDetailId
				--		  FROM CreativeDetailPUB a 
				--		  LEFT JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.[CreativeDetailID]
				--		  LEFT JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
				--		  LEFT JOIN CreativeForCropStaging d on b.CreativeCropID = d.CreativeCropId
				--		  where c.FK_CropID = @CropID
				--    END	
								  
                     END          
              END TRY
              BEGIN CATCH
                                  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
                                  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
                                  RAISERROR ('sp_CPGetCreativeDetailsCropImageInCRForm: %d: %s',16,1,@error,@message,@lineNo); 
              END CATCH
END