/****** Object:  StoredProcedure [dbo].[sp_PatternTotalScore]    Script Date: 7/13/2016 10:38:33 AM ******/
CREATE PROCEDURE [dbo].[sp_PatternTotalScore]
AS
DECLARE
@MediaWeight		INT = 1, 
@DateFactor			INT = 20

------------------UPDATE FOR RADIO SCORE------------------
UPDATE PatternStaging
		SET ScoreQ = TotalsTable.Score
		FROM
		(SELECT	(((	DATEDIFF(day, MIN(OccurrenceDetailRA.AirStartDT), getdate()) 
				  + DATEDIFF(day, Max(OccurrenceDetailRA.AirEndDT), getdate())) 
				  - (@MediaWeight * COUNT(distinct OccurrenceDetailRAID))) 
				  * @DateFactor) AS Score,
				  PatternStaging.PatternID 
				  FROM PatternStaging
			INNER JOIN OccurrenceDetailRA
				ON PatternStaging.PatternID = OccurrenceDetailRA.PatternID
				WHERE PatternStaging.ScoreQ IS NULL AND MediaStream = '145' GROUP BY PatternStaging.PatternID ) AS TotalsTable 

------------------UPDATE FOR EMAIL SCORE------------------
UPDATE PatternStaging
		SET ScoreQ = TotalsTable.Score
		FROM
		(SELECT	(((	DATEDIFF(day, MIN(OccurrenceDetailEM.DistributionDT), getdate()) 
				  + DATEDIFF(day, Max(OccurrenceDetailEM.DistributionDT), getdate())) 
				  - (@MediaWeight * COUNT(distinct OccurrenceDetailEMID))) 
				  * @DateFactor) AS Score,
				  PatternStaging.PatternID 
				  FROM PatternStaging
			INNER JOIN OccurrenceDetailEM
				ON PatternStaging.PatternID = OccurrenceDetailEM.PatternID
				WHERE PatternStaging.ScoreQ IS NULL AND MediaStream = '154' GROUP BY PatternStaging.PatternID ) AS TotalsTable