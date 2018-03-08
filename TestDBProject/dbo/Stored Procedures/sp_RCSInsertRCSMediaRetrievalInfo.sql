-- ============================================= 

-- Author: Govardhan.R 

-- Create date: 04/30/2015 

-- Description: Insert the RCS media information. 

-- Query : exec sp_RCSInsertRCSMediaRetrievalInfo '1334','.gsm','C:\\MTG-Spend\\RA\\','C:\\MTG-Spend\\RA\\585-163490208.gsm','53638'

-- ============================================= 

CREATE PROCEDURE [dbo].[sp_RCSInsertRCSMediaRetrievalInfo](

@OccrnID  INT,

@MediaFormat varchar(10),

@MediaFilePath varchar(250),

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
                 DECLARE @CreativeMasterStgId AS INT;
	             --DECLARE @LocalRepository AS varchar(250);
	             DECLARE @MediaStream AS varchar(250);
	             
	             --select @LocalRepository = Value from ConfigMaster where ValueTitle='LocalRepository'
	             select @MediaStream = Value from [Configuration] where ValueTitle='Radio'
	             
                 INSERT INTO [CreativeStaging] 
				 (Deleted,
				 [CreatedDT],
				 [OccurrenceID])
	             
                 VALUES(0,
				 GETDATE(),
				 @OccrnID)
	             
	             SELECT @CreativeMasterStgId = @@IDENTITY ;
	             
	             
	             
                 INSERT INTO [CreativeDetailStagingRA] ([CreativeStgID],MediaFormat,MediaFilepath,MediaFileName,FileSize)
	             VALUES(@CreativeMasterStgId,replace(@MediaFormat,'.',''),'\'+@MediaStream+'\'+convert(varchar(250),@CreativeMasterStgId)+'\Original\',convert(varchar(250),@CreativeMasterStgId),@FileSize)

	             update [PatternStaging]  set [CreativeStgID]=@CreativeMasterStgId where [PatternStagingID]=@PatternMasterStagingID

			            
				 select [CreativeDetailStagingRAID], [CreativeStgID],@MediaBasePath + '\'+ @MediaStream [AssetServer],
				 @MediaBasePath+'\'+@MediaStream+'\'+convert(varchar(250),@CreativeMasterStgId)+'\Original\'+convert(varchar(250),@CreativeMasterStgId)+'.wav'[SharedFilePath],
				 @MediaBasePath+'\'+@MediaStream+'\'+convert(varchar(250),@CreativeMasterStgId)+'\'+'Original'[CreativeFolderPath]
				
				 from [CreativeDetailStagingRA] where [CreativeDetailStagingRAID]=@@IDENTITY             
	            

          COMMIT TRANSACTION 
      END try



      BEGIN catch 

          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = Error_number(), 
                 @Message = Error_message(), 
                 @LineNo = Error_line() 

          RAISERROR ('sp_RCSInsertRCSMediaRetrievalInfo: %d: %s',16,1,@Error, 
                     @Message, 
                     @LineNo); 

          ROLLBACK TRANSACTION; 

      END catch; 

  END;