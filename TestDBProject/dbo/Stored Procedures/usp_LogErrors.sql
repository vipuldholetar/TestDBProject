-- ============================================= 
-- Author:    Nanjunda 
-- Create date: 12/29/2014 
-- Description:  Loads the Data from flat file to TMS Translation table 
-- Query : 
/*
exec usp_LogErrors 'TMSDataLoad','Ingestion Manager','TMS Ingestion','TMSIE1','TMSPC1','TMSS1',
'Ingestion','Ingestion Process Error','Ingestion Process Error','2015-01-02 05:49:53.167'
*/
-- ============================================= 
CREATE PROC [dbo].[usp_LogErrors]
(
	@EventType varchar(50),
	@ProcessManager varchar(50),
	@ProcessEngine varchar(50),
	@JobId varchar(10),
	@JobPackageId varchar(10),
	@JobStepId varchar(10),
	@ServiceEventType varchar(50),
	@LogDisplayMessage varchar(50),
	@LogDetails varchar(MAX),
	@TimeStamp varchar(50)
)
AS
BEGIN
	 SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 
			INSERT INTO [ErrorLog](	EventType,
									ProcessManager,
									ProcessEngine,
									[JobID],
									[JobPackageID],
									[JobStepID],
									ServiceEventType,
									LogDisplayMessage,
									LogDetails,
									[TimeStamp]
								  )
			VALUES(	@EventType,
					@ProcessManager,
					@ProcessEngine,
					@JobId,
					@JobPackageId,
					@JobStepId,
					@ServiceEventType,
					@LogDisplayMessage, 
					@LogDetails,
					@TimeStamp
				)
		COMMIT TRANSACTION 
		END TRY 

    BEGIN CATCH 
        --RAISERROR ('usp_LogErrors: %d: %s',16,1,ERROR_NUMBER(),ERROR_MESSAGE(),ERROR_LINE()); 
        ROLLBACK TRANSACTION 
		THROW
    END CATCH 
END
