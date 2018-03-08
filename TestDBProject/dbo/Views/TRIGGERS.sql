
create view TRIGGERS as
SELECT  TRIG.OBJECT_ID,
		TAB.name as table_name 
		, TRIG.name as trigger_name
		, TRIG.is_disabled 
		, OBJECT_DEFINITION(TRIG.OBJECT_ID) as trigger_text
FROM [sys].[triggers] as TRIG 
inner join sys.tables as TAB on TRIG.parent_id = TAB.object_id


