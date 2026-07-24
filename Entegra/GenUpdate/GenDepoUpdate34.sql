if object_id('dbo.STOKLAR_USER','U') is null
begin
  create table dbo.STOKLAR_USER(
    ID int not null,
    EKLEYEN int null,
    EKLEMETARIHI datetime null constraint DF_STOKLAR_USER_EKLEMETARIHI default(getdate()),
    DEGISTIREN int null,
    DEGISTIRMETARIHI datetime null,
	[SUTKODU] [varchar](50) NULL,
	[BRANSKODU] [nvarchar](50) NULL,
	[GMDN] [nvarchar](50) NULL,
	[GMDNADI] [nvarchar](150) NULL,
	[MEDIKALSINIF] [smallint] NULL,
	[ITHALIMAL] [smallint] NULL,
	[MENSEIULKE] [smallint] NULL,
	[UTSREF] [nvarchar](50) NULL,
	[FTN] [nvarchar](50) NULL,
	[DIGERURUNADI] [nvarchar](150) NULL,
	[IHALESIRANO] [nvarchar](50) NULL,
	[SMKODU] [nvarchar](20) NULL,
	[DMOKODU] [nvarchar](20) NULL,


    constraint PK_STOKLAR_USER primary key clustered(ID),
    constraint FK_STOKLAR_USER_STOKLAR foreign key(ID) references dbo.STOKLAR(ID)
  );
end
go

declare @Alanlar table(Alan sysname not null primary key);
insert into @Alanlar(Alan) values
('SUTKODU'),('BRANSKODU'),('UTSREF'),('FTN'),('GMDN'),('GMDNADI'),
('DIGERURUNADI'),('MEDIKALSINIF'),('ITHALIMAL'),('MENSEIULKE'),
('IHALESIRANO'),('DMOKODU'),('SMKODU');

declare @sql nvarchar(max) = N'';

select @sql = @sql + N'
if col_length(''dbo.STOKLAR_USER'', ''' + A.Alan + N''') is null
  alter table dbo.STOKLAR_USER add ' + quotename(A.Alan) + N' ' +
  case
    when T.name in ('varchar','char','varbinary','binary') then T.name + '(' + case when C.max_length = -1 then 'max' else convert(varchar(10), C.max_length) end + ')'
    when T.name in ('nvarchar','nchar') then T.name + '(' + case when C.max_length = -1 then 'max' else convert(varchar(10), C.max_length / 2) end + ')'
    when T.name in ('decimal','numeric') then T.name + '(' + convert(varchar(10), C.precision) + ',' + convert(varchar(10), C.scale) + ')'
    when T.name in ('datetime2','datetimeoffset','time') then T.name + '(' + convert(varchar(10), C.scale) + ')'
    else T.name
  end + N' null;'
from @Alanlar A
inner join sys.columns C on C.object_id = object_id('dbo.STOKLAR') and C.name = A.Alan
inner join sys.types T on T.user_type_id = C.user_type_id;

exec sp_executesql @sql;
go

-- ONCE veriyi STOKLAR -> STOKLAR_USER aktar (STOKLAR'dan DROP'tan ONCE olmali; aksi halde
-- kaynak kolonlar silinmis olur -> @Kolonlar/@Secim bos -> insert HIC calismaz, eski veri kaybolur).
declare @Kolonlar nvarchar(max);
declare @Secim nvarchar(max);
declare @BosDegilKosul nvarchar(max);
declare @sql nvarchar(max);

