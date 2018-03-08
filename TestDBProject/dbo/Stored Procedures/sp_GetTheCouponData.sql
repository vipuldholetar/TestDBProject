﻿-- ================================================================================
-- Author		: S Dinesh Karthick
-- Create date	: 12th jan 2015
-- Description	: This Procedure is Used to get the values coupon book 
-- Updated By	: 
-- Execution	: [sp_GetTheCouponData] '01/27/2016','RedPlum'
-- =========================================================================
CREATE  PROCEDURE [dbo].[sp_GetTheCouponData] 
(
@IssueDate  AS VARCHAR(50)='',
@Section As VARCHAR(MAX)
)
AS
BEGIN
	
	SET NOCOUNT ON;
			BEGIN TRY
			BEGIN TRANSACTION	
							
				Declare @SectionList varchar(max)
				Declare @AdvertiserIDList varchar(max)
				Declare @PublicationList  varchar(max) 
				DECLARE @BasePath AS NVARCHAR(max) 
				SET @BasePath= (SELECT value FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Creative Repository') 

				Create table #TempData
				(
				ID INT IDENTITY(1,1)  NOT NULL,
				AdID  INT NULL,
				Publicationlist  varchar(100) NULL
				)
				
			  SELECT @SectionList = (COALESCE(@SectionList + ', ', '') + CAST(Value AS varchar(max)) )
                                                       FROM [Configuration] 
                                                         WHERE SystemName ='All' 
                                                         AND ComponentName = 'Coupon Book to PUB'
														 AND ValueTitle = @Section
				
				--Print @SectionList
				--Print(@Section)

			  SELECT @AdvertiserIDList = COALESCE(@AdvertiserIDList + ', ', '') + CAST(valuegroup AS varchar(10))
							 	  FROM [Configuration] 
								  WHERE SystemName ='All'
								  AND ComponentName ='Coupon Book to PUB'
								
			--Print(@AdvertiserIDList)

			  SELECT  @PublicationList = COALESCE(@PublicationList + ', ', '') + CAST([PubSectionID] AS varchar(10))
			  FROM PubSection ps  INNER JOIN PUBLICATION p ON 
			  ps.[PublicationID]=p.[PublicationID] 
			  WHERE [PubSectionID] IN (Select Distinct Id from [dbo].[fn_CSVToTable](@SectionList)) 
			--print @PublicationList

				declare @NoTakeStatusID int
				select @NoTakeStatusID = os.[OccurrenceStatusID] 
				from OccurrenceStatus os
				inner join Configuration c on os.[Status] = c.ValueTitle
				where /*c.SystemName = 'All' and*/ c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 
				
				INSERT INTO #CouponBookTable 
				SELECT 
				distinct c.[AdID],
				e.Descrip,				
				(select [Status] from ScanStatus where ScanStatusID = c.ScanStatusID),
				c.[OccurrenceDetailPUBID] AS OccurrenceID,
				--d.PK_Id,
				c.PageCount,
				c.Color,
				b.[PublicationID],
				c.[PubSectionID],
				--CASE WHEN (g.CreativeRepository + g.CreativeAssetName) IS NULL THEN @BasePath ELSE (g.CreativeRepository + g.CreativeAssetName) END as ImagePath,
				CASE WHEN (g.CreativeRepository + g.CreativeAssetName) IS NULL THEN NULL ELSE @BasePath +'\'+(g.CreativeRepository + g.CreativeAssetName) END as ImagePath,

				--g.CreativeRepository + g.CreativeAssetName as ImagePath,
				a.[PubIssueID] As PubIssueId,
				(select [dbo].[fn_PublicationList](c.[AdID],d.[AdvertiserID],c.[PubSectionID], CONVERT(VARCHAR, Cast(@IssueDate AS DATE), 110))) as CheckedPublications
				FROM PubIssue a left join PubEdition b ON   b. [PubEditionID]= a.[PubEditionID] 
				INNER JOIN [OccurrenceDetailPUB] c ON  c.[PubIssueID]= a.[PubIssueID]				
				INNER JOIN Ad d ON d.[PrimaryOccurrenceID]=c.[OccurrenceDetailPUBID]
				INNER JOIN [Advertiser] e  ON e.AdvertiserID= d.[AdvertiserID] 
				INNER JOIN [Pattern] f ON f.[PatternID] = c.[PatternID] 			
				LEFT OUTER JOIN CreativeDetailPUB g ON g.CreativeMasterID =f.[CreativeID]
				WHERE b.[PublicationID] in (SELECT Distinct Id from [dbo].[fn_CSVToTable](@PublicationList))  
				AND a.IssueDate = CONVERT(VARCHAR, Cast(@IssueDate AS DATE), 110)  
				AND c.OccurrenceStatusID != @NoTakeStatusID 
				AND g.Deleted = 0
				AND c.[PubSectionID] in (SELECT Distinct Id from [dbo].[fn_CSVToTable](@SectionList)) 
				ORDER BY c.[AdID]


				

				-- loop logic start
				--INSERT INTO #TempData
				--(AdID,Publicationlist)
				--SELECT 
				--distinct c.FK_AdID,
				--(select [dbo].[fn_PublicationList](c.FK_AdID,d.AdvId,c.FK_PubSectionID, CONVERT(VARCHAR, Cast(@IssueDate AS DATE), 110))) as CheckedPublications
				--FROM PubIssue a inner join PubEdition b
				--ON   b. PK_PubEditionID= a.FK_PubEditionID 
				--Inner join OccurrenceDetailsPUB c ON  c.FK_PubIssueID= a.PK_PubIssueID
				--INNER JOIN Ad d ON d.PrimaryOccrncId=c.PK_OccurrenceID
				--INNER JOIN AdvertiserMaster e  ON e.AdvertiserID= d.AdvId
				--INNER JOIN PatternMaster f ON f.PK_Id = c.FK_PatternMasterID
				--LEFT OUTER JOIN CreativeDetailPUB g ON g.CreativeMasterID =f.FK_CreativeId

				--WHERE b.FK_PublicationID in (SELECT Distinct Id from [dbo].[fn_CSVToTable](@PublicationList))  
				--AND a.IssueDate = CONVERT(VARCHAR, Cast(@IssueDate AS DATE), 110)  
				--AND c.OccurrenceStatus != (SELECT ValueTitle FROM CONFIGURATIONMASTER WHERE ComponentName = 'Occurrence Status' AND Value = 'NT') 
				--AND g.Deleted = 0
				--ORDER BY c.FK_AdId

				----SELECT * FROM #TempData

				--Declare @Counter as int=0
				--declare @Index as int=0
				--DECLARE @PublicationSelectionList as NVARCHAR(200)=''
				--DECLARE @PublicationIDList as NVARCHAR(200)=''
				--SELECT @Counter = Count(*) FROM   #TempData
				--PRINT(@Counter) 
				--SET @Index = 1 

				-- WHILE @Index <= @Counter
				--	BEGIN 
				--	SET @PublicationSelectionList =(SELECT Publicationlist FROM   #TempData WHERE  id = @Index)
				--	SET @PublicationIDList=@PublicationIDList+','+@PublicationSelectionList
				--	set @Index=@Index+1
				--	print @index
				--	END  
				--  SELECT CASE WHEN PubCode IS NULL THEN Descrip ELSE PubCode END as PubCode,PK_PublicationId from publication 
				--  where PK_PublicationId in (Select Distinct Id from [dbo].[fn_CSVToTable](@PublicationIDList))


				--  Drop table #TempData
				-- loop logig end

				SELECT CASE WHEN PubCode IS NULL THEN Descrip ELSE PubCode END as PubCode,[PublicationID] from publication 
				 where [PublicationID] in (Select Distinct Id from [dbo].[fn_CSVToTable](@PublicationList))
			COMMIT TRANSACTION
 			END TRY 
			BEGIN CATCH 
						DECLARE @error   INT,@message VARCHAR(4000), @lineNo  INT 
						SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
						RAISERROR ('sp_GetTheCouponData: %d: %s',16,1,@error,@message,@lineNo);
						ROLLBACK TRANSACTION
			END CATCH 
   
END