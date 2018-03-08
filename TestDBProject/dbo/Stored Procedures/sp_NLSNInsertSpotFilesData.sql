CREATE PROCEDURE [dbo].[sp_NLSNInsertSpotFilesData](@NLSNTSData dbo.NLSNTSData readonly, @NLSNPFData dbo.NLSNPFData readonly, @SpotRatingFileName varchar(100), @SpotProgramFileName varchar(100))
AS
BEGIN 
     -- SET nocount ON; 
      BEGIN TRY 
        BEGIN TRANSACTION 

		TRUNCATE TABLE NLSNTSData;

		TRUNCATE TABLE NLSNPFData;

		INSERT INTO NLSNTSData
		(
		Column1,
Column2,
Column3,
Column4,
Column5,
Column6,
Column7,
Column8,
Column9,
Column10,
Column11,
Column12,
Column13,
Column14,
Column15,
Column16,
Column17,
Column18,
Column19,
Column20,
Column21,
Column22,
Column23,
Column24,
Column25,
Column26,
Column27,
Column28
		)
		SELECT Column1,
Column2,
Column3,
Column4,
Column5,
Column6,
Column7,
Column8,
Column9,
Column10,
Column11,
Column12,
Column13,
Column14,
Column15,
Column16,
Column17,
Column18,
Column19,
Column20,
Column21,
Column22,
Column23,
Column24,
Column25,
Column26,
Column27,
Column28
FROM @NLSNTSData

INSERT INTO NLSNPFData
(Column1,
Column2,
Column3,
Column4,
Column5,
Column6,
Column7,
Column8,
Column9,
Column10,
Column11,
Column12,
Column13,
Column14,
Column15,
Column16,
Column17,
Column18,
Column19,
Column20,
Column21,
Column22,
Column23,
Column24)
SELECT Column1,
Column2,
Column3,
Column4,
Column5,
Column6,
Column7,
Column8,
Column9,
Column10,
Column11,
Column12,
Column13,
Column14,
Column15,
Column16,
Column17,
Column18,
Column19,
Column20,
Column21,
Column22,
Column23,
Column24
FROM @NLSNPFData

EXEC dbo.[sp_NLSNProcessSpotRatingFileData] 
@NLSNTSData, 
@SpotRatingFileName

EXEC dbo.[sp_NLSNProcessSpotProgramFileData] 
@NLSNPFData, 
@SpotProgramFileName


		COMMIT TRANSACTION
      END TRY 

      BEGIN CATCH 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 
          SELECT @error = Error_number(), 
                 @message = Error_message(), 
                 @lineNo = Error_line() 

          RAISERROR ('sp_NLSNInsertSpotFilesData: %d: %s',16,1,@error,@message, @lineNo); 
          ROLLBACK TRANSACTION 
      END catch; 
  END;