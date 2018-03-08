﻿Create proc ViewNielsonCommercialSyndicationData
as
begin
SELECT 
SUBSTRING(VALUE,15,6)[ACN Network Code],
SUBSTRING(VALUE,21,10)[ACN Program Code],
SUBSTRING(VALUE,44,7)[Air Date],
SUBSTRING(VALUE,58,10)[Telecast Number],
SUBSTRING(VALUE,86,4)[Start Time],
SUBSTRING(VALUE,278,4)[End Time],
SUBSTRING(VALUE,337,9)[Households]
FROM [CommercialSyndicationData]
WHERE SUBSTRING(VALUE,11,1)=0
AND SUBSTRING(VALUE,85,1)='C'
AND SUBSTRING(VALUE,97,2)='A'
AND SUBSTRING(VALUE,1,2)='06'

SELECT 
SUBSTRING(VALUE,15,6)[ACN Network Code],
SUBSTRING(VALUE,21,10)[ACN Program Code],
SUBSTRING(VALUE,44,7)[Air Date],
SUBSTRING(VALUE,58,10)[Telecast Number],
SUBSTRING(VALUE,86,4)[Start Time],
SUBSTRING(VALUE,278,4)[End Time]
FROM [CommercialCableData]
WHERE  SUBSTRING(VALUE,11,1)=0
AND SUBSTRING(VALUE,85,1)='P'
AND SUBSTRING(VALUE,97,2)='A'
AND SUBSTRING(VALUE,1,2)='06'

end