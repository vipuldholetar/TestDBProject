CREATE proc  [dbo].[usp_GetAllTables]
as
select name 
from sysobjects 
where	xtype='u' and 
		name not like '%sysdiagrams%' and name not like '%TMS_USERS%' and
		name like 'TMS%' or
		name like 'TV%'
union all
select 'STATION_MAP' as name
union all
select 'ING_TYPES' as name
union all
select 'QUARTER_HOURS' as name
union all
select 'PROGRAM_MAP' as name

order by name
