declare @Tablolar table(
  Tablo sysname not null primary key,
  UserTablo sysname null
);

insert into @Tablolar(Tablo, UserTablo) values
('REHBER', null),
('DEMIRBAS', null),
('SERVIS', null),
('SERVISHAREKET', null),
('SIPARIS', null),
('TEKLIF', null),
('DOKUMAN', null),
('FATBASLIK', null),
('URETIMEMRI', null),
('URETIMOPERASYONPERSONEL', 'URETIMOPERASYONPERSONEL_USER');

declare @Tablo sysname;
declare @UserTablo sysname;
declare @sql nvarchar(max);

declare cur cursor local fast_forward for
select Tablo, isnull(UserTablo, Tablo + '_USER') from @Tablolar;

open cur;
fetch next from cur into @Tablo, @UserTablo;

while @@fetch_status = 0
begin
  if object_id('dbo.' + @UserTablo, 'U') is null
  begin
    set @sql = N'
create table dbo.' + quotename(@UserTablo) + N'(
  ID int not null,
  EKLEYEN int null,
  EKLEMETARIHI datetime null constraint ' + quotename('DF_' + @UserTablo + '_EKLEMETARIHI') + N' default(getdate()),
  DEGISTIREN int null,
  DEGISTIRMETARIHI datetime null,
  constraint ' + quotename('PK_' + @UserTablo) + N' primary key clustered(ID),
  constraint ' + quotename('FK_' + @UserTablo + '_' + @Tablo) + N' foreign key(ID) references dbo.' + quotename(@Tablo) + N'(ID)
);';
    exec sp_executesql @sql;
  end;

  fetch next from cur into @Tablo, @UserTablo;
end;

close cur;
deallocate cur;
