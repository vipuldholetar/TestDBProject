
-- ===================================================================================
-- Author		: Karunakar
-- Create date	: 06/13/2015
-- Description	: This Adding new record into Ad table for Publication
-- exec			:sp_PublicationDPFPrimaryOccurrenceData 12
-- UpdatedBy	: Ramesh Bangi on 08/14/2015  for OneMT CleanUp
--				  Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- ====================================================================================
CREATE PROCEDURE [dbo].[sp_PublicationDPFPrimaryOccurrenceData]
	@AdId As Int
AS
BEGIN
		 BEGIN TRY
			 Declare @PrimaryOccurrenceId As BigInt
			  BEGIN TRANSACTION 
			  Select @PrimaryOccurrenceId=[PrimaryOccurrenceID] from Ad where [AdID]=@AdId
			  Select [EventID],[ThemeID],[SalesStartDT],[SalesEndDT],[FlashInd],NationalIndicator,Color,PageCount,[MediaTypeID],[SubSourceID],PubPageNumber
			  from vw_PublicationOccurrenceData where [OccurrenceDetailPUBID]=@PrimaryOccurrenceId
			  Commit TRANSACTION
           End TRY
	     BEGIN CATCH
		 	 DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			 SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			 RAISERROR ('sp_PublicationDPFSaveAdData: %d: %s',16,1,@error,@message,@lineNo)   ; 
			 ROLLBACK TRANSACTION 
		 END CATCH
END
