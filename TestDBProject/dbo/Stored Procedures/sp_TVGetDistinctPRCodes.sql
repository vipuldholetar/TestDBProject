CREATE PROCEDURE [dbo].[sp_TVGetDistinctPRCodes] 

AS 

  BEGIN 

      BEGIN TRY 

	  DECLARE @DistinctPRCode TABLE
		(
		  [RowId] [INT] IDENTITY(1,1) NOT NULL,
		  PRCode VARCHAR(200),
		  OriginalPRCode VARCHAR(200) 
		);

		INSERT INTO @DistinctPRCode
		(
		PRCode,  -- This could be an ethnic code
		OriginalPRCode  -- if so, then this will contain the original PR Code value
		)
		SELECT 
		DISTINCT [CreativeSignature], [OriginalPRCode]
		FROM [PatternStaging]  
		left join TVEthnicPRCode on [TVEthnicPRCodeId] = [CreativeSignature]
		WHERE MediaStream = 144 and [CreativeStgID] IS NULL
		

	  SELECT * FROM @DistinctPRCode

      END TRY 

      BEGIN CATCH 

          DECLARE @error   INT,
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_TVGetDistinctPRCodes: %d: %s',16,1,@error,@message,@lineNo); 

          ROLLBACK TRANSACTION 

      END catch; 

  END;