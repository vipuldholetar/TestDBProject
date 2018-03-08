
-- =============================================
-- Author		:	KARUNAKAR.P
-- Create date	:	21/01/2016
-- Description	:	This Procedure is used to get the coupon Occurrence data
-- Execution	:   sp_PublicationGetCouponOccurrenceData 560061

-- =============================================
CREATE PROCEDURE sp_PublicationGetCouponOccurrenceData
	@CupnOccurrenceID as BIGINT
AS
BEGIN
	
	SET NOCOUNT ON;
	Declare @MediaTypeID as  integer
	Declare @SizingMethodID as INTEGER
	DECLARE @SizingMethod as varchar(50)

	SET @MediaTypeID=(Select [MediaTypeID] from Mediatype where Mediastream ='PUB' and Descrip ='Coupon Book')

	Select  @SizingMethodID=ConfigurationID,@SizingMethod=ValueTitle from [Configuration] WHERE SystemName ='All'
								  AND ComponentName = 'Sizing Method' and ValueTitle='Standard Display'

	Select @MediaTypeID as MediaTypeID,[MarketID] as MarketID,[SubSourceID] as SubSourceID,@SizingMethodID as SizingMethodID,@SizingMethod as SizingMethod,
	P.FK_PubSection,DistributionDate
	from  [OccurrenceDetailCIR] ocr inner join PubIssue P on ocr.[OccurrenceDetailCIRID]= P.CpnOccurrenceID
	Where ocr.[OccurrenceDetailCIRID]=@CupnOccurrenceID
    
END
