

--===============================================================================
-- Author			: Arun Nair 
-- Create date		: 10 July 2015
-- Description		: Update Ad that is Edited 
-- Updated By		: Ramesh On 08/12/2015  - CleanUp for OneMTDB  
--					  Arun Nair on 08/25/2015 - Added ModifiedDate,ModifiedBy 
--================================================================================
CREATE PROCEDURE [dbo].[sp_OutdoorUpdateAdDetails]
(
@Adid AS INT,
@LeadAudioHeadline AS NVARCHAR(Max)='',
@LeadText AS NVARCHAR(Max)='', 
@Visual AS NVARCHAR(Max)='',
@Description AS NVARCHAR(Max)='',
@AdvertiserID  AS INT=0,
@LanguageID AS INT=0,
@CommondAdDate AS DATETIME,
@InternalLookupNotes  AS NVARCHAR(Max)='',
@NotakeReason AS INTEGER,
@Length AS INT=0,
@CreativeAssetQuality AS INT,
@OriginalADID AS INT=0,
@RevisionDetail AS NVARCHAR(Max)='',
@FirstRunDate           AS DATETIME, 
@LastRunDate            AS DATETIME, 
@FirstRunDMA            AS NVARCHAR(max)='', 
@UserId AS INTEGER
)
AS
BEGIN
				SET NOCOUNT ON;	    
	   BEGIN TRY
	   BEGIN TRANSACTION   
					
			 DECLARE @RunDMAID AS INT = NULL

			 IF @FirstRunDMA <> '' AND @FirstRunDMA IS NOT NULL
			 BEGIN
				SELECT @RunDMAID = MarketID FROM Market 
				    WHERE Descrip = @FirstRunDMA
			 END
			 ELSE
			 BEGIN
				SELECT @RunDMAID = o.MTMarketID FROM OccurrenceDetailODR o
				    INNER JOIN Ad a on a.PrimaryOccurrenceID = o.OccurrenceDetailODRID
				    WHERE OccurrenceDetailODRID = @Adid
			 END 

			 -------Update Ad Table--------------------
			 UPDATE [dbo].[Ad] 
				SET LeadAvHeadline=@LeadAudioHeadline,[LeadText]=@LeadText,[ADVisual]=@Visual,[Description]=@Description,
				[AdvertiserID]=@AdvertiserID,[LanguageID]=@LanguageID,[CommonAdDT]=@CommondAdDate,[InternalNotes]=@InternalLookupNotes,
				[NoTakeAdReason]=@NotakeReason,[AdLength]=@Length,[OriginalAdID]=@OriginalADID,[RecutDetail]=@RevisionDetail,
				[FirstRunMarketID] = @RunDMAID,  FirstRunDate = @FirstRunDate, LastRunDate = @LastRunDate, 
				ModifiedDate=getdate(),ModifiedBy=@UserId
			 Where [AdID]=@Adid

			 ------Update Creative Master----------------
			 UPDATE [dbo].[Creative]
			 SET [PrimaryQuality]=@CreativeAssetQuality
			 Where [AdId]=@Adid
			
		  COMMIT TRANSACTION
 	   END TRY 
	   BEGIN CATCH 
				    DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
				    SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
				    RAISERROR ('sp_OutdoorUpdateAdDetails: %d: %s',16,1,@error,@message,@lineNo);
				    ROLLBACK TRANSACTION
	   END CATCH 
	
END