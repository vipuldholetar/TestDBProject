-- =============================================     
-- Author:    Govardhan.R     
-- Create date: 01/13/2016     
-- Description:  Update Admin Tool XML Config values  
 --Query : exec SP_UPDATEADMINTOOLXMLCONFIGS 'Empty/Value','5','10','Seconds','Database','markettrack.messenger@genpact.com','nanjundaswamy.as@genpact.com,Govardhan@genpact.com','nanjundaswamy.as@genpact.com,Govardhan@genpact.com','Yes',
 --                                         '0','$DB_SERVER','$DB_NAME','$DB_USER','$DB_PWD',
 --                                         '0','$IsProxyRequired','$ProxyUserName','$ProxyPassword','$ProxyDomainName',
 --                                         '0','$IsLocalAsset','$AssetBasePath','$AssetFileExtension','$AssetServerUserName','$AssetServerPassword','$AssetServerDomainName',
 --                                         '0','$OutputMediaFilePath','$MediaFileExtension',
 --                                         '0','$WS_URL','$WS_USER','$WS_PWD','$WS_PI',
 --                                         '0','$FTP_SERVER','$FTP_USER','$FTP_PORT','$FTP_PWD','$FTP_SOURCE_FOLDER','$FTP_DEST_FOLDER',
 --                                         '0','$SOURCE_FOLDER','$ARCHIVE_FOLDER','$ERROR_FOLDER',
 --                                         '0','$BiggestSequenceId','$MaxRowsToRetrieve','$RetrievalIteration','$TimeToReStartRetrieval','$WaitTimeBetweenIteration',
 --                                         '0','$SMSRecipients','$ETHENIC_ID','$INGESTION_TYPE',
 --                                         '0','$BatchFilePath','$DownloadPath',
 --                                         '0','$BatchCount','$AssetBasePathForJPEGAndWav','$AssetBasePathForMedia'  
-- Query : exec SP_UPDATEADMINTOOLXMLCONFIGS '6094','5','10','Seconds','Database','markettrack.messenger@genpact.com','nanjundaswamy.as@genpact.com,Govardhan@genpact.com','nanjundaswamy.as@genpact.com,Govardhan@genpact.com','Yes',
                                          --'1','$DB_SERVER','$DB_NAME','$DB_USER','$DB_PWD',
                                          --'0','$IsProxyRequired','$ProxyUserName','$ProxyPassword','$ProxyDomainName',
                                          --'0','$IsLocalAsset','$AssetBasePath','$AssetFileExtension','$AssetServerUserName','$AssetServerPassword','$AssetServerDomainName',
                                          --'0','$OutputMediaFilePath','$MediaFileExtension',
                                          --'0','$WS_URL','$WS_USER','$WS_PWD','$WS_PI',
                                          --'0','$FTP_SERVER','$FTP_USER','$FTP_PORT','$FTP_PWD','$FTP_SOURCE_FOLDER','$FTP_DEST_FOLDER',
                                          --'0','$SOURCE_FOLDER','$ARCHIVE_FOLDER','$ERROR_FOLDER',
                                          --'0','$BiggestSequenceId','$MaxRowsToRetrieve','$RetrievalIteration','$TimeToReStartRetrieval','$WaitTimeBetweenIteration',
                                          --'0','$SMSRecipients','$ETHENIC_ID','$INGESTION_TYPE',
                                          --'0','$BatchFilePath','$DownloadPath',
                                          --'0','$BatchCount','$AssetBasePathForJPEGAndWav','$AssetBasePathForMedia'   
