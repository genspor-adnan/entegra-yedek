-- ============================================================================
--  Gentegre AI — ENTEGRATOR BAGIMSIZLIGI (e-Belge gonderimi)
--  167_ebelge_entegrator.sql
--
--  Kullanici: "sadece izibiz ile degil baska entegrator ile de calisabiliriz,
--  ona gore duzenle."
--
--  SORUN: gonderim govdesi (166) izibiz'in JSON semasina gore yazilmisti ve
--  entegrator adi ayarda SERBEST METINDI ("İzibiz"). Baska entegratore gecen
--  musteride kod her yerde degisirdi.
--
--  YAPI - UC KATMAN:
--    1. ORTAK DOGRULAMA  `fn_ebelge_gonderim_dogrula`  -> GIB kurali; entegrator
--       fark etmez (firma bilgisi, alici kimligi, kalem/tutar, senaryo).
--    2. ADAPTOR          `fn_ebelge_govde_<kod>`       -> o entegratorun bekledigi
--       govde. izibiz'inki 166'da. Yeni entegrator = YENI FONKSIYON.
--    3. DAGITICI         `fn_ebelge_gonderim_govdesi`  -> secili entegratoru
--       katalogdan okur, adaptorunu cagirir. Uygulama YALNIZ bunu bilir.
--
--  Katalogda `govde_fn` bos olan entegrator "taniniyor ama gonderim uretecimiz
--  yok" demektir: secilebilir (kimlik/URL ayarlari tutulur), gonderimde ACIK
--  hata verir. Sessizce izibiz govdesi uretmek en kotu sonuc olurdu.
--
--  URL'ler: `efatura.test_url` / `efatura.uretim_url` ayarlari ELLE girilebilir;
--  bos birakilirsa katalogdaki varsayilan kullanilir. Entegrator degistiginde
--  eski URL'in ayarda kalip yanlis sunucuya gitmesini onler.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- katalog -----
create table if not exists public.ebelge_entegrator (
    kod               varchar(20)  primary key,
    ad                varchar(60)  not null,
    -- Govdenin BICIMI: 1 JSON (REST), 2 UBL-XML (SOAP/REST). Uygulama istegi
    --   buna gore kurar; adaptor de bu bicime uygun uretir.
    gonderim_bicimi   smallint     not null default 1,
    test_url          varchar(200) not null default '',
    uretim_url        varchar(200) not null default '',
    -- Govdeyi ureten PG fonksiyonu. Bos = adaptor henuz yazilmadi.
    govde_fn          varchar(80)  not null default '',
    aciklama          varchar(200) not null default '',
    sira              smallint     not null default 0,
    aktif             smallint     not null default 1,
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamp    not null default now()::timestamp,
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamp
);

comment on table public.ebelge_entegrator is
  'e-Belge entegrator katalogu: kod, gonderim bicimi, varsayilan URL''ler ve govde ureteci (167).';
comment on column public.ebelge_entegrator.govde_fn is
  'Gonderim govdesini ureten fonksiyon (fn_ebelge_govde_<kod>). Bos = bu entegrator icin uretec yok.';

-- Turkiye'de yaygin ozel entegratorler. Kimlik/URL ayarlari her biri icin ayni
--   anahtarlarda tutulur (ebelge.kullanici / ebelge.sifre / ebelge.vkn).
insert into public.ebelge_entegrator (kod, ad, gonderim_bicimi, test_url, uretim_url, govde_fn, aciklama, sira)
values
  ('izibiz',    'İzibiz',              1, 'https://apitest.izibiz.com.tr', 'https://api.izibiz.com.tr',
   'public.fn_ebelge_govde_izibiz', 'REST + JSON. Gönderim üreteci hazır.', 10),
  ('uyumsoft',  'Uyumsoft',            2, '', '', '', 'SOAP + UBL-XML. Üreteç henüz yok.', 20),
  ('edm',       'EDM Bilişim',         2, '', '', '', 'SOAP + UBL-XML. Üreteç henüz yok.', 30),
  ('sovos',     'Sovos (Foriba)',      2, '', '', '', 'SOAP + UBL-XML. Üreteç henüz yok.', 40),
  ('veriban',   'Veriban',             2, '', '', '', 'SOAP + UBL-XML. Üreteç henüz yok.', 50),
  ('elogo',     'e-Logo',              2, '', '', '', 'SOAP + UBL-XML. Üreteç henüz yok.', 60),
  ('nes',       'NES Bilgi',           2, '', '', '', 'SOAP + UBL-XML. Üreteç henüz yok.', 70),
  ('turkcell',  'Turkcell e-Şirket',   2, '', '', '', 'SOAP + UBL-XML. Üreteç henüz yok.', 80),
  ('digitalp',  'Digital Planet',      2, '', '', '', 'SOAP + UBL-XML. Üreteç henüz yok.', 90),
  ('mysoft',    'Mysoft',              2, '', '', '', 'SOAP + UBL-XML. Üreteç henüz yok.', 100),
  ('diger',     'Diğer',               1, '', '', '', 'Katalogda olmayan entegratör.', 999)
