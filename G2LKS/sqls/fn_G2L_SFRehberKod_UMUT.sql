-- select dbo.fn_G2L_SFRehberKod('619328',[1|2])
/*
  dbo.fn_G2L_SFRehberKod('619328',[1|2])
  @type parametresi kuruma ait diðer bilgilerin alýnmasý için
  
*/

alter function [dbo].[fn_G2L_SFRehberKod](@referansKod varchar(50), @type int)
returns varchar(20)
as
begin
  declare @result varchar(30)
  select
    @result = (case @type when 1 then MUHKODU when 2 then KOD else KOD end )        
  from
	REHBER
  where 
	KOD = @referansKod
  return (@result)
end










