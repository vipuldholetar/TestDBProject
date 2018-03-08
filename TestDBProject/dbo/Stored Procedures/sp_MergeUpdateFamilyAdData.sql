-- =============================================
-- Author		: Karunakar
-- Create date	: 12th jan 2015
-- Description	: This Procedure is Used to Updating Family Merge of Non Surviving Ad and Surviving Ad Details
-- Updated By	: 
--				: 
-- =============================================
CREATE PROCEDURE [dbo].[sp_MergeUpdateFamilyAdData] 
(
@NonSurvivingAdid AS INT,
@SurvivingAdid AS INT,
@nonSurvivingMediaStream AS NVARCHAR(Max)
)
AS
BEGIN
	
	SET NOCOUNT ON;

			BEGIN TRY
				BEGIN TRANSACTION 
				Declare @IsMerge as Bit=0
				Declare @NoTakeReason as int
				Declare @MediaStreamVal AS NVARCHAR(50)

				Select @NoTakeReason=ConfigurationID  from [Configuration]   where componentname='No Take Ad' and ValueTitle='Merge'
				Select @MediaStreamVal=Value from [Configuration] where componentname='Media Stream' and ValueTitle=@nonSurvivingMediaStream

				IF(@MediaStreamVal='CIR')
				BEGIN
					--Updating OccurrenceDetailsCIR
					UPDATE [OccurrenceDetailCIR] SET [AdID] = @SurvivingAdid WHERE [AdID] = @NonSurvivingAdid
					set @IsMerge=1
				END

				ELSE IF(@MediaStreamVal='PUB')
				BEGIN
					--Updating OccurrenceDetailsPUB
					UPDATE [OccurrenceDetailPUB] SET [AdID] = @SurvivingAdid WHERE [AdID] = @NonSurvivingAdid
					set @IsMerge=1					
				END

				ELSE IF(@MediaStreamVal='EM')
				BEGIN
					--Updating OccurrenceDetailsEM
					UPDATE [OccurrenceDetailEM] SET [AdID] = @SurvivingAdid WHERE [AdID] = @NonSurvivingAdid
					set @IsMerge=1					
				END

				ELSE IF(@MediaStreamVal='SOC')
				BEGIN
					--Updating OccurrenceDetailsSOC
					UPDATE [OccurrenceDetailSOC] SET [AdID] = @SurvivingAdid WHERE [AdID] = @NonSurvivingAdid
					set @IsMerge=1					
				END

				ELSE IF(@MediaStreamVal='WEB')
				BEGIN
					--Updating OccurrenceDetailsWEB
					UPDATE [OccurrenceDetailWEB] SET [AdID] = @SurvivingAdid WHERE [AdID] = @NonSurvivingAdid	
					set @IsMerge=1				
				END

				IF(@IsMerge=1)
				BEGIN
							--Updating PatternMaster
							UPDATE [Pattern] SET [AdID] =@SurvivingAdid WHERE [AdID] = @NonSurvivingAdid
				
							--Updating CreativeMaster with PrimaryIndicator is No
							UPDATE [Creative] SET [AdId] = @SurvivingAdid WHERE [AdId] = @NonSurvivingAdid AND PrimaryIndicator = 0

							--Updating CreativeMaster with PrimaryIndicator is Yes and CreativeType is Original
							UPDATE [Creative] SET [AdId] = @SurvivingAdid,PrimaryIndicator = 0
							WHERE [AdId] = @NonSurvivingAdid AND PrimaryIndicator = 1 AND CreativeType is Null
							-- Need to be modified ( As there is no records with creative type is 'Original')
							 -- CreativeType = 'Original' 
							

							--No Take Non Surviving Ad
							UPDATE Ad SET NoTakeAdReason =@NoTakeReason  WHERE [AdID] = @NonSurvivingAdid

							--Redirect revisions to Surviving Ad

							UPDATE Ad SET [OriginalAdID] = @SurvivingAdid WHERE [OriginalAdID] = @NonSurvivingAdid
				END
					--Merge Status
					Select @IsMerge as Status
				COMMIT TRANSACTION
 			END TRY 
			BEGIN CATCH 
						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('sp_MergeUpdateFamilyAdData: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 
   
END
