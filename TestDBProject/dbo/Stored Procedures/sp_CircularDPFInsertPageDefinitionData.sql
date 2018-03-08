
-- ===============================================================================================================
-- Author		:	Karunakar
-- Create date	:	10th August 2015
-- Description	:	This Procedure is Used to Insert New Circular Page Definition Details in CreativeDetailCir
-- Execute		:	sp_CircularDPFInsertPageDefinitionData 
-- Updated By	:   Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
--					Karunakar on 7th Sep 2015
-- ===============================================================================================================

CREATE Procedure [dbo].[sp_CircularDPFInsertPageDefinitionData]
(
@OccurrenceId As BigInt,
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
						declare @PubPageNumber as Nvarchar(50)
						Declare @TotalPageCount As Int
						Declare @OccurrencePubPageNumber as Nvarchar(50)
			 
						Declare @IsDeleted As Bit=0

						-- Creating temp table
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
						PubPageNumber  NVARCHAR(50)
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
						PageDefinitionData.value('(PubPageNumber)[1]', 'nvarchar(max)')					AS PubPageNumber
						FROM   @PageDefinitionXML.nodes('DocumentElement/PageDefinition') AS PageDefinitionProc(PageDefinitionData)
						select * from #tempPageDefinitionData
						SELECT @NumberRecords = Count(*) 
						FROM   #tempPageDefinitionData 
						--PRINT(@NumberRecords) 
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
						--Print(@PageStartDate)
			
						--Inserting data into CreativeDetailCIR
						Insert into [dbo].[CreativeDetailCIR]
						([CreativeMasterID],[Deleted],[PageNumber],[PageTypeID],[SizeID],[PageStartDT],[PageEndDT],[PageName],[PubPageNumber])
						Values
						(@CreativeMasterID,@IsDeleted,@PageNumber,@PageTypeId,@SizeId,@PageStartDate,@PageEndDate,@PageName,@PubPageNumber)		  
						set @Index=@Index+1
						print @index
						END 
			
						DROP TABLE #tempPageDefinitionData
			
						--Updating OccurrenceDetailsCIR		
						Set @TotalPageCount=(Select Count(*) from CreativeDetailCir  Where Creativemasterid=@CreativeMasterID)
						Set @OccurrencePubPageNumber=(Select PubPageNumber from CreativeDetailCir  Where Creativemasterid=@CreativeMasterID and pagenumber=1)

						--Updating Page Count and Pub Page Number Details in OccurrenceDetailCIR
						Update [OccurrenceDetailCIR] Set [OccurrenceDetailCIR].PubPageNumber=@OccurrencePubPageNumber,
						[OccurrenceDetailCIR].[PageCount]=@TotalPageCount Where [OccurrenceDetailCIRID]=@OccurrenceId

						END TRY
						BEGIN CATCH 

						DECLARE @error   INT, @message VARCHAR(4000),  @lineNo  INT 

						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 

						RAISERROR ('[sp_CircularDPFInsertPageDefinitionData]: %d: %s',16,1,@error,@message,@lineNo); 
						END CATCH                   

END
