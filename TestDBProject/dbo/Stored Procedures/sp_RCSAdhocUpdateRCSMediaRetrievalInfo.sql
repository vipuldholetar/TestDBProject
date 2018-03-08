
-- ============================================= 
-- Author: KARUNAKAR.P
-- Create date: 12/10/2015 
-- Description: Update the RCS Adhoc media information into CreativeDetailsRaStg. 
-- Query : exec sp_RCSAdhocUpdateRCSMediaRetrievalInfo 61030,33,'\\182.95.60.158\MT_Assets'
-- ============================================= 

CREATE PROCEDURE [dbo].[sp_RCSAdhocUpdateRCSMediaRetrievalInfo]
(
@FileSize bigint,
@PatternMasterStagingID bigint,
@MediaBasePath varchar(250)
)
 AS
BEGIN
		SET NOCOUNT ON;	    
		BEGIN TRY
			BEGIN TRANSACTION         
				 DECLARE @MediaStream AS varchar(250);
				 Declare @CreativeDetailstgId as INT;
	             select @MediaStream = Value from [Configuration] where ValueTitle='Radio'
                

				 --update configurationmaster set value=@MediaBasePath where systemName='All' and componentName='Creative Repository'

				select @CreativeDetailstgId =(select [CreativeDetailStagingRAID] from [CreativeDetailStagingRA] where [CreativeStgID]=(Select [CreativeStgID] from [PatternStaging] where [PatternStaging].[PatternStagingID]=@PatternMasterStagingID))

	             Update [CreativeDetailStagingRA] set FileSize=@FileSize where [CreativeDetailStagingRAID]=@CreativeDetailstgId


				  select [CreativeDetailStagingRAID], [CreativeStgID],@MediaBasePath + '\'+ @MediaStream [AssetServer], @MediaBasePath+MediaFilePath+MediaFileName+'.'+MediaFormat [SharedFilePath],

				  @MediaBasePath+MediaFilePath [CreativeFolderPath] from [CreativeDetailStagingRA] where [CreativeDetailStagingRAID]=@CreativeDetailstgId

      		COMMIT TRANSACTION
 		END TRY 
		BEGIN CATCH 
          DECLARE @Error   INT, @Message VARCHAR(4000), @LineNo  INT 
          SELECT @Error = Error_number(), @Message = Error_message(), @LineNo = Error_line() 

          RAISERROR ('sp_RCSAdhocUpdateRCSMediaRetrievalInfo: %d: %s',16,1,@Error, @Message, @LineNo); 
          ROLLBACK TRANSACTION 
      END CATCH 
	
END