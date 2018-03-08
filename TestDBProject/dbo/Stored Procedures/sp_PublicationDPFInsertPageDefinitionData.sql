
-- =================================================================================================================
-- Author		:	Karunakar
-- Create date	:	4th August 2015
-- Description	:	This Procedure is Used to Insert New Publication Page Definition Details in CreativeDetailPub
-- Updated By	:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- ================================================================================================================

CREATE Procedure [dbo].[sp_PublicationDPFInsertPageDefinitionData] --2,13329, '<DocumentElement><PageDefinition><PageTypeId>B</PageTypeId><SizeId>8</SizeId><PageName>1</PageName><Size>00.00 X 01.75</Size><PageNumberOrder>1</PageNumberOrder><PageNumber>1</PageNumber><PubPageNumber>1</PubPageNumber></PageDefinition><PageDefinition><PageTypeId>B</PageTypeId><SizeId>8</SizeId><PageName>2</PageName><Size>00.00 X 01.75</Size> <PageNumberOrder>2</PageNumberOrder><PageStartDt>2015-08-04T00:00:00+05:30</PageStartDt><PageEndDt>2015-08-04T00:00:00+05:30</PageEndDt><PageNumber>2</PageNumber><PubPageNumber>2</PubPageNumber></PageDefinition> </DocumentElement>'
(
@OccurrenceId As Bigint,
@CreativeMasterID As Int,
@PageDefinitionXML As Xml
)
AS

BEGIN

       SET NOCOUNT ON;

              BEGIN TRY

			  declare @NumberRecords as int
              declare @Index as int=0
              declare @PageTypeId as NVARCHAR(50)
              declare @SizeId as int
              declare @PageName as NVARCHAR(50)
              declare @Size AS NVARCHAR(50)
			  declare @InsertNumberId as int
			  declare @PageNumberOrderId as int
              declare @PageStartDate as datetime
			  declare @PageEndDate as datetime
              declare @PageNumber as int
			  declare @PubPageNumber as Int
			  Declare @TotalPageCount As Int
			  Declare @OccurrencePubPageNumber as Nvarchar(50)
			 
			  Declare @IsDeleted As Bit=0

			   create table #tempPageDefinitionData
              (
              id int identity(1,1),
              PageTypeId nvarchar(50),
              SizeId int,
			  PageName  NVARCHAR(50),
			  Size  NVARCHAR(50),
			  InsertNumberId  int,
			  PageNumberOrderId  int,
			  PageStartDate datetime,
			  PageEndDate  datetime,
			  PageNumber  int,
			  PubPageNumber  Int
              )

		insert into  #tempPageDefinitionData
          SELECT PageDefinitionData.value('(PageTypeId)[1]', 'nvarchar(max)')		AS PageTypeId,
				PageDefinitionData.value('(SizeId)[1]', 'int')						AS SizeId,
				PageDefinitionData.value('(PageName)[1]', 'nvarchar(max)')			AS PageName,
				PageDefinitionData.value('(Size)[1]', 'nvarchar(max)')				AS Size,
				PageDefinitionData.value('(InsertNumber)[1]', 'int')				AS InsertNumberId,
				PageDefinitionData.value('(PageNumberOrder)[1]', 'int')				AS PageNumberOrderId,
				Convert(varchar(10),PageDefinitionData.value('(PageStartDt)[1]', 'nvarchar(max)'),100)		AS PageStartDate,
				Convert(varchar(10),PageDefinitionData.value('(PageEndDt)[1]', 'nvarchar(max)'),100)		AS PageEndDate,
				PageDefinitionData.value('(PageNumber)[1]', 'int')					AS PageNumber,
				PageDefinitionData.value('(PubPageNumber)[1]', 'int')					AS PubPageNumber
			FROM   @PageDefinitionXML.nodes('DocumentElement/PageDefinition') AS PageDefinitionProc(PageDefinitionData)
			select * from #tempPageDefinitionData
			SELECT @NumberRecords = Count(*) 
			FROM   #tempPageDefinitionData 
			PRINT(@NumberRecords) 
			 SET @Index = 1 

			 WHILE @Index <= @NumberRecords 
			BEGIN 

					SELECT @PageTypeId=PageTypeId, 
					   @SizeId=SizeId, 
					   @PageName=PageName, 
					   @Size=Size,
					   @InsertNumberId=InsertNumberId,
					   @PageNumberOrderId=PageNumberOrderId,
					   @PageStartDate=PageStartDate,
					   @PageEndDate=PageEndDate,
					   @PageNumber=PageNumber,
					   @PubPageNumber=PubPageNumber
				 
					FROM   #tempPageDefinitionData 
					WHERE  id = @Index 
					Print(@PageStartDate)
			
			 --Need CreativeMasterID 



			 Insert into [dbo].[CreativeDetailPUB]
			 ([CreativeMasterID],[Deleted],[PageNumber],[PageTypeID],[FK_SizeID],[PageStartDT],[PageEndDT],[PageName],[PubPageNumber])
			 Values
			 (@CreativeMasterID,@IsDeleted,@PageNumber,@PageTypeId,@SizeId,@PageStartDate,@PageEndDate,@PageName,@PubPageNumber)		  
     		 --Select * from CreativeDetailPUB
			set @Index=@Index+1
			print @index
			END 
			
			DROP TABLE #tempPageDefinitionData
			
			--Updated By Karunakar on 5th August 2015,Updating OccurrenceDetailsPub
			
			Set @TotalPageCount=(Select Count(*) from CreativeDetailPUB  Where Creativemasterid=@CreativeMasterID)
			Set @OccurrencePubPageNumber=(Select PubPageNumber from CreativeDetailPUB  Where Creativemasterid=@CreativeMasterID and pagenumber=1)
			--Updating Page Count and Pub Page Number Details in OccurrenceDetailPub
			Update [OccurrenceDetailPUB] Set PubPageNumber=@OccurrencePubPageNumber,PageCount=@TotalPageCount Where [OccurrenceDetailPUBID]=@OccurrenceId

			  END TRY
			  BEGIN CATCH 

					 DECLARE @error   INT, @message VARCHAR(4000),  @lineNo  INT 

                    SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

					RAISERROR ('[sp_PublicationDPFInsertPageDefinitionData]: %d: %s',16,1,@error,@message,@lineNo); 
					END CATCH                   

END
