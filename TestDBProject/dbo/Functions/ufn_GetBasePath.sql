CREATE FUNCTION ufn_GetBasePath ()
RETURNS Varchar(200)
AS
	BEGIN			
		DECLARE @BasePath varchar(200)
		SET @BasePath =(SELECT Value from [Configuration] where Componentname='Creative Repository' and Systemname='All')+'\' 		
		RETURN @BasePath
	END
