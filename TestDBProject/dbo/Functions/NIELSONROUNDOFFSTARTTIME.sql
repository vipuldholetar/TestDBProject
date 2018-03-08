﻿-- =============================================   
-- Author:    Govardhan   
-- Create date: 05/22/2015   
-- Description: fUNCTION TO ROUND OFF STARTTIME.  
-- Query :   
/*  

SELECT NIELSONROUNDOFFSTARTTIME '',  

*/ 
CREATE FUNCTION NIELSONROUNDOFFSTARTTIME(@STARTTIME VARCHAR(50))

returns VARCHAR(4)

AS

	BEGIN

	DECLARE @STARTTIMEInt AS INT,@MULTIPLIER AS INT,@REMAINDER AS INT,@STARTTIMERETURN AS VARCHAR(50);

	SET @STARTTIMEInt=SUBSTRING(@STARTTIME,3,2);

	SELECT @MULTIPLIER=@STARTTIMEInt/15;

	SELECT @REMAINDER=@STARTTIMEInt%15;

	IF(@REMAINDER<8)

	BEGIN

	     IF(@MULTIPLIER=0)

		 BEGIN

		 	select @STARTTIMERETURN=SUBSTRING(@STARTTIME,1,2)+'00';

		 END

		 ELSE 

		 BEGIN

		 	select @STARTTIMERETURN=SUBSTRING(@STARTTIME,1,2)+CONVERT(VARCHAR(2),(@MULTIPLIER*15));

		 END



	END

	ELSE 

	BEGIN

	select @STARTTIMERETURN= REPLACE(CONVERT(VARCHAR(5), (DATEADD(MINUTE,((15-@REMAINDER)),CAST(SUBSTRING(@STARTTIME, 1, 2) + ':' + SUBSTRING(@STARTTIME, 3, 2) AS DATETIME ))), 108), ':', '')

	--select @STARTTIMERETURN=SUBSTRING(@STARTTIME,1,2)+CONVERT(VARCHAR(2),((@MULTIPLIER+1)*15));

	END

	RETURN @STARTTIMERETURN;

END
