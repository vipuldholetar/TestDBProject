CREATE VIEW INDEXES AS
SELECT  TABLE_NAME = OBJECT_NAME(i.id), INDEX_NAME = i.name, 
COLUMN_LIST = dbo.GetIndexColumns(OBJECT_NAME(i.id), i.id, i.indid), 
IS_CLUSTERED = INDEXPROPERTY(i.id, i.name, 'IsClustered'), 
IS_UNIQUE = INDEXPROPERTY(i.id, i.name, 'IsUnique'), 
FILE_GROUP = g.GroupName 
FROM sysindexes i 
INNER JOIN sysfilegroups g ON i.groupid = g.groupid 
WHERE (i.indid BETWEEN 1 AND 254) 
-- leave out JAADLERT2_STATISTICS: 
AND (i.Status & 64)=0 
-- leave out system tables: 
AND OBJECTPROPERTY(i.id, 'IsMsShipped') = 0 
