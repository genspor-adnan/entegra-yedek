if object_id('dbo.URETIMEMRI', 'U') is not null
begin
  if object_id('dbo.URETIMEMRI_USER', 'U') is null
  begin
    create table dbo.URETIMEMRI_USER(
      ID int not null,
      EKLEYEN int null,
      EKLEMETARIHI datetime null constraint DF_URETIMEMRI_USER_EKLEMETARIHI default(getdate()),
      DEGISTIREN int null,
      DEGISTIRMETARIHI datetime null,
      constraint PK_URETIMEMRI_USER primary key clustered(ID),
      constraint FK_URETIMEMRI_USER_URETIMEMRI foreign key(ID) references dbo.URETIMEMRI(ID)
    );
  end;

  declare @Alanlar table(
    AlanAdi sysname not null primary key,
    Tur int null
  );

  insert into @Alanlar(AlanAdi, Tur)
  select distinct A.ALANADI, max(A.TUR)
  from dbo.ALANLAR A
  where upper(ltrim(rtrim(A.TABLO))) in ('URETIMEMRI', 'URETIMEMRI_USER')
    and isnull(A.ALANADI, '') <> ''
    and isnull(A.TUR, 0) not in (11, 12)
  group by A.ALANADI;

  declare @sql nvarchar(max) = N'';

  select @sql = @sql + N'
if col_length(''dbo.URETIMEMRI_USER'', ''' + A.AlanAdi + N''') is null
  alter table dbo.URETIMEMRI_USER add ' + quotename(A.AlanAdi) + N' ' +
  case
    when C.name is not null then
      case
        when T.name in ('varchar','char','varbinary','binary') then T.name + '(' + case when C.max_length = -1 then 'max' else convert(varchar(10), C.max_length) end + ')'
        when T.name in ('nvarchar','nchar') then T.name + '(' + case when C.max_length = -1 then 'max' else convert(varchar(10), C.max_length / 2) end + ')'
        when T.name in ('decimal','numeric') then T.name + '(' + convert(varchar(10), C.precision) + ',' + convert(varchar(10), C.scale) + ')'
        when T.name in ('datetime2','datetimeoffset','time') then T.name + '(' + convert(varchar(10), C.scale) + ')'
        else T.name
      end
    else
      case
        when A.Tur in (1,4,7,9,10) then 'nvarchar(100)'
        when A.Tur in (2,6) then 'int'
        when A.Tur = 3 then 'datetime'
        when A.Tur = 5 then 'bit'
        when A.Tur = 8 then 'decimal(12,4)'
        when A.Tur = 13 then 'image'
        else 'nvarchar(100)'
      end
  end + N' null;'
  from @Alanlar A
  left join sys.columns C on C.object_id = object_id('dbo.URETIMEMRI') and C.name = A.AlanAdi
  left join sys.types T on T.user_type_id = C.user_type_id;

  exec sp_executesql @sql;

  declare @Kolonlar nvarchar(max);
  declare @Secim nvarchar(max);
  declare @Setler nvarchar(max);
  declare @BosDegilKosul nvarchar(max);
  declare @BosKosul nvarchar(max);

  select
    @Kolonlar = stuff((
      select ',' + quotename(A.AlanAdi)
      from @Alanlar A
      where col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null
        and col_length('dbo.URETIMEMRI', A.AlanAdi) is not null
      order by A.AlanAdi
      for xml path(''), type).value('.','nvarchar(max)'), 1, 1, ''),
    @Secim = stuff((
      select ',K.' + quotename(A.AlanAdi)
      from @Alanlar A
      where col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null
        and col_length('dbo.URETIMEMRI', A.AlanAdi) is not null
      order by A.AlanAdi
      for xml path(''), type).value('.','nvarchar(max)'), 1, 1, ''),
    @Setler = stuff((
      select ',U.' + quotename(A.AlanAdi) + '=K.' + quotename(A.AlanAdi)
      from @Alanlar A
      where col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null
        and col_length('dbo.URETIMEMRI', A.AlanAdi) is not null
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
      inner join sys.columns C on C.object_id = object_id('dbo.URETIMEMRI') and C.name = A.AlanAdi
      inner join sys.types T on T.user_type_id = C.user_type_id
      where col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null
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
      inner join sys.columns C on C.object_id = object_id('dbo.URETIMEMRI') and C.name = A.AlanAdi
      inner join sys.types T on T.user_type_id = C.user_type_id
      where col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null
      order by A.AlanAdi
      for xml path(''), type).value('.','nvarchar(max)'), 1, 5, '');

  if isnull(@Setler, '') <> '' and isnull(@BosDegilKosul, '') <> ''
  begin
    set @sql = N'
