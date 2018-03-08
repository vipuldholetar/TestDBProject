
-- ============================================================================================================
-- Author                         :      Ganesh Prasad
-- Create date                    :      08/26/2015
-- Description                    :      This stored procedure is used to Getting Data for "Similar Signature Differnt Ad" Report Dataset
-- Execution Process              :      [dbo].[sp_SimilarSignatureandDifferentAd] 
-- Updated By                     :      
-- =============================================================================================================


CREATE PROCEDURE [dbo].[sp_SimilarSignatureandDifferentAd] 
AS 
  BEGIN 
      SET NOCOUNT ON; 

      BEGIN try 
          SELECT  [dbo].[TVPattern].originalprcode AS MAP_PR_MC,
		          [dbo].[TVPattern].priority  AS  MAP_PRIORITY,
				  [dbo].[OccurrenceDetailTV].[AdID] AS MTADCOD,
				  [dbo].[OccurrenceDetailTV].adlength AS MTADLEN ,
                  [dbo].[Configuration].valuetitle AS MTBADTP,
                 [dbo].[Fn_getfakeprcode]([TVPattern].originalprcode)  AS  [FAKE PR CODE]--- This is the Function we created for getting FakePrCodes when we provide oririginal PR Code as Input parameter 
          FROM   [dbo].[OccurrenceDetailTV] 
                 INNER JOIN [dbo].[TVPattern] 
                         ON [dbo].[TVPattern].[TVPatternCODE] = [dbo].[OccurrenceDetailTV].[PRCODE] 
                 INNER JOIN [dbo].[Creative] 
                         ON [dbo].[Creative].[SourceOccurrenceId] =  [dbo].[OccurrenceDetailTV].[OccurrenceDetailTVID] 
                 INNER JOIN [Configuration] 
                         ON [dbo].[Configuration].configurationid = [dbo].[Creative].primaryquality 
      END try 

      BEGIN catch 
          DECLARE @error   INT,  @message VARCHAR(4000),   @lineNo  INT 
		  SELECT @error = Error_number() ,@message = Error_message() ,@lineNo = Error_line() 
          RAISERROR ('[sp_SimilarSignatureandDifferentAd]: %d: %s',16,1,@error, @message,@lineNo); 
      END catch 

  END
