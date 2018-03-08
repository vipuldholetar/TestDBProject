-- =============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Populates the TMS master table from the TMS_Translation table  
-- Query : exec usp_TMS_06_StationMapping 'NT AUTHORITY\SYSTEM'  
-- =============================================  
CREATE PROCEDURE [dbo].[usp_TMS_06_StationMapping] 
(
	@UserName        AS VARCHAR(20)
)
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 
          DECLARE @userid INT 

          -- Retreiving userID  
          SELECT @userid = userid 
          FROM   tms_users 
          WHERE  username = @Username 
   		 
		 SELECT ftt.ProgTmsChannel as PROG_TMS_CHANNEL,
				ftt.Src,
              CASE  
				   WHEN  (SELECT c.DMA
					  FROM   station_map a,TMS_TV_STATION b,TV_STATIONS c
					  WHERE  a.tms_station_id = b.TV_STATION_ID and 
							 b.TV_STATION_NAME=FTT.PROG_TMS_CHANNEL and c.MT_STATION_ID=a.MT_STATION_ID)='CAB' THEN
						FTT.PROG_TMS_CHANNEL
				   WHEN ftt.prog_source_type ='N'  THEN 
				   (SELECT c.NETWORK_AFFILIATION
					  FROM   station_map a,TMS_TV_STATION b,TV_STATIONS c
					  WHERE  a.tms_station_id = b.TV_STATION_ID and 
							 b.TV_STATION_NAME=FTT.PROG_TMS_CHANNEL and c.MT_STATION_ID=a.MT_STATION_ID) 
                   WHEN ftt.prog_source_type='S' THEN 'SYN'
                   WHEN ftt.prog_source_type='L' THEN 'LOC'
				  END  AS mt_station_Name
			into #updatesource
          FROM   TEMPTRANSLATION FTT

		  update TEMPTRANSLATION 
		  set [SOURCE]=TU.mt_station_Name
		  from TEMPTRANSLATION TT
		  left join #updatesource TU
		  on TU.PROG_TMS_CHANNEL=TT.PROG_TMS_CHANNEL and 
			 tu.prog_source_type=tt.prog_source_type

			 drop table #updatesource

		  COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = ERROR_NUMBER(), 
                 @message = ERROR_MESSAGE(), 
                 @lineNo = ERROR_LINE() 

          RAISERROR ('usp_TMS_06_StationMapping: %d: %s',16,1,@error,@message, 
                     @lineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
