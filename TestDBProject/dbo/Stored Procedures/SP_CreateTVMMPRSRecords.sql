CREATE PROCEDURE [dbo].[SP_CreateTVMMPRSRecords]
@TempForApproval dbo.MultiMapApproval readonly, 
@TempForApprovalList dbo.MultiMapApprovalList readonly,
@CreatedBy INT 
AS
 IF 1 = 0 
   BEGIN 
    SET FMTONLY OFF 
   END
BEGIN
 SET NOCOUNT ON
      BEGIN TRY
		DECLARE @Index  INT =0
		DECLARE @CurrentRow INT =0
		DECLARE @Counter INT=0
		DECLARE @AdIdTemp INT=0
		DECLARE @MediaStreamTemp INT=0
		DECLARE @MediaStreamVal VARCHAR(20)=''
		DECLARE @StatusTemp VARCHAR(20)=''
		DECLARE @StatusTempAll VARCHAR(20)=''
		DECLARE @OriginalPatternCodeTemp VARCHAR(200)=''
		DECLARE @MarketIdTemp INT = 0
		DECLARE @MINDATE AS  DATETIME = dateADD(day, -30, (select MIN(EffectiveStartDate) FROM @TempForApprovalList))
		SELECT TOP 1 @StatusTempAll =  [Status] from  @TempForApprovalList --WHERE RowID= @CurrentRow
		IF (@StatusTempAll = 'AP')
		 BEGIN
			SELECT TOP 1 @OriginalPatternCodeTemp = [OriginalPatternCode] FROM  @TempForApprovalList --WHERE RowID= @CurrentRow
			SELECT TOP 1 @AdIdTemp =  [AdId] FROM  @TempForApprovalList --WHERE RowID= @CurrentRow					
			SELECT TOP 1 @MediaStreamVal = [MediaStream] FROM  @TempForApprovalList --WHERE RowID= @CurrentRow
			SELECT TOP 1 @MarketIdTemp = [MarketId] FROM  @TempForApprovalList --WHERE RowID= @CurrentRow
			SELECT @MediaStreamTemp = ConfigurationId FROM [Configuration] WHERE value = @MediaStreamVal AND ComponentName = 'Media Stream' and ValueGroup = 'Non Print'
			EXEC sp_MultiMapAproveforAllMarketAndAirDate @TempForApproval,@OriginalPatternCodeTemp,@AdIdTemp,@MediaStreamTemp,@StatusTempAll,@MarketIdTemp,@MINDATE,@CreatedBy
		 END
		ELSE
		 BEGIN			
			SELECT @Counter = Count(*) FROM   @TempForApprovalList
			PRINT(@Counter) 
			SET @Index = 1 
			WHILE @Index <= @Counter
			BEGIN						
				SET @OriginalPatternCodeTemp= (SELECT OriginalPatternCode FROM  @TempForApprovalList WHERE RowID= @Index)
				SET @AdIdTemp = (SELECT AdId FROM  @TempForApprovalList WHERE RowID= @Index)
				SET @StatusTemp = ( SELECT Status FROM  @TempForApprovalList WHERE RowID= @Index)
				SET @MediaStreamVal = (SELECT MediaStream FROM  @TempForApprovalList WHERE RowID= @Index)
				SELECT @MediaStreamTemp = ConfigurationId FROM [Configuration] WHERE value = @MediaStreamVal AND ComponentName = 'Media Stream' and ValueGroup = 'Non Print'
				SET @MarketIdTemp = (SELECT MarketId FROM  @TempForApprovalList WHERE RowID= @Index)
				
				Print @OriginalPatternCodeTemp
				Print @AdIdTemp
				Print @StatusTemp
				Print @MediaStreamTemp
				Print @MarketIdTemp
				print @MINDATE		
				IF(@StatusTemp = 'UA')
				BEGIN
					print 'Processing Selected Market'								
					EXEC [dbo].[sp_MultiMapApproveGeographicAreaAndAirDates] @OriginalPatternCodeTemp,@AdIdTemp,@MediaStreamTemp,@StatusTemp,@MarketIdTemp,@MINDATE,@TempForApproval,@CreatedBy 
				END
				ELSE IF (@StatusTemp = 'RE')
				BEGIN
					print 'Processing Rejected Market'						
					EXEC [dbo].[sp_MultiMapRejectedGeoAndAirDate] @OriginalPatternCodeTemp,@AdIdTemp,@StatusTemp,@MarketIdTemp,@MINDATE,@CreatedBy
				END
				SELECT @Index= (@Index + 1)					 
			END			
		 END
	  END TRY 
	  BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000),@lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[SP_CreateTVMMPRSRecords]: %d: %s',16,1,@error,@message,@lineNo)         
      END CATCH 
END
