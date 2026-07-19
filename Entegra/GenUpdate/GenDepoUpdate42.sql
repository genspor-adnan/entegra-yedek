set nocount on;

declare @UserTablolar table(UserTablo sysname not null primary key);

insert into @UserTablolar(UserTablo) values
('FATURA_USER'),
('FATBASLIK_USER'),
('STOKLAR_USER'),
('REHBER_USER'),
('DEMIRBAS_USER'),
('SERVIS_USER'),
('SERVISHAREKET_USER'),
('SIPARIS_USER'),
('TEKLIF_USER'),
('DOKUMAN_USER'),
('URETIMEMRI_USER'),
('URETIMOPERASYONPERSONEL_USER');

delete U
from @UserTablolar U
where object_id('dbo.' + U.UserTablo, 'U') is null;

declare @Sonuc table(
  UserTablo sysname not null,
  Silinen int not null
);

declare @UserTablo sysname;
declare @BosKosul nvarchar(max);
declare @sql nvarchar(max);
declare @Silinen int;

declare cur cursor local fast_forward for
select UserTablo
from @UserTablolar
order by UserTablo;

open cur;
fetch next from cur into @UserTablo;

while @@fetch_status = 0
begin
  select @BosKosul = stuff((
    select ' and ' +
      case
        when T.name in ('varchar','char','nvarchar','nchar','text','ntext','xml') then
          'nullif(ltrim(rtrim(convert(nvarchar(max),U.' + quotename(C.name) + '))),N'''') is null'
        else
          'U.' + quotename(C.name) + ' is null'
      end
    from sys.columns C
    inner join sys.types T on T.user_type_id = C.user_type_id
    where C.object_id = object_id('dbo.' + @UserTablo)
      and C.name not in ('ID','EKLEYEN','EKLEMETARIHI','DEGISTIREN','DEGISTIRMETARIHI')
    order by C.column_id
    for xml path(''), type).value('.','nvarchar(max)'), 1, 5, '');

  if isnull(@BosKosul, '') = ''
    set @BosKosul = N'1=1';

  set @sql = N'
delete U
from dbo.' + quotename(@UserTablo) + N' U
where ' + @BosKosul + N';
set @Silinen = @@rowcount;';

  set @Silinen = 0;
  exec sp_executesql @sql, N'@Silinen int output', @Silinen output;

  insert into @Sonuc(UserTablo, Silinen)
  values(@UserTablo, @Silinen);

  fetch next from cur into @UserTablo;
end;

close cur;
deallocate cur;

select UserTablo, Silinen
from @Sonuc
where Silinen > 0
order by UserTablo;
