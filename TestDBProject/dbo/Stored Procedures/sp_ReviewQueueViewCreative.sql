-- =========================================================================================================
-- Author			: Karunakar
-- Create date		: 09/01/2015
-- Description		: This stored procedure is used to Getting Review Queue View Creative Data
-- Execution Process: [dbo].[sp_QueryQueueViewCreative]'9233','ISS',0,0,1022
-- Updated By		: Ramesh Bangi for Online Display on 09/25/2015
--					: Karunakar on 10/13/2015,Adding Mobile,Online Video and Online Display
--					  Arun Nair on 01/25/2016 - Added CreativeMasterId for Outdoor,Mobile,OnlineDisplay
-- ============================================================================================================
CREATE PROCEDURE [dbo].[sp_ReviewQueueViewCreative]  
(
 @MediaStream AS NVARCHAR(MAX),
 @AdID AS INT,
 @OccurrenceID AS BIGINT,
 @PatternmasterId AS INT      
)
AS
BEGIN
       	DECLARE @MediaStreamValue As Nvarchar(max)=''
		SELECT @MediaStreamValue=Value  FROM   [dbo].[Configuration] WHERE ValueTitle=@MediaStream

		BEGIN TRY
		IF(@MediaStreamValue='RAD')
			BEGIN
					SELECT        [CreativeDetailRA].Rep+[CreativeDetailRA].AssetName+'.'+FileType As [PrimarySource]
					FROM            [Pattern] 
					INNER JOIN   [CreativeDetailRA] 
					ON [Pattern].[CreativeID] = [CreativeDetailRA].[CreativeID]
					Where [Pattern].[PatternID]=@PatternmasterId
			END
		IF(@MediaStreamValue='TV')
			BEGIN
					SELECT        CreativeDetailTV.CreativeRepository+CreativeDetailTV.CreativeAssetName As [PrimarySource]
					FROM            [Pattern] 
					INNER JOIN   CreativeDetailTV 
					ON [Pattern].[CreativeID] = CreativeDetailTV.CreativeMasterID
					Where [Pattern].[PatternID]=@PatternmasterId
				END
         IF(@MediaStreamValue='OD')
			BEGIN
					SELECT        CreativeDetailODR.CreativeRepository+CreativeDetailODR.CreativeAssetName As [PrimarySource],CreativeDetailODR.CreativeMasterID
					FROM            [Pattern] 
					INNER JOIN   CreativeDetailODR 
					ON [Pattern].[CreativeID] = CreativeDetailODR.CreativeMasterID
					Where [Pattern].[PatternID]=@PatternmasterId
			END		
	     IF(@MediaStreamValue='CIN')
			BEGIN
				SELECT        CreativeDetailCIN.CreativeRepository+CreativeDetailCIN.CreativeAssetName As [PrimarySource]
				FROM            [Pattern] 
				INNER JOIN   CreativeDetailCIN 
				ON [Pattern].[CreativeID] = CreativeDetailCIN.[CreativeMasterID]
				Where [Pattern].[PatternID]=@PatternmasterId
			END	
		 IF(@MediaStreamValue='OND')		--Online Display
			BEGIN
				SELECT        CreativeDetailOND.CreativeRepository+CreativeDetailOND.CreativeAssetName As [PrimarySource],CreativeDetailOND.[CreativeMasterID]
				FROM            [Pattern] 
				INNER JOIN   CreativeDetailOND 
				ON [Pattern].[CreativeID] = CreativeDetailOND.[CreativeMasterID]
				Where [Pattern].[PatternID]=@PatternmasterId
			END	
		 IF(@MediaStreamValue='ONV')		--Online Video
			BEGIN
				SELECT        CreativeDetailONV.CreativeRepository+CreativeDetailONV.CreativeAssetName As [PrimarySource]
				FROM            [Pattern] 
				INNER JOIN   CreativeDetailONV 
				ON [Pattern].[CreativeID] = CreativeDetailONV.[CreativeMasterID]
				Where [Pattern].[PatternID]=@PatternmasterId
			END	 
		 IF(@MediaStreamValue='MOB')		--Mobile
			BEGIN
				SELECT        CreativeDetailMOB.CreativeRepository+CreativeDetailMOB.CreativeAssetName As [PrimarySource],creativefiletype,CreativeDetailMOB.[CreativeMasterID]
				FROM            [Pattern] 
				INNER JOIN   CreativeDetailMOB 
				ON [Pattern].[CreativeID] = CreativeDetailMOB.[CreativeMasterID]
				Where [Pattern].[PatternID]=@PatternmasterId
			END	  
		END TRY
		BEGIN CATCH
					DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_ReviewQueueViewCreative]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH
END
