-- ============================================================================
--  1121_ayar_kapilari.sql
--  AYARA BAĞLI KART ALANI / LİSTE KOLONU (kullanıcı 17.10.2026: gönderen doktor "opsiyona mı
--  profile mi" → "görünsün/görünmesin" ayarı, varsayılanı kurum tipinden).
--
--  fn_ayar_kapilari(sube): katalogda AyarKapisi verilmiş alanların açık mı (1) kapalı mı (0)
--  olduğunu döner. Kapalı kapının alanı kart metasına ve liste kolonlarına HİÇ girmez (ürün modu
--  süzgeciyle aynı yerde, sunucuda). Değer referans tablosundan ('0' / '1'); girilmemişse kurum
--  tipinin varsayılanı.
--    randevu.gonderen_doktor : randevuda gönderen (dış) doktor (1120). Hasta dışarıdan gelmeyen
--      kurumlarda (muayenehane, diş, OSGB, ERP) varsayılan KAPALI, diğerlerinde AÇIK.
--    randevu.bolum_doktor : randevu kartı / listesinde Bölüm ve Doktor (kullanıcı 17.10.2026: "görüntüleme
--      merkezinde randevu kartında ve listesinde bölüm ve doktor alanlarına gerek yok" - randevu
--      cihaza verilir). Görüntüleme ve laboratuvar kurum tiplerinde varsayılan KAPALI.
--  Yeni kapı = bu fonksiyona bir satır + katalogda AyarKapisi. Tekrar çalıştırılabilir.
-- ============================================================================

create or replace function public.fn_ayar_kapilari(p_sube integer)
returns table (anahtar varchar, acik smallint)
language sql stable as $$
    with tip as (
        select coalesce(
                 (select nullif(kp.kurum_tipi, '') from public.kurum_profil kp where kp.sube_id = coalesce(p_sube, 0)),
                 (select nullif(kp.kurum_tipi, '') from public.kurum_profil kp where kp.sube_id = 0),
                 '') as kod)
    select 'randevu.gonderen_doktor'::varchar,
           coalesce((select case when r.deger in ('0', '1') then r.deger::smallint end
                       from public.referans r where r.anahtar = 'randevu.gonderen_doktor'),
                    case when (select kod from tip) in ('muayenehane', 'dis', 'osgb', 'erp') then 0 else 1 end)::smallint
    union all
    select 'randevu.bolum_doktor'::varchar,
           coalesce((select case when r.deger in ('0', '1') then r.deger::smallint end
                       from public.referans r where r.anahtar = 'randevu.bolum_doktor'),
                    case when (select kod from tip) in ('goruntuleme', 'lab', 'goruntuleme_lab') then 0 else 1 end)::smallint
$$;

comment on function public.fn_ayar_kapilari(integer) is
  '1121: ayara bagli kart alani / liste kolonu kapilari - acik 1/0 (referans, yoksa kurum tipi varsayilani)';
