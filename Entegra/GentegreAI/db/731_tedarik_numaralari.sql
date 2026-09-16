-- =====================================================================
--  731_tedarik_numaralari.sql
--  ECZANE · BİYOMEDİKAL · SATINALMA belgelerinin NUMARA ŞABLONLARI.
--
--  Sekiz yeni numara türü (910-917) ve her biri için üretici tetik. 722-724
--  bu tabloları `*_no` kolonlarıyla açmış ama numarayı KİMİN üreteceğini
--  söylememişti; alanlar boş kalıyor, kullanıcı elle dolduruyordu.
--
--  ŞABLONA BAĞLI, KODA DEĞİL (634/635 kuralı). Numaranın biçimini kurum
--    belirler: ön ek, başlangıç, hane, yıl kapsamı, şube. Kodda sabit bir
--    biçim yazsaydık her kurum aynı numarayı almak zorunda kalırdı.
--
--  ŞABLON YOKSA ALAN BOŞ KALIR. Numarası olmayan bir alana kendiliğinden
--    numara basmak, kurumun hiç istemediği bir kimliği kayıtlara yazmak
--    olurdu. Kurum Genel Ayarlar › Numaralama'dan satır açınca başlar.
--    Mevcut kayıtlar da GERİYE DÖNÜK NUMARALANMAZ - sonradan verilen numara,
--    o gün orada olmayan bir kimliği belgeye yazmaktır.
--
--  DOLU GELEN NUMARAYA DOKUNULMAZ: göç/aktarım kendi numarasını taşır,
--    kullanıcı da elle yazabilir (kısmi unique indeksler bunu zaten korur).
--
--  TETİK YAZAR, UÇ DEĞİL (719'da öğrenilen ders). Bu kayıtların çoğu iki
--    yoldan doğuyor - generic karttan ve akış ucundan. Numarayı uca koysaydık
--    karttan açılan kayıt numarasız kalır ve "bazısında var bazısında yok"
--    diye görünürdü.
--
--  SİPARİŞ NUMARASI BURADA YOK. Alış siparişi `belge` tür 9'dur ve belge
--    hattının kendi numaralama yolu var (Genel Ayarlar › Numaralama › Alış
--    Belgeleri). İkinci bir üretici koysaydık aynı belgeye iki numara
--    verilebilirdi.
--
--  KONTROLLÜ İLAÇ DEFTERİ DE BURADA YOK (730). Defter numarası mevzuatın
--    istediği KESİNTİSİZ SERİDİR ve kırmızı/yeşil için ayrı akar; şablon
--    sistemi "iki ayrı defter" kuralını ifade edemez. Kendi tetiğinde kalıyor.
-- =====================================================================

-- ========================================================= tür listesi ==
-- Sıra TEDARİK ZİNCİRİNİN SIRASI: talep > teklif > mal kabul > eczane
--   hazırlama > imha > demirbaş > kalibrasyon > iş emri. Alfabetik dizseydik
--   ekranda birbiriyle ilgisiz satırlar yan yana gelirdi.
create or replace view public.v_numara_turu_tedarik as
 select 915 as id, 'Satınalma Talep No'::varchar as ad, 1::smallint as aktif,
        1::smallint as sira
union all
 select 916, 'Teklif / İhale No'::varchar,      1::smallint, 2::smallint
union all
 select 917, 'Mal Kabul Tutanak No'::varchar,   1::smallint, 3::smallint
union all
 select 910, 'Eczane Hazırlama No'::varchar,    1::smallint, 4::smallint
union all
 select 911, 'İlaç İmha Tutanak No'::varchar,   1::smallint, 5::smallint
union all
 select 912, 'Demirbaş No'::varchar,            1::smallint, 6::smallint
union all
 select 913, 'Kalibrasyon Kayıt No'::varchar,   1::smallint, 7::smallint
union all
 select 914, 'İş Emri No'::varchar,             1::smallint, 8::smallint;

comment on view public.v_numara_turu_tedarik is
  '731: eczane / biyomedikal / satinalma belge numara turleri (910-917). '
  'Siparis numarasi belge hattinda (tur 9), kontrollu defter kendi tetiginde (730).';

-- AYARI OLMAYAN TÜR DE SATIR OLARAK GÖRÜNÜR (636 deseni): `numara_sablonu`dan
--   okusaydı yalnız ayarlanmış türler çizilir, kullanıcı ötekilerin var
--   olduğunu hiç göremezdi. Ayarsız tür `id = 0` satırı olarak gelir; ekran
--   ona tıklanınca "yeni" kartını türü seçili açar.
create or replace view public.v_numara_tedarik as
 select n.id, n.tur, t.ad as tur_adi, t.sira, n.baslama_tarihi, n.on_ek,
        n.baslama_no, n.hane, n.sube_id, n.elle_girilir, n.durum
   from public.numara_sablonu n
   join public.v_numara_turu_tedarik t on t.id = n.tur
union all
 select 0, t.id, t.ad, t.sira, null::date, ''::varchar, ''::varchar,
        0, null::integer, null::smallint, null::smallint
   from public.v_numara_turu_tedarik t
  where not exists (select 1 from public.numara_sablonu n where n.tur = t.id);

comment on view public.v_numara_tedarik is
  '731: numaralama ekranindaki "Tedarik Belgeleri" gridi. Ayari olmayan tur '
  'id = 0 satiri olarak gelir - kullanici turun var oldugunu gorsun.';

-- ================================================ eksik benzersiz indeks ==
-- İKİ TUTANAK AYNI NUMARAYI TAŞIMAMALI. 722/724'te öteki numaralara kısmi
--   unique konmuş ama bu ikisi atlanmış; numaralamayı açarken eksiği de
--   kapatıyoruz - numaralanan bir alanın benzersizliği korunmazsa numara
--   kimlik olmaktan çıkar. BOŞ OLANLAR DIŞARIDA (şablonsuz kurumda hepsi boş).
create unique index if not exists ux_eczane_hazirlama_no
  on public.eczane_hazirlama (sube_id, hazirlama_no) where hazirlama_no <> '';
create unique index if not exists ux_satinalma_kabul_no
  on public.satinalma_kabul (sube_id, tutanak_no) where tutanak_no <> '';

-- ===================================================== üretici tetikler ==

-- ------------------------------------------------- satınalma talep no (915)
create or replace function public.fn_satinalma_talep_no_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.talep_no), '') = '' then
        new.talep_no := public.fn_numara_kimlik_uret(
            915, coalesce(new.sube_id, 0), 'satinalma_talep', 'talep_no',
            coalesce(new.tarih, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_satinalma_talep_no on public.satinalma_talep;
create trigger tg_satinalma_talep_no
  before insert on public.satinalma_talep
  for each row execute function public.fn_satinalma_talep_no_uret();

-- ---------------------------------------------------------- teklif no (916)
create or replace function public.fn_satinalma_teklif_no_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.teklif_no), '') = '' then
        -- DAVET TARİHİ HENÜZ YOK OLABİLİR: teklif kaydı davetten önce açılır
        --   (kriterler, ağırlıklar hazırlanır). Bugünün şablonuna düşeriz.
        new.teklif_no := public.fn_numara_kimlik_uret(
            916, coalesce(new.sube_id, 0), 'satinalma_teklif', 'teklif_no',
            coalesce(new.davet_tarihi, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_satinalma_teklif_no on public.satinalma_teklif;
create trigger tg_satinalma_teklif_no
  before insert on public.satinalma_teklif
  for each row execute function public.fn_satinalma_teklif_no_uret();

-- ------------------------------------------------- mal kabul tutanak (917)
create or replace function public.fn_satinalma_kabul_no_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.tutanak_no), '') = '' then
        new.tutanak_no := public.fn_numara_kimlik_uret(
            917, coalesce(new.sube_id, 0), 'satinalma_kabul', 'tutanak_no',
            coalesce(new.tarih, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_satinalma_kabul_no on public.satinalma_kabul;
create trigger tg_satinalma_kabul_no
  before insert on public.satinalma_kabul
  for each row execute function public.fn_satinalma_kabul_no_uret();

-- ----------------------------------------------- eczane hazırlama no (910)
create or replace function public.fn_eczane_hazirlama_no_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.hazirlama_no), '') = '' then
        -- PLANLANAN GÜN esas alınır: kür takvimi ileri tarihli açılır ve
        --   numaranın yıl kapsamı hazırlamanın yapılacağı yıla düşmeli.
        new.hazirlama_no := public.fn_numara_kimlik_uret(
            910, coalesce(new.sube_id, 0), 'eczane_hazirlama', 'hazirlama_no',
            coalesce(new.planlanan::date, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_eczane_hazirlama_no on public.eczane_hazirlama;
create trigger tg_eczane_hazirlama_no
  before insert on public.eczane_hazirlama
  for each row execute function public.fn_eczane_hazirlama_no_uret();

-- -------------------------------------------------- imha tutanak no (911)
create or replace function public.fn_eczane_imha_no_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.tutanak_no), '') = '' then
        new.tutanak_no := public.fn_numara_kimlik_uret(
            911, coalesce(new.sube_id, 0), 'eczane_imha', 'tutanak_no',
            coalesce(new.tarih, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_eczane_imha_no on public.eczane_imha;
create trigger tg_eczane_imha_no
  before insert on public.eczane_imha
  for each row execute function public.fn_eczane_imha_no_uret();

-- ------------------------------------------------------- demirbaş no (912)
-- SAYAÇ ŞUBEYE GÖRE DEĞİL, KURUM GENELİNDE akar (p_sube_id = 0). Sebebi
--   `ux_demirbas_kod`: benzersizlik şube bazlı değil, kod kolonunun
--   KENDİSİNDE. Şube başına ayrı sayaç verseydik iki şube aynı numarayı
--   üretir ve ikincisi kaydedilemezdi. Şubeye göre ayırmak isteyen kurum
--   şablonun ön ekini şube bazlı tanımlar - orada ayrım ön ektedir.
create or replace function public.fn_demirbas_kod_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.kod), '') = '' then
        new.kod := public.fn_numara_kimlik_uret(
            912, 0, 'demirbas', 'kod',
            coalesce(new.alis_tarihi, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_demirbas_kod on public.demirbas;
create trigger tg_demirbas_kod
  before insert on public.demirbas
  for each row execute function public.fn_demirbas_kod_uret();

-- ------------------------------------------------ kalibrasyon kayıt (913)
create or replace function public.fn_demirbas_kalib_no_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.kayit_no), '') = '' then
        new.kayit_no := public.fn_numara_kimlik_uret(
            913, coalesce(new.sube_id, 0), 'demirbas_kalibrasyon', 'kayit_no',
            coalesce(new.tarih, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_demirbas_kalib_no on public.demirbas_kalibrasyon;
create trigger tg_demirbas_kalib_no
  before insert on public.demirbas_kalibrasyon
  for each row execute function public.fn_demirbas_kalib_no_uret();

-- ---------------------------------------------------------- iş emri (914)
create or replace function public.fn_demirbas_is_emri_no_uret()
returns trigger language plpgsql as $tg$
begin
    if coalesce(trim(new.is_emri_no), '') = '' then
        -- BİLDİRİM ANI esas: arıza ne zaman bildirildiyse numara o güne ait.
        --   Planlanan bakımda bildirim damgası boş olabilir, planlanan güne düşer.
        new.is_emri_no := public.fn_numara_kimlik_uret(
            914, coalesce(new.sube_id, 0), 'demirbas_is_emri', 'is_emri_no',
            coalesce(new.bildirim_zamani::date, new.planlanan, current_date));
    end if;
    return new;
end;
$tg$;

drop trigger if exists tg_demirbas_is_emri_no on public.demirbas_is_emri;
create trigger tg_demirbas_is_emri_no
  before insert on public.demirbas_is_emri
  for each row execute function public.fn_demirbas_is_emri_no_uret();
