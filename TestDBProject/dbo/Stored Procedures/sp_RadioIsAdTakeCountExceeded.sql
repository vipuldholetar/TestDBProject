
-- ======================================================================================
-- Author			: KARUNAKAR		 
-- Create date		: 23rd April 2015
-- Description		: This Stored Procedure compares total Ad with Max Count
-- EXEC				: [sp_RadioIsAdTakeCountExceeded] 21,40,1,'03/28/2015'
-- Updated By		: Arun Nair on 08/11/2015 - CleanUp for OneMTDB 
--======================================================================================
CREATE PROCEDURE [dbo].[sp_RadioIsAdTakeCountExceeded] 
	@pAdvertiserId int,
	@pMediaStream int,
	@pLanguageID int,
	@pSessionDate varchar(100)	
AS
BEGIN
	
	SET NOCOUNT ON;
	Declare @TotalAdCount As Integer
	Declare @MaxTakeCount as Integer
	Declare @MonthYear As Varchar(50)
	Declare @isAdTakeCountExceeded BIT
		BEGIN TRY

			  SELECT @MonthYear=cast(month(@pSessionDate) as varchar)+'/'+cast(DATENAME(yyyy, @pSessionDate) as varchar)
			  			  
			  SELECT @TotalAdCount=Count(*) FROM AD INNER JOIN [Pattern] ON AD.[AdID] = [Pattern].[AdID]  WHERE Ad.[AdvertiserID]=@pAdvertiserId
			   and [Pattern].MediaStream=@pMediaStream and Ad.[LanguageID]=@pLanguageID
	  
			  SELECT @MaxTakeCount=MaxTakeCount FROM [AdTakeCount] WHERE AdvertiserID=@pAdvertiserId and MediaStream=@pMediaStream and LanguageID=@pLanguageID and MonthYear=@MonthYear
			

			  IF(@TotalAdCount>=@MaxTakeCount)
				  Begin
						Set @isAdTakeCountExceeded=1
				  End
			  Else
				  BEGIN
						Set @isAdTakeCountExceeded=0
				  End    

			 SELECT  @isAdTakeCountExceeded as isAdTakeCountExceeded

		END TRY

		BEGIN CATCH 
          DECLARE @error   INT,@message VARCHAR(4000),@lineNo  INT
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_RadioIsAdTakeCountExceeded]: %d: %s',16,1,@error,@message,@lineNo); 
		END CATCH 

END
