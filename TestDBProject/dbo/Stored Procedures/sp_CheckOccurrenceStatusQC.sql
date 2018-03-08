-- ===================================================================================

-- Author		: Arun Nair

-- Create date	: 10/12/2015

-- Execution	: sp_CheckOccurrenceStatusQC 41,151

-- Description	: Enable/Disable QCComplete Button in DPF Based on Occurrence Value

-- Updated By	: Arun Nair on 11/04/2015 -QCComplete Enable/Disable button for Email 
--				: Arun Nair on 11/13/2015 -QCComplete Enable/Disable button for Website 
--				: Karunakar on 11/27/2015 -QCComplete Enable/Disable button for Social 
--				: Josh Hartzell on 4/18/2016 -- Updated to account for new Status table 
--====================================================================================

CREATE PROCEDURE [dbo].[sp_CheckOccurrenceStatusQC]

(
@OccurrenceId AS BIGINT,
@MediaStreamId AS INTEGER
)
AS
BEGIN	
SET NOCOUNT ON ;
	BEGIN TRY 

	 DECLARE @WaitingStatus AS VARCHAR(20) 
	 DECLARE @CompleteStatus AS VARCHAR(20) 
	 DECLARE @NotRequiredStatus AS VARCHAR(20) 
	 DECLARE @QCStatus AS NVARCHAR(20)
	 DECLARE @IndexStatus AS NVARCHAR(20)
	 DECLARE @ScanStatus AS NVARCHAR(20) 
	 DECLARE @MediaStreamValue AS NVARCHAR(20)

	 --Get Status from CONFIGURATIONMASTER
	 SELECT @WaitingStatus	= VALUETITLE	FROM   [Configuration]  WHERE  SystemName = 'All' AND ComponentName  = 'QC Status' AND value = 'W' 
	 SELECT @CompleteStatus	= VALUETITLE	FROM   [Configuration]	WHERE  SystemName = 'All' AND ComponentName  = 'Index Status' AND value = 'C' 
	 SELECT @NotRequiredStatus	= VALUETITLE	FROM   [Configuration]  WHERE  SystemName = 'All' AND ComponentName  = 'Scan Status' AND value = 'NR' 
	 SELECT @MediaStreamValue=VALUE FROM [Configuration] WHERE componentname='Media Stream' AND ConfigurationId=@MediaStreamId

	IF @MediaStreamValue='CIR'   --Circular
	BEGIN							
		--Get Status of OccurrenceId
		SELECT 
			@IndexStatus=OccurrenceIndexStatus.Status, 
			@ScanStatus=OccurrenceScanStatus.Status, 
			@QCStatus=OccurrenceQCStatus.Status

		FROM [dbo].[OccurrenceDetailCIR]				
		LEFT JOIN [OccurrenceStatus] as OccurrenceIndexStatus ON [OccurrenceIndexStatus].OccurrenceStatusID = [OccurrenceDetailCIR].IndexStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceScanStatus ON [OccurrenceScanStatus].OccurrenceStatusID = [OccurrenceDetailCIR].ScanStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceQCStatus ON [OccurrenceQCStatus].OccurrenceStatusID = [OccurrenceDetailCIR].RouteStatusID
		
		WHERE [OccurrenceDetailCIRID]=@OccurrenceId

		IF( ((@QCStatus=@WaitingStatus) OR (@QCStatus=@CompleteStatus)) 
			AND ((@IndexStatus=@CompleteStatus) OR (@IndexStatus=@NotRequiredStatus)) 
			AND ((@ScanStatus=@CompleteStatus) OR (@ScanStatus=@NotRequiredStatus)
		  ))
				BEGIN
					SELECT 1 AS Result	--QC Complete Enabled
				END
		ELSE
				BEGIN
					SELECT 0 AS Result--QC Complete Disabled 
				END 
	END
	ELSE IF @MediaStreamValue='PUB' --Publication
		BEGIN							
		--Get Status of OccurrenceId
		SELECT 
			@IndexStatus=OccurrenceIndexStatus.Status, 
			@ScanStatus=OccurrenceScanStatus.Status, 
			@QCStatus=OccurrenceQCStatus.Status

		FROM [dbo].[OccurrenceDetailPUB]				
		LEFT JOIN [OccurrenceStatus] as OccurrenceIndexStatus ON [OccurrenceIndexStatus].OccurrenceStatusID = [OccurrenceDetailPUB].IndexStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceScanStatus ON [OccurrenceScanStatus].OccurrenceStatusID = [OccurrenceDetailPUB].ScanStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceQCStatus ON [OccurrenceQCStatus].OccurrenceStatusID = [OccurrenceDetailPUB].RouteStatusID
		
		WHERE [OccurrenceDetailPUBID]=@OccurrenceId

		IF( ((@QCStatus=@WaitingStatus) OR (@QCStatus=@CompleteStatus)) 
			AND ((@IndexStatus=@CompleteStatus) OR (@IndexStatus=@NotRequiredStatus)) 
			AND ((@ScanStatus=@CompleteStatus) OR (@ScanStatus=@NotRequiredStatus)
		  ))
				BEGIN
					SELECT 1 AS Result	--QC Complete Enabled
				END
		ELSE
				BEGIN
					SELECT 0 AS Result--QC Complete Disabled 
				END 
	END

	ELSE IF @MediaStreamValue='EM' --EMail
		BEGIN							
		--Get Status of OccurrenceId
		SELECT 
			@IndexStatus=OccurrenceIndexStatus.Status, 
			@ScanStatus=OccurrenceScanStatus.Status, 
			@QCStatus=OccurrenceQCStatus.Status

		FROM [dbo].[OccurrenceDetailEM]				
		LEFT JOIN [OccurrenceStatus] as OccurrenceIndexStatus ON [OccurrenceIndexStatus].OccurrenceStatusID = [OccurrenceDetailEM].IndexStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceScanStatus ON [OccurrenceScanStatus].OccurrenceStatusID = [OccurrenceDetailEM].ScanStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceQCStatus ON [OccurrenceQCStatus].OccurrenceStatusID = [OccurrenceDetailEM].RouteStatusID
		
		WHERE [OccurrenceDetailEMID]=@OccurrenceId

		IF( ((@QCStatus=@WaitingStatus) OR (@QCStatus=@CompleteStatus)) 
			AND ((@IndexStatus=@CompleteStatus) OR (@IndexStatus=@NotRequiredStatus)) 
			AND ((@ScanStatus=@CompleteStatus) OR (@ScanStatus=@NotRequiredStatus)
		  ))
				BEGIN
					SELECT 1 AS Result	--QC Complete Enabled
				END
		ELSE
				BEGIN
					SELECT 0 AS Result--QC Complete Disabled 
				END 
	END
	ELSE IF @MediaStreamValue='WEB' --Website
		BEGIN							
		--Get Status of OccurrenceId
		SELECT 
			@IndexStatus=OccurrenceIndexStatus.Status, 
			@ScanStatus=OccurrenceScanStatus.Status, 
			@QCStatus=OccurrenceQCStatus.Status

		FROM [dbo].[OccurrenceDetailWEB]				
		LEFT JOIN [OccurrenceStatus] as OccurrenceIndexStatus ON [OccurrenceIndexStatus].OccurrenceStatusID = [OccurrenceDetailWEB].IndexStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceScanStatus ON [OccurrenceScanStatus].OccurrenceStatusID = [OccurrenceDetailWEB].ScanStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceQCStatus ON [OccurrenceQCStatus].OccurrenceStatusID = [OccurrenceDetailWEB].RouteStatusID
		
		WHERE [OccurrenceDetailWEBID]=@OccurrenceId

		IF( ((@QCStatus=@WaitingStatus) OR (@QCStatus=@CompleteStatus)) 
			AND ((@IndexStatus=@CompleteStatus) OR (@IndexStatus=@NotRequiredStatus)) 
			AND ((@ScanStatus=@CompleteStatus) OR (@ScanStatus=@NotRequiredStatus)
		  ))
				BEGIN
					SELECT 1 AS Result	--QC Complete Enabled
				END
		ELSE
				BEGIN
					SELECT 0 AS Result--QC Complete Disabled 
				END 
	END
		ELSE IF @MediaStreamValue='SOC' --Social
					BEGIN							
		--Get Status of OccurrenceId
		SELECT 
			@IndexStatus=OccurrenceIndexStatus.Status, 
			@ScanStatus=OccurrenceScanStatus.Status, 
			@QCStatus=OccurrenceQCStatus.Status

		FROM [dbo].[OccurrenceDetailSOC]				
		LEFT JOIN [OccurrenceStatus] as OccurrenceIndexStatus ON [OccurrenceIndexStatus].OccurrenceStatusID = [OccurrenceDetailSOC].IndexStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceScanStatus ON [OccurrenceScanStatus].OccurrenceStatusID = [OccurrenceDetailSOC].ScanStatusID
		LEFT JOIN [OccurrenceStatus] as OccurrenceQCStatus ON [OccurrenceQCStatus].OccurrenceStatusID = [OccurrenceDetailSOC].RouteStatusID
		
		WHERE [OccurrenceDetailSOCID]=@OccurrenceId

		IF( ((@QCStatus=@WaitingStatus) OR (@QCStatus=@CompleteStatus)) 
			AND ((@IndexStatus=@CompleteStatus) OR (@IndexStatus=@NotRequiredStatus)) 
			AND ((@ScanStatus=@CompleteStatus) OR (@ScanStatus=@NotRequiredStatus)
		  ))
				BEGIN
					SELECT 1 AS Result	--QC Complete Enabled
				END
		ELSE
				BEGIN
					SELECT 0 AS Result--QC Complete Disabled 
				END 
	END
	END TRY
	   BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line()
			RAISERROR ('sp_CheckOccurrenceStatusQC: %d: %s',16,1,@error,@message,@lineNo); 
	   END CATCH 
		
END
