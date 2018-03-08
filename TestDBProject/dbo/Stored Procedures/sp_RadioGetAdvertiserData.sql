-- =====================================================================
-- Author			:Arun Nair 
-- Create date		:28 April 2015
-- Description		:Get Advertiser Data
-- Updated By		:Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--=======================================================================
CREATE PROCEDURE [dbo].[sp_RadioGetAdvertiserData]
(
@RCSAccountID AS INT
)
AS
BEGIN
		BEGIN TRY
				SELECT [Advertiser].Descrip, [Advertiser].AdvertiserID FROM AcctMap INNER JOIN
                [Advertiser] ON AcctMap.[AdvID] = [Advertiser].AdvertiserID WHERE AcctMap.[RCSAcctID]=@RCSAccountID
		END TRY
		BEGIN CATCH 
			DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
			SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			RAISERROR ('sp_RadioGetAdvertiserData: %d: %s',16,1,@error,@message,@lineNo);
		 END CATCH 
END
