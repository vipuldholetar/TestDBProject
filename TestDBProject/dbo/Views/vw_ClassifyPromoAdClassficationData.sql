
-- ==============================================================================================



-- Author			:	Govardhan.R on 10/01/2015



-- Description		:	This view RETURNS THE DATA



-- ==============================================================================================



CREATE VIEW [dbo].[vw_ClassifyPromoAdClassficationData]
AS
SELECT 
	DATA.MEDIASTREAM,
	DATA.MEDIASTREAMID,
	DATA.[AdID],
	MIN(Priority)[Priority] 
FROM (
	SELECT distinct 
		A.[AdID],
		CM.VALUETITLE[MediaStream],
		CM.VALUE[MediaStreamID],
		0 as [Priority]
		--CASE WHEN PM.[PatternID]>=2000 AND PM.[PatternID]<3000 THEN 2
		--	 WHEN PM.[PatternID]>=3000 AND PM.[PatternID]<4000 THEN 3
		--	 WHEN PM.[PatternID]>=4000 AND PM.[PatternID]<5000 THEN 4
		--	 WHEN PM.[PatternID]>=5000 AND PM.[PatternID]<6000 THEN 5
		--	 WHEN PM.[PatternID]>=6000 AND PM.[PatternID]<7000 THEN 6
		--	 WHEN PM.[PatternID]>=7000 AND PM.[PatternID]<8000 THEN 7
		--	 WHEN PM.[PatternID]>=8000 AND PM.[PatternID]<9000 THEN 8
		--	 WHEN PM.[PatternID]>=9000 AND PM.[PatternID]<10000 THEN 9
		--	 WHEN PM.[PatternID]>=10000 AND PM.[PatternID]<11000 THEN 10
		--	 WHEN PM.[PatternID]>=11000 AND PM.[PatternID]<12000 THEN 11
		--	 WHEN PM.[PatternID]>=12000 AND PM.[PatternID]<13000 THEN 12
		--	 WHEN PM.[PatternID]>=13000 AND PM.[PatternID]<14000 THEN 13
		--	 WHEN PM.[PatternID]>=14000 AND PM.[PatternID]<15000 THEN 14
		--	 WHEN PM.[PatternID]>=15000 AND PM.[PatternID]<16000 THEN 14
		--	 WHEN PM.[PatternID]>=16000 AND PM.[PatternID]<17000 THEN 14
		--	 WHEN PM.[PatternID]>=17000 AND PM.[PatternID]<18000 THEN 14
		--	 WHEN PM.[PatternID]>=18000 AND PM.[PatternID]<19000 THEN 14
		--	 WHEN PM.[PatternID]>=19000 AND PM.[PatternID]<20000 THEN 14
		--	 WHEN PM.[PatternID]>=20000 AND PM.[PatternID]<21000 THEN 14
		--	 WHEN PM.[PatternID]>=21000 AND PM.[PatternID]<30000 THEN 14
		--END [Priority]
	FROM [Pattern] PM
	INNER JOIN AD A ON PM.[AdID]=A.[AdID]
	INNER JOIN [Configuration] CM ON CM.CONFIGURATIONID=PM.MediaStream
	WHERE (PM.[Query]!=1 OR PM.[Query] IS NULL)
	AND a.CLASSIFIEDBY is NULL
	AND (A.NOTAKEADREASON is NULL or A.NOTAKEADREASON=0)
) DATA 
GROUP BY 
	DATA.MEDIASTREAM,
	DATA.MEDIASTREAMID,
	DATA.[AdID]