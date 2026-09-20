-- =====================================================================
--  893_lab_sonuc_dogrulama.sql
--  BOŞ / ANLAMSIZ SONUÇ GÖNDERİLEMEZ
--  (KTS denetim maddesi L1: "Sonuçlar boş ya da anlamsız olarak
--   gönderilebiliyor mu?" - gönderilememeli.)
--
--  BUGÜN NE VAR: zorunlu alan denetimi (istem satırı, numune) ve panik
--  sınırları. `lab_tetkik.olculebilir_alt/ust` kolonları DA VAR ama
--  hiçbir yerde okunmuyor - kartta duruyor, sonuç yazarken kimse bakmıyor.
--  Sonuç olarak sayısal bir tetkike "iyi" yazılabiliyor, hemoglobin 500
--  g/dL girilebiliyor, boş değerle satır sonuçlandırılabiliyor.
--
--  ÜÇ AYRI SINIR VARDIR, KARIŞTIRILMAMALI:
--    * PANİK sınırı  - gerçek ama HAYATİ değer. Sonuç yazılır, hekime
--      bildirilir (zaten var).
--    * ÖLÇÜLEBİLİR aralık - cihazın/yöntemin ölçebildiği aralık. Dışı
--      "ölçüm dışı"dır; cihaz zaten `<0.01` / `>1000` diye işaretli gönderir.
--      İşaretsiz gelirse UYARIDIR, engel değil: gerçekten o değer okunmuş
--      olabilir ve sonucu düşürmek veriyi kaybettirir.
--    * MANTIK sınırı  - fizyolojik olarak İMKÂNSIZ değer (negatif
--      hemoglobin, 500 g/dL). Bu bir ölçüm değil, yazım hatasıdır; ENGEL.
--
--  KURAL: engel = sonuç yazılmaz (422). Uyarı = sonuç yazılır ama
--  OTOMATİK ONAYLANMAZ ve uyarı sonucun yorumuna düşer - insanın bakması
--  gereken bir şey, sessizce onaylanıp rapora gitmemeli.
--
--  SINIRLAR TOHUMLANMAZ. Hangi değerin imkânsız olduğu yönteme ve kuruma
--  bağlıdır; uydurulmuş bir sınır, gerçek bir sonucu reddettirir. Kurum
--  tetkik kartından yazar; yazmadıysa yalnız BOŞ SONUÇ engeli çalışır.
-- =====================================================================

alter table public.lab_tetkik
  add column if not exists mantik_alt      numeric(19,6),
  add column if not exists mantik_ust      numeric(19,6),
  add column if not exists deger_deseni    varchar(200) not null default '',
  add column if not exists bos_sonuc_engel smallint     not null default 1;

comment on column public.lab_tetkik.mantik_alt is
  '893: fizyolojik olarak IMKANSIZ alt sinir - altindaki deger olcum degil '
  'yazim hatasidir, sonuc YAZILMAZ. Olculebilir sinirdan farklidir.';
comment on column public.lab_tetkik.mantik_ust is
  '893: fizyolojik olarak IMKANSIZ ust sinir.';
comment on column public.lab_tetkik.deger_deseni is
  '893: metin/secenek tetkiklerde kabul edilen degerler - POSIX duzenli '
  'ifade ("^(Negatif|Pozitif|Suphei)$"). Bos = serbest metin.';
comment on column public.lab_tetkik.bos_sonuc_engel is
  '893: bos sonucla satir sonuclandirilamaz (varsayilan ACIK).';

/**
 * SONUÇ DOĞRULAMA - tek karar noktası.
 *
 * Dönüş: durum 0 tamam · 1 uyarı · 2 engel, ve kullanıcıya gösterilecek
 * mesaj. Hem sonuç yazarken hem onaylarken buradan sorulur; iki yerde ayrı
 * yazılsaydı ekranın kabul ettiğini onay reddederdi.
 *
 * İŞARETLİ DEĞERLER (`<0.01`, `>1000`, `≥`, `≤`) SAYIDIR: cihazlar ölçüm
 * sınırını böyle bildirir. İşareti sıyırıp sayıya bakarız; işaretli değer
 * ölçüm aralığı dışında olmaktan dolayı uyarı ÜRETMEZ - zaten "aralık
 * dışında" demenin cihazca yoludur.
 */
create or replace function public.fn_lab_sonuc_dogrula(p_tetkik_id integer,
                                                       p_deger     varchar)
returns table(durum smallint, mesaj varchar)
-- GÖVDE ETİKETİ `$fn$`: desen içindeki `[$]` ile `$$` yan yana gelince
--   dolar-tırnak ERKEN kapanıyor ve fonksiyon yarım kalıyordu.
language plpgsql stable as $fn$
declare
    t        public.lab_tetkik;
    v_ham    text := coalesce(trim(p_deger), '');
    v_sayi   text;
    v_isaret boolean := false;
    v_deger  numeric;
begin
    select * into t from public.lab_tetkik where id = p_tetkik_id;
    if t.id is null then
        return query select 2::smallint, 'Tetkik bulunamadı.'::varchar;
        return;
    end if;

    -- BOŞ SONUÇ: "sonuçlandı" demek ama bir şey söylememek. Rapora boş
    --   satır, e-Nabız'a boş değer gider; denetimin sorduğu tam budur.
    if v_ham = '' then
        if t.bos_sonuc_engel = 1 then
            return query select 2::smallint,
                   'Sonuç boş olamaz - değer girin ya da satırı iptal edin.'::varchar;
        else
            return query select 1::smallint, 'Sonuç boş.'::varchar;
        end if;
        return;
    end if;

    -- METİN / SEÇENEK TETKİK: desen tanımlıysa dışına çıkılamaz.
    if t.tur in (2, 3) then
        if t.deger_deseni <> '' and v_ham !~ t.deger_deseni then
            -- MESAJDA REGEX GÖSTERİLMEZ: kullanıcıya "^(Negatif|Pozitif)$"
            --   demek, ne yazacağını söylememektir. Basit seçenek deseni
            --   okunur listeye çevrilir; karmaşık desende genel cümle kalır.
            return query select 2::smallint,
                   (case when t.deger_deseni ~ '^\^\(([^()]*)\)[$]$'
                         then 'Bu tetkikte kabul edilen değerler: '
                              || replace(substring(t.deger_deseni from '^\^\((.*)\)[$]$'),
                                         '|', ', ')
                         else 'Girilen değer bu tetkik için tanımlı biçime uymuyor.'
                    end)::varchar;
            return;
        end if;
        return query select 0::smallint, ''::varchar;
        return;
    end if;

    -- KÜLTÜR VE GENETİK: değer serbest metindir (üreme yok / organizma adı).
    if t.tur not in (1) then
        return query select 0::smallint, ''::varchar;
        return;
    end if;

    -- SAYISAL TETKİK. İşaret önekleri sıyrılır: `<0.01` bir sayıdır.
    v_sayi := v_ham;
    if left(v_sayi, 1) in ('<', '>') or left(v_sayi, 1) in ('≤', '≥') then
        v_isaret := true;
        v_sayi := trim(substring(v_sayi from 2));
    end if;
    -- Ondalık ayıracı virgül de olabilir (elle giriş).
    v_sayi := replace(v_sayi, ',', '.');

    begin
        v_deger := v_sayi::numeric;
    exception when others then
        return query select 2::smallint,
               ('Bu tetkik SAYISAL sonuç bekliyor; "' || v_ham
                || '" sayı değil.')::varchar;
        return;
    end;

    -- MANTIK SINIRI: fizyolojik olarak imkânsız = yazım hatası, ENGEL.
    if t.mantik_alt is not null and v_deger < t.mantik_alt then
        return query select 2::smallint,
               (v_ham || ' ' || t.birim || ' fizyolojik olarak imkânsız (alt sınır '
                || public.fn_lab_sayi_metni(t.mantik_alt)
                || ') - değeri kontrol edin.')::varchar;
        return;
    end if;
    if t.mantik_ust is not null and v_deger > t.mantik_ust then
        return query select 2::smallint,
               (v_ham || ' ' || t.birim || ' fizyolojik olarak imkânsız (üst sınır '
                || public.fn_lab_sayi_metni(t.mantik_ust)
                || ') - değeri kontrol edin.')::varchar;
        return;
    end if;

    -- ÖLÇÜLEBİLİR ARALIK: dışı UYARIDIR. Sonucu düşürmek veriyi
    --   kaybettirirdi; ama otomatik onaylanmamalı - insan bakmalı.
    if not v_isaret and t.olculebilir_alt is not null and v_deger < t.olculebilir_alt then
        return query select 1::smallint,
               ('Değer cihazın ölçüm aralığının ALTINDA ('
                || public.fn_lab_sayi_metni(t.olculebilir_alt)
                || ' ' || t.birim || ') - doğrulayın.')::varchar;
        return;
    end if;
    if not v_isaret and t.olculebilir_ust is not null and v_deger > t.olculebilir_ust then
        return query select 1::smallint,
               ('Değer cihazın ölçüm aralığının ÜSTÜNDE ('
                || public.fn_lab_sayi_metni(t.olculebilir_ust)
                || ' ' || t.birim || ') - seyreltme gerekebilir.')::varchar;
        return;
    end if;

    return query select 0::smallint, ''::varchar;
end $fn$;

comment on function public.fn_lab_sonuc_dogrula(integer, varchar) is
  '893: sonuc dogrulama (KTS L1). 0 tamam · 1 uyari (yazilir, oto-onay yok) '
  '· 2 engel (yazilmaz). Panik / olculebilir / mantik sinirlari AYRI '
  'kavramlardir.';

-- SINIRI OLAN TETKİKLER: denetimde "hangi testlerde mantık sınırı tanımlı"
--   sorusunun cevabı ve kurumun kendi eksik listesi.
create or replace view public.v_lab_tetkik_dogrulama as
select t.id as tetkik_id, t.kod, t.ad, t.tur, t.birim,
       t.mantik_alt, t.mantik_ust, t.olculebilir_alt, t.olculebilir_ust,
       t.deger_deseni, t.bos_sonuc_engel,
       (t.mantik_alt is not null or t.mantik_ust is not null) as mantik_var,
       (t.tur in (2, 3) and t.deger_deseni <> '')             as desen_var
  from public.lab_tetkik t
 where t.durum = 0;

comment on view public.v_lab_tetkik_dogrulama is
  '893: tetkik basina sonuc dogrulama ayarlari - hangi testte mantik siniri '
  'ya da deger deseni tanimli.';

do $$
begin
    raise notice '893 tamam: % aktif tetkik, % tanesinde mantik siniri var',
        (select count(*) from public.v_lab_tetkik_dogrulama),
        (select count(*) from public.v_lab_tetkik_dogrulama where mantik_var);
end $$;
