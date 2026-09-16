-- 707: MEDULA (SGK) ENTEGRASYONU — çekirdek şema.
--
-- Kaynak tasarım `Ekranlar/Medula/medula_sureci.html` ve beş mockup: hasta
-- kabul / provizyon, hizmet kaydı, e-reçete / e-rapor, fatura & dönem,
-- gönderim kuyruğu & ayarlar.
--
-- TEMEL KARARLAR
--  1. YERELDE ÖNCE YAZ, SONRA GÖNDER. Hasta bekletilmez: provizyon, hizmet
--     kaydı, reçete, fatura önce bizim tabloya yazılır; Medula çağrısı
--     `medula_kuyruk` satırıdır. Kapı kapalıysa satır "bekliyor" kalır ve
--     sonra tekrar denenir - hasta kabul ekranı Medula'nın nabzına bağlı
--     olmamalı.
--  2. HER ÇAĞRI BİR SATIRDIR (`medula_kuyruk`): servis, işlem, kaynak, istek,
--     yanıt, sonuç kodu, deneme. "Bu takip no nereden geldi" ve "neden hata
--     aldı" sorusu satırdan okunur; yeniden gönderim aynı satırı tekrar dener.
--  3. PROVİZYON MEVCUT TABLODA (`belge_provizyon`, 299): sgk_* alanları
--     zaten var; çıkış zamanı ve branş kodu eklenir. Ayrı "takip" tablosu
--     açmak aynı bilgiyi iki yerde tutmak olurdu.
--  4. HİZMET KAYDI SATIR BAŞINA (`medula_islem` ↔ `belge_satir`): Medula
--     kabul/red satır bazında gelir; başvuru düzeyinde tek durum "hangi satır
--     reddedildi"yi gizlerdi.
--  5. FATURA TAKİP BAŞINA, DÖNEM AY BAŞINA; dönem sonlandırma geri alınamaz ve
--     ayrı aksiyon yetkisidir (medula.donem).
--  6. KAPI SOYUTLANIR: bu sürümde SİMÜLASYON kapısı (SGK kuralları yerel
--     kurallarla taklit edilir: 1006 açık takip, 1013 müstehak değil, 1020
--     tescil eksik, 1200 çıkışsız fatura). Canlı SOAP kapısı aynı arayüzü
--     uygular; ekran ve tablolar değişmez.

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('medula.takip_tipi',     'Medula Takip Tipi'),
    ('medula.provizyon_tipi', 'Medula Provizyon Tipi'),
    ('medula.kuyruk_durum',   'Medula Gönderim Durumu'),
    ('medula.islem_durum',    'Medula Hizmet Kaydı Durumu'),
    ('medula.fatura_turu',    'Medula Fatura Türü'),
    ('medula.fatura_durum',   'Medula Fatura Durumu'),
    ('medula.donem_durum',    'Medula Dönem Durumu'),
    ('medula.rapor_turu',     'Medula Rapor Türü'),
    ('medula.itiraz_durum',   'Medula Kesinti İtiraz Durumu')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    ('medula.takip_tipi', 1, 'Ayaktan'), ('medula.takip_tipi', 2, 'Yatan'), ('medula.takip_tipi', 3, 'Günübirlik'),
    ('medula.provizyon_tipi', 1, 'Normal'), ('medula.provizyon_tipi', 2, 'Acil'), ('medula.provizyon_tipi', 3, 'İş kazası'),
    ('medula.provizyon_tipi', 4, 'Trafik kazası'), ('medula.provizyon_tipi', 5, 'Meslek hastalığı'),
    ('medula.kuyruk_durum', 1, 'Bekliyor'), ('medula.kuyruk_durum', 2, 'Gönderildi'), ('medula.kuyruk_durum', 3, 'Kabul'),
    ('medula.kuyruk_durum', 4, 'Hata'), ('medula.kuyruk_durum', 5, 'Elle müdahale'), ('medula.kuyruk_durum', 6, 'İptal'),
    ('medula.islem_durum', 1, 'Bekliyor'), ('medula.islem_durum', 2, 'Kabul'), ('medula.islem_durum', 3, 'Hata'),
    ('medula.islem_durum', 4, 'İptal'), ('medula.islem_durum', 5, 'Yerel (ücretli)'),
    ('medula.fatura_turu', 1, 'Ayaktan'), ('medula.fatura_turu', 2, 'Yatan'), ('medula.fatura_turu', 3, 'Günübirlik'), ('medula.fatura_turu', 4, 'Acil'),
    ('medula.fatura_durum', 1, 'Taslak'), ('medula.fatura_durum', 2, 'Kaydedildi'), ('medula.fatura_durum', 3, 'Dönemde'),
    ('medula.fatura_durum', 4, 'Dönem kapandı'), ('medula.fatura_durum', 5, 'İncelendi'), ('medula.fatura_durum', 6, 'Ödendi'), ('medula.fatura_durum', 7, 'İptal'),
    ('medula.donem_durum', 1, 'Açık'), ('medula.donem_durum', 2, 'Sonlandırıldı'), ('medula.donem_durum', 3, 'İncelemede'), ('medula.donem_durum', 4, 'Kapandı'),
    ('medula.rapor_turu', 1, 'İlaç kullanım raporu'), ('medula.rapor_turu', 2, 'Sevk raporu'), ('medula.rapor_turu', 3, 'İş göremezlik'),
    ('medula.rapor_turu', 4, 'Malzeme raporu'), ('medula.rapor_turu', 5, 'Refakat'),
    ('medula.itiraz_durum', 0, 'Edilmedi'), ('medula.itiraz_durum', 1, 'Edildi · bekliyor'), ('medula.itiraz_durum', 2, 'Kabul · iade'), ('medula.itiraz_durum', 3, 'Red')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d where d.liste_id = l.id and d.deger = v.deger);

