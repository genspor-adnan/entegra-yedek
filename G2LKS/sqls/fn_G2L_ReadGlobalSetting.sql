create function dbo.fn_G2L_ReadGlobalSetting(@section varchar(70),@key varchar(50))
returns varchar(100) as
begin
  declare @result varchar(100)
  select @result = ISNULL(DEGER,'') from GENOTIPINI where
   (BOLUM=@section) and (ANAHTAR = @key)
  return @result
end