



-- =====================================================================
-- Author		: Arun Nair 
-- Create date	: 07 May 2015
-- Description	: ByPassSenderFilter for OccurrenceCheckIn 
-- Updated By	: Arun Nair On 09/30/2015 - Changed ByPassFilter Query

--=======================================================================
CREATE PROCEDURE [dbo].[sp_LoadAdvertiserBySender]
(
@SenderID AS INT,
@MediaTypeId AS INT,
@MarketId AS INT
)
AS

BEGIN			
			SET NOCOUNT ON; 
			--Select Advertiser 
			BEGIN TRY

				IF(@SenderID is not null)
					BEGIN
						SELECT Distinct [Advertiser].Descrip, [Advertiser].Priority,AdvertiserComments,SenderExpectation.[SenderID],Sender.Name,
						[Advertiser].AdvertiserID
						FROM SenderExpectation INNER JOIN Expectation ON SenderExpectation.ExpectationID = Expectation.ExpectationId INNER JOIN
							 [Advertiser] ON Expectation.[RetailerID] = [Advertiser].AdvertiserID INNER JOIN Sender ON SenderExpectation.[SenderID] = Sender.[SenderID]
						WHERE Sender.[SenderID]= @SenderID order by 1
						
					END
				ELSE 
					BEGIN
										
						SELECT Distinct b.Descrip, b.Priority,b.AdvertiserComments,b.AdvertiserID 
						 FROM Expectation a INNER JOIN [Advertiser] b ON b.AdvertiserID = a.[RetailerID] 
						 WHERE  a.[MediaID] =@MediaTypeId AND a.[MarketID] = @MarketId ORDER BY 1

					END
				END TRY 

		  BEGIN CATCH 
			  DECLARE @error   INT, 
					  @message VARCHAR(4000), 
					  @lineNo  INT 

			  SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			  RAISERROR ('[sp_LoadAdvertiserBySender]: %d: %s',16,1,@error,@message,@lineNo);
		  END CATCH 

END
