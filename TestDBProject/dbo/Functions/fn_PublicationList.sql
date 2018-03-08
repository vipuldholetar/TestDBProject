
-- ==================================================
-- Author		: Arun Nair
-- Create date	: 12/30/2015
-- Description	: Get Publication List as Comma Separated
-- Updated By	: select dbo.[fn_PublicationList](24646,5645,'01/20/2016')
--select * from pubissue where cpnoccurrenceid is not null
--select * from occurrencedetailscir where pk_occurrenceid=550052
--select * from pubedition
--select * from occurrencedetailspub where fk_pubissueid=19371
--===================================================
CREATE FUNCTION [dbo].[fn_PublicationList]
(
@AdId INTEGER,
@AdvertisrID INTEGER,
@SectionID int,
@PubIssueDate varchar(30)
)
RETURNS VARCHAR(MAX) 
AS
BEGIN
			DECLARE @NotakeStatusID AS int     
			DECLARE @PublicationList AS NVARCHAR(MAX)

			SET @NotakeStatusID = (
				SELECT os.OccurrenceStatusID 
				FROM   [Configuration] cfg
				INNER JOIN [OccurrenceStatus] os ON cfg.ValueTitle = os.[Status]
				WHERE  cfg.systemname = 'All' 
				AND cfg.componentname = 'Occurrence Status' 
				AND cfg.value = 'NT'
			) 				
				
			SELECT @PublicationList=COALESCE(@PublicationList +',','')+CONVERT(VARCHAR(MAX),d.[PublicationID])  FROM [OccurrenceDetailPUB] a 
			INNER JOIN PubIssue b on a.[PubIssueID]=b.[PubIssueID] 
			inner join PubEdition c on b.[PubEditionID]=c.[PubEditionID]
			INNER JOIN Publication d on d.[PublicationID]=c.[PublicationID]
			AND convert(varchar,cast(b.issuedate as date),110)  = convert(varchar,cast(@PubIssueDate as date),110) 
			AND a.OccurrenceStatusID != @NotakeStatusID 
			AND a.[AdID] =@AdId
			--AND a.FK_PubSectionID=@SectionID
			--and a.
						
			RETURN @PublicationList

END 


--SELECT [dbo].[fn_MarketList] (21636,1,'2015-12-30')