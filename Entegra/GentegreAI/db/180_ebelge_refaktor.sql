-- ============================================================================
--  Gentegre AI — e-BELGE KODUNDA TEKRAR TEMIZLIGI (refaktor)
--  180_ebelge_refaktor.sql
--
--  Kullanici: "kodu refaktor yap." Davranis DEGISMEZ.
--
--  TEKRAR 1 - DURUM METNI: "0 kagit / 1 e-Fatura / 2 e-Fatura ✓ / 11 e-Arsiv..."
--  esleme dort yerde ayri ayri yaziliydi (fatura listesi, irsaliye listesi,
--  onizleme HTML'i, mesaj gecmisi). Biri guncellenip digeri unutuldugunda
--  ekranlar farkli sey soyluyordu - nitekim irsaliye listesi FATURA kodlarina
--  bakiyordu (51/52 yerine 1/2) ve hazirlanmis irsaliye "Kağıt" gorunuyordu.
--
--  TEKRAR 2 - TARAF JSON'U: gonderici ve alici bloklari ayni kaliba sahip
--  (kimlik semasi, TCKN'de ad/soyad, adres, vergi dairesi) ama 166'da iki kez
--  yazilmisti.
--
--  Iki tekrar da FONKSIYONA alindi; cagiran yerler 180 sonrasi tek kaynaktan
--  okur.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------- durum metinleri ---
-- `belge.efatura_durum` kodunun okunabilir karsiligi. Rozet metinleri de
--   buradan gelir: gonderilmis belge "✓" ile ayrilir.
create or replace function public.fn_ebelge_durum_adi(p_durum integer,
                                                      p_kagit text default '')
returns text language sql immutable as $$
    select case coalesce(p_durum, 0)
                when 0  then p_kagit
                when 1  then 'e-Fatura'    when 2  then 'e-Fatura ✓'
                when 3  then 'Kabul'       when 4  then 'Red'
                when 11 then 'e-Arşiv'     when 12 then 'e-Arşiv ✓'
                when 51 then 'e-İrsaliye'  when 52 then 'e-İrsaliye ✓'
                when 53 then 'Kabul'       when 54 then 'Red'
                else 'Bilinmiyor' end
$$;

comment on function public.fn_ebelge_durum_adi(integer, text) is
  'efatura_durum kodunun ekranda gorunen karsiligi; p_kagit "hic hazirlanmadi" metnidir (180).';

-- Uzun aciklama (onizleme basligi): tur + asama birlikte.
create or replace function public.fn_ebelge_durum_aciklama(p_durum integer)
returns text language sql immutable as $$
    select case coalesce(p_durum, 0)
                when 0  then 'Hazırlanmadı'
                when 1  then 'Hazırlandı (e-Fatura)'    when 2  then 'Gönderildi (e-Fatura)'
                when 11 then 'Hazırlandı (e-Arşiv)'     when 12 then 'Gönderildi (e-Arşiv)'
                when 51 then 'Hazırlandı (e-İrsaliye)'  when 52 then 'Gönderildi (e-İrsaliye)'
                else 'Bilinmiyor' end
$$;

comment on function public.fn_ebelge_durum_aciklama(integer) is
  'efatura_durum kodunun uzun aciklamasi (onizleme basligi) - 180.';

-- ---------------------------------------------------------- taraf JSON'u ---
-- Gonderici ve alici AYNI kaliptan uretilir: kimlik semasi, gercek kiside
--   ad/soyad ayrimi, vergi dairesi, adres. Tek fark ek alanlar (identifications,
--   e-posta) - onlari cagiran ekler.
create or replace function public.fn_ebelge_taraf_json(
        p_unvan text, p_vkno text, p_vd text,
        p_adres text, p_ilce text, p_il text,
        p_posta_kodu text default '', p_eposta text default '',
        p_telefon text default '', p_web text default '')
returns jsonb language sql immutable as $$
    select jsonb_build_object(
               'identifier', regexp_replace(coalesce(p_vkno, ''), '\D', '', 'g'),
               'schemeId',   public.fn_ebelge_kimlik_semasi(p_vkno),
               -- GIB gercek kiside ad ve SOYADI ayri ister; tuzel kiside unvan.
               'address',    jsonb_strip_nulls(jsonb_build_object(
                   'country',    'TR',
                   'city',       nullif(btrim(coalesce(p_il, '')), ''),
                   'subCity',    nullif(btrim(coalesce(p_ilce, '')), ''),
                   'streetName', nullif(btrim(coalesce(p_adres, '')), ''),
                   'postalCode', nullif(btrim(coalesce(p_posta_kodu, '')), ''),
                   'email',      nullif(btrim(coalesce(p_eposta, '')), ''),
                   'telephone',  nullif(btrim(coalesce(p_telefon, '')), ''),
                   'webSite',    nullif(btrim(coalesce(p_web, '')), ''))))
           || case when public.fn_ebelge_kimlik_semasi(p_vkno) = 'TCKN'
                   then (select jsonb_build_object('firstName', a.ad,
                                                   'lastName', a.soyad)
                           from public.fn_ad_soyad_ayir(p_unvan) a)
                   else jsonb_build_object('name', btrim(coalesce(p_unvan, ''))) end
           || case when coalesce(btrim(p_vd), '') <> ''
                   then jsonb_build_object('taxOffice', btrim(p_vd))
                   else '{}'::jsonb end
$$;

comment on function public.fn_ebelge_taraf_json(text, text, text, text, text, text,
                                                text, text, text, text) is
  'e-Belge taraf blogu (gonderici/alici ortak kalibi): kimlik semasi, TCKN''de ad/soyad, adres, vergi dairesi (180).';

do $$
begin
    raise notice '180 tamam: fn_ebelge_durum_adi / _aciklama + fn_ebelge_taraf_json.';
end $$;