on conflict (kod) do update
   set ad = excluded.ad,
       -- URL ve uretec MERKEZDEN guncellenir (entegrator adres degistirirse),
       --   ama musterinin ELLE girdigi ayarlar `referans`ta durur ve ustundur.
       gonderim_bicimi = excluded.gonderim_bicimi,
       govde_fn = excluded.govde_fn,
       aciklama = excluded.aciklama,
       sira = excluded.sira,
       degistirme_tarihi = now()::timestamp;

-- izibiz URL'lerini SIFIRLAMA: yukaridaki update govde/aciklama tazeliyor ama
--   URL'ler yalniz BOSSA doldurulur - musteri ozel bir uc nokta girmis olabilir.
update public.ebelge_entegrator
   set test_url   = coalesce(nullif(test_url, ''),   'https://apitest.izibiz.com.tr'),
       uretim_url = coalesce(nullif(uretim_url, ''), 'https://api.izibiz.com.tr')
 where kod = 'izibiz';

-- Ayar ekraninin combo kaynagi (kod tablosu sozlesmesi: id / ad / aktif).
--   DUSUR+KUR: 171 bu gorunumu sayisal id ile yeniden kuruyor; `create or
--   replace` kolon tipini degistiremedigi icin dosya tek basina calistirilinca
--   patliyordu.
drop view if exists public.v_ebelge_entegrator_lookup;
create view public.v_ebelge_entegrator_lookup as
    select e.kod as id, e.ad, e.aktif
      from public.ebelge_entegrator e
     order by e.sira, e.ad;

-- --------------------------------------------------- ayar degerini koda cevir
-- BILIM'den tasinirken serbest metin gelmisti ("İzibiz"). Kod uzayina cekilir;
--   eslesmeyen deger 'diger' YAPILMAZ - kullanicinin yazdigi bilgi kaybolmasin
--   diye oldugu gibi birakilir ve gonderimde acik hata verir.
do $$
declare v_ham text; v_kod text;
begin
    select btrim(coalesce(deger, '')) into v_ham
      from public.referans where anahtar = 'ebelge.entegrator';

    if coalesce(v_ham, '') = '' then
        return;
    end if;
    if exists (select 1 from public.ebelge_entegrator where kod = v_ham) then
        return;                                   -- zaten kod
    end if;

    select kod into v_kod from public.ebelge_entegrator
     where lower(ad) = lower(v_ham)
        or lower(replace(ad, ' ', '')) = lower(replace(v_ham, ' ', ''))
     limit 1;

    if v_kod is not null then
        update public.referans set deger = v_kod, degistirme_tarihi = now()::timestamp
         where anahtar = 'ebelge.entegrator';
        raise notice '167: ebelge.entegrator "%" -> "%" koduna cevrildi.', v_ham, v_kod;
    else
        raise notice '167 UYARI: ebelge.entegrator degeri "%" katalogda yok; ayardan yeniden secilmeli.', v_ham;
    end if;
end $$;

-- ------------------------------------------------- gonderilen belgenin izi --
-- Belge HANGI entegratorle gitti: ayar sonradan degisince gecmis bozulmasin
--   (durum sorgusu / iptal eski entegratore gider).
alter table public.e_belge
    add column if not exists entegrator varchar(20) not null default '';

