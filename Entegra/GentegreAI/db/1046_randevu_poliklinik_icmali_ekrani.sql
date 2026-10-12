-- =============================================================================
--  1046  RANDEVU / POLİKLİNİK İCMALİ - ekran kodu + yardım
--
--  Kullanıcı (12.10.2026): "icmalleri yap" (mockup
--  Ekranlar/İcmal/randevu_poliklinik_icmali.html).
--
--  Şema değişikliği YOK: randevu (durum / tip / kaynak / bolum), çalışma planı
--  (fn_hekim_calisma_bloklari - slot), muayene.randevu_id (bekleme, randevusuz).
--  Mockup'taki iptal nedeni / iptal zamanı alanları bugün yok; icmalde yer almaz.
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi):
--    randevu.icmal   Randevu › Randevu / Poliklinik İcmali   ← randevu
--  Randevular ekranını gören rol yeni ekranı AYNI haklarla görür. İdempotent.
-- =============================================================================

begin;

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('randevu.icmal', 'randevu', 'Randevu / Poliklinik İcmali (Randevu)', 'Randevu');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1046: % satırın eski kodu yetki tablosunda yok', n; end if;
end $$;

insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
select b.yeni, b.ad, b.grup, 0, ye.sira, ye.urun_modu, ye.modul
  from _bolme b
  join public.yetki ye on ye.kod = b.eski
on conflict (kod) do update
   set ad = excluded.ad, grup = excluded.grup, tur = 0, aktif = 1;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger, kapsam, ekleyen)
select ry.rol_id, yn.id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger, ry.kapsam, 0
  from _bolme b
  join public.yetki ye     on ye.kod = b.eski
  join public.yetki yn     on yn.kod = b.yeni
  join public.rol_yetki ry on ry.yetki_id = ye.id
on conflict (rol_id, yetki_id) do nothing;

update public.rol r set yetki_surumu = yetki_surumu + 1
 where exists (select 1 from public.rol_yetki ry
                 join public.yetki y on y.id = ry.yetki_id
                 join _bolme b on b.yeni = y.kod
                where ry.rol_id = r.id);

-- ---------------------------------------------------------- yardım kataloğu --
--  Asistan ekranı tarif edebilsin (yeni ekran = ai_rehber_ekran satırı).
insert into public.ai_rehber_ekran (kaynak, rota, baslik, yol, menu_grup, menu_ad,
                                    yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
select v.kaynak, v.rota, v.baslik, v.yol, v.menu_grup, v.menu_ad, v.yetki_kodu, v.urun_modu,
       v.anahtar, v.aciklama, v.aksiyon_ekrani
  from (values
    ('randevu-icmal', '/randevu-icmal', 'Randevu / Poliklinik İcmali', 'Randevu › Randevu / Poliklinik İcmali',
     'Randevu', 'Randevu / Poliklinik İcmali', 'randevu.icmal', 2,
     'randevu poliklinik icmal no-show gelmeyen gelmedi iptal slot doluluk bekleme süresi kanal mhrs randevusuz muayene ilk kontrol hekim',
     'Dönemde verilen / gelen / gelmeyen / iptal randevu, poliklinik ve hekim başına slot doluluğu (çalışma planından), '
     || 'bekleme süresi dağılımı, randevu kanalları, gün × saat doluluğu, randevusuz muayene ve gelmeyen randevular; A4.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
