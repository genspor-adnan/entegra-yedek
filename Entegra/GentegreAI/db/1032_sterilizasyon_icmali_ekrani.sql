-- =============================================================================
--  1032  STERİLİZASYON İCMALİ - ekran kodu + cihaz yük kapasitesi
--
--  Kullanıcı (11.10.2026): "sterilizasyon icmalini kodla" (mockup
--  Ekranlar/İcmal/sterilizasyon_icmali.html).
--
--  YÜK KAPASİTESİ: steril_cihaz.kapasite serbest metin ("22 L · 2 tepsi") -
--  doluluk hesaplanamıyordu. Sayı alanı eklendi (cihaz kartında girilir):
--    steril_cihaz.yuk_kapasite   bir döngüye sığan paket / birim
--  Girilmemiş cihazda icmal doluluğu "—" gösterir (tahmin edilmez).
--
--  EKRAN KODU (menü kodu = yetki matrisi kodu, 1003 ilkesi):
--    steril.icmal   Diş › Sterilizasyon › Sterilizasyon İcmali   ← steril.pano
--  Sterilizasyon panosunu gören rol yeni ekranı AYNI haklarla görür. İdempotent.
-- =============================================================================

begin;

alter table public.steril_cihaz add column if not exists yuk_kapasite smallint;
comment on column public.steril_cihaz.yuk_kapasite is
  'Bir döngüye sığan paket / birim (1032, Sterilizasyon İcmali doluluğu). Boş = tanımsız.';

create temp table _bolme (yeni varchar(60), eski varchar(60), ad varchar(120),
                          grup varchar(40))
  on commit drop;

insert into _bolme values
  ('steril.icmal', 'steril.pano', 'Sterilizasyon İcmali (Sterilizasyon)', 'Sterilizasyon');

do $$
declare n int;
begin
  select count(*) into n from _bolme b where not exists (select 1 from public.yetki y where y.kod = b.eski);
  if n > 0 then raise exception '1032: % satırın eski kodu yetki tablosunda yok', n; end if;
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
    ('steril-icmal', '/steril-icmal', 'Sterilizasyon İcmali', 'Diş › Sterilizasyon › Sterilizasyon İcmali',
     'Diş', 'Sterilizasyon İcmali', 'steril.icmal', 2,
     'sterilizasyon icmal döngü otoklav doluluk paket set ömrü indikatör bowie-dick biyolojik karantina geri çağırma süresi dolan bölüm',
     'Dönemde cihaz başına döngü, serbest / karantina / başarısız, doluluk, validasyon; set ömrü ve eşiğe yakın birimler; indikatörler; '
     || 'karantina, geri çağırma ve süresi dolan paketler; bölümlere giden paketler, A4. Doluluk cihaz kartındaki yük kapasitesinden.', ''))
    as v(kaynak, rota, baslik, yol, menu_grup, menu_ad, yetki_kodu, urun_modu, anahtar, aciklama, aksiyon_ekrani)
 where not exists (select 1 from public.ai_rehber_ekran e where e.kaynak = v.kaynak);

commit;
