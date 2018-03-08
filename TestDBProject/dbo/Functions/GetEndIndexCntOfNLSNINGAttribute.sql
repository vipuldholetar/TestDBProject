
CREATE function GetEndIndexCntOfNLSNINGAttribute(@FileType varchar(50),@FieldName varchar(50))
returns int
as
begin
return (select (EndPosition-startposition+1) from NLSNPositionLookup where FileType=@FileType and FieldName=@FieldName);
end
