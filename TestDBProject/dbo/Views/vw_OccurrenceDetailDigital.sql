




CREATE VIEW [dbo].[vw_OccurrenceDetailDigital]
AS
SELECT 'OND' AS mediastream, OccurrenceDetailONDID AS OccurrenceDetailId, CreativeSignature,AdID,PatternID,CreatedDT
FROM            dbo.OccurrenceDetailOND

UNION

SELECT 'MOB' AS mediastream, OccurrenceDetailMOBID AS OccurrenceDetailId, CreativeSignature,AdID,PatternID,CreatedDT
FROM            dbo.OccurrenceDetailMOB