comment on column public.e_belge.entegrator is
  'Belgenin gonderildigi entegrator kodu; ayar sonradan degisse de gecmis dogru kalir (167).';

-- ------------------------------------------------------ secili entegrator ---
create or replace function public.fn_ebelge_entegrator()
returns text language sql stable as $$
    select coalesce(nullif(btrim((select deger from public.referans
                                   where anahtar = 'ebelge.entegrator')), ''), '')
$$;

comment on function public.fn_ebelge_entegrator() is
  'Ayarlardaki secili entegrator kodu (167).';

-- Etkin uc nokta: elle girilen ayar > katalog varsayilani.
create or replace function public.fn_ebelge_url(p_test boolean default null)
returns text language plpgsql stable as $$
declare
    v_kod  text := public.fn_ebelge_entegrator();
    v_test boolean;
    v_url  text;
begin
    v_test := coalesce(p_test,
        coalesce((select deger from public.referans where anahtar = 'ebelge.test_aktif'), '0') = '1');

    select btrim(coalesce(deger, '')) into v_url
      from public.referans
     where anahtar = case when v_test then 'efatura.test_url' else 'efatura.uretim_url' end;

    if coalesce(v_url, '') = '' then
        select case when v_test then e.test_url else e.uretim_url end into v_url
          from public.ebelge_entegrator e where e.kod = v_kod;
    end if;

    return coalesce(v_url, '');
end $$;

comment on function public.fn_ebelge_url(boolean) is
  'Secili entegratorun etkin uc noktasi: ayarda girilen URL, yoksa katalog varsayilani (167).';

-- ------------------------------------------------------- ortak dogrulama ----
-- ENTEGRATORDEN BAGIMSIZ gonderim on-kosullari. Adaptorler bunu cagirir; boylece
--   ikinci entegrator eklendiginde kurallar tekrar yazilmaz ve ayrisma olmaz.
create or replace function public.fn_ebelge_gonderim_dogrula(p_belge_id integer)
returns void
language plpgsql stable as $$
declare
    b record;
    g record;
