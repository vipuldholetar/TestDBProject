-- =============================================
-- Author:		Ashanie Cole
-- Create date:	December 2016
-- Description:	GetTVJPEGCreatives

--EXEC sp_GetPRJPEGCreatives '0JGC2A4I.PA0'
-- =============================================

CREATE PROCEDURE sp_GetPRJPEGCreatives
	@PRCode as varchar(50)
AS
BEGIN
    
    SET NOCOUNT ON;

    DECLARE @JPEGPath AS VARCHAR(200) = 'I:\arc_jpg\<xxx>\<yy>\'
    DECLARE @WAVPath AS VARCHAR(200) = 'I:\arc_wav\<xxx>\<yy>\'
    DECLARE @HQVideoPath AS VARCHAR(200) = 'J:\<xxx>\<yy>\'

    SET @JPEGPath = REPLACE(@JPEGPath,'<xxx>',SUBSTRING(@PRCode,3,3))
    SET @WAVPath = REPLACE(@WAVPath,'<xxx>',SUBSTRING(@PRCode,3,3))
    SET @HQVideoPath = REPLACE(@HQVideoPath,'<xxx>',SUBSTRING(@PRCode,3,3))

    SET @JPEGPath = REPLACE(@JPEGPath,'<yy>',SUBSTRING(@PRCode,1,2))
    SET @WAVPath = REPLACE(@WAVPath,'<yy>',SUBSTRING(@PRCode,1,2))
    SET @HQVideoPath = REPLACE(@HQVideoPath,'<yy>',SUBSTRING(@PRCode,1,2))

    print @JPEGPath
    print @WAVPath
    print @HQVideoPath

    select @JPEGPath AS JPEGCreative, @WAVPath AS WAVCreative, @HQVideoPath AS HQVideo

    --SELECT 'C:\VehicleImage\201303\41768042\Full\N913N8.jpg' AS JPEGCreative, 'C:\VehicleImage\10002.wav' as WAVCreative
    --UNION
    --SELECT 'C:\VehicleImage\201303\41768042\Full\N913NB.jpg' AS JPEGCreative, 'C:\VehicleImage\10002.wav' as WAVCreative
    --UNION
    --SELECT 'C:\VehicleImage\201303\41768042\Full\N913ND.jpg' AS JPEGCreative, 'C:\VehicleImage\10002.wav' as WAVCreative
    --UNION
    --SELECT 'C:\VehicleImage\201303\41768042\Full\N913NE.jpg' AS JPEGCreative, 'C:\VehicleImage\10002.wav' as WAVCreative
END