-- ============================================================ ek kolonlar ==
alter table public.belge_provizyon add column if not exists sgk_cikis_zaman   timestamp;
alter table public.belge_provizyon add column if not exists sgk_cikis_sekli   smallint;
alter table public.belge_provizyon add column if not exists sgk_brans_kodu    varchar(10) not null default '';
alter table public.belge_provizyon add column if not exists sgk_hekim_tescil  varchar(20) not null default '';
alter table public.belge_provizyon add column if not exists sgk_kuyruk_id     bigint;
comment on column public.belge_provizyon.sgk_cikis_zaman is 'hastaCikisKayit zamanı (707); dolu takip fatura kesilebilir.';

alter table public.recete add column if not exists medula_recete_no varchar(20) not null default '';
alter table public.recete add column if not exists medula_kuyruk_id bigint;

alter table public.hizmet add column if not exists sut_kodu varchar(12) not null default '';
comment on column public.hizmet.sut_kodu is 'SUT kodu (707) - boşsa kod 6 haneli sayıysa o kullanılır.';
update public.hizmet set sut_kodu = kod where sut_kodu = '' and kod ~ '^[0-9]{6}$';

alter table public.taraf_personel add column if not exists medula_brans_kodu varchar(10) not null default '';

-- ================================================================== kuyruk ==
create table if not exists public.medula_kuyruk (
  id              bigint generated by default as identity primary key,
  sube_id         integer not null default 0,
  servis          varchar(40)  not null,           -- HastaKabulIslemleri · HizmetKayitIslemleri · ...
  islem           varchar(40)  not null,           -- hastaKabul · hizmetKayit · eReceteKayit · faturaKayit ...
  kaynak_tablo    varchar(40)  not null default '',
  kaynak_id       bigint,
  hasta_id        integer references public.taraf(id),
  belge_id        integer references public.belge(id),
  istek           jsonb not null default '{}'::jsonb,
  yanit           jsonb,
  sonuc_kod       varchar(10)  not null default '',
  sonuc_mesaj     varchar(400) not null default '',
  durum           smallint     not null default 1, -- medula.kuyruk_durum
  deneme          smallint     not null default 0,
  sonraki_deneme  timestamptz,
  gonderim        timestamptz,
  sure_ms         integer      not null default 0,
  oncelik         smallint     not null default 5, -- 1 hasta kabul (hasta bekliyor) ... 9 fatura
  kullanici_id    integer      not null default 0,
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_medula_kuyruk_durum on public.medula_kuyruk (durum, oncelik, id);
create index if not exists ix_medula_kuyruk_kaynak on public.medula_kuyruk (kaynak_tablo, kaynak_id);
create index if not exists ix_medula_kuyruk_belge on public.medula_kuyruk (belge_id);
comment on table public.medula_kuyruk is 'Medula çağrı günlüğü ve kuyruğu (707): her çağrı bir satır, yeniden gönderim aynı satırdan.';

-- ============================================================ hizmet kaydı ==
create table if not exists public.medula_islem (
  id              integer generated by default as identity primary key,
  sube_id         integer not null default 0,
  belge_id        integer not null references public.belge(id),
  belge_satir_id  integer references public.belge_satir(id),
  takip_no        varchar(40) not null default '',
  sut_kodu        varchar(12) not null default '',
  islem_adi       varchar(200) not null default '',
  adet            numeric(9,2) not null default 1,
  tutar           numeric(18,2) not null default 0,
  tarih           date not null default current_date,
  hekim_id        integer references public.taraf(id),
  dis_no          smallint,
  tetkik          smallint not null default 0,       -- 1 tetkik/radyoloji kaydı
  medula_sira     integer,
  durum           smallint not null default 1,       -- medula.islem_durum
  sonuc_kod       varchar(10) not null default '',
  sonuc_mesaj     varchar(400) not null default '',
  kuyruk_id       bigint references public.medula_kuyruk(id),
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_medula_islem_belge on public.medula_islem (belge_id, durum);
create unique index if not exists ux_medula_islem_satir on public.medula_islem (belge_satir_id) where belge_satir_id is not null and durum <> 4;

create table if not exists public.medula_tani (
  id              integer generated by default as identity primary key,
  belge_id        integer not null references public.belge(id),
  tani_id         integer references public.tani(id),
  icd_kod         varchar(10) not null,
  ana_tani        smallint not null default 0,
  dis_no          smallint,
  durum           smallint not null default 1,
  sonuc_kod       varchar(10) not null default '',
  kuyruk_id       bigint references public.medula_kuyruk(id),
  sube_id         integer not null default 0,
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_medula_tani_belge on public.medula_tani (belge_id);

-- =================================================================== rapor ==
create table if not exists public.medula_rapor (
  id              integer generated by default as identity primary key,
  sube_id         integer not null default 0,
  hasta_id        integer not null references public.taraf(id),
  muayene_id      integer references public.muayene(id),
  belge_id        integer references public.belge(id),
  hekim_id        integer references public.taraf(id),
  rapor_turu      smallint not null default 1,       -- medula.rapor_turu
  rapor_no        varchar(30) not null default '',
  icd_kod         varchar(10) not null default '',
  tani            varchar(200) not null default '',
  baslangic       date not null default current_date,
  bitis           date,
  heyet           smallint not null default 0,
  aciklama        varchar(400) not null default '',
  durum           smallint not null default 1,       -- 1 taslak · 2 imzalı · 3 Medula kabul · 4 iptal · 5 hata
  medula_sonuc    varchar(200) not null default '',
  kuyruk_id       bigint references public.medula_kuyruk(id),
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_medula_rapor_hasta on public.medula_rapor (hasta_id, durum);

create table if not exists public.medula_rapor_satir (
  id              integer generated by default as identity primary key,
  rapor_id        integer not null references public.medula_rapor(id) on delete cascade,
  etken_madde     varchar(200) not null,
  form            varchar(60) not null default '',
  doz             varchar(40) not null default '',
  gunluk          varchar(20) not null default '',
  aciklama        varchar(200) not null default '',
  sube_id         integer not null default 0,
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);

-- ================================================================== fatura ==
create table if not exists public.medula_donem (
  id              integer generated by default as identity primary key,
  sube_id         integer not null default 0,
  yil             smallint not null,
  ay              smallint not null,
  fatura_turu     smallint not null default 0,       -- 0 tümü
  fatura_sayisi   integer not null default 0,
  toplam          numeric(18,2) not null default 0,
  kesinti         numeric(18,2) not null default 0,
  odenen          numeric(18,2) not null default 0,
  odeme_tarihi    date,
  sonlandirma     timestamptz,
  icmal_no        varchar(30) not null default '',
  evrak_gonderim  timestamptz,
  durum           smallint not null default 1,       -- medula.donem_durum
  aciklama        varchar(300) not null default '',
  kuyruk_id       bigint references public.medula_kuyruk(id),
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_medula_donem on public.medula_donem (sube_id, yil, ay, fatura_turu);

create table if not exists public.medula_fatura (
  id              integer generated by default as identity primary key,
  sube_id         integer not null default 0,
  belge_id        integer not null references public.belge(id),
  hasta_id        integer not null references public.taraf(id),
  takip_no        varchar(40) not null default '',
  fatura_turu     smallint not null default 1,       -- medula.fatura_turu
  donem_id        integer references public.medula_donem(id),
  medula_fatura_no varchar(40) not null default '',
  fatura_tarihi   date not null default current_date,
  yerel_tutar     numeric(18,2) not null default 0,
  medula_tutar    numeric(18,2) not null default 0,
  hasta_katilim   numeric(18,2) not null default 0,
  sgk_tutar       numeric(18,2) not null default 0,
  ilac_tutar      numeric(18,2) not null default 0,
  malzeme_tutar   numeric(18,2) not null default 0,
  durum           smallint not null default 1,       -- medula.fatura_durum
  sonuc_kod       varchar(10) not null default '',
  sonuc_mesaj     varchar(400) not null default '',
  kayit_zaman     timestamptz,
  iptal_zaman     timestamptz,
  kuyruk_id       bigint references public.medula_kuyruk(id),
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_medula_fatura_belge on public.medula_fatura (belge_id) where durum <> 7;
create index if not exists ix_medula_fatura_donem on public.medula_fatura (donem_id, durum);

create table if not exists public.medula_kesinti (
  id              integer generated by default as identity primary key,
  sube_id         integer not null default 0,
  medula_fatura_id integer not null references public.medula_fatura(id),
  donem_id        integer references public.medula_donem(id),
  sut_kodu        varchar(12) not null default '',
  kesinti_kodu    varchar(10) not null default '',
  aciklama        varchar(300) not null default '',
  tutar           numeric(18,2) not null default 0,
  itiraz_durum    smallint not null default 0,       -- medula.itiraz_durum
  itiraz_zaman    timestamptz,
  itiraz_metni    varchar(600) not null default '',
  sonuc_zaman     timestamptz,
  iade_tutar      numeric(18,2) not null default 0,
  ekleyen         integer not null default 0,
  ekleme_tarihi   timestamptz not null default now(),
  degistiren      integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_medula_kesinti_fatura on public.medula_kesinti (medula_fatura_id);

-- ================================================================== ayarlar ==
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, v.deger, v.tip, 'firma', v.aciklama from (values
    ('medula.otomatik_mustehaklik', '1', 'mantik', 'Kayıt kabulde TCKN girilince müstehaklık otomatik sorgulansın'),
    ('medula.otomatik_provizyon',   '1', 'mantik', 'Başvuru açılırken provizyon otomatik alınsın (kapı kapalıysa kuyrukta bekler)'),
    ('medula.otomatik_hizmet_kaydi','1', 'mantik', 'Muayene tamamlanınca hizmet kaydı otomatik gönderilsin'),
    ('medula.otomatik_recete',      '0', 'mantik', 'Reçete imzalanınca Medula''ya otomatik gönderilsin'),
    ('medula.gece_toplu_fatura',    '1', 'mantik', 'Gece işi: çıkışı verilmiş takipleri toplu fatura kaydet'),
    ('medula.deneme_sayisi',        '3', 'sayi',   'Hatalı çağrı kaç kez tekrar denensin (sonra elle müdahale)'),
    ('medula.deneme_aralik_dk',     '2,5,15', 'metin', 'Yeniden deneme aralıkları (dakika, virgüllü)'),
    ('medula.tutar_fark_esigi',     '0', 'sayi',   'Yerel ↔ Medula tutar farkı bu eşiği aşarsa fatura kaydı engellenir (₺)'),
    ('medula.donem_uyari_gun',      '5', 'sayi',   'Ayın kaçında dönem sonlandırma uyarısı'),
    ('medula.xml_saklama_gun',      '90','sayi',   'İstek/yanıt günlüğü kaç gün saklansın'),
    ('medula.muayene_katilim_payi', '0', 'sayi',   'Muayene katılım payı (₺) - fatura hasta payı hesabı'),
    ('medula.kapi_kapali',          '0', 'mantik', 'Simülasyon: kapı kapalı (çağrılar kuyrukta bekler) - test için')
  ) as v(anahtar, deger, tip, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

-- Zamanlı iş: bekleyen/hatalı kuyruk her 5 dakikada bir denenir.
insert into public.zamanli_is (kod, ad, periyot, gun, saat, dakika, aktif, aciklama)
select 'medula.kuyruk', 'Medula gönderim kuyruğu', 1, 1, 0, 5, 1,
       'Bekleyen ve yeniden denenecek Medula çağrılarını gönderir; kapı kapalıysa bekletir.'
 where not exists (select 1 from public.zamanli_is where kod = 'medula.kuyruk');

-- =================================================================== yetki ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'medula', 'Medula (SGK)', 'Medula', 0, 38, 1
 where not exists (select 1 from public.yetki where kod = 'medula');

insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select v.kod, v.ad, 'Medula', v.tur, v.sira, 1 from (values
    ('medula.provizyon', 'Hasta kabul / provizyon (takip al, iptal, çıkış)', 0, 1),
    ('medula.hizmet',    'Hizmet kaydı gönder / iptal',                     0, 2),
    ('medula.recete',    'e-Reçete / e-Rapor gönder',                        0, 3),
    ('medula.fatura',    'Fatura kaydı / kesinti',                           0, 4),
    ('medula.donem',     'Dönemi sonlandır (geri alınamaz)',                 1, 5),
    ('medula.ayar',      'Kuyruk, hesap ve günlük (XML) görüntüleme',        0, 6)
  ) as v(kod, ad, tur, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and (y.kod = 'medula' or y.kod like 'medula.%')
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ========================================================= liste görünümleri ==
-- Takipler: SGK'lı başvurular + provizyon durumu + hizmet/fatura özeti.
create or replace view public.v_medula_takip as
select b.id as belge_id, b.sube_id, b.belge_no, b.belge_tarihi, b.taraf_id as hasta_id, t.unvan as hasta_adi,
       bb.personel_id as hekim_id, h.unvan as hekim_adi, bb.bolum_id, d.ad as bolum_adi,
       bb.odeyen_kurum_id, k.unvan as odeyen_adi,
       p.sgk_durum, p.sgk_takip_no, p.sgk_provizyon_no, p.sgk_takip_turu, p.sgk_provizyon_tipi,
       p.sgk_sigorta_turu, p.sgk_mustehaklik, p.sgk_mustehaklik_zaman, p.sgk_takip_tarihi, p.sgk_gecerlilik,
       p.sgk_red_nedeni, p.sgk_cikis_zaman, p.sgk_sevkli, p.sgk_sevk_kurum, p.sgk_brans_kodu,
       (select count(*) from public.medula_islem i where i.belge_id = b.id and i.durum = 2)::int as kabul_islem,
       (select count(*) from public.medula_islem i where i.belge_id = b.id and i.durum = 3)::int as hatali_islem,
       (select count(*) from public.belge_satir s where s.belge_id = b.id and s.hizmet_id is not null)::int as satir_sayisi,
       coalesce((select sum(s.tutar_kdvli) from public.belge_satir s where s.belge_id = b.id), 0) as yerel_tutar,
       f.id as medula_fatura_id, f.medula_fatura_no, f.medula_tutar, f.durum as fatura_durum,
       (select count(*) from public.medula_kuyruk q where q.belge_id = b.id and q.durum in (4, 5))::int as hata_sayisi
  from public.belge b
  join public.belge_basvuru bb on bb.id = b.id
  join public.taraf t on t.id = b.taraf_id
  left join public.taraf h on h.id = bb.personel_id
  left join public.departman d on d.id = bb.bolum_id
  left join public.taraf k on k.id = bb.odeyen_kurum_id
  left join public.belge_provizyon p on p.id = b.id
  left join public.medula_fatura f on f.belge_id = b.id and f.durum <> 7
 where b.tur = 19;

comment on view public.v_medula_takip is 'Medula takipleri (707): başvuru + provizyon + hizmet kaydı/fatura özeti.';

create or replace view public.v_medula_kuyruk as
select q.id, q.sube_id, q.servis, q.islem, q.kaynak_tablo, q.kaynak_id, q.hasta_id, coalesce(t.unvan, '') as hasta_adi,
       q.belge_id, q.sonuc_kod, q.sonuc_mesaj, q.durum, q.deneme, q.sonraki_deneme, q.gonderim, q.sure_ms,
       q.oncelik, q.kullanici_id, coalesce(u.ad, '') as kullanici_adi, q.ekleme_tarihi,
       (q.istek is not null) as istek_var, (q.yanit is not null) as yanit_var
  from public.medula_kuyruk q
  left join public.taraf t on t.id = q.hasta_id
  left join public.v_kullanici_lookup u on u.id = q.kullanici_id;

create or replace view public.v_medula_fatura as
select f.id, f.sube_id, f.belge_id, b.belge_no, f.hasta_id, t.unvan as hasta_adi, f.takip_no, f.fatura_turu,
       f.donem_id, dn.yil as donem_yil, dn.ay as donem_ay, f.medula_fatura_no, f.fatura_tarihi,
       f.yerel_tutar, f.medula_tutar, f.hasta_katilim, f.sgk_tutar, f.yerel_tutar - f.medula_tutar as fark,
       f.durum, f.sonuc_kod, f.sonuc_mesaj, f.kayit_zaman, coalesce(h.unvan, '') as hekim_adi,
       (select coalesce(sum(k.tutar), 0) from public.medula_kesinti k where k.medula_fatura_id = f.id) as kesinti
  from public.medula_fatura f
  join public.belge b on b.id = f.belge_id
  join public.taraf t on t.id = f.hasta_id
  left join public.belge_basvuru bb on bb.id = b.id
  left join public.taraf h on h.id = bb.personel_id
  left join public.medula_donem dn on dn.id = f.donem_id;

-- Kesinti kartında fatura seçimi: fatura no + hasta.
create or replace view public.v_medula_fatura_lookup as
select f.id, (coalesce(nullif(f.medula_fatura_no, ''), 'taslak') || ' · ' || t.unvan)::varchar(160) as ad, f.sube_id,
       case when f.durum in (2, 3, 4, 5, 6) then 1 else 0 end as aktif
  from public.medula_fatura f join public.taraf t on t.id = f.hasta_id;
