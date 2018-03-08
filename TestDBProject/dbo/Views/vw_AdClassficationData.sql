
-- ==============================================================================================
-- Author			:	Govardhan.R on 10/01/2015
-- Description		:	This view RETURNS THE DATA
-- ==============================================================================================
CREATE VIEW [dbo].[vw_AdClassficationData]
AS
SELECT A.[AdID],CM.VALUE[MediaStream],
CASE WHEN PM.[PatternID]>=2000 AND PM.[PatternID]<3000 THEN 2
     WHEN PM.[PatternID]>=3000 AND PM.[PatternID]<4000 THEN 3
     WHEN PM.[PatternID]>=4000 AND PM.[PatternID]<5000 THEN 4
	 WHEN PM.[PatternID]>=5000 AND PM.[PatternID]<6000 THEN 5
	 WHEN PM.[PatternID]>=6000 AND PM.[PatternID]<7000 THEN 6
	 WHEN PM.[PatternID]>=7000 AND PM.[PatternID]<8000 THEN 7
	 WHEN PM.[PatternID]>=8000 AND PM.[PatternID]<9000 THEN 8
END [Priority]
FROM [Pattern] PM
INNER JOIN AD A ON PM.[AdID]=A.[AdID]
INNER JOIN [Configuration] CM ON CM.CONFIGURATIONID=PM.MediaStream
WHERE PM.[Query]!=1
AND a.CLASSIFIEDBY is NULL
AND A.NOTAKEADREASON is NULL
