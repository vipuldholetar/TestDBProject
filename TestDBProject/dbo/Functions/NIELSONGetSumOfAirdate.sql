﻿
-- =============================================   
-- Author:    Govardhan   
-- Create date: 05/22/2015   
-- Description:Get Sum Of Airdate bits.  
-- Query :   
/*  

SELECT NIELSONGetSumOfAirdate '',  

*/ 

CREATE FUNCTION NIELSONGetSumOfAirdate(@AIRDATE VARCHAR(50))
returns INT
AS
BEGIN
RETURN (
SELECT (
CONVERT(INT,SUBSTRING(@AIRDATE,1,1))	+CONVERT(INT,SUBSTRING(@AIRDATE,2,1))	
+CONVERT(INT,SUBSTRING(@AIRDATE,3,1))+CONVERT(INT,SUBSTRING(@AIRDATE,4,1))	
+CONVERT(INT,SUBSTRING(@AIRDATE,5,1))+CONVERT(INT,SUBSTRING(@AIRDATE,6,1))	
+CONVERT(INT,SUBSTRING(@AIRDATE,7,1))	
));
END
