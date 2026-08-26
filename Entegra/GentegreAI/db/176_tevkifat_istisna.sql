-- ============================================================================
--  Gentegre AI — TEVKIFAT ve KDV ISTISNASI
--  176_tevkifat_istisna.sql
--
--  Kullanici: "biri iade, biri KDV istisna, digeri tevkifatli 3 satis faturasi
--  olustur ve teste gonder."
--
--  EKSIKLIK: `belge.tipi` kod listesinde Tevkifatlı (22) ve KDV İstisna (24)
--  vardi ama satirda TEVKIFAT ORANI/KODU tutulacak alan yoktu; KDV muafiyet
--  kodu kolonu (`belge_satir.kdv_muafiyeti`) da bos bir kod listesine
--  bakiyordu. Ikisi de GIB'e giden belgede ZORUNLU alanlar.
--
--  TEVKIFAT NEDIR: KDV'nin bir kismini alici dogrudan devlete oder. Fatura
--  KDV'yi tam gosterir, tevkifat tutarini duser; odenecek = KDV - tevkifat.
--  Oran KODA baglidir (GIB listesi): 601 = 5/10, 617 = 4/10 vb.
--
--  ORAN SATIRDA: ayni faturada farkli tevkifat oranli kalemler olabilir
--  (Delphi de satir bazli tasiyor).
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge_satir
    add column if not exists tevkifat_kodu  varchar(4)   not null default '',
    add column if not exists tevkifat_orani numeric(5,2) not null default 0;

comment on column public.belge_satir.tevkifat_kodu is
  'GIB tevkifat kodu (601, 617...). Bos = tevkifatsiz (176).';
comment on column public.belge_satir.tevkifat_orani is
  'Tevkifat orani YUZDE olarak (50 = 5/10). KDV tutarinin bu yuzdesi alicida kalir (176).';

-- ------------------------------------------------- tevkifat kod listesi -----
insert into public.kod_liste (kod, ad)
select 'belge.tevkifat', 'Tevkifat Kodu'
 where not exists (select 1 from public.kod_liste where kod = 'belge.tevkifat');

-- GIB tevkifat kod listesinin yaygin kullanilanlari. `deger` kodun sayisal
--   halidir; oran ADIN icinde yaziyor - kullanici oranla birlikte secer.
insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
select l.id, v.deger, -1, v.ad, v.sira, 1
  from public.kod_liste l,
       (values (601, '601 - Yapım İşleri (4/10)',                        1::smallint),
               (602, '602 - Etüt, Plan-Proje, Danışmanlık (9/10)',       2::smallint),
               (603, '603 - Makine, Teçhizat, Demirbaş Tamir (7/10)',    3::smallint),
               (604, '604 - Yemek Servisi ve Organizasyon (5/10)',       4::smallint),
               (605, '605 - İşgücü Temin Hizmetleri (9/10)',             5::smallint),
               (606, '606 - Yapı Denetim Hizmetleri (9/10)',             6::smallint),
               (607, '607 - Fason Tekstil, Konfeksiyon (7/10)',          7::smallint),
               (608, '608 - Turistik Mağazalara Aracılık (9/10)',        8::smallint),
               (609, '609 - Spor Kulüplerine Reklam (9/10)',             9::smallint),
               (610, '610 - Temizlik, Çevre, Bahçe Bakım (9/10)',       10::smallint),
               (611, '611 - Servis Taşımacılığı (5/10)',                11::smallint),
               (612, '612 - Her Türlü Baskı ve Basım (7/10)',           12::smallint),
               (613, '613 - Külçe Metal Teslimi (7/10)',                13::smallint),
               (614, '614 - Bakır, Çinko, Alüminyum Ürünleri (7/10)',   14::smallint),
               (615, '615 - Hurda Metal Teslimi (7/10)',                15::smallint),
               (616, '616 - Ağaç ve Orman Ürünleri (5/10)',             16::smallint),
               (617, '617 - Diğer Hizmetler (5/10)',                    17::smallint))
         as v(deger, ad, sira)
 where l.kod = 'belge.tevkifat'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger and d.dil = -1);

-- Kod -> oran: JSON ureticisi ve dogrulama ayni kaynaktan okusun (elle girilen
--   oran koda uymazsa GIB sematronu reddeder).
create or replace function public.fn_tevkifat_orani(p_kod text)
returns numeric language sql immutable as $$
    select case regexp_replace(coalesce(p_kod, ''), '\D', '', 'g')
             when '601' then 40 when '602' then 90 when '603' then 70
             when '604' then 50 when '605' then 90 when '606' then 90
             when '607' then 70 when '608' then 90 when '609' then 90
             when '610' then 90 when '611' then 50 when '612' then 70
             when '613' then 70 when '614' then 70 when '615' then 70
             when '616' then 50 when '617' then 50
             else 0 end::numeric
$$;

comment on function public.fn_tevkifat_orani(text) is
  'GIB tevkifat kodunun resmi orani (yuzde). 617 -> 50 (5/10) - 176.';

-- ------------------------------------------------ KDV muafiyet listesi ------
insert into public.kod_liste (kod, ad)
select 'belge.kdv_muafiyeti', 'KDV İstisna Kodu'
 where not exists (select 1 from public.kod_liste where kod = 'belge.kdv_muafiyeti');

-- GIB KDV istisna kodlarinin yaygin olanlari. 351 "Diğerleri" varsayilandir -
--   bedelsiz/%100 iskontolu satista da bu kullanilir.
insert into public.kod_deger (liste_id, deger, dil, ad, sira, aktif)
select l.id, v.deger, -1, v.ad, v.sira, 1
  from public.kod_liste l,
       (values (201, '201 - Mal İhracatı',                          1::smallint),
               (202, '202 - Hizmet İhracatı',                       2::smallint),
               (213, '213 - Diplomatik İstisna',                    3::smallint),
               (301, '301 - Teşvikli Yatırım Mal Teslimi',          4::smallint),
               (302, '302 - Liman ve Hava Meydanı Hizmetleri',      5::smallint),
               (325, '325 - Ulusal Güvenlik Kuruluşlarına Teslim',  6::smallint),
               (350, '350 - Serbest Bölgelerdeki Müşteriler',       7::smallint),
               (351, '351 - Diğerleri',                             8::smallint))
         as v(deger, ad, sira)
 where l.kod = 'belge.kdv_muafiyeti'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger and d.dil = -1);

-- ------------------------------------------------------- iade referansi -----
-- Iade faturasi (tipi=2) hangi faturayi iade ediyor: `belge.kaynak_id` zaten
--   donusum zincirini tasiyor ama iade AYRI bir bag - iade edilen fatura
--   donusturulmus degildir. GIB schematron 10003 bu referansi ZORUNLU tutar.
alter table public.belge
    add column if not exists iade_belge_id integer null references public.belge(id);

comment on column public.belge.iade_belge_id is
  'Iade faturasinin (tipi=2) iade ettigi ORIJINAL fatura - GIB billingReference (176).';

create index if not exists ix_belge_iade on public.belge(iade_belge_id)
    where iade_belge_id is not null;

do $$
begin
    raise notice '176 tamam: tevkifat (satir kodu/orani + kod listesi), KDV istisna kod listesi, iade referansi.';
end $$;
