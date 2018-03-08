-- =============================================  
-- Author:    Nanjunda  
-- Create date: 11/14/2014  
-- Description:  Populates the TMS master table from the TMS_Translation table  
-- Query : exec sp_TMSStationMapping 'NT AUTHORITY\SYSTEM'  
-- =============================================  
CREATE PROCEDURE [dbo].[sp_TMSStationMapping] 
(
	@UserName        AS VARCHAR(20)
)
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN TRY 
          BEGIN TRANSACTION 
          DECLARE @UserId INT 

          -- Retreiving userID  
          SELECT @UserId = [TMSUserID] 
          FROM   [TMSUser] 
          WHERE  UserName = @Username 
   		 
		 SELECT FTT.ProgTMSChannel as ProgTMSChannel,
				FTT.ProgSrcType,
              CASE  
				   WHEN  (SELECT Mkt.[Descrip] --TSM.Dma
					  FROM   StationMapMaster SMM,[TMSTvStation] TTSM,[TVStation] TSM, [Market] Mkt
					  WHERE  SMM.[TMSStationID] = TTSM.[TMSTvStationID] and 
							 TTSM.TvStationName=FTT.ProgTMSChannel and TSM.[TVStationID]=SMM.[TVStationID]
							 and TSM.[MarketId] = Mkt.[MarketID]) ='CAB' THEN
						FTT.ProgTMSChannel
				   WHEN FTT.ProgSrcType ='N'  THEN 
				   (SELECT TN.NetworkShortName 
					  FROM   StationMapMaster SMM,[TMSTvStation] TTSM,[TVStation] TSM, [TVNetwork] TN
					  WHERE  SMM.[TMSStationID] = TTSM.[TMSTvStationID] and 
							 TTSM.TvStationName=FTT.ProgTMSChannel and TSM.[TVStationID]=SMM.[TVStationID]
							 and TN.[TVNetworkID] = TSM.[NetworkID]) 
                   WHEN FTT.ProgSrcType='S' THEN 'SYN'
                   WHEN FTT.ProgSrcType='L' THEN 'LOC'
				  END  AS MTStationName
			into #UpdateSource
          FROM   [TempTranslation] FTT

		  update [TempTranslation] 
		  set [Src]=TU.MTStationName
		  from [TempTranslation] TT
		  left join #UpdateSource TU
		  on TU.ProgTMSChannel=TT.ProgTMSChannel and 
			 TU.ProgSrcType=TT.ProgSrcType

			 drop table #UpdateSource

		  COMMIT TRANSACTION 
      END try 

      BEGIN catch 
          DECLARE @Error   INT, 
                  @Message VARCHAR(4000), 
                  @LineNo  INT 

          SELECT @Error = ERROR_NUMBER(), 
                 @Message = ERROR_MESSAGE(), 
                 @LineNo = ERROR_LINE() 

          RAISERROR ('sp_TMSStationMapping: %d: %s',16,1,@Error,@Message, 
                     @LineNo) 
          ; 

          ROLLBACK TRANSACTION 
      END catch; 
  END;