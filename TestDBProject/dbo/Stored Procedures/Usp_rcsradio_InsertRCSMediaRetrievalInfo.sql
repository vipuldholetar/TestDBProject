-- ============================================= 

-- Author: Govardhan.R 

-- Create date: 04/30/2015 

-- Description: Insert the RCS media information. 

-- Query : exec Usp_rcsradio_InsertRCSMediaRetrievalInfo '1334','.gsm','C:\\MTG-Spend\\RA\\','C:\\MTG-Spend\\RA\\585-163490208.gsm','53638'

-- ============================================= 

CREATE PROCEDURE [dbo].[Usp_rcsradio_InsertRCSMediaRetrievalInfo](

@OccurrenceID  INT,

@MediaFormat varchar(10),

@MediaFilepath varchar(250),

@MediaFileName varchar(250),

@FileSize bigint,

@PatternMasterStagingID bigint,

@MediaBasePath varchar(250)
)

AS 

  BEGIN 

      SET nocount ON; 

      BEGIN try 

          BEGIN TRANSACTION  



      DECLARE @CreativeStagingID AS INT;
 --DECLARE @LocalRepository AS varchar(250);
 DECLARE @MediaStream AS varchar(250);

--select @LocalRepository = value from configurationmaster where systemName='All' and componentName='Creative Repository'
select @MediaStream =value from [Configuration] where valuetitle='Radio'

      INSERT INTO CREATIVEMASTERSTAGING (Deleted,CreatedDTM,OccurrenceID)

      VALUES(0,GETDATE(),@OccurrenceID)

	SELECT @CreativeStagingID = @@IDENTITY ;
	--print @CreativeStagingID
	 --print @@IDENTITY


        INSERT INTO CREATIVEDETAILSRASTAGING (CreativeStagingID,MediaFormat,MediaFilepath,MediaFileName,FileSize)

      VALUES(@CreativeStagingID,replace(@MediaFormat,'.',''),'\'+@MediaStream+'\'+convert(varchar(250),@CreativeStagingID)+'\Original\',convert(varchar(250),@CreativeStagingID),@FileSize)

--print @@IDENTITY

	update [PATTERNMASTERSTAGING]  set CreativeStagingID=@CreativeStagingID where PatternMasterStagingID=@PatternMasterStagingID

	update [Configuration] set value=@MediaBasePath where systemName='All' and componentName='Creative Repository'

	select CreativeDetailRAStagingID, CreativeStagingID,@MediaBasePath + '\'+ @MediaStream [AssetServer],
	@MediaBasePath+'\'+@MediaStream+'\'+convert(varchar(250),@CreativeStagingID)+'\Original\'+convert(varchar(250),@CreativeStagingID)+'.wav'[SharedFilePath],
	@MediaBasePath+'\'+@MediaStream+'\'+convert(varchar(250),@CreativeStagingID)+'\'+'Original'[CreativeFolderPath]
	
	 from CREATIVEDETAILSRASTAGING where CreativeDetailRAStagingID=@@IDENTITY

	 

          COMMIT TRANSACTION 
      END try



      BEGIN catch 

          DECLARE @error INT, 

                  @message VARCHAR(4000), 

                  @lineNo INT 



          SELECT @error = Error_number(), 

                 @message = Error_message(), 

                 @lineNo = Error_line() 



          RAISERROR ('Usp_rcsradio_InsertRCSMediaRetrievalInfo: %d: %s',16,1,@error, 

                     @message, 

                     @lineNo); 



          ROLLBACK TRANSACTION 

      END catch; 

  END;