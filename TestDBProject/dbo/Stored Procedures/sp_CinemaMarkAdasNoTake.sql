-- =======================================================================
-- Author			:		Karunakar
-- Create date		:		07/20/2015
-- Description		:		This stored procedure is used to Mark Adid as Notake Ad
-- Execution Process:		[dbo].[sp_CinemaMarkAdasNoTake]
-- Updated By		:		Ramesh On 08/12/2015  - CleanUp for OneMTDB
--							Karunakar on 7th Sep 2015 
-- =======================================================================
CREATE PROCEDURE [dbo].[sp_CinemaMarkAdasNoTake]
	@adId int,
	@notakereasoncode int
AS
BEGIN
		SET NOCOUNT ON;
		BEGIN TRY
			--	Updating NoTakeReason into Ad table
			UPDATE Ad set NoTakeAdReason=@notakereasoncode where [AdID]=@adId
		End TRY

	   BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('sp_CinemaMarkAdasNoTake: %d: %s',16,1,@error,@message,@lineNo);
		END CATCH 

END
