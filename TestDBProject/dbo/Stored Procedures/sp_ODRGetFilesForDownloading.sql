-- ==============================================================================================================   
-- Author:    Govardhan   
-- Create date: 07/09/2015   
-- Description:  GET FILES FOR DOWNLOADING.  
-- Query :   
/* exec sp_ODRGetFilesForDownloading
*/ 
-- ================================================================================================================   
CREATE PROCEDURE [dbo].[sp_ODRGetFilesForDownloading]
AS 
  BEGIN 
      SET nocount ON; 
      BEGIN try 
          BEGIN TRANSACTION 

		   DECLARE @LocalRepository AS varchar(250);
		   DECLARE @MediaStream AS varchar(250);
		   select @LocalRepository = value from [Configuration] where systemName='All' and componentName='Creative Repository'
		   select @MediaStream =value from [Configuration] where valuetitle='Outdoor'

		   select  *,('\'+@MediaStream+'\'+CMSMonth+' '+CMSYear+'\'+[MarketName]+'\')[SharedFolderPath] from (
		    SELECT [Market].[Descrip] as MarketName, REPLACE(RD.CMSSOURCEFOLDER,'\','/')+'/'[CMSSOURCEFOLDER],RD.CMSFILENAME,RD.CMSFILESIZE,RD.CMSFILEDATE,OD.[OccurrenceDetailODRID][OCCURRENCEID],
			isnull(PM.[CreativeStgID],0)[CREATIVESTAGINGID],OD.[MTMarketID],OD.FILESOURCETYPE,
			(select item from dbo.ODRSplitString(replace(substring(RD.CMSSOURCEFOLDER,2,len(RD.CMSSOURCEFOLDER)),'\',' '),' ') where item<>'' and slno=1)[CMSMonth],
			(select item from dbo.ODRSplitString(replace(substring(RD.CMSSOURCEFOLDER,2,len(RD.CMSSOURCEFOLDER)),'\',' '),' ') where item<>'' and slno=2)[CMSYear],
			(select MTFormatID from ODRAdFormatMap where CMSSourceFormat = RD.CMSFormat) AdFormatID
			 FROM 
			CMSRAWDATA RD
			INNER JOIN [OccurrenceDetailODR] OD
			ON RD.CMSFILENAME=OD.IMAGEFILENAME
			INNER JOIN [PatternStaging] PM
			on OD.IMAGEFILENAME=PM.[CreativeSignature]
			inner join Market on Market.MarketID = OD.MTMarketID
			WHERE ISNULL(PM.[CreativeStgID],0)=(case when LOWER(RD.INGESTIONSTATUS)='ingested' THEN 0
			                                     when LOWER(RD.INGESTIONSTATUS)='updatedmedia' then PM.[CreativeStgID] end)
			)filter
		   COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_ODRGetFilesForDownloading: %d: %s',16,1,@error,@message 
                     , 
                     @lineNo); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;