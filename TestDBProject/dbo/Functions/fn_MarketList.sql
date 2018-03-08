
-- ==================================================
-- Author		: Arun Nair
-- Create date	: 12/30/2015
-- Description	: Get Marketlist as Comma Separated
-- Updated By	: select dbo.[fn_MarketList](24646,1,'01/05/2016',0)
--===================================================
CREATE FUNCTION [dbo].[fn_MarketList]
(
@AdId INTEGER,
@PublicationId INTEGER,
@PubIssueDate NVARCHAR(MAX),
@MNIindicator bit
)
RETURNS NVARCHAR(MAX) 
AS
BEGIN
			--DECLARE @NotakeStatus AS NVARCHAR(10)     
			DECLARE @NotakeStatusID AS int     
			DECLARE @MarketList AS NVARCHAR(MAX)

			SET @NotakeStatusID = (
				SELECT os.OccurrenceStatusID 
				FROM   [Configuration] cfg
				INNER JOIN [OccurrenceStatus] os ON cfg.ValueTitle = os.[Status]
				WHERE  cfg.systemname = 'All' 
				AND cfg.componentname = 'Occurrence Status' 
				AND cfg.value = 'NT'
			) 				
				
			SELECT @MarketList=COALESCE(@MarketList +',','')+CONVERT(NVARCHAR(MAX),c.[MarketID])  FROM [OccurrenceDetailPUB] a 
			INNER JOIN PubIssue b on a.[PubIssueID]=b.[PubIssueID] 
			INNER JOIN PubEdition c on c.[PubEditionID] = b.[PubEditionID] AND c.[PublicationID] = @PublicationId 
			AND convert(varchar,cast(b.issuedate as date),110)  = convert(varchar,cast(@PubIssueDate as date),110) 
			AND a.OccurrenceStatusID != @NotakeStatusID  
			AND a.[AdID] =@AdId
			and c.[MNIInd]=@mniindicator
						
			RETURN @MarketList

END 


--SELECT [dbo].[fn_MarketList] (21636,1,'2015-12-30')