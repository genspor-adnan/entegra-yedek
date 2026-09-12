-- =====================================================================
--  559_bolum_gorev_skrs.sql
--  BÖLÜM ve GÖREV listeleri SKRS'den yeniden kurulur.
--
--  Kullanıcı: "kod eşleme istemiyorum. bölüm ve görevi boşalt, sonra SKRS'den
--  ikisini de doldur."
--
--  KARAR: eşleme tablosu (`enabiz_kod_esleme`) yerine KODUN KENDİSİ tabloda.
--  Eşleme deseni iki liste tutmayı ve ikisini elle bağlamayı gerektiriyordu;
--  kurumun kendi bölüm adları zaten SKRS kliniklerinin bir alt kümesi. Bölüm
--  kodu = SKRS klinik kodu olunca e-Nabız gönderimi eşlemeye bakmadan doğru
--  kodu yazar.
--
--  KAYNAK: SKRS senkronu (`/api/entegrasyon/{id}/skrs-senkron`) iki listeyi
--  zaten çekiyor ve kod listelerine yazıyor:
--      KLİNİKLER            -> `skrs.klinik`   (165 değer)
--      PERSONEL BRANŞ KODU  -> `hekim.brans`   (106 değer)
--  Bu göç o listeleri TABLOYA taşır; SKRS'den yeniden çekildiğinde göç
--  tekrar çalıştırılarak tazelenebilir (kod ile eşleşir, ad güncellenir).
--
--  VERİ KAYBI VAR - BİLEREK: mevcut 61 bölüm ve 29 görev siliniyor. İkisi de
--  yedeklenir (`_yedek_departman_559`, `_yedek_personel_gorev_559`); bağlı
--  kayıt sayısı ölçüldü: başvuru 0, personel 0, randevu bölüm ayarı 1 satır
--  (o da siliniyor). Müşteri veritabanında bağlı kayıt VARSA bu göç
--  çalışmamalı - aşağıdaki sayım bunu kontrol eder ve durur.
-- =====================================================================

do $$
declare
    v_bagli  integer;
    v_klinik integer;
    v_brans  integer;
begin
    -- ------------------------------------------------------- emniyet ----
    select (select count(*) from public.belge_basvuru where coalesce(bolum_id, 0) <> 0)
         + (select count(*) from public.taraf_personel where coalesce(departman, 0) <> 0)
         + (select count(*) from public.taraf_personel where coalesce(gorev, '') <> '')
      into v_bagli;
    if v_bagli > 0 then
        raise exception '559 DURDU: bolum/gorev kayitlarina bagli % kayit var. '
                        'Once bunlar tasinmali - sessizce silinmemeli.', v_bagli;
    end if;

    select count(*) into v_klinik
      from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
     where kl.kod = 'skrs.klinik';
    select count(*) into v_brans
      from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
     where kl.kod = 'hekim.brans';
    if v_klinik = 0 or v_brans = 0 then
        raise exception '559 DURDU: SKRS listeleri bos (klinik %, brans %). '
                        'Once Entegrasyon > SKRS Senkron calistirilmali.', v_klinik, v_brans;
    end if;

    -- ------------------------------------------------------- yedekler ----
    if to_regclass('public._yedek_departman_559') is null then
        create table public._yedek_departman_559 as select * from public.departman;
    end if;
    if to_regclass('public._yedek_personel_gorev_559') is null then
        create table public._yedek_personel_gorev_559 as select * from public.personel_gorev;
    end if;
end $$;

-- GOREV KODU: SKRS brans kodu tabloda dursun (eslemeye gerek kalmasin).
alter table public.personel_gorev
    add column if not exists kod varchar(20) not null default '';

comment on column public.personel_gorev.kod is
  'SKRS personel brans kodu (559). Bos = kuruma ozel gorev.';
comment on column public.departman.kod is
  'SKRS klinik kodu (559). Bos = kuruma ozel bolum.';

do $$
declare
    v_sayi integer;
begin
    -- --------------------------------------------------------- bosalt ----
    -- Bolume bagli tek kayit: randevu bolum ayari (bolum silinince anlamsiz).
    delete from public.randevu_bolum_ayar;
    -- Ust birim bagi kendine: once koparilir, sonra silinir.
    update public.departman set ustbirim_id = null where ustbirim_id is not null;
    delete from public.personel_gorev;
    delete from public.departman;

    -- Kimlikler bastan: SKRS kodu ile id'nin karismamasi icin sayaci sifirla.
    alter sequence if exists public.departman_id_seq restart with 1;
    alter sequence if exists public.personel_gorev_id_seq restart with 1;

    -- ---------------------------------------------------- BOLUM <- SKRS ----
    insert into public.departman (kod, ad, durum, sira, randevu_verilebilir, ekleyen)
    select kd.deger::text, btrim(kd.ad), case when kd.aktif = 1 then 1 else 0 end,
           coalesce(kd.sira, 0), 1, 0
      from public.kod_deger kd
      join public.kod_liste kl on kl.id = kd.liste_id
     where kl.kod = 'skrs.klinik'
     order by btrim(kd.ad);
    get diagnostics v_sayi = row_count;
    raise notice '559: % bolum SKRS kliniklerinden yazildi.', v_sayi;

    -- ---------------------------------------------------- GOREV <- SKRS ----
    -- Gorev DEPARTMANDAN BAGIMSIZ acilir (departman_id = 0): SKRS bransi
    --   klinige degil KISIYE aittir; ayni brans birden cok klinikte calisir.
    insert into public.personel_gorev (kod, ad, departman_id, durum, sira, ekleyen)
    select kd.deger::text, btrim(kd.ad), 0,
           case when kd.aktif = 1 then 1 else 0 end, coalesce(kd.sira, 0), 0
      from public.kod_deger kd
      join public.kod_liste kl on kl.id = kd.liste_id
     where kl.kod = 'hekim.brans'
     order by btrim(kd.ad);
    get diagnostics v_sayi = row_count;
    raise notice '559: % gorev SKRS brans kodlarindan yazildi.', v_sayi;
end $$;
