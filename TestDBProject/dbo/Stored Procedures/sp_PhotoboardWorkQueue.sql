﻿create procedure [dbo].[sp_PhotoboardWorkQueue]
as
--begin
--select b.Priority as Priority,
--	a.FK_AdID as AdID,
--	c.AdvertiserName as Advertiser,
--	b.CreateDTM,
--	a.StartedDTM,
--	concatenate(d.FName,' ',d.Lname) as AssignedTo,
--	case when Status = 'R' then 'Y' --R = Replace
--	else 'N' end as Replace,
--	a.PK_PhotoboardID as KeyID,
--	a.MediaStream,
--	b.FK_AdvertiserID as AdvertiserID,
--	b.LeadText,
--	b.Length,
--	case when b.OriginalAdID = NULL then 'New'
--	else 'Recut' end as NewRecut,
--	b.FirstRunDate,
--	e.ProductName
--from Photoboard a, Ad b, Advertiser c, [User] d, Product e
--where b.PK_AdID = a.FK_AdID
--AND c.PK_AdvertiserID = b.FK_AdvertiserID
--AND d.PK_UserID = a.AssignedTo
--AND e.PK_ProductID = b.FK_ProductID
--AND a.Status NOT IN ('F', 'X') --'F'-Finished, 'X'-Remove
--AND a.IsDeleted = 0
--end