

-- =============================================================================



-- Author		: Govardhan.R



-- Create date	: 12/21/2015



-- Description	: Gets the data from View to display in Query Form



-- Updated By	: 



-- Execution	: SP_CPGetQueryData '144,145,146,147,148,149,150,151,152,153,154,155,156','01/01/15','12/31/15','1'







CREATE PROC [dbo].[SP_CPGetQueryData]



(



@MediaStream varchar(250),



@RaisedOnFromm varchar(50),



@RaisedOnTo varchar(50),



@IncludeAnsweredQuery int



)



as



BEGIN







SELECT CM.VALUETITLE[MEDIASTREAM],VW.MEDIASTREAM[MEDIASTREAMID],VW.RECORDID,VW.QUERYCATEGORY,VW.QUERYCATEGORYID,VW.QUESTION,
(SELECT FNAME+' '+LName from [USER] where UserID=(case when VW.RAISEDBY=1 then 29712038 else VW.RAISEDBY end )) [RAISEDBY]
,



VW.RAISEDON,VW.ANSWER,
(SELECT FNAME+' '+LName from [USER] where UserID=(case when VW.ANSWEREDBY=1 then 29712039 else VW.ANSWEREDBY end ))[ANSWEREDBY],VW.ANSWEREDON,



--CASE WHEN VW.ANSWEREDON IS NULL THEN (GETDATE()-VW.RAISEDON)



--     ELSE (ANSWEREDON-RAISEDON)



--END ,



''[AGE],VW.KeyIDMode,vw.KEYID,vw.QueryId,vw.Category,vw.CategoryID



FROM 



VW_QueryQueueCP VW 



INNER JOIN [Configuration] CM ON CM.ConfigurationID=VW.MEDIASTREAM



WHERE VW.MEDIASTREAM IN (SELECT Item FROM dbo.SplitString(@MediaStream, ','))



AND  VW.RAISEDON>= CONVERT(VARCHAR, @RaisedOnFromm, 110) AND VW.RAISEDON <= CONVERT(VARCHAR,dateadd(day,1,@RaisedOnTo), 110) 
--AND (CONVERT(VARCHAR,VW.RAISEDON, 1)>= CONVERT(VARCHAR, @RaisedOnFromm, 101) AND  CONVERT(VARCHAR,VW.RAISEDON, 1) <= CONVERT(VARCHAR, @RaisedOnTo, 101))



AND ISNULL(VW.ANSWER,'xxx')= (CASE WHEN @IncludeAnsweredQuery=1 THEN ISNULL(VW.ANSWER,'xxx') ELSE 'xxx' END )



AND ISNULL(VW.[Query],9) = (CASE WHEN @IncludeAnsweredQuery=1 THEN ISNULL(VW.[Query],9) ELSE 1 END )



AND CM.COMPONENTNAME='Media Stream' and SystemName='All'



END
