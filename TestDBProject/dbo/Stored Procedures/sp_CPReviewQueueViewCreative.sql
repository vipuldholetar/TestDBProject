-- =============================================
-- Author:		Suman Saurav
-- Create date: 29 Dec 2015
-- Description:	Used to find media type
--Exec : EXEC sp_CPReviewQueueViewCreative 'Outdoor','AC',0,2159
-- =============================================
CREATE PROCEDURE [dbo].[sp_CPReviewQueueViewCreative]
(
	@MediaStream	NVARCHAR(MAX),
	@AuditType		VARCHAR(2),
	@CropId			INT,
	@AdId			INT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @MediaStreamValue AS NVARCHAR(MAX) = '', @MediaStreamBasePath AS NVARCHAR(MAX) = ''
        SELECT @MediaStreamValue = Value FROM [dbo].[Configuration] WHERE ValueTitle = @MediaStream
		
		SELECT @MediaStreamBasePath = VALUE FROM [Configuration] WHERE SystemName = 'All' AND ComponentName = 'Creative Repository';
		--For AuditType of “CR” and “PE”, to view is Crop Page.
		IF(@AuditType = 'CR' OR @AuditType = 'PE')
		BEGIN
			IF(@MediaStreamValue = 'RAD')
			BEGIN
				SELECT TOP 1 c.[CreativeDetailRAID], c.CreativeRepository + c.AssetName + ' ' + c.FileType AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailRA c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.[CreativeDetailRAID] = b.[CreativeDetailID]				
			END
			ELSE
			IF(@MediaStreamValue = 'OD')
			BEGIN
				SELECT TOP 1 c.[CreativeDetailODRID], c.CreativeRepository + c.CreativeAssetName AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailODR c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.[CreativeDetailODRID] = b.[CreativeDetailID]				
			END
			ELSE
			IF(@MediaStreamValue = 'CIN')
			BEGIN
				SELECT TOP 1 c.[CreativeDetailCINID], c.CreativeRepository + c.CreativeAssetName AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailCIN c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.[CreativeDetailCINID] = b.[CreativeDetailID]				
			END
			ELSE
			IF(@MediaStreamValue = 'TV')
			BEGIN
				SELECT TOP 1 c.[CreativeDetailTVID], c.CreativeRepository + c.CreativeAssetName AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailTV c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.[CreativeDetailTVID] = b.[CreativeDetailID]				
			END 
			ELSE IF(@MediaStreamValue = 'CIR')
			BEGIN
				
				SELECT TOP 1 c.CreativeDetailID, c.CreativeRepository + c.CreativeAssetName AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailCIR c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.CreativeDetailID = b.[CreativeDetailID]				
			END
			ELSE
			IF(@MediaStreamValue = 'EM')
			BEGIN
				SELECT c.[CreativeDetailsEMID], c.CreativeRepository + c.CreativeAssetName AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailEM c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.[CreativeDetailsEMID] = b.[CreativeDetailID]				
			END
			ELSE
			IF(@MediaStreamValue = 'MOB')
			BEGIN
				SELECT TOP 1 c.[CreativeDetailMOBID], c.CreativeRepository + c.CreativeAssetName AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailMOB c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.[CreativeDetailMOBID] = b.[CreativeDetailID]				
			END
			ELSE
			IF(@MediaStreamValue = 'OND')
			BEGIN
				SELECT TOP 1 c.[CreativeDetailONDID], c.CreativeRepository + c.CreativeAssetName AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailOND c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.[CreativeDetailONDID] = b.[CreativeDetailID]				
			END
			ELSE IF(@MediaStreamValue = 'PUB')
			BEGIN
				SELECT TOP 1 c.CreativeDetailID, c.CreativeRepository + c.CreativeAssetName + ' ' + c.CreativeFileType AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailPUB c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.CreativeDetailID = b.[CreativeDetailID]				
			END
			ELSE IF(@MediaStreamValue = 'ONV')
			BEGIN
				SELECT TOP 1 c.[CreativeDetailONVID], c.CreativeRepository + c.CreativeAssetName + ' ' + c.CreativeFileType AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailONV c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.[CreativeDetailONVID] = b.[CreativeDetailID]				
			END
			ELSE IF(@MediaStreamValue = 'PUB')
			BEGIN
				SELECT TOP 1 c.CreativeDetailID, c.CreativeRepository + c.CreativeAssetName AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailPUB c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.CreativeDetailID = b.[CreativeDetailID]				
			END
			ELSE IF(@MediaStreamValue = 'SOC')
			BEGIN
				SELECT TOP 1 c.[CreativeDetailSOCID], c.CreativeRepository + c.CreativeAssetName AS [PrimarySource], @MediaStreamBasePath[BasePath]
				FROM  CreativeDetailInclude a, CreativeContentDetail b, CreativeDetailSOC c
				WHERE a.FK_CropID = @CropId
				AND b.[CreativeContentDetailID] = a.FK_ContentDetailID
				AND c.[CreativeDetailSOCID] = b.[CreativeDetailID]				
			END
		END
		ELSE IF(@AuditType = 'AC')
		BEGIN
			IF(@MediaStreamValue = 'RAD')
			BEGIN
				SELECT TOP 1 a.PK_ID, b.Rep + b.AssetName + ' ' + b.FileType AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, [CreativeDetailRA] b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.[CreativeID] = a.PK_ID
			END
			ELSE
			IF(@MediaStreamValue = 'OD')
			BEGIN
				SELECT TOP 1 a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailODR b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.CreativeMasterID = a.PK_ID
			END
			ELSE
			IF(@MediaStreamValue = 'CIN')
			BEGIN
				SELECT TOP 1 a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailCIN b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.[CreativeMasterID] = a.PK_ID
			END
			ELSE
			IF(@MediaStreamValue = 'TV')
			BEGIN
				SELECT TOP 1 a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailTV b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.CreativeMasterID = a.PK_ID
			END 
			ELSE IF(@MediaStreamValue = 'CIR')
			BEGIN
				SELECT TOP 1 a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailCIR b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.CreativeMasterID = a.PK_ID
			END
			ELSE
			IF(@MediaStreamValue = 'EM')
			BEGIN
				SELECT TOP 1 a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailEM b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.CreativeMasterID = a.PK_ID
			END
			ELSE
			IF(@MediaStreamValue = 'MOB')
			BEGIN
				SELECT TOP 1 a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailMOB b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.[CreativeMasterID] = a.PK_ID
			END
			ELSE
			IF(@MediaStreamValue = 'OND')
			BEGIN
				SELECT TOP 1 a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailOND b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.[CreativeMasterID] = a.PK_ID
			END
			ELSE IF(@MediaStreamValue = 'PUB') 
			BEGIN

			   SELECT TOP 1 a.PK_ID, b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailPUB b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.CreativeMasterID = a.PK_Id

			END
			ELSE IF(@MediaStreamValue = 'ONV')
			BEGIN
			     SELECT TOP 1 a.PK_ID,b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailONV b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.[CreativeMasterID] = a.PK_Id

			END
			ELSE IF(@MediaStreamValue = 'PUB')
			BEGIN

			SELECT TOP 1 a.PK_ID,b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailPUB b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.CreativeMasterID = a.PK_Id
				
			END
			ELSE IF(@MediaStreamValue = 'SOC')
			BEGIN

				SELECT TOP 1 a.PK_ID,b.CreativeRepository + b.CreativeAssetName  AS [PrimarySource] , @MediaStreamBasePath[BasePath]
				FROM  [Creative] a, CreativeDetailSOC b
				WHERE a.[AdId] = @AdId
				AND a.PrimaryIndicator = 1
				AND b.CreativeMasterID = a.PK_Id

			END
		END
	END TRY
	BEGIN CATCH
		DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
        SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
        RAISERROR ('sp_CPReviewQueueViewCreative: %d: %s',16,1,@error,@message,@lineNo);
	END CATCH
END
