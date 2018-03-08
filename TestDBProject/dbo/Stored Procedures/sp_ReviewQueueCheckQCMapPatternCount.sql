-- =============================================
-- Author		:	Karunakar
-- Create date	:   29th October 2015
-- Description	:	This Procedure is Used to Check PatternCount of QC MAP Unod Map Index	
-- Exec			:   sp_ReviewQueueCheckQCMapPatternCount 8377
-- =============================================
CREATE PROCEDURE sp_ReviewQueueCheckQCMapPatternCount
@Adid As Int
AS
BEGIN
	
	SET NOCOUNT ON;

   Declare @PatternCount as Int=0

				Select @PatternCount=count(*) from [Pattern] where [AdID]=@Adid
				if @PatternCount=1
				begin
				select 0 as result
				end
				else
				begin
				select 1 as result
				end

END
