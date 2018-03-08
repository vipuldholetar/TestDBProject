-- ==========================================================================
-- Author			:	Arun Nair 
-- Create date		:	20/05/2015
-- Description		:	Select Ad Details in DPF For Publication
-- Execution Process: 
-- Updated By		:	sp_GetPublicationAdDetails 4034
-- ==========================================================================

CREATE PROCEDURE [dbo].[sp_GetPublicationAdDetails]
(
@AdID AS INT
)
AS
BEGIN
	SELECT top 1 AdID,[OriginalAdID],[LeadAudioHeadline],[TitleLeadText] ,[Visual],[Description],Advertiser,[Language], [Tagline],[CommonAdDT],
	[InternalLookupNotes],[NoTakeReason],MediaStreamId,[Length],[CreativeAssetQuality],Tradeclass,[CoreSupplemental],[DistributionType],[RevisionDetail],[IssueDate],
	 [FirstRunDMA],SessionDate,AdvertiserID,LanguageID  FROM [dbo].vw_PublicationAdDetails WHERE AdID=@AdID
END
