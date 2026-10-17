-- =============================================================================
--  1132  LİSTE / KART AYRIMI - GRUP 3: KARTI BAŞKA EKRANDA OLAN LİSTELER
--
--  Kullanıcı (17.10.2026): "dışarıda kalanları grup grup yap". Bu listeler kendi kodlarını taşıyor
--  ama aşama 1 köprüsüyle ortak kaynağın kapısını BÜTÜN işlemlerde açıyorlardı:
--    radyoloji.kritik / .konsultasyon / .teslim  -> radyoloji  (Kritik Bulgu'da Değiştir'i olan
--                                                  Cihaz / Rapor Şablonu kartlarını da düzenliyordu)
--    servis.is_emri                              -> servis     (İş Emri Listesi'nin Yeni / Sil'i)
--  Artık yalnız Gör. 1130 ile aynı adımlar: liste satırındaki Ekle / Değiştir / Sil karta açılır
--  (kimse hak kaybetmez - matriste görünür olur, gerekirse oradan kaldırılır), listede sıfırlanır.
--  Rapor yazma / teslim gibi işler zaten ayrı aksiyon kodlarında (rad.rapor_yaz, rad.teslim,
--  servis.teslim); etkilenmez.
--
--  Dışarıda (bilinçli): Acil Triyaj / Takip Panosu (kendi koduyla yazan iş ekranları), Vade / Plan
--  (kendi kaynağı, ayrı kart kodu yok), Kalite Dokümanı / Cihaz Envanteri / Satınalma Tedarikçi
--  (liste kodu hedef kartı hiç açmıyor; karta bağlamak okumayı bütün kayıtlara genişletirdi).
--  Dokunulan satırlar public._yedek_rol_yetki_1132'de. İdempotent.
-- =============================================================================

begin;

create temp table _l (liste varchar(60), kart varchar(60)) on commit drop;
insert into _l values
  ('radyoloji.kritik',       'radyoloji'),
  ('radyoloji.konsultasyon', 'radyoloji'),
  ('radyoloji.teslim',       'radyoloji'),
  ('servis.is_emri',         'servis');

create table if not exists public._yedek_rol_yetki_1132 as
select ry.*, now() as yedek_tarihi from public.rol_yetki ry where false;

insert into public._yedek_rol_yetki_1132
select ry.*, now()
  from public.rol_yetki ry
  join public.yetki y on y.id = ry.yetki_id
 where (y.kod in (select liste from _l) and (ry.ekle = 1 or ry.degistir = 1 or ry.sil = 1))
    or (y.kod in (select kart from _l)
        and exists (select 1 from public.rol_yetki rl
                      join public.yetki yl on yl.id = rl.yetki_id
                      join _l l on l.liste = yl.kod and l.kart = y.kod
                     where rl.rol_id = ry.rol_id
                       and (rl.ekle > ry.ekle or rl.degistir > ry.degistir or rl.sil > ry.sil)));

-- 1) Liste satırındaki işlem hakkı karta (yalnız AÇAR).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select rl.rol_id, yk.id, 1, rl.ekle, rl.degistir, rl.sil, 0
  from public.rol_yetki rl
  join public.yetki yl on yl.id = rl.yetki_id
  join _l l            on l.liste = yl.kod
  join public.yetki yk on yk.kod = l.kart
 where (rl.ekle = 1 or rl.degistir = 1 or rl.sil = 1)
on conflict (rol_id, yetki_id) do update
   set gor      = 1,
       ekle     = greatest(public.rol_yetki.ekle,     excluded.ekle),
       degistir = greatest(public.rol_yetki.degistir, excluded.degistir),
       sil      = greatest(public.rol_yetki.sil,      excluded.sil),
       degistirme_tarihi = now()
 where excluded.ekle > public.rol_yetki.ekle
    or excluded.degistir > public.rol_yetki.degistir
    or excluded.sil > public.rol_yetki.sil;

-- 2) Liste satırları yalnız Gör.
update public.rol_yetki ry
   set ekle = 0, degistir = 0, sil = 0, degistirme_tarihi = now()
  from public.yetki y
 where y.id = ry.yetki_id and y.kod in (select liste from _l)
   and (ry.ekle = 1 or ry.degistir = 1 or ry.sil = 1);

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public._yedek_rol_yetki_1132 b
                where b.rol_id = r.id and b.yedek_tarihi = now());

commit;
