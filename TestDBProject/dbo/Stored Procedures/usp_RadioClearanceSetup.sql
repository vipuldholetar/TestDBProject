-- ============================================= 
-- AUTHOR:		 MURALI JAGANATHAN
-- CREATE DATE:  04/22/2015 
-- DESCRIPTION:  RADIO CLEARANCE SETUP FOR VALID AD OCCURANCE RECORD
-- QUERY :		 EXEC usp_RadioClearanceSetup 
-- ============================================= 

CREATE PROC [dbo].[usp_RadioClearanceSetup] 
AS 
  BEGIN 
      SET NOCOUNT ON 
      BEGIN TRY 
	    Declare @clearance varchar(50);
		 set @clearance = 'Local'
		 				
						-- Setup clearance for occurrence records in OccurrenceDetailsRA

		INSERT INTO [OccurrenceClearanceRA] 
		SELECT TOP 500 [OccurrenceDetailRAID], 
				CLEARANCE=@clearance,
				[Deleted],
				GETDATE(),
				1,
				null,
				null 
				FROM [OccurrenceDetailRA] odra
				WHERE NOT EXISTS(SELECT [OccurrenceDetailRAID] 
				FROM [OccurrenceClearanceRA] ocra
				WHERE ocra.[OccurrenceDetailRAID] = odra.[OccurrenceDetailRAID]) 
				AND odra.PatternID IS NOT NULL 
				AND [AdID] IS NOT NULL 
				AND [Deleted]=0

				-- Insert the occurrence records in OccurrenceClientFacingRA

		INSERT INTO [OccurrenceClientFacingRA] 
		SELECT TOP 500 DE.[OccurrenceDetailRAID], 
		DE.[AdID],
		[OccurrenceClearanceRAID],
		NULL,
		1,
		[AirDT],
		[AirStartDT],
		[AirEndDT],
		GETDATE(),
		1,
		null,
		null 
		FROM [OccurrenceClearanceRA] CL 
		INNER JOIN [OccurrenceDetailRA] DE ON DE.[OccurrenceDetailRAID]=CL.[OccurrenceDetailRAID]
		WHERE NOT EXISTS(SELECT OCCURRENCEDETAILRAID 
		FROM [OccurrenceClientFacingRA] ocfra
		WHERE DE.OCCURRENCEDETAILRAID = CL.OccurrenceClearanceRAID) 
		AND DE.PatternID IS NOT NULL 
		AND DE.ADID IS NOT NULL 
		AND DE.[Deleted]=0

      END TRY 
      BEGIN CATCH 
          DECLARE @ERROR   INT,
                  @MESSAGE VARCHAR(4000),
                  @LINENO  INT
          SELECT @ERROR = ERROR_NUMBER(),
                 @MESSAGE = ERROR_MESSAGE(),
                 @LINENO = ERROR_LINE() RAISERROR ('usp_RadioClearanceSetup : %d: %s',16,1,@ERROR,@MESSAGE,@LINENO)
      END CATCH; 
  END;
