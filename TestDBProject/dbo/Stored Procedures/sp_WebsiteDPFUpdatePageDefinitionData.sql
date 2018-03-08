-- ====================================================================================================
-- Author		:	Arun Nair 
-- Create date	:	11/11/2015
-- Description	:	Update and Insert New Email Page Definition Details in CreativeDetailWeb
-- Execution	:	sp_EmailDPFUpdatePageDefinitionData 2,11686,'<DocumentElement><PageDefinition> <PageTypeId>B</PageTypeId> <SizeId>8</SizeId> <PageName>1</PageName><Size>00.00 X 01.75</Size><PageNumberOrder>1</PageNumberOrder><PageNumber>1</PageNumber><PubPageNumber>2</PubPageNumber></PageDefinition><PageDefinition><PageTypeId>B</PageTypeId><SizeId>8</SizeId><PageName>2</PageName><Size>00.00 X 01.75</Size><PageNumberOrder>2</PageNumberOrder><PageNumber>2</PageNumber><PubPageNumber>2</PubPageNumber></PageDefinition><PageDefinition><PageTypeId>I</PageTypeId><SizeId>8</SizeId><PageName>I1-1</PageName><Size>00.00 X 01.75</Size><InsertNumber>1</InsertNumber><PageNumberOrder>1</PageNumberOrder><PageNumber>3</PageNumber><PubPageNumber>2</PubPageNumber></PageDefinition></DocumentElement>'
-- Updated By	:	
--				    
--					
-- =====================================================================================================

CREATE Procedure [dbo].[sp_WebsiteDPFUpdatePageDefinitionData] 
(
@OccurrenceId As BigInt,
@Patternmasterid As Int,
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
								declare @Creativemasterid as Int
								declare @CreativeDetailId As Int	
								declare @IsDeleted As Bit=0
								declare @TotalPageCount As Int
								declare @OccurrencePubPageNumber as Nvarchar(50)


								-- CreativeMasterID 
								Set @Creativemasterid=(SELECT [Pattern].[CreativeID] from [Pattern] Where [Pattern].[PatternID]=@Patternmasterid)
							print N'Next SP'
							PRINT @Patternmasterid
								Print(@Creativemasterid)
								--Creating temp table
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
								PubPageNumber  NVARCHAR(50),
								CreativeDetailid Int
								)
								--Inserting data into temp table
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
								PageDefinitionData.value('(PubPageNumber)[1]', 'nvarchar(max)')				AS PubPageNumber,
								PageDefinitionData.value('(CreativeDetailID)[1]', 'int')			AS CreativeDetailid
								FROM   @PageDefinitionXML.nodes('DocumentElement/PageDefinition') AS PageDefinitionProc(PageDefinitionData)
			
								select * from #tempPageDefinitionData
			
								-- Deleting Records From CreativeDetailsPub Where Not Exisits in TempPageDefinitionData Table
								Delete From CreativeDetailWeb where CreativeDetailWeb.CreativeMasterID=@Creativemasterid and CreativeDetailWeb.[CreativeDetailWebID] Not in (select CreativeDetailID from #tempPageDefinitionData)
			
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
									@PubPageNumber=PubPageNumber,
									@CreativeDetailId=CreativeDetailid
								FROM   #tempPageDefinitionData 
								WHERE  id = @Index 
								--Print(@PageStartDate)
					
								--Checking Creativemasterid Found or not
								--IF Exists(Select 1 FROM CreativeDetailWeb WHERE CreativeMasterID=@Creativemasterid)
								--BEGIN
									IF Exists(Select 1  FROM CreativeDetailWeb WHERE CreativeDetailWeb.CreativeMasterID=@Creativemasterid and CreativeDetailWeb.[CreativeDetailWebID]=@CreativeDetailId)
										BEGIN					
											Update CreativeDetailWeb SET [PageTypeID]=@PageTypeId,[SizeID]=@SizeId,[PageStartDT]=@PageStartDate,[PageEndDT]=@PageEndDate,PageName=@PageName,
											PubPageNumber=@PubPageNumber,PageNumber=@PageNumber  Where CreativeDetailWeb.[CreativeDetailWebID]=@CreativeDetailId
										END
									ELSE
										BEGIN
											Insert into [dbo].[CreativeDetailWeb]
											([CreativeMasterID],[Deleted],[PageNumber],[PageTypeID],[SizeID],[PageStartDT],[PageEndDT],[PageName],[PubPageNumber])
											Values
											(@Creativemasterid,@IsDeleted,@PageNumber,@PageTypeId,@SizeId,@PageStartDate,@PageEndDate,@PageName,@PubPageNumber)
											Set @CreativeDetailId=scope_identity();				
											Print(@CreativeDetailId)										 
										END
								--END	 		    		
								SET @Index=@Index+1
								--print @index
								END 			
								DROP TABLE #tempPageDefinitionData 

								----Updating OccurrenceDetailsEM
								SET @TotalPageCount=(Select Count(*) from CreativeDetailWeb  Where Creativemasterid=@CreativeMasterID)
								SET @OccurrencePubPageNumber=(Select PubPageNumber from CreativeDetailWeb  Where Creativemasterid=@CreativeMasterID and pagenumber=1)

								--Updating Page Count and Pub Page Number Details in OccurrenceDetailEM
								--Update OccurrenceDetailsEM Set EmailPageNumber=@OccurrencePubPageNumber,PageCount=@TotalPageCount Where PK_Id=@OccurrenceId

					END TRY
					BEGIN CATCH 

								DECLARE @error   INT, @message VARCHAR(4000),  @lineNo  INT
								SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
								RAISERROR ('[sp_WebsiteDPFUpdatePageDefinitionData]: %d: %s',16,1,@error,@message,@lineNo); 
					END CATCH                   

END
