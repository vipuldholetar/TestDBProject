
CREATE function GetStartIndexOfNLSNINGAttribute(@FileType varchar(50),@FieldName varchar(50))
returns int
as
begin
return (select startposition from NLSNPositionLookup where FileType=@FileType and FieldName=@FieldName);
end
