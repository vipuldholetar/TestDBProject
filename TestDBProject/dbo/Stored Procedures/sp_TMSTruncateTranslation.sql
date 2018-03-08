-- =============================================
-- Author:		Nanjunda
-- Create date: 11/14/2014
-- Description:	deletes all the previous records from the TMS_Transaltion table
-- Query : exec sp_TMSTruncateTranslation
-- =============================================
CREATE PROCEDURE [dbo].[sp_TMSTruncateTranslation] 
AS 
  BEGIN 
      SET nocount ON; 

      -- Truncating TMS_TRANSALATION Table and TMS_RAWDATA table 
	  TRUNCATE TABLE [TMSRawData]
      TRUNCATE TABLE [TMSTranslation] 
	  TRUNCATE TABLE [TempTranslation]
	  TRUNCATE TABLE [TempTMSSchedule]
  END
