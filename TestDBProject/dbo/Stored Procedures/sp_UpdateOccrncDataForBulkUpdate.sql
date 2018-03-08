-- ======================================================================================
-- Author		: 
-- Create date	: 
-- Description	: 
-- Updated By	: Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--=======================================================================================
CREATE PROCEDURE [dbo].[sp_UpdateOccrncDataForBulkUpdate] 
(
@bulkupdateXML as xml
)
           
AS
IF 1=0 BEGIN
    SET FMTONLY OFF
END
BEGIN

       SET NOCOUNT ON;

              BEGIN TRY

              declare @NumberRecords as int
              declare @Index as int=0
              declare @pOccurrenceID bigint
              declare @pMediaTypeId int
              declare @pMarketId int
              declare @pPublicationID int
              declare @pDistDate as datetime
              declare @pAdDate as datetime
              declare @pFlash as bit
              declare @pNational as bit
              declare @pageCount as int
              declare @pEventID as int
              declare @pThemeId as int
              declare @pSaleStartDate datetime
              declare @pSaleEndDate datetime
              declare @Color as varchar(max)
              declare @pSizingMethod as varchar(max)
              declare @PatternMasterID int

              create table #tempbulkupdateData
              (
              id int identity(1,1),
              OccurrenceID int,
              MediaTypeId int,
              MarketId int,
              PublicationID int,
              DistDate date,
              AdDate date,
              Flash bit,
              NationalIndicator bit,
              PageCount int,
              EventID int,
              ThemeId int,
              SalesStartDate date,
              SalesEndDate date,
              Color nvarchar(max),
              SizingMethod nvarchar(max)
              )

              insert into  #tempbulkupdateData
         SELECT bulkupdatedata.value('(OccurrenceID)[1]', 'int')                     AS OccurrenceID,
             bulkupdatedata.value('(MediaTypeID)[1]', 'int')           AS MediaTypeId,
             bulkupdatedata.value('(FK_MarketID)[1]', 'int')        AS MarketId,
             bulkupdatedata.value('(FK_PubEditionID)[1]', 'nvarchar(max)') AS PublicationID,
             bulkupdatedata.value('(Dist)[1]', 'nvarchar(max)') AS DistDate, 
             bulkupdatedata.value('(AdDate)[1]', 'nvarchar(max)')   AS AdDate, 
             bulkupdatedata.value('(Flash)[1]', 'nvarchar(max)')      AS Flash,
             bulkupdatedata.value('(NationalIndicator)[1]', 'nvarchar(max)') AS NationalIndicator, 
             bulkupdatedata.value('(PageCount)[1]', 'nvarchar(max)')     AS PageCount,
             bulkupdatedata.value('(EventId)[1]', 'nvarchar(max)')      AS EventID,
                       bulkupdatedata.value('(ThemeId)[1]', 'nvarchar(max)')      AS ThemeId,
                        bulkupdatedata.value('(SalesStartDate)[1]', 'nvarchar(max)')      AS SalesStartDate,
                         bulkupdatedata.value('(SalesEndDate)[1]', 'nvarchar(max)')      AS SalesEndDate, 
                            bulkupdatedata.value('(Color)[1]', 'nvarchar(max)')      AS Color,
                             bulkupdatedata.value('(SizingMethod)[1]', 'nvarchar(max)')      AS SizingMethod
            FROM   @bulkupdateXML.nodes('DocumentElement/BULKLOAD') AS bulkupdateproc(bulkupdatedata) 

       
				SELECT @NumberRecords = Count(*) FROM   #tempbulkupdateData 
				-- PRINT(@NumberRecords) 
				  SET @Index = 1 
				  WHILE @Index <= @NumberRecords 
				  BEGIN 
					SELECT @pOccurrenceID=OccurrenceID, 
						   @pMediaTypeId=MediaTypeId, 
						   @pMarketId=MarketId, 
						   @pPublicationID=PublicationID, 
						   @pDistDate=DistDate, 
						   @pAdDate=AdDate , 
						   @pFlash= Flash, 
						   @pNational=NationalIndicator, 
						   @pageCount=PageCount, 
						   @pEventID=EventID,
						   @pThemeId=ThemeId,
						   @pSaleStartDate=SalesStartDate,
						   @pSaleEndDate=SalesEndDate,
						   @Color=Color,
						   @pSizingMethod=SizingMethod
					FROM   #tempbulkupdateData 
					WHERE  id = @Index 

				---get Patternmasterid from Patternmastertable
				select @PatternMasterID=[PatternID] from [OccurrenceDetailCIR] where [OccurrenceDetailCIRID]=@pOccurrenceID

				---Color and SizingMethod need to be added             
					UPDATE [dbo].[OccurrenceDetailCIR]  set   [OccurrenceDetailCIR].[MediaTypeID]=@pMediaTypeId, [OccurrenceDetailCIR].[MarketID]=@pMarketId, [OccurrenceDetailCIR].[PubEditionID]=@pPublicationID, 
									[OccurrenceDetailCIR].DistributionDate=@pDistDate, 
									[OccurrenceDetailCIR].AdDate=@pAdDate, [OccurrenceDetailCIR].PageCount=@pageCount,[Color]= @Color, [SizingMethod]=@pSizingMethod                  
									where [OccurrenceDetailCIR].[OccurrenceDetailCIRID]=    @pOccurrenceID

					UPDATE [Pattern] set [Pattern].[EventID]=@pEventID,[Pattern].[ThemeID]=@pThemeId, [Pattern].[FlashInd]=@pFlash, 
							[Pattern].NationalIndicator=@pNational,[Pattern].[SalesStartDT]=@pSaleStartDate, [Pattern].[SalesEndDT]=@pSaleEndDate 
							where [Pattern].[PatternID]=@PatternMasterID
				   set @Index=@Index+1
				  END
       
              END TRY 
            BEGIN CATCH 
					DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
					SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
					RAISERROR ('[sp_UpdateOccurrenceDateForBulkUpdate]: %d: %s',16,1,@error,@message,@lineNo); 
			END CATCH                   



END
