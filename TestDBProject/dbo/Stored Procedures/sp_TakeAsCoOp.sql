-- ===========================================================================================
-- Author                         :      Ganesh prasad
-- Create date                    :      10/16/2015
-- Description                    :      This stored procedure is used for getting Data to Take As Co-Op Report Dataset
-- Execution Process              :      [dbo].[sp_TakeAsCoOp]
-- Updated By                     :      
-- ============================================================================================
CREATE PROCEDURE [dbo].[sp_TakeAsCoOp]
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY
IF OBJECT_ID('tempdb..#TempWWT') IS NOT NULL
    DROP TABLE #TempWWT

Create Table #TempWWT
(
ID int identity (1,1),
Advertiser VARCHAR(MAX),
AdCode  INT,
MediaType VARCHAR(MAX),
Creator VARCHAR(MAX),
CoopPartner1 VARCHAR(MAX),
CoopPartner2 VARCHAR(MAX),
CoopPartner3 VARCHAR(MAX)
)
INSERT INTO #TempWWT
select  distinct [dbo].[Advertiser].Descrip as Advertiser, [dbo].Ad.[AdID] as AdCode,[dbo].[Configuration].ValueTitle as  MediaType,

     [dbo].[User].fname+' '+[dbo].[user].lname as Creator,

	 [dbo].Ad.Coop1AdvId , [dbo].Ad.Coop2AdvId ,

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
	--where convert(Date,Ad.Createdate )= convert(Date,GetDate() -1) --filters the records of previous day
	--select * from #tempwwt
	
	DECLARE @Count AS INTEGER=1
	DECLARE @REcordCount AS INTEGER
	DECLARE @AdidTemp AS INTEGER
	DECLARE @CoopCompCodeCount AS INTEGER
	SET @REcordCount=(SELECT Count(*) FROM #TEMPWWT)

	WHILE (@Count<=@REcordCount)
	BEGIN
			SELECT @AdidTemp =AdCode FROM  #TEMPWWT WHERE ID =  @Count
			SELECT @CoopCompCodeCount=Count(CoopCompCode) FROM AdCoOPComp WHERE [AdCoopID]=@AdidTemp AND CoopCompCode='C' 
			IF(@CoopCompCodeCount=1)
				BEGIN
					UPDATE #TEMPWWT SET CoopPartner1='C' WHERE AdCode=@AdidTemp 
				END
			ElSE IF (@CoopCompCodeCount=2)
				BEGIN
					UPDATE #TEMPWWT SET [CoopPartner1]='C',CoopPartner2='C' WHERE AdCode=@AdidTemp 
				END
			ElSE IF (@CoopCompCodeCount=3)
				BEGIN
					UPDATE #TEMPWWT SET CoopPartner1='C',CoopPartner2='C',CoopPartner3='C' WHERE AdCode=@AdidTemp 
				END
			ELSE
			 BEGIN
				UPDATE #TEMPWWT SET CoopPartner1=NULL,CoopPartner2=NULL,CoopPartner3=Null WHERE AdCode=@AdidTemp 
			END
		SET @Count=@Count+1
		
	END 
	select * from #TEMPWWT
	END TRY
	 BEGIN CATCH 

                DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
                SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
			    RAISERROR ('[sp_TakeAsCoOp]: %d: %s',16,1,@error,@message,@lineNo); 

                END CATCH 
END
