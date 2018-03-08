-- =============================================
-- Author:		Nanjunda
-- Create date: 11/14/2014
-- Description:	deletes all the previous records from the TMS_Transaltion table
-- Query : exec usp_TMS_01_TruncateTranslation
-- =============================================
CREATE PROCEDURE [dbo].[usp_TMS_01_TruncateTranslation] 
AS 
  BEGIN 
      SET nocount ON; 

      -- Truncating TMS_TRANSALATION Table and TMS_RAWDATA table 
	  TRUNCATE TABLE TMS_RAWDATA
      TRUNCATE TABLE TMS_TRANSLATION 
	  TRUNCATE TABLE TEMPTRANSLATION
	  TRUNCATE TABLE TEMPTMSSCHEDULE
  END
