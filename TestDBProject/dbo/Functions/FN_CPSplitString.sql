-- =============================================
-- Author:		Monika. J
-- Create date: 05/10/2015
-- Description:	Function will split the comma seperated string value
-- =============================================
CREATE FUNCTION  [dbo].[FN_CPSplitString] 
(	
	-- Add the parameters for the function here
	@Input NVARCHAR(MAX)
)
RETURNS @Output TABLE (     
      Item NVARCHAR(1000)
)
AS
BEGIN	
	Declare @products varchar(200) = @Input
	Declare @individual varchar(200) = null
	WHILE LEN(@products) > 0
	BEGIN
		IF PATINDEX('%,%',@products) > 0
			BEGIN
				SET @individual = SUBSTRING(@products, 0, PATINDEX('%,%',@products))
				INSERT INTO @Output (Item)	
				SELECT @individual 
				SET @products = SUBSTRING(@products, LEN(@individual + ',') + 1,
															 LEN(@products))
			END
		ELSE
			BEGIN
				SET @individual = @products
				SET @products = NULL
				INSERT INTO @Output (Item)
				SELECT @individual 
			END	
	END
	RETURN 
END