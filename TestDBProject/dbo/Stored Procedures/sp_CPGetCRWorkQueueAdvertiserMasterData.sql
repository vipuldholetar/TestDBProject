-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE sp_CPGetCRWorkQueueAdvertiserMasterData 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here
	--Advertiser MASTER DATA
		SELECT 0[VALUE],'ALL'[VALUETITLE]
		UNION ALL
		SELECT AdvertiserID [VALUE],Descrip[VALUETITLE] FROM [Advertiser] order by [VALUE]
END TRY
BEGIN CATCH 
			  DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT 
			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('sp_CPGetCRWorkQueueAdvertiserMasterData: %d: %s',16,1,@error,@message,@lineNo); 
			 -- ROLLBACK TRANSACTION
END CATCH 
END
