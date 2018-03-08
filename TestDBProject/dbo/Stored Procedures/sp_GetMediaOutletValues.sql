
-- =============================================
-- Author:		Ashanie Cole
-- Create date:	Oct 2016
-- Description:	
-- =============================================
CREATE PROCEDURE sp_GetMediaOutletValues
    @MediaStream varchar(50)
AS
BEGIN
	select distinct ISNULL(MediaOutlet,'') AS MediaOutlet
	   from PatternStaging ps inner join Configuration c on ps.MediaStream = CAST(c.ConfigurationID as varchar(20))
    where  ComponentName = 'Media Stream' and ValueTitle = @MediaStream
    order by ISNULL(MediaOutlet,'') asc
END