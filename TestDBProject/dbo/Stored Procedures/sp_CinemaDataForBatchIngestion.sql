-- =============================================

-- Author:		Monika. J

-- Create date: 09/01/2015

-- Description:	Procedure for Cinema Ingestion -- To get batch wise data For Ingestion

-- =============================================

CREATE PROCEDURE [dbo].[sp_CinemaDataForBatchIngestion] --[sp_CinemaDataForBatchIngestion] 1000

	-- Add the parameters for the stored procedure here

	@BatchID INT

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;

	declare @tempTable table
			(
			ID int,
			PK_Id bigint, 
			NCMFileName varchar(200), 
			DMANetwork varchar(200), 
			CampaignTitle varchar(200), 
			Customer varchar(200), 
			StartDate datetime, 
			EndDate datetime, 
			Rating varchar(200), 
			[Length] int, 
			AdName varchar(200), 
			IngestionStatus int, 
			IngestionDate datetime,
			Priority int	
			)

    -- Insert statements for procedure here
	Insert into @tempTable (ID,PK_Id, NCMFileName, DMANetwork, CampaignTitle, Customer, StartDate, EndDate, Rating, Length, AdName, IngestionStatus, IngestionDate,Priority)
	select ROW_NUMBER() OVER (ORDER BY [NCMRawDataID]) AS [serial number] ,* from NCMRawData 
	where ingestionstatus=0
	order by [serial number] OFFSET 0 ROWS FETCH NEXT 500 ROWS ONLY
	--select ROW_NUMBER() OVER (ORDER BY PK_ID) AS [serial number] , * from  [NCMRawData]

	select  PK_Id, NCMFileName, DMANetwork, CampaignTitle, Customer, StartDate, EndDate, Rating, Length, AdName, IngestionStatus, IngestionDate
	from @tempTable
END