insert into dbo.URETIMEMRI_USER(ID,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI,' + @Kolonlar + N')
select K.ID,K.EKLEYEN,K.EKLEMETARIHI,K.DEGISTIREN,K.DEGISTIRMETARIHI,' + @Secim + N'
from dbo.URETIMEMRI K
where not exists(select 1 from dbo.URETIMEMRI_USER U where U.ID = K.ID)
  and (' + @BosDegilKosul + N');';
    exec sp_executesql @sql;

    set @sql = N'
update U set ' + @Setler + N'
from dbo.URETIMEMRI_USER U
inner join dbo.URETIMEMRI K on K.ID = U.ID;';
    exec sp_executesql @sql;

    set @sql = N'
delete U
from dbo.URETIMEMRI_USER U
where ' + @BosKosul + N';';
    exec sp_executesql @sql;
  end;

  update dbo.ALANLAR
  set TABLO = 'URETIMEMRI_USER'
  where upper(ltrim(rtrim(TABLO))) = 'URETIMEMRI';

  set @sql = N'';

  select @sql = @sql + N'
alter table dbo.URETIMEMRI drop constraint ' + quotename(DC.name) + N';'
  from @Alanlar A
  inner join sys.columns C on C.object_id = object_id('dbo.URETIMEMRI') and C.name = A.AlanAdi
  inner join sys.default_constraints DC on DC.parent_object_id = C.object_id and DC.parent_column_id = C.column_id
  where col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null;

  select @sql = @sql + N'
alter table dbo.URETIMEMRI drop constraint ' + quotename(CC.name) + N';'
  from @Alanlar A
  inner join sys.check_constraints CC on CC.parent_object_id = object_id('dbo.URETIMEMRI')
  where col_length('dbo.URETIMEMRI', A.AlanAdi) is not null
    and col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null
    and (charindex('[' + A.AlanAdi + ']', CC.definition) > 0 or charindex(A.AlanAdi, CC.definition) > 0);

  select @sql = @sql + N'
drop statistics dbo.URETIMEMRI.' + quotename(S.name) + N';'
  from @Alanlar A
  inner join sys.columns C on C.object_id = object_id('dbo.URETIMEMRI') and C.name = A.AlanAdi
  inner join sys.stats_columns SC on SC.object_id = C.object_id and SC.column_id = C.column_id
  inner join sys.stats S on S.object_id = SC.object_id and S.stats_id = SC.stats_id
  where S.user_created = 1
    and col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null
    and not exists(select 1 from sys.indexes I where I.object_id = S.object_id and I.name = S.name);

  select @sql = @sql + N'
drop index ' + quotename(I.name) + N' on dbo.URETIMEMRI;'
  from @Alanlar A
  inner join sys.index_columns IC on IC.object_id = object_id('dbo.URETIMEMRI')
  inner join sys.columns C on C.object_id = IC.object_id and C.column_id = IC.column_id and C.name = A.AlanAdi
  inner join sys.indexes I on I.object_id = IC.object_id and I.index_id = IC.index_id
  where I.is_primary_key = 0
    and I.is_unique_constraint = 0
    and col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null;

  select @sql = @sql + N'
alter table dbo.URETIMEMRI drop column ' + quotename(A.AlanAdi) + N';'
  from @Alanlar A
  where col_length('dbo.URETIMEMRI', A.AlanAdi) is not null
    and col_length('dbo.URETIMEMRI_USER', A.AlanAdi) is not null;

  exec sp_executesql @sql;

  select
    TABLO,
    ALANADI,
    USER_KOLON_VAR = case when col_length('dbo.URETIMEMRI_USER', ALANADI) is null then 0 else 1 end,
    ANA_KOLON_VAR = case when col_length('dbo.URETIMEMRI', ALANADI) is null then 0 else 1 end
  from dbo.ALANLAR
  where upper(ltrim(rtrim(TABLO))) = 'URETIMEMRI_USER'
  order by ALANADI;
end;
