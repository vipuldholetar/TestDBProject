

-- ============================================= 

-- Author:    Ramesh Bangi

-- Create date: 7/6/2015

-- Description:  Loads the Data from flat file to NCMRawData table 

-- Query : 

/*



exec sp_CinemaDataLoad2NCMRawData 'C:\MTG-Spend\CinemaData\ncmdata.txt'

 

*/

-- ============================================= 

CREATE PROCEDURE [dbo].[sp_CinemaDataLoad2NCMRawData] (@CinemaData  dbo.NCMRawData READONLY) 

AS 

  BEGIN 

      SET nocount ON; 



      BEGIN try 

          BEGIN TRANSACTION 

		  --TRUNCATE TABLE [NCMRawData]

	 INSERT INTO [dbo].[NCMRawData] 

                      ([NCMFileName], 

                       [DMANetwork], 

                       [CampaignTitle], 

					   [Customer],

                       [StartDT], 

                       [EndDT], 

                       [Rating], 

                       [Length], 

                       [AdName], 

                       [IngestionStatus],

					   [IngestionDT],
					   
					   [Priority]) 

          SELECT [NCMFileName], 

                       [DMANetwork], 
					   --[DMANetwork] = CASE WHEN ISNUMERIC(DMANetwork)<>1 THEN 1 ELSE [DMANetwork] END, 
                       [CampaignTitle], 

					   [Customer],

                       [StartDate], 

                       [EndDate], 

                       [Rating], 

                       [Length], 

                       [AdName], 

                       [IngestionStatus],

					   [IngestionDate],

					   [Priority]

          FROM   @CinemaData 



	--DECLARE @ImportedRecCount INT 



    COMMIT TRANSACTION 

END try 



    BEGIN catch 

        DECLARE @error   INT, 

                @message VARCHAR(4000), 

                @lineNo  INT 



        SELECT @error = Error_number(), 

               @message = Error_message(), 

               @lineNo = Error_line() 



        RAISERROR ('sp_CinemaDataLoad2NCMRawData: %d: %s',16,1,@error,@message,@lineNo); 



        ROLLBACK TRANSACTION 

    END catch; 

END;