begin
    select bl.tur, bl.tipi, bl.senaryo, bl.sube_id, bl.taraf_vkno, bl.genel_toplam,
           e.belge_turu, e.durum as e_durum
      into b
      from public.belge bl
      join public.e_belge e on e.belge_id = bl.id
     where bl.id = p_belge_id
     order by e.id desc
     limit 1;

    if not found then
        raise exception 'Belge için hazırlanmış e-Belge yok (%). Önce "e-Fatura Hazırla" çalıştırın.', p_belge_id;
    end if;

    -- Gonderilmis belge yeniden gonderilmez (mukerrer belge = GIB'de iki fatura).
    if b.e_durum in (2, 12, 52) then
        raise exception 'Bu belge zaten gönderilmiş.';
    end if;

    -- Desteklenmeyen senaryolar: eksik govde uretip GIB'e gondermek yerine burada
    --   durur. Sematron reddi belge gonderildikten SONRA gorunur, pahali.
    if coalesce(b.senaryo, 0) in (3, 7, 8) then
        raise exception 'Bu senaryo (%) için gönderim gövdesi henüz üretilmiyor (ihracat / kamu / ilaç-tıbbi cihaz).',
                        b.senaryo;
    end if;
    -- Tevkifat 176'da desteklendi; burada engel YOK. Tevkifat kodu/orani
    --   eksikse gövde ureticisi zaten oran 0 hesaplar ve fatura tevkifatsiz
    --   gider - sessiz yanlis olmasin diye kod girilmis ama oran cozulemiyorsa
    --   asagida uyarilir.
    if coalesce(b.tipi, 0) = 22
       and not exists (select 1 from public.belge_satir s
                        where s.belge_id = p_belge_id
                          and coalesce(nullif(s.tevkifat_orani, 0),
                                       public.fn_tevkifat_orani(s.tevkifat_kodu)) > 0) then
        raise exception 'Tevkifatlı fatura seçildi ama hiçbir kalemde tevkifat kodu/oranı yok.';
    end if;

    select * into g from public.v_ebelge_gonderici
     where sube_id = coalesce(nullif(b.sube_id, 0), (select min(id) from public.sube));
    if not found then
        raise exception 'Belgenin şubesi bulunamadı; firma bilgileri girilmemiş.';
    end if;
    if not g.ebelge_hazir then
        raise exception 'Firma bilgileri eksik (resmî unvan, VKN, vergi dairesi, adres, il). Yönetim › Firma Bilgileri''nden tamamlayın.';
    end if;

    if coalesce(btrim(b.taraf_vkno), '') = '' then
        raise exception 'Alıcının vergi/kimlik numarası yok; e-Belge gönderilemez.';
    end if;
    -- HANE KONTROLU (kullanici testinde yakalandi): 14 haneli "VKN" ile
    --   gonderilen belge entegratorden schematron 816 ("gecersiz taraf bilgisi
    --   tipi") ile doner. Hatayi GIB-den once burada yakalamak, numarayi
    --   harcamadan duzeltme sansi verir.
    if length(regexp_replace(b.taraf_vkno, '\D', '', 'g')) not in (10, 11) then
        raise exception 'Alıcının vergi/kimlik numarası % hane ("%"); VKN 10, TCKN 11 hane olmalı.',
              length(regexp_replace(b.taraf_vkno, '\D', '', 'g')), btrim(b.taraf_vkno);
    end if;
    if not exists (select 1 from public.belge_satir s where s.belge_id = p_belge_id) then
        raise exception 'Belgede kalem yok.';
    end if;
    if coalesce(b.genel_toplam, 0) <= 0 then
        raise exception 'Belge tutarı sıfır; e-Belge gönderilemez.';
    end if;
end $$;

comment on function public.fn_ebelge_gonderim_dogrula(integer) is
  'Entegratorden BAGIMSIZ gonderim on-kosullari (firma/alici/kalem/tutar/senaryo). Her adaptor bunu cagirir (167).';

-- --------------------------------------------------------------- dagitici ---
-- Uygulamanin bildigi TEK giris: entegratoru katalogdan cozer, adaptorunu cagirir.
create or replace function public.fn_ebelge_gonderim_govdesi(
        p_belge_id integer, p_entegrator text default null)
returns table (entegrator varchar, bicim smallint, govde jsonb)
language plpgsql stable as $$
declare
    v_kod  text := coalesce(nullif(btrim(p_entegrator), ''), public.fn_ebelge_entegrator());
    e      record;
    v_json jsonb;
begin
    if coalesce(v_kod, '') = '' then
        raise exception 'Entegratör seçilmemiş. Ayarlar › Satış Belgeleri › e-Belge › Entegratör''den seçin.';
    end if;

    select * into e from public.ebelge_entegrator where kod = v_kod;
    if not found then
        raise exception '"%" tanımlı bir entegratör değil. Ayarlar › Satış Belgeleri › e-Belge''den yeniden seçin.', v_kod;
    end if;
    if e.aktif <> 1 then
        raise exception '"%" entegratörü pasif.', e.ad;
    end if;
    if coalesce(btrim(e.govde_fn), '') = '' then
        raise exception '% için gönderim gövdesi üreteci henüz yazılmadı; şu an yalnızca İzibiz gönderimi yapılabiliyor.', e.ad;
    end if;

    -- Adaptor dinamik cagrilir: yeni entegrator eklerken bu fonksiyon degismez.
    execute format('select %s($1)', e.govde_fn) into v_json using p_belge_id;

    return query select e.kod, e.gonderim_bicimi, v_json;
end $$;

comment on function public.fn_ebelge_gonderim_govdesi(integer, text) is
  'e-Belge gonderim govdesi: secili entegratorun adaptorunu cagirir, kod+bicim ile birlikte dondurur (167). Uygulama yalniz bunu cagirir.';

do $$
declare v_kod text := public.fn_ebelge_entegrator();
begin
    raise notice '167 tamam: % entegrator katalogda, secili "%", URL: %',
        (select count(*) from public.ebelge_entegrator), v_kod, public.fn_ebelge_url();
end $$;
