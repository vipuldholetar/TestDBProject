-- =============================================
-- Author:		Lisa East
-- Create date:	November 28,2017
-- Description:	soft/Logical Delete occurrencedetailtv record  based on occurrenceID or PRCode
-- =============================================
create PROCEDURE [dbo].[sp_TelevisionDeletecreativedetailstagingtv]
	@OccurrenceID int=0, 
	@PRCODE varchar(200)='',
	@AFFECTED int=0 OUTPUT
AS
BEGIN
    SET NOCOUNT OFF;
    BEGIN TRY

		Declare @CreativeDetailStagingTVID as int
		Declare @path as varchar(50)
		
		CREATE TABLE #CreativeDetailstgIDS (
		 CreativeDetailID int
			)

If @OccurrenceID > 0 
BEGIN 
		INSERT INTO #CreativeDetailstgIDS (CreativeDetailID)
		SELECT  DISTINCT  detail.CreativeDetailStagingTVID 
		FROM occurrencedetailtv occ 
		JOIN PatternStaging pat on occ.PatternID=pat.PatternID
		JOIN CreativeStaging creat on pat.CreativeStgID=creat.CreativeStagingID
		JOIN creativedetailstagingtv detail on creat.CreativeStagingID=detail.creativestgMasterID
		WHERE  OccurrenceDetailTVID=@OccurrenceID
END 
ELSE IF @PRCODE <>''
BEGIN 
		INSERT INTO #CreativeDetailstgIDS (CreativeDetailID)
		SELECT  DISTINCT  detail.CreativeDetailStagingTVID 
		FROM occurrencedetailtv occ 
		JOIN PatternStaging pat on occ.PatternID=pat.PatternID
		JOIN CreativeStaging creat on pat.CreativeStgID=creat.CreativeStagingID
		JOIN creativedetailstagingtv detail on creat.CreativeStagingID=detail.creativestgMasterID
		WHERE  OCC.PRCODE=@PRCODE
END 



		IF exists (Select top 1 CreativeDetailID from #CreativeDetailstgIDS )
		BEGIN
			UPDATE detail SET detail.[deleted] =1
			FROM CREATIVEDETAILSTAGINGTV detail
			JOIN #CreativeDetailstgIDS ID ON ID.CreativeDetailID=detail.CreativeDetailStagingTVID
		END

		SELECT @AFFECTED= @@ROWCOUNT

	Drop table #CreativeDetailstgIDS

 
	Return @AFFECTED

	
    END  TRY
    BEGIN CATCH
		  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
		  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
		  RAISERROR ('[sp_TelevisionDeletecreativedetailstagingtv]: %d: %s',16,1,@error,@message,@lineNo);
    END CATCH
END

