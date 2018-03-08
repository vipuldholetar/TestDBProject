


-- ============================================================
-- Author:		Arun Nair 
-- Create date: 21 April 2015
-- Description:	Show Occurence Details   
-- Updated By : Arun Nair on 06/30/2015 for adding DMA 
--=============================================================
CREATE PROCEDURE  [dbo].[sp_RadioGetOccurrencedisplaydata]
(
@occurrenceID AS INT,
@MarketOutletValue  as Varchar(Max)  
)
AS
BEGIN
	SET NOCOUNT ON; 
		DECLARE @SQL AS VARCHAR(MAX) 
		BEGIN TRY
			SET @SQL='SELECT OccurrenceID,rcsadvertisername,StationFormat,RadioStation,[AirStartDT],
			[Length],ISNULL(NetworkAffiliate,'''') AS NetworkAffiliate ,ISNULL(LiveRead,'''') AS LiveRead,ISNULL(DMA,'''') AS DMA
			From [dbo].[vw_RadioOccurrenceData] Where OccurrenceID='''+convert (varchar, @occurrenceID)+''''

			IF (@MarketOutletValue <>'' OR @MarketOutletValue <> NULL)
			Begin
			SET @SQL=@SQL + ' AND DMA= '''+ @MarketOutletValue + ''''
			End

			Execute (@SQl)

		END TRY
		BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('sp_RadioGetOccurrencedisplaydata: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH 

END