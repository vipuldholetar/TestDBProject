-- =============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Populates the TMS master table from the TempTranslation table  
-- Query : exec usp_TMS_07_ProgramMapping 1,'NT AUTHORITY\SYSTEM',1   
-- =============================================  
CREATE PROCEDURE [dbo].[usp_TMS_07_ProgramMapping] 
(
	@EthnicID        AS INT, 
	@UserName        AS VARCHAR(20), 
	@IngestionTypeID AS INT 
)
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 
          DECLARE @userid INT 
		  SELECT @userid = userid 
          FROM   tms_users 
          WHERE  username = @Username 
        -- Inserting records to TMS Program Master     
			select distinct progname into #DistNewTVProgs from TempTranslation 
			except
			SELECT tpm.prog_desc FROM  
			 tms_tv_prog_mst tpm 
			 
			 INSERT INTO tms_tv_prog_mst 
			 Select Prog_name,
					GETDATE(),
					@userid,
					GETDATE(),
					@userid
			 from 
					#DistNewTVProgs
			 
			 Drop table #DistNewTVProgs;

			  --  Selecting non duplicate programs and stations from translation table and inserting into tms_tv_progs    
          WITH tempprogramstationmapping ( prog_id, tv_station_id, 
               prog_source_type,
			   ethnic_group_id, 
               duplicatereccount ) 
               AS (SELECT prog_id, 
                          tv_station_id, 
                          prog_source_type, 
						  ethnic_group_id,
                          ROW_NUMBER() 
                            OVER( 
                              PARTITION BY prog_id, tv_station_id, 
                            prog_source_type ,ethnic_group_id
                              ORDER BY prog_id) AS duplicatereccount 
                   FROM   (SELECT tpm.prog_id, 
                                  ts.tv_station_id, 
                                  tt.prog_source_type ,
								  tt.ethnic_group_id
                           FROM   TempTranslation TT 
                                  INNER JOIN tms_tv_prog_mst TPM 
                                          ON tt.prog_name = tpm.prog_desc 
                                  INNER JOIN tms_tv_station TS 
                                          ON ts.tv_station_name = 
                                             tt.prog_tms_channel) duplicatecheck 
                  ) 
          -- Inserting only non duplicate records and records which are not present in TMS_TV_PROGS table    
          INSERT INTO tms_tv_progs( PROG_ID,PROG_TV_STATION_ID,PROG_ING_TYPE_ID,PROG_ETHNIC_GROUP_ID,CREATE_DT)
          SELECT prog_id, 
                 tv_station_id, 
                 @IngestionTypeID, 
                 @EthnicID, 
				 GETDATE() 
          FROM   (SELECT prog_id, 
                         tv_station_id
                  FROM   tempprogramstationmapping 
                  WHERE  duplicatereccount = 1 
                  EXCEPT 
                  SELECT prog_id, 
                         prog_tv_station_id
                  FROM   tms_tv_progs) NewStationPrograms 

 SELECT TTP.SEQID,
		TPM.prog_id, 
        TT.PROG_TMS_CHANNEL,
		TT.PROG_NAME
INTO   #tempPrograms
FROM   TEMPTRANSLATION TT 
        INNER JOIN TMS_TV_STATION TS 
                ON TS.TV_STATION_NAME = TT.SOURCE 
		INNER JOIN TMS_TV_PROG_MST TPM 
                ON TT.PROG_NAME = TPM.PROG_DESC  
		INNER JOIN TMS_TV_PROGS TTP 
				ON TTP.PROG_TV_STATION_ID=TS.TV_STATION_ID AND 
					TTP.PROG_ID=TPM.PROG_ID

--Updating SEQId and Prog_Id from Temp Program and Source Mapping table
update TempTranslation
set [SeqID]=tp.SEQID,[ProgID]=tp.PROG_ID
from TempTranslation TT
LEFT JOIN #TEMPPROGRAMS TP 
		ON TT.PROG_NAME=TP.PROG_NAME AND 
			TT.PROG_TMS_CHANNEL=TP.PROG_TMS_CHANNEL

drop table  #TEMPPROGRAMS

		  COMMIT TRANSACTION 
		
      END try 

      BEGIN catch 
          DECLARE @error   INT, 
                  @message VARCHAR(4000), 
                  @lineNo  INT 

          SELECT @error = ERROR_NUMBER(), 
                 @message = ERROR_MESSAGE(), 
                 @lineNo = ERROR_LINE() 

          RAISERROR ('usp_TMS_07_ProgramMapping: %d: %s',16,1,@error,@message, 
                     @lineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
