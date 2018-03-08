




-- ======================================================================================
-- Author		: Arun Nair 
-- Create date	: 07 May 2015 
-- Description	: CheckIn Data for OccurrenceCheckIn 
-- Updated By	: Update By Karunakar on 11th August 2015,Changing Patternmaster Fileds
--				: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--=======================================================================================
CREATE PROCEDURE [dbo].[sp_UpdateCircularOccurrence]
 (
@EnvelopeID AS INT, 
@MediaTypeID AS  INT, 
@MarketCode AS INT , 
@PublicationEditionID AS INT, 
@DistDate AS DATETIME, 
@ADDate AS DATETIME, 
@AdvertiserID AS INT, 
@InternalReferenceNotes AS  NVARCHAR(max), 
@PageCount AS  INT, 
@National AS  BIT, 
@Flash AS BIT, 
@IsAudit AS  BIT, --When CheckInAudit Clicked  CreateFromAuditIndicator =True 
@UserID AS INT,
@Priority as int,
@OccurrenceID as bigint
) 

AS 
  BEGIN 
			SET nocount ON; 
			--Insert a OccurrenceCheckInCIR 
			DECLARE @languageID AS      INT      
			DECLARE @PatternMasterID AS INTEGER 
    
			BEGIN try 
						  BEGIN TRANSACTION 
						  --Get languageId 
						  SELECT @languageID=[LanguageID]  FROM   pubedition WHERE  pubedition.[PubEditionID]=@publicationEditionID 
					-- Insert pattern master
						update [Pattern] set [FlashInd]=@Flash,nationalindicator=@National
						where [Pattern].[PatternID]=(select [PatternID] from [OccurrenceDetailCIR] where [OccurrenceDetailCIRID]=@occurrenceid)

						  BEGIN 
						  update dbo.[OccurrenceDetailCIR]
						  set [AdvertiserID]=@AdvertiserID,[MediaTypeID]=@MediaTypeID,[MarketID]=@MarketCode,[PubEditionID]=@PublicationEditionID,
						  [LanguageID]=@languageID,[DistributionDate]=@DistDate,[AdDate]=@ADDate,[Priority]=@Priority,[InternalRefenceNotes]=@InternalReferenceNotes
						  ,[PageCount]=@PageCount,[CreateFromAuditIndicator]=@IsAudit, [ModifiedDT]=getdate(),[ModifiedByID] =@UserID
						  where [OccurrenceDetailCIRID]=@occurrenceid
        
							if @isaudit='true'
							begin
							update [OccurrenceDetailCIR] set auditby=@userid, auditdtm=getdate() where [OccurrenceDetailCIRID]= @OccurrenceID
							end

						  END 
						  --Update Status in ConfigReqdStatus Pending 
						  COMMIT TRANSACTION 
			END try 
			BEGIN catch 
			  DECLARE @error INT,@message     VARCHAR(4000),@lineNo      INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_UpdateCircularOccurrence]: %d: %s',16,1,@error,@message,@lineNo); 
			  ROLLBACK TRANSACTION 
			END catch 
  END
