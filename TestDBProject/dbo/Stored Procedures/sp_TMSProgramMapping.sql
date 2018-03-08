-- =============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Populates the TMS master table from the TempTranslation table  
-- Query : exec sp_TMSProgramMapping 1,'NT AUTHORITY\SYSTEM',1   
-- =============================================  
CREATE PROCEDURE [dbo].[sp_TMSProgramMapping] 
(
	@EthnicId        AS INT, 
	@UserName        AS VARCHAR(20), 
	@IngestionTypeID AS INT 
)
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 
          DECLARE @UserId INT 
		  SELECT @UserId = [TMSUserID] 
          FROM   [TMSUser] 
          WHERE  UserName = @UserName 
        -- Inserting records to TMS Program Master     
			select distinct ProgName into #DistNewTVProgs from TempTranslation 
			except
			SELECT tpm.ProgDescrip FROM  
			 [TMSTvProg] tpm 
			 
			 INSERT INTO [TMSTvProg] 
			 Select ProgName,
					GETDATE(),
					@UserId,
					GETDATE(),
					@UserId
			 from 
					#DistNewTvProgs
			 
			 Drop table #DistNewTvProgs;

			  --  Selecting non duplicate programs and stations from translation table and inserting into tms_tv_progs    
          WITH TempProgramStationMapping ( ProgId, TvStationId, 
               ProgSrcType,
			   Ethi, 
               DuplicateRecCount ) 
               AS (SELECT [TMSTvProgID], 
                          TvStationId, 
                          ProgSrcType, 
						  [EthnicGrpID],
                          ROW_NUMBER() 
                            OVER( 
                              PARTITION BY [TMSTvProgID], TvStationId, 
                            ProgSrcType ,[EthnicGrpID]
                              ORDER BY [TMSTvProgID]) AS DuplicateRecCount 
                   FROM   (SELECT tpm.[TMSTvProgID], 
                                  TS.[TMSTvStationID] AS TvStationId, 
                                  TT.ProgSrcType ,
								  TT.[EthnicGrpID]
                           FROM   TempTranslation TT 
                                  INNER JOIN [TMSTvProg] TPM 
                                          ON TT.ProgName = tpm.ProgDescrip
                                  INNER JOIN [TMSTvStation] TS 
                                          ON TS.TvStationName = 
                                             TT.ProgTMSChannel) DuplicateCheck 
                  ) 



          -- Inserting only non duplicate records and records which are not present in TMS_TV_PROGS table    
          INSERT INTO [TMSTvProgs]( [ProgID],[ProgTvStationID],[ProgIngestionTypeID],[ProgEthnicGrpID],[CreatedDT])
          SELECT ProgId, 
                 TvStationId, 
                 @IngestionTypeID, 
                 @EthnicId, 
				 GETDATE() 
          FROM   (SELECT ProgId, 
                         TvStationId
                  FROM   TempProgramStationMapping 
                  WHERE  DuplicateRecCount = 1 
                  EXCEPT 
                  SELECT [ProgID], 
                         [ProgTvStationID]
                  FROM   [TMSTvProgs]) NewStationPrograms 

 SELECT TTP.[TMSTvProgsID],
		TPM.[TMSTvProgID], 
        TT.ProgTMSChannel,
		TT.ProgName
INTO   #TempPrograms
FROM   TempTranslation TT 
        INNER JOIN [TMSTvStation] TS 
                ON TS.TvStationName = TT.[Src] 
		INNER JOIN [TMSTvProg] TPM 
                ON TT.ProgName = TPM.ProgDescrip  
		INNER JOIN [TMSTvProgs] TTP 
				ON TTP.[ProgTvStationID]=TS.[TMSTvStationID] AND 
					TTP.[ProgID]=TPM.[TMSTvProgID]

--Updating SEQId and Prog_Id from Temp Program and Source Mapping table
update TempTranslation
set [SeqID]=TP.[TMSTvProgsID],[ProgID]=TP.[TMSTvProgID]
from TempTranslation TT
LEFT JOIN #TempPrograms TP 
		ON TT.ProgName=TP.ProgName AND 
			TT.ProgTMSChannel=TP.ProgTMSChannel

drop table  #TempPrograms

		  COMMIT TRANSACTION 
		
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = ERROR_NUMBER(), 
                 @Message = ERROR_MESSAGE(), 
                 @LineNo = ERROR_LINE() 

          RAISERROR ('sp_TMSProgramMapping: %d: %s',16,1,@Error,@Message, 
                     @LineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END catch; 
  END;
