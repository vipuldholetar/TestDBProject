




CREATE VIEW [dbo].[vw_OccurrenceDetailPrint]
AS
SELECT 'PUB' as mediastream, OccurrenceDetailPUBID AS OccurrenceDetailId,AdID,PatternID,CreatedDT
FROM            dbo.OccurrenceDetailPUB

UNION

SELECT 'CIR' as mediastream, OccurrenceDetailCIRID AS OccurrenceDetailId,AdID,PatternID,CreatedDT
FROM            dbo.OccurrenceDetailCIR