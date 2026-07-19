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
inner join @TabloMap M
  on A.TABLO in (M.KaynakTablo, M.UserTablo)
where isnull(A.ALANADI, '') <> ''
  and isnull(A.TUR, 0) not in (11, 12)
  and object_id('dbo.' + M.KaynakTablo, 'U') is not null
  and object_id('dbo.' + M.UserTablo, 'U') is not null
  and col_length('dbo.' + M.KaynakTablo, A.ALANADI) is not null
  and col_length('dbo.' + M.UserTablo, A.ALANADI) is not null;

declare @sql nvarchar(max) = N'';

select @sql = @sql + N'
alter table dbo.' + quotename(X.KaynakTablo) + N' drop constraint ' + quotename(DC.name) + N';'
from @Alanlar X
inner join sys.columns C on C.object_id = object_id('dbo.' + X.KaynakTablo) and C.name = X.AlanAdi
inner join sys.default_constraints DC on DC.parent_object_id = C.object_id and DC.parent_column_id = C.column_id;

select @sql = @sql + N'
alter table dbo.' + quotename(X.KaynakTablo) + N' drop constraint ' + quotename(CC.name) + N';'
from @Alanlar X
inner join sys.check_constraints CC on CC.parent_object_id = object_id('dbo.' + X.KaynakTablo)
where charindex('[' + X.AlanAdi + ']', CC.definition) > 0
   or charindex(X.AlanAdi, CC.definition) > 0;

select @sql = @sql + N'
drop statistics dbo.' + quotename(X.KaynakTablo) + N'.' + quotename(S.name) + N';'
from @Alanlar X
inner join sys.columns C on C.object_id = object_id('dbo.' + X.KaynakTablo) and C.name = X.AlanAdi
inner join sys.stats_columns SC on SC.object_id = C.object_id and SC.column_id = C.column_id
inner join sys.stats S on S.object_id = SC.object_id and S.stats_id = SC.stats_id
where S.user_created = 1
  and not exists(select 1 from sys.indexes I where I.object_id = S.object_id and I.name = S.name);

select @sql = @sql + N'
drop index ' + quotename(I.name) + N' on dbo.' + quotename(X.KaynakTablo) + N';'
from @Alanlar X
inner join sys.index_columns IC on IC.object_id = object_id('dbo.' + X.KaynakTablo)
inner join sys.columns C on C.object_id = IC.object_id and C.column_id = IC.column_id and C.name = X.AlanAdi
inner join sys.indexes I on I.object_id = IC.object_id and I.index_id = IC.index_id
where I.is_primary_key = 0
  and I.is_unique_constraint = 0;

select @sql = @sql + N'
alter table dbo.' + quotename(X.KaynakTablo) + N' drop column ' + quotename(X.AlanAdi) + N';'
from @Alanlar X
where col_length('dbo.' + X.KaynakTablo, X.AlanAdi) is not null
  and col_length('dbo.' + X.UserTablo, X.AlanAdi) is not null;

exec sp_executesql @sql;
