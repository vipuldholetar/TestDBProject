
-- =============================================      
-- Author:    Govardhan.R      
-- Create date: 04/06/2015      
-- Description:  Process RCS Raw Data use case      
-- Query : exec sp_GetRCSRawDataUseCase '340868146','A340863033'     
CREATE PROCEDURE [sp_RCSGetRawDataUseCase] (@AcId BIGINT, 
                                              @CreativeId  VARCHAR(255)) 
AS 
  BEGIN 
      DECLARE @RCSCreativesCnt INT 
      DECLARE @RCSAcId BIGINT 

      SELECT @RCSCreativesCnt = Count(*) 
      FROM   RCSCreative
      WHERE  
        [RCSCreativeID] = @CreativeId 
  
      SELECT @RCSAcId = Count(*) 
      FROM   RCSAcIdToRCSCreativeIdMap 
      WHERE  [RCSAcIdToRCSCreativeIdMapID] = @AcId 

     
      IF( @RCSAcId = 0 
          AND @RCSCreativesCnt = 0 ) 
        BEGIN 
            SELECT 'NN'[RCSUseCase] 
        END 

      IF( @RCSAcId = 0 
          AND @RCSCreativesCnt >= 1 ) 
        BEGIN 
            SELECT 'NE'[RCSUseCase] 
        END 

      IF( @RCSAcId >= 1 
          AND @RCSCreativesCnt = 0 ) 
        BEGIN 
            SELECT 'EN'[RCSUseCase] 
        END 

      IF( @RCSAcId >= 1 
          AND @RCSCreativesCnt >= 1 ) 
        BEGIN 
            SELECT 'EE'[RCSUseCase] 
        END 
  END