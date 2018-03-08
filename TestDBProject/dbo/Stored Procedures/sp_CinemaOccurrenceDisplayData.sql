-- ====================================================================================
-- Author			: Karunakar
-- Create date		: 20th July 2015
-- Description		: This Procedure is Used to Display Cinema Occurrence Details 
-- Execute			: Exec	sp_CinemaOccurrenceDisplayData 1
-- Updated By		: Arun Nair on 08/24/2015 - For OccurrenceId Change Datatype-Seeding
-- ====================================================================================
CREATE PROCEDURE [dbo].[sp_CinemaOccurrenceDisplayData] 
	@OccurrenceId AS BIGINT
AS
BEGIN
	
	SET NOCOUNT ON;
	 
	 Select [OccurrenceDetailCINID] AS OccurrenceId,[Rating],[Length],'' AS City From [OccurrenceDetailCIN] 
	 --LEFT JOIN MarketMaster ON MarketMaster.MarketCode=OccurrenceDetailsCIN.FK_MarketId
	 Where [OccurrenceDetailCINID]=@OccurrenceId
   
END
