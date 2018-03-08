create procedure [dbo].[sp_GetConfigurationBySystemComponent]
(
	@SystemName varchar(50),
	@ComponentName varchar(50)
)
AS
BEGIN
	SELECT ConfigurationID, EffectiveDT, endDT, SystemName, ComponentName, Value, ValueTitle, ValueGroup, ValueType, Notes 
	FROM [Configuration] 
	WHERE ComponentName = @ComponentName
	AND SystemName = @SystemName
END