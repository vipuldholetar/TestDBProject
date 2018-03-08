-- ========================================================================
-- Author            : Arun Nair 
-- Create date       : 06/10/2015
-- Description       : This Procedure is Used to getting Duplicate Occurrence Data for Circular 
-- Execution		 : [dbo].[sp_CheckDupOccurrenceDataForCircular]
-- Updated By		 : Karunakar on 7th Sep 2015 ,Adding Comments 
--=========================================================================

CREATE PROCEDURE [dbo].[sp_CheckDupOccurrenceDataForCircular] 
@pMediaTypeID    INT 
,@pAdvertiserID  INT 
,@pPublicationID INT 
,@pMarketID      INT 
,@pPubEditionID  INT 
,@pAdDate        DATE 
,@pNumberOfdays  INT 
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
					SELECT Count(1) 
					FROM   vw_CircularOccurrences 
					where  [MediaTypeID] = @pMediaTypeID 
					and [AdvertiserID] = @pAdvertiserID 
					and [MarketID] = @pMarketID 
					and [LanguageID] = (select distinct [LanguageID] 
										from   pubedition 
										where  [PubEditionID] = @pPubEditionID) 
					and AdDate >= Cast(Dateadd(Day, -@pnumberofDays, @padDate) as 
									DATE) 
					and AdDate <= Cast(Dateadd(Day, @pNumberOfdays, @padDate) as 
									DATE 
								) 
					and [PublicationID] = @pPublicationID 
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number() 
                 ,@message = Error_message() 
                 ,@lineNo = Error_line() 

          RAISERROR ('sp_CheckDupOccurrenceDataForCircular: %d: %s',16,1,@error, 
                     @message,@lineNo); 
      END CATCH 
  END
