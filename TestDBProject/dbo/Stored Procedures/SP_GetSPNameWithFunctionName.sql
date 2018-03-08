CREATE procedure  SP_GetSPNameWithFunctionName 
(@FunctionName varchar(50))
As
Begin
select Routine_Name as SPname
from Information_Schema.Routines
where Routine_Definition = @FunctionName
and Routine_Type = 'Procedure'
End
