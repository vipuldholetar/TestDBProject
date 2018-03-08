-- ============================================= 

-- Author: Govardhan.R 

-- Create date: 04/30/2015 

-- Description: Insert the Outdoor media information.

-- Query : exec sp_ODRInsertMediaInformation '1334','.gsm','C:\\MTG-Spend\\RA\\','C:\\MTG-Spend\\RA\\585-163490208.gsm','53638'

-- ============================================= 

CREATE PROCEDURE [dbo].[sp_ODRInsertMediaInformation](

@CMSSourceFolder  varchar(200),

@CMSFileName varchar(200),

@CMSFileSize int,

@CMSFileDate datetime,

@OccurnceId int,

@CreativeMstrStgId int,

@MTMarketId int,

@FileType varchar(50),

@CreativeFilePath varchar(200),

@MTFileSize int,

@MTFileDate datetime,

@AdFormatID int

)

AS 

BEGIN 

     SET nocount ON; 

     BEGIN try 

          BEGIN TRANSACTION 

		   DECLARE @CreativeStagingID AS INT;

		   DECLARE @LocalRepository AS varchar(1000);

		   DECLARE @MediaStream AS varchar(250);

		   select @LocalRepository = value from [Configuration] where systemName='All' and componentName='Creative Repository'

		   select @MediaStream =value from [Configuration] where valuetitle='Outdoor'

		   

		   IF(@CreativeMstrStgId=0)

		   BEGIN

			   --INSERT INTO CREATIVE MASTER STAGING TABLE

			   INSERT INTO [CreativeStaging] (Deleted,[CreatedDT],[OccurrenceID], CreativeSignature)

      		   VALUES(0,GETDATE(),@OccurnceId,@CMSFileName)

		   

			   --Get the Identity column of Master table. 

			   SELECT @CreativeStagingID = @@IDENTITY;



			   --INSERT THE MEDIA INFORMATION.

			   INSERT INTO [CreativeDetailStagingODR] (CreativeStagingID,CreativeFileType,CreativeRepository,CreativeAssetName,CreativeFileSize,AdFormatID)

			   VALUES(@CreativeStagingID, RIGHT( @CMSFileName, CHARINDEX( '.', REVERSE( @CMSFileName ) + '.' ) - 1 ),  -- get file extension
			   
			   --,dbo.TVGetSplitStringByRowNo(@CMSFileName,'.',2),
			   --@CreativeFilePath,dbo.TVGetSplitStringByRowNo(@CMSFileName,'.',1),@CMSFileSize)
			   @CreativeFilePath,@CMSFileName,@CMSFileSize, @AdFormatID)



			   --UPDATE PATTERN MASTER STAGING TABLE.



			   UPDATE [PatternStaging] SET [CreativeStgID]=@CreativeStagingID

			   WHERE [CreativeSignature]=@CMSFileName;



			   --UPDATE MTIMAGEDETAILS IN OCCURENCE DETAILS TABLE.

			   UPDATE [OccurrenceDetailODR] SET [MTImageDT]=@MTFileDate ,MTIMAGESIZE=@MTFileSize

			   WHERE IMAGEFILENAME=@CMSFileName;



			   --UPDATE CMS RAW DATA FOR MT File Size and DateTime



			   UPDATE CMSRAWDATA SET INGESTIONSTATUS='INGESTED'

			   WHERE CMSFileName=@CMSFileName;



			   SELECT * FROM [CreativeDetailStagingODR] where CreativeStagingID=@CreativeStagingID



		   END

		   ELSE

		   BEGIN



		       --UPDATE CREATIVEDETAILSODRStg TABLE.

			   UPDATE [CreativeDetailStagingODR] SET CreativeRepository=@CreativeFilePath,CreativeFileSize=@CMSFileSize

			   WHERE CreativeStagingID=@CreativeMstrStgId;



			   --UPDATE MTIMAGEDETAILS IN OCCURENCE DETAILS TABLE.

			   UPDATE [OccurrenceDetailODR] SET [MTImageDT]=@MTFileDate ,MTIMAGESIZE=@MTFileSize

			   WHERE IMAGEFILENAME=@CMSFileName;



			   --UPDATE CMS RAW DATA FOR MT File Size and DateTime



			   UPDATE CMSRAWDATA SET INGESTIONSTATUS='INGESTED'

			   WHERE CMSFileName=@CMSFileName;



			   SELECT * FROM [CreativeDetailStagingODR] where CreativeStagingID=@CreativeMstrStgId;



		   END



		   COMMIT TRANSACTION 

      END try 



      BEGIN catch 

          DECLARE @error   INT, 

                  @message VARCHAR(4000), 

                  @lineNo  INT 



          SELECT @error = Error_number(), 

                 @message = Error_message(), 

                 @lineNo = Error_line() 



          RAISERROR ('sp_ODRInsertMediaInformation: line#:%d; %d: %s',16,1,@lineNo,@error,@message); 



          ROLLBACK TRANSACTION 

      END catch; 

  END;