CREATE PROCEDURE [dbo].[SP_UPDATEADMINTOOLXMLCONFIGS]
(
@ServiceId varchar(250),
@HeartbeatInterval INT,
@ApproximateDuration INT,
@UnitOfDuration VARCHAR(50),
@NotificationType VARCHAR(25),
@FromAddress VARCHAR(250),
@ToAddress VARCHAR(250),
@CCAddress VARCHAR(250),
@LogInfoToTrace VARCHAR(250),
@UpdateDbDetails int=NULL,
@DB_SERVER VARCHAR(250)=NULL,
@DB_NAME VARCHAR(250)=NULL,
@DB_USER VARCHAR(250)=NULL,
@DB_PWD varchar(250)=NULL,
@UpdateProxyDetails int=NULL,
@IsProxyRequired VARCHAR(250)=NULL,
@ProxyUserName VARCHAR(250)=NULL,
@ProxyPassword VARCHAR(250)=NULL,
@ProxyDomainName varchar(250)=NULL,
@UpdateAssetDetails int=NULL,
@IsLocalAsset VARCHAR(250)=NULL,
@AssetBasePath VARCHAR(250)=NULL,
@AssetFileExtension VARCHAR(250)=NULL,
@AssetServerUserName varchar(250)=NULL,
@AssetServerPassword VARCHAR(250)=NULL,
@AssetServerDomainName varchar(250)=NULL,
@UpdateMediaPathDetails int=NULL,
@OutputMediaFilePath varchar(250)=NULL,
@MediaFileExtension varchar(250)=NULL,
@UpdateWebServiceDetails int=NULL,
@WS_URL VARCHAR(250)=NULL,
@WS_USER varchar(250)=NULL,
@WS_PWD varchar(250)=NULL,
@WS_PI varchar(250)=NULL,
@UpdateFTPDetails int=NULL,
@FTP_SERVER VARCHAR(250)=NULL,
@FTP_USER varchar(250)=NULL,
@FTP_PORT varchar(250)=NULL,
@FTP_PWD varchar(250)=NULL,
@FTP_SOURCE_FOLDER varchar(250)=NULL,
@FTP_DEST_FOLDER varchar(250)=NULL,
@UpdateFoldersDetails int=NULL,
@SOURCE_FOLDER varchar(250)=NULL,
@ARCHIVE_FOLDER varchar(250)=NULL,
@ERROR_FOLDER varchar(250)=NULL,
@UpdateRCSConfigDetails int=NULL,
@BiggestSequenceId varchar(250)=NULL,
@MaxRowsToRetrieve varchar(250)=NULL,
@RetrievalIteration varchar(250)=NULL,
@TimeToReStartRetrieval varchar(250)=NULL,
@WaitTimeBetweenIteration varchar(250)=NULL,
@UpdateTMSDetails int=NULL,
@SMSRecipients varchar(250)=NULL,
@ETHENIC_ID varchar(250)=NULL,
@INGESTION_TYPE varchar(250)=NULL,
@UpdateNielsenConfigDetails int=NULL,
@BatchFilePath varchar(250)=NULL,
@DownloadPath varchar(250)=NULL,
@UpdateTVConfigDetails int=NULL,
@BatchCount varchar(250)=NULL,
@AssetBasePathForJPEGAndWav varchar(250)=NULL,
@AssetBasePathForMedia varchar(250)=NULL
)
AS
BEGIN
-- DAFAULT CONFIGURATIONS
	  BEGIN
		   --UPDATE HEART BEAT INTERVAL
		   UPDATE [JobStep]
		   SET [Configuration].modify('
		   replace value of (/configuration/HeartbeatInterval[1]/text())[1]
		   with sql:variable("@HeartbeatInterval")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

		   --UPDATE APPROXIMATE DURATION
		   UPDATE [JobStep]
		   SET [Configuration].modify('
		   replace value of (/configuration/ApproximateDuration[1]/text())[1]
		   with sql:variable("@ApproximateDuration")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

		   --UPDATE UNIT OF DURATION
		   UPDATE [JobStep]
		   SET [Configuration].modify('
		   replace value of (/configuration/UnitOfDuration[1]/text())[1]
		   with sql:variable("@UnitOfDuration")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

		   --UPDATE NOTIFICATION TYPE
		   UPDATE [JobStep]
		   SET [Configuration].modify('
		   replace value of (/configuration/NotificationType[1]/text())[1]
		   with sql:variable("@NotificationType")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

		   --UPDATE FROM ADDRESS
		   UPDATE [JobStep]
		   SET [Configuration].modify('
		   replace value of (/configuration/FromAddress[1]/text())[1]
		   with sql:variable("@FromAddress")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

		   --UPDATE TO ADDRESS
		   UPDATE [JobStep]
		   SET [Configuration].modify('
		   replace value of (/configuration/ToAddress[1]/text())[1]
		   with sql:variable("@ToAddress")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

		   --UPDATE TO ADDRESS
		   UPDATE [JobStep]
		   SET [Configuration].modify('
		   replace value of (/configuration/CCAddress[1]/text())[1]
		   with sql:variable("@CCAddress")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

		   --UPDATE LOG INFO TRACE
		   UPDATE [JobStep]
		   SET [Configuration].modify('
		   replace value of (/configuration/LogInfoToTrace[1]/text())[1]
		   with sql:variable("@LogInfoToTrace")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

	   END
		   BEGIN
			   --UPDATE DATABASE DETAILS		   
			   BEGIN
			       IF(@UpdateDbDetails=1)
					   BEGIN
						   --UPDATE DB SERVER
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/DB_SERVER[1]/text())[1]
						   with sql:variable("@DB_SERVER")') WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE DB NAME
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/DB_NAME[1]/text())[1]
						   with sql:variable("@DB_NAME")') WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE DB USER
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/DB_USER[1]/text())[1]
						   with sql:variable("@DB_USER")') WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE DB PASSWORD
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/DB_PWD[1]/text())[1]
						   with sql:variable("@DB_PWD")') WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)
					   END
			   END
			   
			   --UPDATE PROXY DETAILS
			   BEGIN
			       IF(@UpdateProxyDetails=1)
					   BEGIN
						   --UPDATE PROXY REQUIRED OR NOT STATUS
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/IsProxyRequired[1]/text())[1]
						   with sql:variable("@IsProxyRequired")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE PROXY USERNAME
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/ProxyUserName[1]/text())[1]
						   with sql:variable("@ProxyUserName")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE PROXY PASSWORD
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/ProxyPassword[1]/text())[1]
						   with sql:variable("@ProxyPassword")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE PROXY DOMAIN NAME
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/ProxyDomainName[1]/text())[1]
						   with sql:variable("@ProxyDomainName")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)
					   END
			   END

			   --UPDATE MEDIA FILE PATH
			   BEGIN
				   IF(@UpdateMediaPathDetails=1)
					   BEGIN
						  --UPDATE OUPUT MEDIA FILE PATH
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/OutputMediaFilePath[1]/text())[1]
						   with sql:variable("@OutputMediaFilePath")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE MEDIA FILE EXTENTION
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/MediaFileExtension[1]/text())[1]
						   with sql:variable("@MediaFileExtension")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)
						END
                END

			   --UPDATE ASSET DETAILS
			   BEGIN
				   IF(@UpdateAssetDetails=1)
					   BEGIN
						   --UPDATE ASSET STATUS
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/IsLocalAsset[1]/text())[1]
						   with sql:variable("@IsLocalAsset")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE ASSET BASE PATH
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/AssetBasePath[1]/text())[1]
						   with sql:variable("@AssetBasePath")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE ASSET FILE EXTENSION
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/AssetFileExtension[1]/text())[1]
						   with sql:variable("@AssetFileExtension")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE ASSET SERVER USER NAME
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/AssetServerUserName[1]/text())[1]
						   with sql:variable("@AssetServerUserName")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE ASSET SERVER PASSWORD
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/AssetServerPassword[1]/text())[1]
						   with sql:variable("@AssetServerPassword")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE ASSET SERVER DOMAIN NAME
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/AssetServerDomainName[1]/text())[1]
						   with sql:variable("@AssetServerDomainName")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)
						   END
                END

	           --WEB SERVICE DETAILS
			   BEGIN
				   IF(@UpdateWebServiceDetails=1)
					       BEGIN
						   --UPDATE WEB SERICE URL
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/WS_URL[1]/text())[1]
						   with sql:variable("@WS_URL")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE WEB SERVICE USER 
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/WS_USER[1]/text())[1]
						   with sql:variable("@WS_USER")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE WEB SERVICE PASSWORD
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/WS_PWD[1]/text())[1]
						   with sql:variable("@WS_PWD")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE WEB SERVICE PI VALUE
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/WS_PI[1]/text())[1]
						   with sql:variable("@WS_PI")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)
						   END
			   END

			   --FTP DETAILS
			   BEGIN
				   IF(@UpdateFTPDetails=1)
					   BEGIN
						   --UPDATE ftp server
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/FTP_SERVER[1]/text())[1]
						   with sql:variable("@FTP_SERVER")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE ftp USER 
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/FTP_USER[1]/text())[1]
						   with sql:variable("@FTP_USER")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE FTP PORT
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/FTP_PORT[1]/text())[1]
						   with sql:variable("@FTP_PORT")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE FTP PASSWORD
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/FTP_PWD[1]/text())[1]
						   with sql:variable("@FTP_PWD")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE FTP SOPURCE FOLDER
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/FTP_SOURCE_FOLDER[1]/text())[1]
						   with sql:variable("@FTP_SOURCE_FOLDER")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE FTP DESTINATION FOLDER
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/FTP_DEST_FOLDER[1]/text())[1]
						   with sql:variable("@FTP_DEST_FOLDER")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)
						 END
			   END

			   --DATA SOURCE FOLDER DETAILS
			   BEGIN
				   IF(@UpdateFoldersDetails=1)
					   BEGIN
			   
						   --UPDATE SOURCE FOLDER
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/SOURCE_FOLDER[1]/text())[1]
						   with sql:variable("@SOURCE_FOLDER")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE ARCHIEVE FOLDER
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/ARCHIVE_FOLDER[1]/text())[1]
						   with sql:variable("@ARCHIVE_FOLDER")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE ERROR FOLDER
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/ERROR_FOLDER[1]/text())[1]
						   with sql:variable("@ERROR_FOLDER")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)
				   
					   END
			   END

			   --RCS CONFIGURATIONS
			   BEGIN
				   IF(@UpdateRCSConfigDetails=1)
					   BEGIN
						  --UPDATE BIGGEST SEQUENCE ID
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/BiggestSequenceId[1]/text())[1]
						   with sql:variable("@BiggestSequenceId")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE MAX ROWS TO GET
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/MaxRowsToRetrieve[1]/text())[1]
						   with sql:variable("@MaxRowsToRetrieve")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE RETRIEVAL ITERATION
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/RetrievalIteration[1]/text())[1]
						   with sql:variable("@RetrievalIteration")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE TIME TO RESTART ITERATION
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/TimeToReStartRetrieval[1]/text())[1]
						   with sql:variable("@TimeToReStartRetrieval")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE WAIT TIME BETWEEN ITERATION
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/WaitTimeBetweenIteration[1]/text())[1]
						   with sql:variable("@WaitTimeBetweenIteration")')  WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)
						  END
				END

				  --TMS CONFIGURATIONS
			   BEGIN
				   IF(@UpdateTMSDetails=1)
					      BEGIN
   						--UPDATE SMS Recipients
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/SMSRecipients[1]/text())[1]
						   with sql:variable("@SMSRecipients")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE ETHENIC ID
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/ETHENIC_ID[1]/text())[1]
						   with sql:variable("@ETHENIC_ID")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE INGESTION TYPE
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/INGESTION_TYPE[1]/text())[1]
						   with sql:variable("@INGESTION_TYPE")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						  END
			   END
	
			   --NIELSEN CONFIGURATION
			   BEGIN
				   IF(@UpdateNielsenConfigDetails=1)
					       BEGIN
						  --UPDATE Batch File Path
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/BatchFilePath[1]/text())[1]
						   with sql:variable("@BatchFilePath")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE Download Path
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/DownloadPath[1]/text())[1]
						   with sql:variable("@DownloadPath")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)
						  END
				  END

			   --TV CONFIGURATION
			   BEGIN
				   IF(@UpdateTVConfigDetails=1)
					   BEGIN
					   --UPDATE BatchCount
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/BatchCount[1]/text())[1]
						   with sql:variable("@BatchCount")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE Asset BasePath ForJPEG And Wav
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/AssetBasePathForJPEGAndWav[1]/text())[1]
						   with sql:variable("@AssetBasePathForJPEGAndWav")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						   --UPDATE Asset Base Path For Media
						   UPDATE [JobStep]
						   SET [Configuration].modify('
						   replace value of (/configuration/AssetBasePathForMedia[1]/text())[1]
						   with sql:variable("@AssetBasePathForMedia")')   WHERE [JobStepID]=(CASE WHEN @ServiceId='' THEN [JobStepID] ELSE @ServiceId END)

						END
    			END

		   END
END
