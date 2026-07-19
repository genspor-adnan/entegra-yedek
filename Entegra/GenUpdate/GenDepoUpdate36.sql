declare @TabloMap table(
  KaynakTablo sysname not null,
  UserTablo sysname not null,
  primary key(KaynakTablo, UserTablo)
);

insert into @TabloMap(KaynakTablo, UserTablo) values
('REHBER', 'REHBER_USER'),
('DEMIRBAS', 'DEMIRBAS_USER'),
('SERVIS', 'SERVIS_USER'),
('SERVISHAREKET', 'SERVISHAREKET_USER'),
('SIPARIS', 'SIPARIS_USER'),
('TEKLIF', 'TEKLIF_USER'),
('DOKUMAN', 'DOKUMAN_USER'),
('FATBASLIK', 'FATBASLIK_USER'),
('URETIMEMRI', 'URETIMEMRI_USER'),
('URETIMOPERASYONPERSONEL', 'URETIMOPERASYONPERSONEL_USER'),
('STOK', 'STOKLAR_USER'),
('STOKLAR', 'STOKLAR_USER');

delete M
from @TabloMap M
where object_id('dbo.' + M.KaynakTablo, 'U') is null
   or object_id('dbo.' + M.UserTablo, 'U') is null;

declare @Alanlar table(
  KaynakTablo sysname not null,
  UserTablo sysname not null,
  AlanAdi sysname not null,
  primary key(KaynakTablo, UserTablo, AlanAdi)
);

insert into @Alanlar(KaynakTablo, UserTablo, AlanAdi)
select distinct
  M.KaynakTablo,
  M.UserTablo,
  A.ALANADI
from dbo.ALANLAR A
inner join @TabloMap M on M.KaynakTablo = A.TABLO
where isnull(A.ALANADI, '') <> ''
  and isnull(A.TUR, 0) not in (11, 12)
  and col_length('dbo.' + M.KaynakTablo, A.ALANADI) is not null;

declare @sql nvarchar(max) = N'';

select @sql = @sql + N'
if col_length(''dbo.' + X.UserTablo + N''', ''' + X.AlanAdi + N''') is null
  alter table dbo.' + quotename(X.UserTablo) + N' add ' + quotename(X.AlanAdi) + N' ' +
  case
    when T.name in ('varchar','char','varbinary','binary') then T.name + '(' + case when C.max_length = -1 then 'max' else convert(varchar(10), C.max_length) end + ')'
    when T.name in ('nvarchar','nchar') then T.name + '(' + case when C.max_length = -1 then 'max' else convert(varchar(10), C.max_length / 2) end + ')'
    when T.name in ('decimal','numeric') then T.name + '(' + convert(varchar(10), C.precision) + ',' + convert(varchar(10), C.scale) + ')'
    when T.name in ('datetime2','datetimeoffset','time') then T.name + '(' + convert(varchar(10), C.scale) + ')'
    else T.name
  end + N' null;'
from @Alanlar X
inner join sys.columns C on C.object_id = object_id('dbo.' + X.KaynakTablo) and C.name = X.AlanAdi
inner join sys.types T on T.user_type_id = C.user_type_id;

exec sp_executesql @sql;

declare @KaynakTablo sysname;
declare @UserTablo sysname;
declare @Kolonlar nvarchar(max);
declare @Secim nvarchar(max);
declare @Setler nvarchar(max);
declare @BosDegilKosul nvarchar(max);
declare @BosKosul nvarchar(max);

declare cur cursor local fast_forward for
select distinct KaynakTablo, UserTablo
from @Alanlar;

open cur;
fetch next from cur into @KaynakTablo, @UserTablo;

