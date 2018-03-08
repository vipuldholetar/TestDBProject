CREATE PROCEDURE [dbo].sp_CleanupData 
AS 
  BEGIN 
      BEGIN try 
          BEGIN TRANSACTION 
			
			
			select count(*) as 'Ad with no Occurrences' from ad where PrimaryOccurrenceId is null 
			select count(*) as 'Ad not reference to any pattern' from ad where 
			 [AdID] not in (select [AdID] from .[Pattern]) 
			
			-- Deleting Ad records which has no pattern reference and primary occurrence

			delete from Ad 

			select count(*) as 'No reference to PatternMasterstg' from [CreativeStaging] 

			-- Deleting Creativemaster staging records which has no reference to PatternMasterstg

			delete from [CreativeStaging]

			-- Deleting Creativemaster records

			delete from [Creative]


          

          COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @ERROR   INT, 
                  @MESSAGE VARCHAR(4000), 
                  @LINENO  INT 

          SELECT @ERROR = Error_number(), 
                 @MESSAGE = Error_message(), 
                 @LINENO = Error_line() 

          RAISERROR ('[sp_CleanupData]: %d: %s',16,1,@ERROR,@MESSAGE,@LINENO 
          ); 

          ROLLBACK TRANSACTION 
      END catch 
  END