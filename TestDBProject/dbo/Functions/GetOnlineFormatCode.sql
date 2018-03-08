create function [dbo].[GetOnlineFormatCode] (@horz int, @vert int) returns varchar(10)
as
begin
  declare @formatCode as varchar(10);
  declare @area as int;

  SELECT @formatCode = [OnlineFormatCODE]
  FROM [OnlineFormat]
  WHERE HorizontalSize = @horz 
  AND VerticalSize = @vert;

  if isnull(@formatCode,'0') = '0'
  begin
    SELECT @formatCode = [OnlineFormatCODE]
    FROM [OnlineFormat]
     WHERE (HorizontalSize = @horz  AND ABS(VerticalSize - @vert) < 25) 
            OR (VerticalSize = @vert AND ABS(HorizontalSize - @horz) < 25);

	 if isnull(@formatCode,'0') = '0'
	 begin
	   set @area = isnull(@horz,0) * isnull(@vert,0);
	   set @formatCode = (case when @area >= 125000 
                                            then 'CUSTL'
                                       when @area between 1 and 9999  
                                            then 'CUSTT'
                                       when @area between 10000 and 49999
                                            then 'CUSTS'
                                       else 'CUST'
                                  end);
	 end
  end

  return @formatcode;
end
