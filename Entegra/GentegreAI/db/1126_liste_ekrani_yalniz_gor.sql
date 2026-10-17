-- =============================================================================
--  1126  KAYIT KABUL LİSTELERİ YALNIZ GÖR (1115 aşama 2)
--
--  Kullanıcı (17.10.2026): "Hasta Listesi yetkisi sade Gör/Görme ve hasta kartı yetkisi
--  Gör/ekle/değiş/sil" -> "evet aşama 2'yi yap".
--
--    hasta.liste    Kayıt Kabul › Hasta Listesi     yalnız GÖR  · kart / veri: hasta
--    basvuru.liste  Kayıt Kabul › Başvuru Listesi   yalnız GÖR  · kart / veri: belge
--
--  1115 liste kodlarına veri kodunun haklarını OLDUĞU GİBİ kopyalamıştı (Ekle / Değiştir / Sil
--  dahil) ve sunucu liste kodunu veri kapısında bütün işlemler için sayıyordu. Artık sunucu
--  (EkranKodlari.YalnizGorListe) liste kodunun yalnız Gör'ünü sayar; kart işlemleri veri koduna
--  bakar. Bu göç satırları buna uydurur:
--
--    1) KİMSE KART HAKKI KAYBETMEZ: liste satırında açık olan Ekle / Değiştir / Sil, veri satırında
--       kapalıysa veri satırına AÇILIR (veri satırı yoksa Gör ile birlikte eklenir). Bugüne kadar o
--       rol bu işlemleri liste kodu üzerinden zaten yapabiliyordu.
--    2) Liste satırlarında Ekle / Değiştir / Sil sıfırlanır (Gör olduğu gibi kalır).
--
--  Dokunulan satırlar önce public._yedek_rol_yetki_1126'ya yazılır. İdempotent: ikinci çalışmada
--  açılacak / sıfırlanacak satır kalmaz.
-- =============================================================================

begin;

create temp table _liste (liste varchar(60), veri varchar(60)) on commit drop;
insert into _liste values ('hasta.liste', 'hasta'), ('basvuru.liste', 'belge');

create table if not exists public._yedek_rol_yetki_1126 as
select ry.*, now() as yedek_tarihi from public.rol_yetki ry where false;

-- Yedek: değişecek liste satırları ve onlara karşılık gelen (varsa) veri satırları.
insert into public._yedek_rol_yetki_1126
select ry.*, now()
  from public.rol_yetki ry
  join public.yetki y on y.id = ry.yetki_id
 where ((y.kod in (select liste from _liste) and (ry.ekle = 1 or ry.degistir = 1 or ry.sil = 1))
     or (y.kod in (select veri from _liste)
         and exists (select 1 from public.rol_yetki rl
                       join public.yetki yl on yl.id = rl.yetki_id
                       join _liste l on l.liste = yl.kod and l.veri = y.kod
                      where rl.rol_id = ry.rol_id
                        and (rl.ekle > ry.ekle or rl.degistir > ry.degistir or rl.sil > ry.sil))));

-- 1) Liste satırındaki işlem hakkını veri satırına taşı (yalnız AÇAR, hiçbir hakkı kapatmaz).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select rl.rol_id, yv.id, 1, rl.ekle, rl.degistir, rl.sil, 0
  from public.rol_yetki rl
  join public.yetki yl on yl.id = rl.yetki_id
  join _liste l        on l.liste = yl.kod
  join public.yetki yv on yv.kod = l.veri
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
 where y.id = ry.yetki_id
   and y.kod in (select liste from _liste)
   and (ry.ekle = 1 or ry.degistir = 1 or ry.sil = 1);

-- Yetki önbelleği: etkilenen rollerin sürümü artar (oturumdaki kullanıcı yeni hakla devam eder).
update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public._yedek_rol_yetki_1126 b
                where b.rol_id = r.id and b.yedek_tarihi = now());

-- Rapor.
do $$
declare n int;
begin
  select count(*) into n from public._yedek_rol_yetki_1126 where yedek_tarihi = now();
  raise notice '1126: % rol_yetki satırı yedeklendi / düzenlendi', n;
end $$;

commit;
