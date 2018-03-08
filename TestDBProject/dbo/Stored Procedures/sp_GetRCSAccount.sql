/****** Object:  StoredProcedure [dbo].[sp_GetRCSAccount]    Script Date: 5/13/2016 2:09:24 PM ******/
CREATE PROCEDURE [dbo].[sp_GetRCSAccount] (
	@UserInput varchar(max)
)
AS
BEGIN
	SELECT 
		a.RCSAcctID,
		rcsa.Name AS AcctName,
		adv.Name AS AdvName,
		a.[Priority] AS Priority,
		rcsa.CreatedDT AS CreatedDT,
		b.Name AS ClassName,
		c.RCSMarket AS RCSMarket,
		COUNT(d.PatternStgID) AS PatternStgID,
		MAX(d.CreatedDT) AS PtrnCreatedDT,
		MAX(d.ModifiedDT) AS ModifiedDT,
		d.ModifiedByID AS ModifiedByID,
		MAX(c.cdt2)
	FROM 
		(SELECT RCSAcctID, RCSAdvID, RCSClassID, Priority, MAX(CreatedDT) as maxDT, MAX(RCSCreativeID) AS RCSCreativeID  FROM RCSCreative
			GROUP BY RCSAcctID, RCSAdvID, RCSClassID, Priority) AS a 
	
	INNER JOIN RCSAcct AS rcsa ON a.RCSAcctID = rcsa.RCSAcctID

	INNER JOIN RCSAdv AS adv ON a.RCSAdvID = adv.RCSAdvID
	
	INNER JOIN RCSClass AS b ON a.RCSClassID = b.RCSClassID
	
	INNER JOIN RCSACIDTORCSCREATIVEIDMAP AS acim ON a.RCSCreativeID = acim.RCSCreativeID 
		INNER JOIN (SELECT RCSAcIdID, RCSStationID, MAX(CreatedDT) AS cdt FROM OccurrenceDetailRA GROUP BY RCSAcIdID, RCSStationID) AS od ON acim.RCSAcIdToRCSCreativeIdMapID = od.RCSAcIdID
			INNER JOIN (SELECT MAX(RCSRadioStationID) AS RCSRadioStationID, RCSMarket, MAX(CreatedDT) AS cdt2 FROM RCSRadioStation GROUP BY RCSMarket) AS c ON od.RCSStationID = c.RCSRadioStationID 
	
	INNER JOIN PatternDetailRAStaging AS d ON a.RCSCreativeID = d.RCSCreativeID 
	WHERE (rcsa.Name like '%'+ @UserInput + '%')
	GROUP BY a.RCSAcctID, rcsa.Name, adv.Name, a.[Priority], rcsa.CreatedDT, b.Name, c.RCSMarket, d.ModifiedByID
	
END