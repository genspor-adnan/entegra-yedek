-- 234: Şube yetkisi ROLE bağlandı (kullanıcı kararı: "şube kısıtını personel
-- değil role ata, personel yetkiyi her zaman rolden alır").
--
-- Önceki model kullanıcı bazlıydı (kullanici_sube). Artık kullanıcının
-- girebildiği şubeler ROLÜNDEN gelir: rol "ne yapabilir" + "nerede çalışır"ın
-- ikisini de taşır. kullanici_sube tablosu SİLİNMEZ - eski dağılım orada
-- kalır (rol_sube tohumu ondan üretiliyor, geri dönüş gerekirse kaynak).

create table if not exists public.rol_sube (
  rol_id            integer  not null references public.rol(id) on delete cascade,
  sube_id           integer  not null references public.sube(id),
  varsayilan        smallint not null default 0,   -- rolün açılış şubesi (en fazla 1)
  yazma             smallint not null default 1,   -- 0 = şube salt okunur
  ekleyen           integer  not null default 0,
  ekleme_tarihi     timestamp not null default now()::timestamp,
  degistiren        integer  not null default 0,
  degistirme_tarihi timestamp,
  constraint pk_rol_sube primary key (rol_id, sube_id)
);

create unique index if not exists ux_rol_sube_varsayilan
  on public.rol_sube (rol_id) where varsayilan = 1;

comment on table public.rol_sube is
  'Rolün çalışabildiği şubeler - kullanıcının şube listesi buradan gelir (234).';

-- Tohum: yönetici rolü TÜM aktif şubelerde yazma yetkili; ilk şube varsayılan.
insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma)
select r.id, s.id,
       case when s.id = (select min(id) from public.sube where aktif = 1) then 1 else 0 end,
       1
  from public.rol r
  cross join public.sube s
 where r.kod = 'yonetici' and s.aktif = 1
   and not exists (select 1 from public.rol_sube x
                    where x.rol_id = r.id and x.sube_id = s.id);

-- Yetkisiz havuz rolü ('Rol Atanmamış'): giriş yapabilsin diye varsayılan
-- şube verilir ama SALT OKUNUR - zaten hiçbir modül yetkisi yok.
insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma)
select r.id, (select min(id) from public.sube where aktif = 1), 1, 0
  from public.rol r
 where r.kod = 'atanmamis'
   and not exists (select 1 from public.rol_sube x where x.rol_id = r.id);