select
  @Kolonlar = stuff((
    select ',' + quotename(C.name)
    from sys.columns C
    where C.object_id = object_id('dbo.STOKLAR')
      and C.name in ('SUTKODU','BRANSKODU','UTSREF','FTN','GMDN','GMDNADI','DIGERURUNADI','MEDIKALSINIF','ITHALIMAL','MENSEIULKE','IHALESIRANO','DMOKODU','SMKODU')
      and col_length('dbo.STOKLAR_USER', C.name) is not null
    order by C.column_id
    for xml path(''), type).value('.','nvarchar(max)'), 1, 1, ''),
  @Secim = stuff((
    select ',S.' + quotename(C.name)
    from sys.columns C
    where C.object_id = object_id('dbo.STOKLAR')
      and C.name in ('SUTKODU','BRANSKODU','UTSREF','FTN','GMDN','GMDNADI','DIGERURUNADI','MEDIKALSINIF','ITHALIMAL','MENSEIULKE','IHALESIRANO','DMOKODU','SMKODU')
      and col_length('dbo.STOKLAR_USER', C.name) is not null
    order by C.column_id
    for xml path(''), type).value('.','nvarchar(max)'), 1, 1, ''),
  @BosDegilKosul = stuff((
    select ' or ' +
      case
        when T.name in ('varchar','char','nvarchar','nchar','text','ntext') then
          'nullif(ltrim(rtrim(convert(nvarchar(max),S.' + quotename(C.name) + '))),N'''') is not null'
        else
          'S.' + quotename(C.name) + ' is not null'
      end
    from sys.columns C
    inner join sys.types T on T.user_type_id = C.user_type_id
    where C.object_id = object_id('dbo.STOKLAR')
      and C.name in ('SUTKODU','BRANSKODU','UTSREF','FTN','GMDN','GMDNADI','DIGERURUNADI','MEDIKALSINIF','ITHALIMAL','MENSEIULKE','IHALESIRANO','DMOKODU','SMKODU')
      and col_length('dbo.STOKLAR_USER', C.name) is not null
    order by C.column_id
    for xml path(''), type).value('.','nvarchar(max)'), 1, 4, '');

if isnull(@Kolonlar, '') <> '' and isnull(@BosDegilKosul, '') <> ''
begin
  set @sql = N'
insert into dbo.STOKLAR_USER(ID,EKLEYEN,EKLEMETARIHI,DEGISTIREN,DEGISTIRMETARIHI' +
  case when isnull(@Kolonlar,'') <> '' then ',' + @Kolonlar else '' end + N')
select S.ID,S.EKLEYEN,S.EKLEMETARIHI,S.DEGISTIREN,S.DEGISTIRMETARIHI' +
  case when isnull(@Secim,'') <> '' then ',' + @Secim else '' end + N'
from dbo.STOKLAR S
where not exists(select 1 from dbo.STOKLAR_USER SU where SU.ID = S.ID)
  and (' + @BosDegilKosul + N');';

  exec sp_executesql @sql;
end
go

-- Veri aktarildiktan SONRA STOKLAR'daki ek kolonlari (constraint/stats/index dahil) DROP et.
declare @DropAlanlar table(Alan sysname not null primary key);
insert into @DropAlanlar(Alan) values
('SUTKODU'),('BRANSKODU'),('UTSREF'),('FTN'),('GMDN'),('GMDNADI'),
('DIGERURUNADI'),('MEDIKALSINIF'),('ITHALIMAL'),('MENSEIULKE'),
('IHALESIRANO'),('DMOKODU'),('SMKODU');

declare @sql nvarchar(max) = N'';

select @sql = @sql + N'
alter table dbo.STOKLAR drop constraint ' + quotename(DC.name) + N';'
from sys.default_constraints DC
inner join sys.columns C on C.object_id = DC.parent_object_id and C.column_id = DC.parent_column_id
inner join @DropAlanlar A on A.Alan = C.name
where DC.parent_object_id = object_id('dbo.STOKLAR');

select @sql = @sql + N'
alter table dbo.STOKLAR drop constraint ' + quotename(CC.name) + N';'
from sys.check_constraints CC
inner join @DropAlanlar A on charindex('[' + A.Alan + ']', CC.definition) > 0 or charindex(A.Alan, CC.definition) > 0
where CC.parent_object_id = object_id('dbo.STOKLAR');

select @sql = @sql + N'
drop statistics dbo.STOKLAR.' + quotename(S.name) + N';'
from sys.stats S
inner join sys.stats_columns SC on SC.object_id = S.object_id and SC.stats_id = S.stats_id
inner join sys.columns C on C.object_id = SC.object_id and C.column_id = SC.column_id
inner join @DropAlanlar A on A.Alan = C.name
where S.object_id = object_id('dbo.STOKLAR')
  and S.user_created = 1
  and not exists(select 1 from sys.indexes I where I.object_id = S.object_id and I.name = S.name);

select @sql = @sql + N'
drop index ' + quotename(I.name) + N' on dbo.STOKLAR;'
from sys.indexes I
where I.object_id = object_id('dbo.STOKLAR')
  and I.is_primary_key = 0
  and I.is_unique_constraint = 0
  and exists(
    select 1
    from sys.index_columns IC
    inner join sys.columns C on C.object_id = IC.object_id and C.column_id = IC.column_id
    inner join @DropAlanlar A on A.Alan = C.name
    where IC.object_id = I.object_id and IC.index_id = I.index_id
  );

select @sql = @sql + N'
alter table dbo.STOKLAR drop column ' + quotename(A.Alan) + N';'
from @DropAlanlar A
where col_length('dbo.STOKLAR', A.Alan) is not null;

exec sp_executesql @sql;
go
