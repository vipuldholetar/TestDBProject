-- ===========================================================================================

-- Author                         :      Ganesh prasad

-- Create date                    :      10/16/2015

-- Description                    :      This stored procedure is used for getting Data to "WWT Overrides" Report Dataset

-- Execution Process              :      [dbo].[sp_WWTOverrides]

-- Updated By                     :      

-- ============================================================================================

CREATE PROCEDURE [dbo].[sp_WWTOverridesSample]

 AS

BEGIN

SET NOCOUNT ON;
BEGIN TRY


Create Table #tempWWT
(Id int identity (1,1),
Advertiser varchar(100),
AdCode int,
MediaType varchar(100),
Creator Varchar(100),
Cooppartner1 varchar(100),
Cooppartner2 varchar(100),
Cooppartner3 varchar(100))

	 select  distinct [dbo].[Advertiser].Descrip as Advertiser, [dbo].Ad.[AdID] as AdCode,[dbo].[Configuration].ValueTitle as  MediaType,

     [dbo].[User].fname+' '+[dbo].[user].lname as Creator,

	 [dbo].Ad.Coop1AdvId,  [dbo].Ad.Coop2AdvId ,

   [dbo].Ad.Coop3AdvId 

     From [dbo].Ad

     Inner Join [dbo].[Advertiser] 

     ON [dbo].Ad.[AdvertiserID] = [dbo].[Advertiser].AdvertiserID

    Inner Join [dbo].[Pattern]

    ON [dbo].[Pattern].[AdID] = [dbo].Ad.[AdID] 

    Inner Join [dbo].[User]

    ON  [dbo].Ad.CreatedBy = [dbo].[User].UserId

    Inner join  [dbo].[Configuration] 

    ON  [dbo].[Pattern].MediaStream= [dbo].[Configuration].ConfigurationID

    Inner Join AdCoopComp

    ON [dbo].AdCoopComp.[AdvertiserID] = [dbo].Ad.[AdvertiserID] and [dbo].AdCoopComp.CoopcompCode = 'c'

	DECLARE @Count  INTEGER=1
	DECLARE @RecordCount  INTEGER
	DECLARE @AdidTemp  INTEGER
	DECLARE @CoopCompCodeCount INTEGER

	SET @RecordCount=(SELECT Count(*) FROM #tempWWT)

	WHILE (@Count<=@REcordCount)
	BEGIN
			SELECT @AdidTemp =COL2 FROM  #tempWWT WHERE Id=@Count
			SELECT @CoopCompCodeCount=Count(CoopCompCode) FROM AdCoOPComp WHERE [AdCoopID]=@AdidTemp AND CoopCompCode='C' 
			IF(@CoopCompCodeCount=1)
				BEGIN
					UPDATE #TEMPWWT SET Cooppartner1='C' WHERE AdCode=@AdidTemp 
				END
			ElSE IF (@CoopCompCodeCount=2)
				BEGIN
					UPDATE #TEMPWWT SET Cooppartner1='C',Cooppartner2='C' WHERE AdCode=@AdidTemp 
				END
			ElSE IF (@CoopCompCodeCount=3)
				BEGIN
					UPDATE #tempWWT SET Cooppartner1='C',Cooppartner2='C',Cooppartner3='C' WHERE AdCode=@AdidTemp 
				END
		SET @Count=@Count+1
		select * from #tempWWT
	END 
	


	--where convert(Date,Ad.Createdate )= convert(Date,GetDate() -1) --filters the records of previous day

END TRY

	 BEGIN CATCH 
     DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
    SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
    RAISERROR ('[sp_WWTOverrides]: %d: %s',16,1,@error,@message,@lineNo); 
    END CATCH 
END
