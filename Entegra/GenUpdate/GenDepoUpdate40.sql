set nocount on;

declare @Map table(
  BaseTable sysname not null,
  UserTable sysname not null,
  FKName sysname not null,
  OldTriggerName sysname not null,
  primary key(BaseTable, UserTable)
);

insert into @Map(BaseTable, UserTable, FKName, OldTriggerName) values
('FATURA', 'FATURA_USER', 'FK_FATURA_USER_FATURA', 'TRG_FATURA_DELETE_FATURA_USER'),
('FATBASLIK', 'FATBASLIK_USER', 'FK_FATBASLIK_USER_FATBASLIK', 'TRG_FATBASLIK_DELETE_FATBASLIK_USER'),
('STOKLAR', 'STOKLAR_USER', 'FK_STOKLAR_USER_STOKLAR', 'TRG_STOKLAR_DELETE_STOKLAR_USER'),
('REHBER', 'REHBER_USER', 'FK_REHBER_USER_REHBER', 'TRG_REHBER_DELETE_REHBER_USER'),
('DEMIRBAS', 'DEMIRBAS_USER', 'FK_DEMIRBAS_USER_DEMIRBAS', 'TRG_DEMIRBAS_DELETE_DEMIRBAS_USER'),
('SERVIS', 'SERVIS_USER', 'FK_SERVIS_USER_SERVIS', 'TRG_SERVIS_DELETE_SERVIS_USER'),
('SERVISHAREKET', 'SERVISHAREKET_USER', 'FK_SERVISHAREKET_USER_SERVISHAREKET', 'TRG_SERVISHAREKET_DELETE_SERVISHAREKET_USER'),
('SIPARIS', 'SIPARIS_USER', 'FK_SIPARIS_USER_SIPARIS', 'TRG_SIPARIS_DELETE_SIPARIS_USER'),
('TEKLIF', 'TEKLIF_USER', 'FK_TEKLIF_USER_TEKLIF', 'TRG_TEKLIF_DELETE_TEKLIF_USER'),
('DOKUMAN', 'DOKUMAN_USER', 'FK_DOKUMAN_USER_DOKUMAN', 'TRG_DOKUMAN_DELETE_DOKUMAN_USER'),
('URETIMEMRI', 'URETIMEMRI_USER', 'FK_URETIMEMRI_USER_URETIMEMRI', 'TRG_URETIMEMRI_DELETE_URETIMEMRI_USER'),
('URETIMOPERASYONPERSONEL', 'URETIMOPERASYONPERSONEL_USER', 'FK_URETIMOPERASYONPERSONEL_USER_URETIMOPERASYONPERSONEL', 'TRG_URETIMOPERASYONPERSONEL_DELETE_USER');

delete M
from @Map M
where object_id('dbo.' + M.BaseTable, 'U') is null
   or object_id('dbo.' + M.UserTable, 'U') is null;

declare @Sonuc table(
  BaseTable sysname not null,
  UserTable sysname not null,
  FKName sysname not null,
  Durum nvarchar(200) not null
);

declare @BaseTable sysname;
declare @UserTable sysname;
declare @FKName sysname;
declare @OldTriggerName sysname;
declare @sql nvarchar(max);

declare cur cursor local fast_forward for
select BaseTable, UserTable, FKName, OldTriggerName
from @Map
order by BaseTable;

open cur;
fetch next from cur into @BaseTable, @UserTable, @FKName, @OldTriggerName;

while @@fetch_status = 0
begin
  set @sql = N'';

  if object_id('dbo.' + @OldTriggerName, 'TR') is not null
  begin
    set @sql = N'drop trigger dbo.' + quotename(@OldTriggerName) + N';';
    exec sp_executesql @sql;
  end;

  set @sql = N'';

  select @sql = @sql + N'
alter table dbo.' + quotename(@UserTable) + N' drop constraint ' + quotename(FK.name) + N';'
  from sys.foreign_keys FK
  where FK.parent_object_id = object_id('dbo.' + @UserTable)
    and FK.referenced_object_id = object_id('dbo.' + @BaseTable);

  if @sql <> N''
    exec sp_executesql @sql;

  set @sql = N'
delete U
from dbo.' + quotename(@UserTable) + N' U
where not exists(select 1 from dbo.' + quotename(@BaseTable) + N' B where B.ID = U.ID);';
  exec sp_executesql @sql;

  set @sql = N'
alter table dbo.' + quotename(@UserTable) + N' with check add constraint ' + quotename(@FKName) + N'
foreign key(ID) references dbo.' + quotename(@BaseTable) + N'(ID) on delete cascade;
alter table dbo.' + quotename(@UserTable) + N' check constraint ' + quotename(@FKName) + N';';
  exec sp_executesql @sql;

  insert into @Sonuc(BaseTable, UserTable, FKName, Durum)
  values(@BaseTable, @UserTable, @FKName, 'CASCADE FK OLUSTU/GUNCELLENDI');

  fetch next from cur into @BaseTable, @UserTable, @FKName, @OldTriggerName;
end;

close cur;
deallocate cur;

select *
from @Sonuc
order by BaseTable;
