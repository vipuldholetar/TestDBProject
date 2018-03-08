CREATE PROCEDURE  [dbo].[sp_GetAllTables]
as
select name 
from sysobjects 
where	xtype='u' and 
		Name not like '%sysdiagrams%' and Name not like '%TMSUsers%' and
		Name like 'TMS%' or
		Name like 'TV%'
union all
select 'StationMapMaster' as Name
union all
select 'IngestionTypesMaster' as Name
union all
select 'QuarterHoursMaster' as Name
union all
select 'ProgramMapMaster' as Name

order by Name
