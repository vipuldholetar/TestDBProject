/****** Object:  StoredProcedure [dbo].[sp_GetSurvivingNonSurvivingAd]    Script Date: 8/12/2016 4:04:33 PM ******/
CREATE PROCEDURE [dbo].[sp_GetSurvivingNonSurvivingAd]
		@AdId INt --34795 -- 33760 --  
AS
BEGIN
	SET NOCOUNT ON;
		BEGIN TRY

		DECLARE @CreativeRepository Varchar(50)
		DECLARE @SQL NVarchar(MAX)
		DECLARE @OccurrenceDetail VARCHAR(200)
		DECLARE @CreativeDetail VARCHAR(200)
		DECLARE @MediaType VARCHAR(200)
		DECLARE @CreativeKey VARCHAR(100)
		DECLARE @Path VARCHAR(550)

		SELECT @CreativeRepository = Value FROM Configuration WHERE ComponentName = 'Creative Repository'
		
		SET @MediaType = (SELECT ValueTitle FROM Configuration WHERE ConfigurationID = (select top 1 MediaStream from Pattern where AdId = @AdId))

		If(@MediaType = 'Email')
		BEGIN
			SET @OccurrenceDetail = 'OccurrenceDetailEM'
			SET @CreativeDetail = 'CreativeDetailEM'
			SET @CreativeKey = 'CreativeMasterID'
			SET @Path = 'h.CreativeRepository,h.CreativeAssetName'
		END
		Else If(@MediaType = 'Radio')
		BEGIN
			SET @OccurrenceDetail = 'OccurrenceDetailRA'
			SET @CreativeDetail = 'CreativeDetailRA'
			SET @CreativeKey = 'CreativeId'
			SET @Path = 'h.Rep,h.AssetName,h.FileType' 
		END
		Else If(@MediaType = 'Television')
		BEGIN
			SET @OccurrenceDetail = 'OccurrenceDetailTV'
			SET @CreativeDetail = 'CreativeDetailTV'
			SET @CreativeKey = 'CreativeMasterID'
			SET @Path = 'h.CreativeRepository,h.CreativeAssetName'
		END
		Else If(@MediaType = 'Circular')
		BEGIN
			SET @OccurrenceDetail = 'OccurrenceDetailCIR'
			SET @CreativeDetail = 'CreativeDetailCIR'
			SET @CreativeKey = 'CreativeMasterID'
			SET @Path = 'h.CreativeRepository,h.CreativeAssetName'
		END
		Else If(@MediaType = 'Publication')
		BEGIN
			SET @OccurrenceDetail = 'OccurrenceDetailPUB'
			SET @CreativeDetail = 'CreativeDetailPUB'
			SET @CreativeKey = 'CreativeMasterID'
			SET @Path = 'h.CreativeRepository,h.CreativeAssetName'
		END

		If (@MediaType = 'Television')
		SET @SQL = 'SELECT a.AdID as AdID,
					a.LeadAvHeadline,
					a.LeadText,
					a.AdVisual,
					b.Descrip as AdvertiserName,
					isnull(a.AdInfo,'''') as Description,
					g.Description as Language,
					e.MediaStream,
					a.AdLength,
					f.PrimaryQuality,
					a.FirstRunDate,
					a.FirstRunMarket,
					a.LastRunDate,
					' + @Path + ',
					f.PK_Id as CreativeMasterId, ''' + @CreativeRepository + ''' as CreativeRepository,
					''' + @MediaType + ''' as MediaType,
					ISNULL(f.CreativeType,'''') as CreativeType,
					d.' + @OccurrenceDetail + 'ID as OccurrenceID
					FROM Ad a, Advertiser b, Language c, ' + @OccurrenceDetail + ' d, Pattern e, Creative f, Language g, ' + @CreativeDetail + ' h
					WHERE a.AdID = ' + CAST(@AdId as VARCHAR) + ' 
					AND b.AdvertiserID = a.AdvertiserID
					AND c.LanguageID = a.LanguageID
					AND d.' + @OccurrenceDetail + 'ID = a.PrimaryOccurrenceID
					AND e.PatternID = d.PatternMasterID
					AND f.AdID = a.AdID
					AND a.LanguageId = g.LanguageId
					AND f.Pk_Id = h.' + @CreativeKey + '
					AND f.PrimaryIndicator = 1'
		ELSE
		SET @SQL = 'SELECT a.AdID as AdID,
					a.LeadAvHeadline,
					a.LeadText,
					a.AdVisual,
					b.Descrip as AdvertiserName,
					isnull(a.AdInfo,'''') as Description,
					g.Description as Language,
					e.MediaStream,
					a.AdLength,
					f.PrimaryQuality,
					a.FirstRunDate,
					a.FirstRunMarket,
					a.LastRunDate,
					' + @Path + ',
					f.PK_Id as CreativeMasterId, ''' + @CreativeRepository + ''' as CreativeRepository,
					''' + @MediaType + ''' as MediaType,
					ISNULL(f.CreativeType,'''') as CreativeType,
					d.' + @OccurrenceDetail + 'ID as OccurrenceID
					FROM Ad a, Advertiser b, Language c, ' + @OccurrenceDetail + ' d, Pattern e, Creative f, Language g, ' + @CreativeDetail + ' h
					WHERE a.AdID = ' + CAST(@AdId as VARCHAR) + ' 
					AND b.AdvertiserID = a.AdvertiserID
					AND c.LanguageID = a.LanguageID
					AND d.' + @OccurrenceDetail + 'ID = a.PrimaryOccurrenceID
					AND e.PatternID = d.PatternID
					AND f.AdID = a.AdID
					AND a.LanguageId = g.LanguageId
					AND f.Pk_Id = h.' + @CreativeKey + '
					AND f.PrimaryIndicator = 1'

		exec SP_EXECUTESQL @SQL

		END TRY
		BEGIN CATCH
		   DECLARE @ERROR   INT, 
                   @MESSAGE VARCHAR(4000), 
                   @LINENO  INT 

          SELECT @ERROR = Error_number(),@MESSAGE = Error_message(),@LINENO = Error_line() 
          RAISERROR ('[sp_GetSurvivingNonSurvivingAd]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO); 
		END CATCH
  
END