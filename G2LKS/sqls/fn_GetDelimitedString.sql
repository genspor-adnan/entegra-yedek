ALTER FUNCTION dbo.fn_GetDelimitedString(@source varchar(255),@index int)
RETURNS varchar(255) AS 
BEGIN
  DECLARE @i int
  DECLARE @comma_position int
  DECLARE @prev_position int
  DECLARE @result varchar(255)
  if (LEN(@source) > 0)
    begin
      SET @i = 0
      SET @comma_position = 1
      while @i < @index
        begin
          SET @prev_position = @comma_position
          SET @comma_position = CHARINDEX(';',@source,@comma_position) + 1
          SET @i = @i + 1  
          if (@i = @index)
            begin
              if ((@prev_position > 1) AND (@comma_position = 1) )
                begin
                  SET @result = SUBSTRING(@source,@prev_position,(LEN(@source) - @prev_position) + 1)
                end
              else
                begin
                  SET @result = SUBSTRING(@source,@prev_position,@comma_position - @prev_position - 1 )
                end
            end
        end
    end
  else
   SET @result = '' 
  RETURN @result
end
