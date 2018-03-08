-- =============================================     
-- Author:    Govardhan.R     
-- Create date: 04/06/2015     
-- Description:  Process RCS Raw Data use case     
-- Query : exec GetRCSRawDataUseCase '340868146','A340863033'    
CREATE PROCEDURE [GetRCSRawDataUseCase] (@AIRCHECK_ID BIGINT, 
                                       @CREATIVEID  VARCHAR(255)) 
AS 
  BEGIN 
      DECLARE @RCSCreativesCnt INT 
      DECLARE @RCSAcid BIGINT 

      SELECT @RCSCreativesCnt = Count(*) 
      FROM   rcsacidtorcscreativeidmap 
      WHERE  --rcsacidid = @AIRCHECK_ID  
        [RCSCreativeID] = @CREATIVEID 

      --AND isdeleted = 0  
      --FROM   rcscreatives  
      --WHERE  rcscreativeid = @CREATIVEID  
      --       AND isdeleted = 0  
      SELECT @RCSAcid = Count(*) 
      FROM   rcsacidtorcscreativeidmap 
      WHERE  RCSAcIdToRCSCreativeIdMapID = @AIRCHECK_ID 

      --AND rcscreativeid = @CREATIVEID  
      -- AND isdeleted = 0  
      --   print(@RCSCreativesCnt); 
      --print(@RCSAcid); 
      IF( @RCSAcid = 0 
          AND @RCSCreativesCnt = 0 ) 
        BEGIN 
            SELECT 'NN'[RcsUseCase] 
        END 

      IF( @RCSAcid = 0 
          AND @RCSCreativesCnt >= 1 ) 
        BEGIN 
            SELECT 'NE'[RcsUseCase] 
        END 

      IF( @RCSAcid >= 1 
          AND @RCSCreativesCnt = 0 ) 
        BEGIN 
            SELECT 'EN'[RcsUseCase] 
        END 

      IF( @RCSAcid >= 1 
          AND @RCSCreativesCnt >= 1 ) 
        BEGIN 
            SELECT 'EE'[RcsUseCase] 
        END 
  END
