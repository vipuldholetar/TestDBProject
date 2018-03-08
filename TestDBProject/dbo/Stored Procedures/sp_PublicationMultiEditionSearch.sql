
-- =========================================================================================================

-- Author		: Arun Nair  
-- Create date  : 12/28/2015  
-- Description  : Search MultiEdition   
-- Execution    : [sp_PublicationMultiEditionSearch] 0,1,'12/28/15',14324  
-- Updated By   

-- ===========================================================================================================

CREATE PROCEDURE [dbo].[sp_PublicationMultiEditionSearch]
 (
 @PubCode       AS INTEGER, 
 @PublicationId AS INTEGER, 
 @IssueDate      AS VARCHAR(50)='',
 @PubIssueId    AS INTEGER
 ) 
AS 
  BEGIN 
      SET NOCOUNT ON; 

      DECLARE @BasePath AS NVARCHAR(max) 
      SET @BasePath= (SELECT value FROM   [Configuration] WHERE  systemname = 'All' AND componentname = 'Creative Repository') 

		declare @NoTakeStatusID int
		select @NoTakeStatusID = os.[OccurrenceStatusID] 
		from OccurrenceStatus os
		inner join Configuration c on os.[Status] = c.ValueTitle
		where c.SystemName = 'All' and c.ComponentName = 'Occurrence Status' AND c.Value = 'NT' 
	  
      BEGIN TRY 

          SELECT a.* 

          FROM   (SELECT ad.[AdID] AS AdId,
                         [dbo].[Advertiser]. [descrip]   AS AdvertiserName, 
						 (select [Status] from ScanStatus where ScanStatusID = OccurrenceDetailPUB.ScanStatusID) as scanstatus,
						 (select [Status] from ClearanceStatus where ClearanceStatusID = OccurrenceDetailPUB.ClearanceStatusID) as clearancestatus,
                         [OccurrenceDetailPUB].mniindicator,
                         [OccurrenceDetailPUB].[pagecount],
                         [OccurrenceDetailPUB].color, 
						 [OccurrenceDetailPUB].[OccurrenceDetailPUBID]  AS OccurrenceId, 
                         pubissue.[PubIssueID]                AS IssueId,
                         pubissue.issuedate, 
                         pubedition.[PubEditionID]            AS EditionId,
                         pubedition.editionname, 
                         publication.[PublicationID]          AS PublicationId, 
                         publication.descrip                   AS 
                         PublicationName, 
                         publication.multieditionind           AS IsMultiEdition 
                         , 
                         pubedition.[DefaultInd], 
                         [Market].abbrevation              AS Market, 
                         [Market].[Descrip]              AS MarketName, 
                         @BasePath + '\' 
                         + creativedetailpub.creativerepository 
                         + creativedetailpub.creativeassetname AS ImagePath ,
                        (select [dbo].[fn_MarketList](ad.[AdID],publication.[PublicationID], CONVERT(VARCHAR, Cast(@IssueDate AS DATE), 110),[OccurrenceDetailPUB].mniindicator)) as CheckedMarkets,
						[Language].Languageid,
						[Language].Description as Language,
						[Advertiser].Advertiserid 
                  FROM   Ad 
                         --INNER JOIN occurrencedetailspub ON occurrencedetailspub.pk_occurrenceid = ad.primaryoccrncid 
                         INNER JOIN [OccurrenceDetailPUB] ON [OccurrenceDetailPUB].[AdID] = ad.[AdID] 
						 INNER JOIN [Advertiser] ON ad.[AdvertiserID] = [Advertiser].[advertiserid] 
                         INNER JOIN pubissue ON pubissue.[PubIssueID] =[OccurrenceDetailPUB].[PubIssueID] 
                         INNER JOIN pubedition  ON pubedition.[PubEditionID] = pubissue.[PubEditionID] 
						 INNER JOIN [Language] on [Language].LanguageID=pubedition.[LanguageID]
                         INNER JOIN publication ON publication.[PublicationID] =  pubedition.[PublicationID] 
                         INNER JOIN [Market] ON [Market].[MarketID] = pubedition.[MarketID] 
						 INNER JOIN [Pattern] ON [Pattern].[PatternID] = [OccurrenceDetailPUB].[PatternID] 
                         INNER JOIN [Creative] ON [Creative].pk_id =  [Pattern].[CreativeID]
                         INNER JOIN creativedetailpub  ON creativedetailpub.creativemasterid = [Creative].pk_id 
                  WHERE  publication.multieditionind = 1 
                         AND [OccurrenceDetailPUB].OccurrenceStatusID != @NoTakeStatusID 
                         AND publication.[PublicationID] = Cast(@PublicationId AS VARCHAR) 
						 AND CONVERT(VARCHAR, Cast(issuedate AS DATE), 110) =CONVERT(VARCHAR, Cast(@IssueDate AS DATE), 110) 
                         --AND pubissue.pk_pubissueid = Cast(@PubIssueId AS VARCHAR) 
                 ) a  

                 INNER JOIN (SELECT [AdID],Min([OccurrenceDetailPUBID]) AS OccurrenceID FROM   [OccurrenceDetailPUB] where [OccurrenceDetailPUB].[PubIssueID] = Cast(@PubIssueId AS VARCHAR) 
				    GROUP  BY [AdID]) b 
                 ON b.occurrenceid = a.occurrenceid 

				ORDER  BY adid 
				EXEC [dbo].[sp_PublicationMultiGetMarket] @PublicationId

      END TRY 
	  BEGIN CATCH 
          DECLARE @error   INT, @message VARCHAR(4000), @lineNo  INT 
          SELECT @error = Error_number(),@message = Error_message(),@lineNo = Error_line() 
          RAISERROR ('[sp_PublicationMultiEdition]: %d: %s',16,1,@error,@message ,@lineNo); 
      END CATCH 

  END