while @@fetch_status = 0
begin
  select
    @Kolonlar = stuff((
      select ',' + quotename(A.AlanAdi)
      from @Alanlar A
      where A.KaynakTablo = @KaynakTablo
        and A.UserTablo = @UserTablo
        and col_length('dbo.' + @UserTablo, A.AlanAdi) is not null
      order by A.AlanAdi
      for xml path(''), type).value('.','nvarchar(max)'), 1, 1, ''),
    @Secim = stuff((
      select ',K.' + quotename(A.AlanAdi)
      from @Alanlar A
      where A.KaynakTablo = @KaynakTablo
        and A.UserTablo = @UserTablo
        and col_length('dbo.' + @UserTablo, A.AlanAdi) is not null
      order by A.AlanAdi
      for xml path(''), type).value('.','nvarchar(max)'), 1, 1, ''),
    @Setler = stuff((
      select ',U.' + quotename(A.AlanAdi) + '=K.' + quotename(A.AlanAdi)
      from @Alanlar A
      where A.KaynakTablo = @KaynakTablo
        and A.UserTablo = @UserTablo
        and col_length('dbo.' + @UserTablo, A.AlanAdi) is not null
      order by A.AlanAdi
      for xml path(''), type).value('.','nvarchar(max)'), 1, 1, ''),
    @BosDegilKosul = stuff((
      select ' or ' +
        case
          when T.name in ('varchar','char','nvarchar','nchar','text','ntext') then
            'nullif(ltrim(rtrim(convert(nvarchar(max),K.' + quotename(A.AlanAdi) + '))),N'''') is not null'
          else
            'K.' + quotename(A.AlanAdi) + ' is not null'
        end
      from @Alanlar A
      inner join sys.columns C on C.object_id = object_id('dbo.' + A.KaynakTablo) and C.name = A.AlanAdi
      inner join sys.types T on T.user_type_id = C.user_type_id
      where A.KaynakTablo = @KaynakTablo
        and A.UserTablo = @UserTablo
        and col_length('dbo.' + @UserTablo, A.AlanAdi) is not null
      order by A.AlanAdi
      for xml path(''), type).value('.','nvarchar(max)'), 1, 4, ''),
    @BosKosul = stuff((
      select ' and ' +
        case
          when T.name in ('varchar','char','nvarchar','nchar','text','ntext') then
            'nullif(ltrim(rtrim(convert(nvarchar(max),U.' + quotename(A.AlanAdi) + '))),N'''') is null'
          else
            'U.' + quotename(A.AlanAdi) + ' is null'
        end
      from @Alanlar A
      inner join sys.columns C on C.object_id = object_id('dbo.' + A.KaynakTablo) and C.name = A.AlanAdi
      inner join sys.types T on T.user_type_id = C.user_type_id
      where A.KaynakTablo = @KaynakTablo
        and A.UserTablo = @UserTablo
        and col_length('dbo.' + @UserTablo, A.AlanAdi) is not null
      order by A.AlanAdi
      for xml path(''), type).value('.','nvarchar(max)'), 1, 5, '');

  if isnull(@Kolonlar, '') <> '' and isnull(@BosDegilKosul, '') <> ''
  begin
    set @sql = N'
insert into dbo.' + quotename(@UserTablo) + N'(ID,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI,' + @Kolonlar + N')
select K.ID,K.EKLEYEN,K.EKLEMETARIHI,K.DEGISTIREN,K.DEGISTIRMETARIHI,' + @Secim + N'
from dbo.' + quotename(@KaynakTablo) + N' K
where not exists(select 1 from dbo.' + quotename(@UserTablo) + N' U where U.ID = K.ID)
  and (' + @BosDegilKosul + N');';
    exec sp_executesql @sql;

    set @sql = N'
update U set ' + @Setler + N'
from dbo.' + quotename(@UserTablo) + N' U
inner join dbo.' + quotename(@KaynakTablo) + N' K on K.ID = U.ID;';
    exec sp_executesql @sql;

    set @sql = N'
delete U
from dbo.' + quotename(@UserTablo) + N' U
where ' + @BosKosul + N';';
    exec sp_executesql @sql;
  end;

  fetch next from cur into @KaynakTablo, @UserTablo;
end;

close cur;
deallocate cur;

update A
set TABLO = M.UserTablo
from dbo.ALANLAR A
inner join @TabloMap M on M.KaynakTablo = A.TABLO
where exists(
  select 1
  from @Alanlar X
  where X.KaynakTablo = M.KaynakTablo
    and X.UserTablo = M.UserTablo
    and X.AlanAdi = A.ALANADI
);
