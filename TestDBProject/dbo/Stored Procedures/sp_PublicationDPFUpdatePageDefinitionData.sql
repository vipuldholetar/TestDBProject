

-- ===============================================================================================================================
-- Author		:	Karunakar
-- Create date	:	4th August 2015
-- Description	:	This Procedure is Used to Update and Insert New Publication Page Definition Details in CreativeDetailPub
-- UpdatedBy	:	Ramesh Bangi on 08/14/2015  for OneMT CleanUp
--					Arun Nair on 08/25/2015  -Change in OccurrenceID DataType,Seed Value
-- ===============================================================================================================================

CREATE Procedure [dbo].[sp_PublicationDPFUpdatePageDefinitionData] 
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
			  declare @PubPageNumber as Int
			  declare @Creativemasterid as Int
			  Declare @CreativeDetailId As Int	
			  Declare @IsDeleted As Bit=0

			  Declare @TotalPageCount As Int
			  Declare @OccurrencePubPageNumber as Nvarchar(50)

			   -- CreativeMasterID 
				Set @Creativemasterid=(Select [CreativeID] from [Pattern] Where [PatternID]=@Patternmasterid)

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
			  PubPageNumber  Int,
			  CreativeDetailid Int
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
				PageDefinitionData.value('(PubPageNumber)[1]', 'int')				AS PubPageNumber,
				PageDefinitionData.value('(CreativeDetailID)[1]', 'int')			AS CreativeDetailid
			FROM   @PageDefinitionXML.nodes('DocumentElement/PageDefinition') AS PageDefinitionProc(PageDefinitionData)
			select * from #tempPageDefinitionData
			
			-- Deleting Records From CreativeDetailsPub Where Not Exisits in TempPageDefinitionData Table
			Delete From CreativeDetailPUB where CreativeMasterID=@Creativemasterid and CreativeDetailID Not in (select CreativeDetailID from #tempPageDefinitionData)
			
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
					   @PubPageNumber=PubPageNumber,
					   @CreativeDetailId=CreativeDetailid
					FROM   #tempPageDefinitionData 
					WHERE  id = @Index 
					Print(@PageStartDate)
				IF Exists(Select 1 from CreativeDetailPUB Where CreativeMasterID=@Creativemasterid)
				BEGIN
					IF Exists(Select 1  from CreativeDetailPUB Where CreativeMasterID=@Creativemasterid and CreativeDetailID=@CreativeDetailId)
					BEGIN					
					 Update CreativeDetailPUB Set [PageTypeID]=@PageTypeId,FK_SizeID=@SizeId,
					        [PageStartDT]=@PageStartDate,[PageEndDT]=@PageEndDate,PageName=@PageName,
							PubPageNumber=@PubPageNumber,PageNumber=@PageNumber  Where CreativeDetailID=@CreativeDetailId
					END
					ELSE
					BEGIN
					Insert into [dbo].[CreativeDetailPUB]
						([CreativeMasterID],[Deleted],[PageNumber],[PageTypeID],[FK_SizeID],[PageStartDT],[PageEndDT],[PageName],[PubPageNumber])
					Values
						(@Creativemasterid,@IsDeleted,@PageNumber,@PageTypeId,@SizeId,@PageStartDate,@PageEndDate,@PageName,@PubPageNumber)
					END
			 END	 		    		
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

					RAISERROR ('[sp_PublicationDPFUpdatePageDefinitionData]: %d: %s',16,1,@error,@message,@lineNo); 
					END CATCH                   

END
