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
where object_id('dbo.' + M.UserTablo, 'U') is null;

update A
set TABLO = M.UserTablo
from dbo.ALANLAR A
inner join @TabloMap M on upper(ltrim(rtrim(A.TABLO))) = M.KaynakTablo
where isnull(A.TABLO, '') <> ''
  and upper(ltrim(rtrim(A.TABLO))) not like '%[_]USER';

select
  TABLO,
  ADET = count(*)
from dbo.ALANLAR
where isnull(TABLO, '') <> ''
group by TABLO
order by TABLO;
