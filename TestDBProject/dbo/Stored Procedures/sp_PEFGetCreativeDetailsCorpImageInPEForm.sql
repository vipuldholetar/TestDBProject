CREATE PROCEDURE [dbo].[sp_PEFGetCreativeDetailsCorpImageInPEForm]  

(

@Media_Stream AS NVARCHAR(MAX),
@AdId INT,
@CropID AS INT  

--@AdID AS INT  

)

AS

BEGIN



			  DECLARE @MediaStreamBasePath As Nvarchar(max)=''
			  DECLARE @MediaStream varchar(max)
			  select @MediaStreamBasePath=VALUE from [Configuration] where SystemName='All' and ComponentName='Creative Repository';
			  select @MediaStream=VALUE FROM   [dbo].[Configuration] WHERE ValueTitle=@Media_Stream 
			  --SELECT @MediaStreamValue as MS,@MediaStreamBasePath as path

    BEGIN TRY

              IF(@MediaStream='RAD')

                     BEGIN                                  

								  SELECT DISTINCT a.FileType, a.Rep  + a.AssetName as AssetPath,@MediaStreamBasePath[BasePath]

									FROM [CreativeDetailRA] a 

									INNER JOIN CreativeContentDetail b ON a.[CreativeDetailRAID]  = b.[CreativeDetailID]

									INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 

									where c.FK_CropID = @CropID



								  

                     END

              IF(@MediaStream='TV')

                     BEGIN                                  

								  SELECT DISTINCT a.CreativeFileType, a.CreativeRepository  + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath]

									FROM CreativeDetailTV a 

									INNER JOIN CreativeContentDetail b ON a.[CreativeDetailTVID]  = b.[CreativeDetailID]

									INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 

									where c.FK_CropID = @CropID

                           END

			IF(@MediaStream='OD')

                     BEGIN
				 
					   SELECT distinct B.CreativeFileType,a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS AssetPath , 
						  @MediaStreamBasePath [BasePath],0 as CreativeContentDetailID,0 as ContentDetailID,
						  0 as CreativeForCropStagingId,b.CreativeDetailODRID as CreativeDetailId
					   FROM  [Creative] a, CreativeDetailODR b
					   WHERE a.[AdId] = @AdId
					   AND b.[CreativeMasterID] = a.PK_ID
					   AND B.CreativeFileType IS NOT NULL

         --                        SELECT DISTINCT a.CreativeFileType, a.CreativeRepository + '/' + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath]

									--FROM CreativeDetailODR a 

									--INNER JOIN CreativeContentDetail b ON a.[CreativeDetailODRID]  = b.[CreativeDetailID]

									--INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 

									--where c.FK_CropID = @CropID

                     END           

            IF(@MediaStream='CIN')

            BEGIN  

						  SELECT DISTINCT a.CreativeFileType, a.CreativeRepository  + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath]

							 FROM CreativeDetailCIN a 

							 INNER JOIN CreativeContentDetail b ON a.[CreativeDetailCINID]  = b.[CreativeDetailID]

							 INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 

							 where c.FK_CropID = @CropID

            END    

              IF(@MediaStream='OND')             --Online Display

                     BEGIN                          
				 
					   SELECT distinct B.CreativeFileType,a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS AssetPath , 
						  @MediaStreamBasePath [BasePath],0 as CreativeContentDetailID,0 as ContentDetailID,
						  0 as CreativeForCropStagingId,b.CreativeDetailONDID as CreativeDetailId
					   FROM  [Creative] a, CreativeDetailOND b
					   WHERE a.[AdId] = @AdId
					   AND b.[CreativeMasterID] = a.PK_ID
					   AND B.CreativeFileType IS NOT NULL

								 --  SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath]

									--FROM CreativeDetailOND a 

									--INNER JOIN CreativeContentDetail b ON a.[CreativeDetailONDID]  = b.[CreativeDetailID]

									--INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 

									--where c.FK_CropID = @CropID

                     END    

              IF(@MediaStream='ONV')             --Online Video

                     BEGIN  

								   SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath]

									FROM CreativeDetailONV a 

									INNER JOIN CreativeContentDetail b ON a.[CreativeDetailONVID]  = b.[CreativeDetailID]

									INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 

									where c.FK_CropID = @CropID

                     END    

               IF(@MediaStream='MOB')             --Mobile
                     BEGIN

						  SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath]
							 FROM CreativeDetailMOB a 
							 INNER JOIN CreativeContentDetail b ON a.[CreativeDetailMOBID]  = b.[CreativeDetailID]
							 INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
							 where c.FK_CropID = @CropID

                     END 

				IF(@MediaStream='CIR')             --Mobile
                     BEGIN
				 --IF(@CropID IS NULL OR @CropID='' or @CropID =0)
				 --   BEGIN
				    --SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath],
				    --	isnull(CreativeContentDetailID,0) as CreativeContentDetailID,isnull(c.FK_ContentDetailID,0) as ContentDetailID,
				    --	isnull(d.CreativeForCropStagingId,0) as CreativeForCropStagingId,a.CreativeDetailId
				    --	FROM CreativeDetailCIR a 
				    --	LEFT JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.[CreativeDetailID]
				    --	LEFT JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
				    --	LEFT JOIN CreativeForCropStaging d on b.CreativeCropID = d.CreativeCropId
				    --	where d.ADID=@AdID --AND a.CreativeFileType IS NOT NULL and a.Deleted = 0

					   SELECT distinct B.CreativeFileType,a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS AssetPath , 
						  @MediaStreamBasePath [BasePath],0 as CreativeContentDetailID,0 as ContentDetailID,
						  0 as CreativeForCropStagingId,b.CreativeDetailId
					   FROM  [Creative] a, CreativeDetailCIR b
					   WHERE a.[AdId] = @AdId
					   AND b.[CreativeMasterID] = a.PK_ID
					   AND B.CreativeFileType IS NOT NULL and B.Deleted = 0
								    
						  -- SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath]
						  --FROM CreativeDetailCIR a 
						  --INNER JOIN CreativeMaster d ON a.CreativeMasterID=d.Pk_ID
						  --LEFT JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.FK_CreativeDetailID
						  --LEFT JOIN CreativeDetailInclude c ON b.PK_ID = c.FK_ContentDetailID 
						  --where  d.FK_ADID=@AdID AND a.CreativeFileType IS NOT NULL
				--    END
				--ELSE
				--    BEGIN
				--    SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath],
				--		  isnull(CreativeContentDetailID,0) as CreativeContentDetailID,isnull(c.FK_ContentDetailID,0) as ContentDetailID,
				--		  isnull(d.CreativeForCropId,0) as CreativeForCropStagingId,a.CreativeDetailId
				--		  FROM CreativeDetailCIR a 
				--		  LEFT JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.[CreativeDetailID]
				--		  LEFT JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
				--		  LEFT JOIN CreativeForCrop d on b.CreativeCropID = d.CreativeForCropID
				--		  where c.FK_CropID = @CropID	and a.Deleted = 0

				--	   --   SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'')  + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath],
				--		  --isnull(CreativeContentDetailID,0) as CreativeContentDetailID,isnull(c.FK_ContentDetailID,0) as ContentDetailID,
				--		  --isnull(d.CreativeForCropId,0) as CreativeForCropStagingId,a.CreativeDetailId
				--		  --FROM CreativeDetailCIR a 
				--		  --INNER JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.[CreativeDetailID]
				--		  --INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 
				--		  --INNER JOIN CreativeForCrop d on d.CreativeForCropID = b.CreativeCropID
				--		  --where c.FK_CropID = @CropID	and a.Deleted = 0
				--    END			
                     END     

				IF(@MediaStream='PUB')             --Mobile

                     BEGIN

				 
					   SELECT distinct B.CreativeFileType,a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS AssetPath , 
						  @MediaStreamBasePath [BasePath],0 as CreativeContentDetailID,0 as ContentDetailID,
						  0 as CreativeForCropStagingId,b.CreativeDetailId
					   FROM  [Creative] a, CreativeDetailPUB b
					   WHERE a.[AdId] = @AdId
					   AND b.[CreativeMasterID] = a.PK_ID
					   AND B.CreativeFileType IS NOT NULL and B.Deleted = 0

								 -- SELECT DISTINCT a.CreativeFileType, ISNULL(a.CreativeRepository,'') + a.CreativeAssetName as AssetPath,@MediaStreamBasePath[BasePath]

									--FROM CreativeDetailPUB a 

									--INNER JOIN CreativeContentDetail b ON a.CreativeDetailID  = b.[CreativeDetailID]

									--INNER JOIN CreativeDetailInclude c ON b.[CreativeContentDetailID] = c.FK_ContentDetailID 

									--where c.FK_CropID = @CropID

                     END          

              END TRY

              BEGIN CATCH

                                  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 

                                  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

                                  RAISERROR ('sp_PEFGetCreativeDetailsCorpImageInPEForm: %d: %s',16,1,@error,@message,@lineNo); 

              END CATCH

END