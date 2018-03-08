-- exec SELECT dbo.GetString(7)  
CREATE Function  [dbo].[GetString] 

(   
    @AdID INT 
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @RESULT_STRING nvarchar(max);
    SELECT 
        @RESULT_STRING = CONVERT(nvarchar,([PrimaryOccurrenceID])) +CONVERT(nvarchar,[AdvertiserID])+
		CONVERT(nvarchar,[LanguageID]) 
        
            FROM Ad  WHERE [AdID] = @AdID
		
    RETURN @RESULT_STRING 
END
