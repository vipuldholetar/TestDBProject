	
-- =============================================   
-- Author:    Nanju   
-- Create date: 07/09/2015   
-- Description: Loads the Data from TV Ads file to data table.  
-- Query :   
/*  
exec sp_TVInsertNewAdFileData '',  

*/ 
-- =============================================   
create PROCEDURE [dbo].[sp_TVInsertNewAdFileData] (@TVAdData dbo.TVNewAdData readonly) 
AS 
  BEGIN 
     -- SET nocount ON; 

      BEGIN try 
          BEGIN TRANSACTION 
			
			INSERT INTO [dbo].[RawTVNewAd]
						([InputFileName], [PatternCODE], [Length], [Priority],   
						 [CreatedDT], [IngestionDT],[IngestionStatus],[Station])
			SELECT [InputFileName], [PatternCode], [Length], [Priority],
				   [CreateDTM],[IngestionDTM] ,[IngestionStatus], [Station]
				   FROM @TVAdData;	
			
			-- update priority of any existing Pattern table records created by playlists being imported first
			with q (PatternCode, Priority) as (select PatternCode, Priority from @TVAdData)
			update [TVPattern]
			set [TVPattern].[Priority] = q.Priority	
			from [TVPattern] as p
			join q on p.OriginalPRCode = q.PatternCode and (p.Priority is null or p.Priority <> q.priority)
			;	

			with q (PatternCode, Priority) as (select PatternCode, Priority from @TVAdData)
			update [Pattern]
			set [Pattern].[Priority] = q.[Priority]	
			from [Pattern] as p
			join q on p.CreativeSignature = q.PatternCode and (p.Priority is null or p.Priority <> q.priority)
			;

			with q (PatternCode, Priority) as (select PatternCode, Priority from @TVAdData)
			update [PatternStaging]
			set [PatternStaging].[Priority] = q.[Priority]	
			from [PatternStaging] as p
			join q on p.CreativeSignature = q.PatternCode and (p.Priority is null or p.Priority <> q.priority)
			;
        
          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_TVInsertNewAdFileData: %d: %s',16,1,@error,@message, 
                     @lineNo 
          ); 

          ROLLBACK TRANSACTION 
      END catch; 
  END;  

