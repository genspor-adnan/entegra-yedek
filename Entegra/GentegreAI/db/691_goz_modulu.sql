-- 691: GÖZ (OFTALMOLOJİ) MODÜLÜ — ÇEKİRDEK ŞEMA.
--
-- Kaynak tasarım: Ekranlar/Goz/goz_sureci.html (03.09.2026) ve yanındaki altı
-- mockup. Bu dosya o notun "İlk sürüm" kapsamını kurar: ünite akışı, detaylı
-- muayene (OD/OS ölçüm tabloları), cihaz ön tetkiki, gözlük/kontakt lens
-- reçetesi, görüntüleme + ayrıştırılmış ölçüm (trend), biyometri/IOL, işlem
-- hattı (enjeksiyon · lazer · ameliyat) ve kronik hastalık takip protokolü.
--
-- TEMEL KARAR 1 — göz muayenesi AYRI BİR MUAYENE DEĞİL, muayenenin uzantısıdır.
--   `goz_muayene` ile `muayene` 1:1. Tanı, istem, e-reçete, tahakkuk, e-Nabız
--   ve "Tamamla" akışı genel muayene modülünde kalır; burada yalnız gözün
--   kendi ölçümleri durur. Ayrı bir muayene kaydı açılsaydı hasta zaman
--   çizelgesinde aynı ziyaret iki kez görünür, prim ve tahakkuk ikiye bölünürdü.
--
-- TEMEL KARAR 2 — HER ÖLÇÜM GÖZ BAZLIDIR ve kendi satırındadır.
--   Sağ/sol için `od_*` / `os_*` kolon çiftleri açmak ilk bakışta kısa yol gibi
--   durur ama: (a) aynı ziyarette aynı ölçüm birden çok kez yapılır (otoref →
--   subjektif → sikloplejik), (b) ölçümün KAYNAĞI (cihaz/tekniker/hekim) ve
--   ZAMANI satır başına değişir, (c) trend sorgusu ("son 2 yılın RNFL eğrisi")
--   kolon çiftinden çıkmaz. Bu yüzden `goz` + `kaynak` + `zaman` her ölçüm
--   satırında tekrar eder.
--
-- TEMEL KARAR 3 — CİHAZ ÖLÇÜMÜ "ÖN VERİ"DİR.
--   Otoref/NCT/pakimetre sonucu hekim onaylayana kadar karar dayanağı değildir
--   (`kaynak = 3`, `onayli = 0`). Cihazdan geleni doğrudan muayene verisi
--   saymak, hasta karışması ve kalibrasyon hatasını sessizce klinik karara
--   taşırdı.
--
-- TEMEL KARAR 4 — İŞLEM (enjeksiyon/lazer/ameliyat) TEK BAŞLIK + TÜRE ÖZEL
--   DETAY. Üçünün ortak soruları aynı (hangi göz, hangi endikasyon, onam,
--   time-out, komplikasyon, ücret); ayrı üç tablo bu ortak alanları üç kez
--   yazdırır ve "bu hastaya bugüne kadar ne yapıldı" sorusunu üç sorguya
--   böler.

-- ============================================================ kod listeleri ==
insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values
    ('goz.taraf',            'Göz (Taraf)'),
    ('goz.kaynak',           'Ölçüm Kaynağı'),
    ('goz.istasyon',         'Göz Ünitesi İstasyonu'),
    ('goz.muayene_turu',     'Göz Muayene Türü'),
    ('goz.va_tur',           'Görme Keskinliği Türü'),
    ('goz.va_esel',          'Görme Eşeli'),
    ('goz.ref_tur',          'Refraksiyon Türü'),
    ('goz.tono_yontem',      'Tonometri Yöntemi'),
    ('goz.fundus_yontem',    'Fundus Bakı Yöntemi'),
    ('goz.dr_evre',          'Diyabetik Retinopati Evresi'),
    ('goz.dmo',              'Diyabetik Maküla Ödemi'),
    ('goz.amd_evre',         'AMD Evresi'),
    ('goz.gozluk_tur',       'Gözlük Reçetesi Türü'),
    ('goz.cam_malzeme',      'Cam Malzemesi'),
    ('goz.kaplama',          'Cam Kaplaması'),
    ('goz.lens_tur',         'Kontakt Lens Türü'),
    ('goz.recete_durum',     'Göz Reçetesi Durumu'),
    ('goz.tetkik',           'Göz Görüntüleme / Tanısal Test'),
    ('goz.goruntuleme_durum','Göz Görüntüleme Durumu'),
    ('goz.olcum',            'Göz Ölçüm Kodu'),
    ('goz.cihaz_tur',        'Göz Cihaz Türü'),
    ('goz.cihaz_protokol',   'Göz Cihaz Protokolü'),
    ('goz.islem_tur',        'Göz İşlem Türü'),
    ('goz.islem_durum',      'Göz İşlem Durumu'),
    ('goz.anestezi',         'Anestezi Türü'),
    ('goz.enj_ilac',         'İntravitreal İlaç'),
    ('goz.enj_protokol',     'Enjeksiyon Protokolü'),
    ('goz.lazer_tur',        'Lazer Türü'),
    ('goz.ameliyat_tur',     'Göz Ameliyatı Türü'),
    ('goz.komplikasyon',     'Göz İşlem Komplikasyonu'),
    ('goz.hastalik',         'Kronik Göz Hastalığı'),
    ('goz.progresyon',       'Progresyon Durumu')
  ) as v(kod, ad)
 where not exists (select 1 from public.kod_liste k where k.kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values
    -- OD/OS/OU: Latince kısaltmalar klinikte konuşulan dildir; "sağ/sol"
    --   yazmak reçete ve epikrizde ikinci bir sözlük açardı.
    ('goz.taraf', 1, 'OD (sağ)'), ('goz.taraf', 2, 'OS (sol)'), ('goz.taraf', 3, 'OU (her iki)'),

    ('goz.kaynak', 1, 'Hekim'), ('goz.kaynak', 2, 'Tekniker'),
    ('goz.kaynak', 3, 'Cihaz'), ('goz.kaynak', 4, 'Hasta beyanı'),

    ('goz.istasyon', 1, 'Kabul'), ('goz.istasyon', 2, 'Ön tetkik'),
    ('goz.istasyon', 3, 'Muayene'), ('goz.istasyon', 4, 'Görüntüleme'),
    ('goz.istasyon', 5, 'Karar / İşlem'), ('goz.istasyon', 6, 'Tamamlandı'),

    ('goz.muayene_turu', 1, 'Tam muayene'), ('goz.muayene_turu', 2, 'Kontrol'),
    ('goz.muayene_turu', 3, 'Postop kontrol'), ('goz.muayene_turu', 4, 'Acil'),
    ('goz.muayene_turu', 5, 'Tarama (DR)'), ('goz.muayene_turu', 6, 'Preop'),
    ('goz.muayene_turu', 7, 'Refraktif değerlendirme'), ('goz.muayene_turu', 8, 'Kontakt lens'),

    ('goz.va_tur', 1, 'UCVA (düzeltmesiz)'), ('goz.va_tur', 2, 'Mevcut gözlükle'),
    ('goz.va_tur', 3, 'Pinhole'), ('goz.va_tur', 4, 'BCVA (en iyi düzeltilmiş)'),
    ('goz.va_tur', 5, 'Yakın'), ('goz.va_tur', 6, 'Kontakt lensle'), ('goz.va_tur', 7, 'Postop'),

    ('goz.va_esel', 1, 'Snellen'), ('goz.va_esel', 2, 'ETDRS'), ('goz.va_esel', 3, 'logMAR'),
    ('goz.va_esel', 4, 'Lea (pediatri)'), ('goz.va_esel', 5, 'Teller (pediatri)'),

    ('goz.ref_tur', 1, 'Otorefraktometre'), ('goz.ref_tur', 2, 'Subjektif'),
    ('goz.ref_tur', 3, 'Sikloplejik'), ('goz.ref_tur', 4, 'Retinoskopi'),
    ('goz.ref_tur', 5, 'Mevcut gözlük (lensmetre)'), ('goz.ref_tur', 6, 'Reçete'),

    ('goz.tono_yontem', 1, 'NCT (hava üflemeli)'), ('goz.tono_yontem', 2, 'Goldmann aplanasyon'),
    ('goz.tono_yontem', 3, 'iCare'), ('goz.tono_yontem', 4, 'Tono-Pen'), ('goz.tono_yontem', 5, 'Dijital'),

    ('goz.fundus_yontem', 1, '90D'), ('goz.fundus_yontem', 2, '78D'),
    ('goz.fundus_yontem', 3, 'İndirekt oftalmoskopi'), ('goz.fundus_yontem', 4, 'Fundus fotoğrafı'),

    -- ETDRS evrelemesi: tarama programının ve sevk kararının ortak dili.
    ('goz.dr_evre', 0, 'R0 — retinopati yok'), ('goz.dr_evre', 1, 'R1 — hafif NPDR'),
    ('goz.dr_evre', 2, 'R2 — orta NPDR'), ('goz.dr_evre', 3, 'R3 — ağır NPDR'),
    ('goz.dr_evre', 4, 'R4 — PDR'),
    ('goz.dmo', 0, 'Yok'), ('goz.dmo', 1, 'Merkez dışı'), ('goz.dmo', 2, 'Merkezi tutan'),
    ('goz.amd_evre', 0, 'Yok'), ('goz.amd_evre', 1, 'Erken kuru'), ('goz.amd_evre', 2, 'Orta kuru'),
    ('goz.amd_evre', 3, 'İleri kuru (GA)'), ('goz.amd_evre', 4, 'Yaş (neovasküler)'),

    ('goz.gozluk_tur', 1, 'Uzak'), ('goz.gozluk_tur', 2, 'Yakın'), ('goz.gozluk_tur', 3, 'Bifokal'),
    ('goz.gozluk_tur', 4, 'Progresif'), ('goz.gozluk_tur', 5, 'Ara mesafe'),
    ('goz.gozluk_tur', 6, 'Güneş / koruyucu'),
    ('goz.cam_malzeme', 1, 'Organik (CR-39)'), ('goz.cam_malzeme', 2, 'Polikarbonat'),
    ('goz.cam_malzeme', 3, 'Yüksek indeks 1.60'), ('goz.cam_malzeme', 4, 'Yüksek indeks 1.67'),
    ('goz.cam_malzeme', 5, 'Yüksek indeks 1.74'), ('goz.cam_malzeme', 6, 'Mineral (cam)'),
    ('goz.kaplama', 1, 'Antirefle'), ('goz.kaplama', 2, 'Sert kaplama'),
    ('goz.kaplama', 3, 'Fotokromik'), ('goz.kaplama', 4, 'Mavi ışık filtresi'),
    ('goz.kaplama', 5, 'Polarize'), ('goz.kaplama', 6, 'UV filtre'),
    ('goz.lens_tur', 1, 'Yumuşak günlük'), ('goz.lens_tur', 2, 'Yumuşak aylık'),
    ('goz.lens_tur', 3, 'Torik'), ('goz.lens_tur', 4, 'Multifokal'),
    ('goz.lens_tur', 5, 'RGP (sert gaz geçirgen)'), ('goz.lens_tur', 6, 'Skleral'),
    ('goz.lens_tur', 7, 'Ortokeratoloji'),
    ('goz.recete_durum', 0, 'İptal'), ('goz.recete_durum', 1, 'Taslak'),
    ('goz.recete_durum', 2, 'İmzalandı'), ('goz.recete_durum', 3, 'Optiğe verildi'),
    ('goz.recete_durum', 4, 'Teslim edildi'),

    ('goz.tetkik', 1, 'OCT — maküla'), ('goz.tetkik', 2, 'OCT — RNFL / GCC'),
    ('goz.tetkik', 3, 'OCT — ön segment'), ('goz.tetkik', 4, 'OCT-A'),
    ('goz.tetkik', 5, 'FAF (otofloresans)'), ('goz.tetkik', 6, 'FA / ICGA'),
    ('goz.tetkik', 7, 'Fundus fotoğrafı'), ('goz.tetkik', 8, 'Görme alanı (GA)'),
    ('goz.tetkik', 9, 'Kornea topografisi'), ('goz.tetkik', 10, 'Pakimetri haritası'),
    ('goz.tetkik', 11, 'Biyometri'), ('goz.tetkik', 12, 'Endotel (spekülar)'),
    ('goz.tetkik', 13, 'UBM'), ('goz.tetkik', 14, 'B-scan USG'), ('goz.tetkik', 15, 'ERG / VEP'),
    ('goz.goruntuleme_durum', 0, 'İptal'), ('goz.goruntuleme_durum', 1, 'İstendi'),
    ('goz.goruntuleme_durum', 2, 'Çekildi'), ('goz.goruntuleme_durum', 3, 'Değerlendirildi'),

    ('goz.cihaz_tur', 1, 'Otorefraktometre / keratometre'), ('goz.cihaz_tur', 2, 'Tonometre (NCT)'),
    ('goz.cihaz_tur', 3, 'Pakimetre'), ('goz.cihaz_tur', 4, 'OCT'),
    ('goz.cihaz_tur', 5, 'Görme alanı'), ('goz.cihaz_tur', 6, 'Fundus kamera'),
    ('goz.cihaz_tur', 7, 'Topografi'), ('goz.cihaz_tur', 8, 'Biyometri'),
    ('goz.cihaz_tur', 9, 'Endotel'), ('goz.cihaz_tur', 10, 'USG'),
    ('goz.cihaz_protokol', 1, 'DICOM'), ('goz.cihaz_protokol', 2, 'Seri metin (RS-232)'),
    ('goz.cihaz_protokol', 3, 'Dosya (XML/CSV/PDF)'), ('goz.cihaz_protokol', 4, 'API'),

    ('goz.islem_tur', 1, 'İntravitreal enjeksiyon'), ('goz.islem_tur', 2, 'Lazer'),
    ('goz.islem_tur', 3, 'Ameliyat'), ('goz.islem_tur', 4, 'Küçük cerrahi'),
    ('goz.islem_tur', 5, 'Perioküler enjeksiyon'),
    ('goz.islem_durum', 0, 'İptal'), ('goz.islem_durum', 1, 'Planlı'),
    ('goz.islem_durum', 2, 'Hazır'), ('goz.islem_durum', 3, 'Uygulandı'),
    ('goz.islem_durum', 4, 'Ertelendi'),
    ('goz.anestezi', 1, 'Topikal'), ('goz.anestezi', 2, 'Lokal / subtenon'),
    ('goz.anestezi', 3, 'Sedasyon'), ('goz.anestezi', 4, 'Genel'),

    ('goz.enj_ilac', 1, 'Aflibersept'), ('goz.enj_ilac', 2, 'Ranibizumab'),
    ('goz.enj_ilac', 3, 'Bevasizumab'), ('goz.enj_ilac', 4, 'Farisimab'),
    ('goz.enj_ilac', 5, 'Deksametazon implant'), ('goz.enj_ilac', 6, 'Triamsinolon'),
    ('goz.enj_protokol', 1, 'Yükleme'), ('goz.enj_protokol', 2, 'PRN (gerektiğinde)'),
    ('goz.enj_protokol', 3, 'Treat & extend'), ('goz.enj_protokol', 4, 'Sabit aralık'),

    ('goz.lazer_tur', 1, 'SLT'), ('goz.lazer_tur', 2, 'ALT'),
    ('goz.lazer_tur', 3, 'YAG kapsülotomi'), ('goz.lazer_tur', 4, 'YAG iridotomi'),
    ('goz.lazer_tur', 5, 'PRP (panretinal)'), ('goz.lazer_tur', 6, 'Fokal / grid'),
    ('goz.lazer_tur', 7, 'Mikropuls'), ('goz.lazer_tur', 8, 'Retinopeksi'),
    ('goz.lazer_tur', 9, 'Vitreolizis'),

    ('goz.ameliyat_tur', 1, 'Fako + IOL'), ('goz.ameliyat_tur', 2, 'ECCE'),
    ('goz.ameliyat_tur', 3, 'Sekonder IOL'), ('goz.ameliyat_tur', 4, 'Trabekülektomi'),
    ('goz.ameliyat_tur', 5, 'Tüp implantı'), ('goz.ameliyat_tur', 6, 'PPV (vitrektomi)'),
    ('goz.ameliyat_tur', 7, 'Skleral çökertme'), ('goz.ameliyat_tur', 8, 'Pterjium'),
    ('goz.ameliyat_tur', 9, 'DCR'), ('goz.ameliyat_tur', 10, 'Pitozis'),
    ('goz.ameliyat_tur', 11, 'Şaşılık'), ('goz.ameliyat_tur', 12, 'Keratoplasti (PK/DALK/DMEK)'),
    ('goz.ameliyat_tur', 13, 'Refraktif (LASIK/PRK/SMILE)'), ('goz.ameliyat_tur', 14, 'ICL'),

    ('goz.komplikasyon', 0, 'Yok'), ('goz.komplikasyon', 1, 'Arka kapsül yırtığı (PCR)'),
    ('goz.komplikasyon', 2, 'Zonül diyalizi'), ('goz.komplikasyon', 3, 'Vitreus kaybı'),
    ('goz.komplikasyon', 4, 'Endoftalmi'), ('goz.komplikasyon', 5, 'GİB yükselmesi'),
    ('goz.komplikasyon', 6, 'Kornea ödemi'), ('goz.komplikasyon', 7, 'Retina dekolmanı'),
    ('goz.komplikasyon', 8, 'Kanama'),

    ('goz.hastalik', 1, 'Glokom'), ('goz.hastalik', 2, 'Diyabetik retinopati'),
    ('goz.hastalik', 3, 'AMD'), ('goz.hastalik', 4, 'Üveit'),
    ('goz.hastalik', 5, 'Keratokonus'), ('goz.hastalik', 6, 'Ambliyopi'),
    ('goz.progresyon', 1, 'Stabil'), ('goz.progresyon', 2, 'Şüpheli'), ('goz.progresyon', 3, 'Progresyon')
  ) as v(liste, deger, ad) on v.liste = l.kod
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- ================================================================== cihazlar ==
-- Lab cihaz katmanıyla AYNI model (dinleyici + ham mesaj günlüğü + eşleme):
--   göz cihazları için ikinci bir entegrasyon mimarisi kurmak, aynı sorunu
--   (sahipsiz sonuç, hasta eşleşmesi, yeniden işleme) iki kez çözmek olurdu.
create table if not exists public.goz_cihaz (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  kod            varchar(20)  not null,
  ad             varchar(120) not null,
  tur            smallint     not null default 0,        -- goz.cihaz_tur
  uretici        varchar(80)  not null default '',
  model          varchar(80)  not null default '',
  seri_no        varchar(60)  not null default '',
  demirbas_id    integer references public.demirbas(id),
  protokol       smallint     not null default 2,        -- goz.cihaz_protokol
  baglanti       varchar(120) not null default '',       -- AE/host:port · COM · klasör
  mwl            smallint     not null default 0,        -- DICOM modality worklist
  -- Cihaz alan adı → `goz.olcum` kodu. Eşleme olmadan gelen ölçüm "ham"
  --   kalır: yanlış eşlenmiş bir RNFL değeri, sessizce yanlış trend üretir.
  olcum_esleme   jsonb        not null default '{}'::jsonb,
  dinleyici_durum smallint    not null default 0,
  son_mesaj      timestamptz,
  aktif          smallint     not null default 1,
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create unique index if not exists ux_goz_cihaz_kod on public.goz_cihaz (kod);

create table if not exists public.goz_cihaz_mesaj (
  id            bigint generated by default as identity primary key,
  cihaz_id      integer not null references public.goz_cihaz(id),
  zaman         timestamptz not null default now(),
  -- Hasta eşleşmesi protokol/barkod ya da ad+doğum ile yapılır; tutmazsa satır
  --   SAHİPSİZ kalır ve kuyrukta bekler - tahmin ederek hastaya yazmak,
  --   başkasının ölçümünü hastanın dosyasına koymaktır.
  hasta_eslesme varchar(40)  not null default '',
  ham           text         not null default '',
  dosya_yolu    varchar(300) not null default '',
  islem_durum   smallint     not null default 0,   -- 0 bekliyor · 1 işlendi · 2 sahipsiz · 3 hata
  hata          varchar(300) not null default ''
);
create index if not exists ix_goz_cihaz_mesaj_zaman on public.goz_cihaz_mesaj (cihaz_id, zaman desc);

-- ======================================================== ziyaret / istasyon ==
-- Ünite akışının kanbanı: hasta kabulden tamamlanmaya kadar istasyon
--   değiştirir. Bekleme süreleri ("ön tetkikte 22 dk") buradan çıkar; tek bir
--   "durum" kolonu tutulsaydı geçmiş kaybolur ve darboğaz görünmezdi.
create table if not exists public.goz_ziyaret_istasyon (
  id            integer generated by default as identity primary key,
  sube_id       integer not null default 0,
  belge_id      integer not null references public.belge(id),
  hasta_id      integer not null references public.taraf(id),
  istasyon      smallint not null default 1,          -- goz.istasyon
  giris         timestamptz not null default now(),
  cikis         timestamptz,
  oda           varchar(30) not null default '',
  personel_id   integer references public.taraf(id),
  -- Dilatasyon zamanlayıcısı: damla saati + 20 dk. Listede "hazır" rozetini
  --   bu üretir; hekim hastayı erken çağırmasın, geç de kalmasın.
  dilatasyon_zamani timestamptz,
  dilatasyon_ilac   varchar(60) not null default '',
  sira_no       smallint not null default 0,
  not_metin     varchar(200) not null default ''
);
create index if not exists ix_goz_istasyon_belge on public.goz_ziyaret_istasyon (belge_id, giris);
create index if not exists ix_goz_istasyon_acik  on public.goz_ziyaret_istasyon (istasyon, giris)
  where cikis is null;

-- ============================================================= göz muayenesi ==
create table if not exists public.goz_muayene (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  muayene_id     integer not null references public.muayene(id),
  hasta_id       integer not null references public.taraf(id),
  muayene_turu   smallint not null default 1,        -- goz.muayene_turu
  dilate         smallint not null default 0,
  dilatasyon_ilac varchar(60) not null default '',
  sablon_id      integer,
  postop_islem_id integer,                            -- → goz_islem (aşağıda FK)
  takip_id       integer,                             -- → goz_hastalik_takip
  degerlendirme  text not null default '',
  plan           text not null default '',
  hasta_egitimi  varchar(400) not null default '',
  gozluk_recete_id integer,
  kontrol_gun    smallint,
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
-- 1:1 — aynı muayeneye ikinci bir göz uzantısı açılamaz.
create unique index if not exists ux_goz_muayene_muayene on public.goz_muayene (muayene_id);
create index if not exists ix_goz_muayene_hasta on public.goz_muayene (hasta_id, ekleme_tarihi desc);

-- -------------------------------------------------------- görme keskinliği --
create table if not exists public.goz_gorme (
  id             bigint generated by default as identity primary key,
  goz_muayene_id integer not null references public.goz_muayene(id) on delete cascade,
  goz            smallint not null,                  -- goz.taraf
  kaynak         smallint not null default 1,        -- goz.kaynak
  zaman          timestamptz not null default now(),
  tur            smallint not null default 4,        -- goz.va_tur
  esel           smallint not null default 1,        -- goz.va_esel
  mesafe_m       numeric(4,2),
  deger_ondalik  numeric(4,2),
  deger_snellen  varchar(10) not null default '',
  -- logMAR HESAPLIDIR: karşılaştırma ve trend yalnız logMAR'da doğrusaldır
  --   (0,1 ile 0,2 arası görme farkı, 0,8 ile 0,9 arasıyla aynı değildir).
  deger_logmar   numeric(4,2),
  -- PH/EH/IH: sayı ile ifade edilemeyen görme düzeyleri. Ondalık alana 0
  --   yazmak "hiç görmüyor" ile "ışık hissi var"ı aynı yapardı.
  deger_metin    varchar(20) not null default '',
  yakin_jaeger   varchar(6)  not null default '',
  not_metin      varchar(100) not null default ''
);
create index if not exists ix_goz_gorme_muayene on public.goz_gorme (goz_muayene_id, goz, tur);

-- ------------------------------------------------------------ refraksiyon --
create table if not exists public.goz_refraksiyon (
  id             bigint generated by default as identity primary key,
  goz_muayene_id integer not null references public.goz_muayene(id) on delete cascade,
  goz            smallint not null,
  kaynak         smallint not null default 1,
  zaman          timestamptz not null default now(),
  tur            smallint not null default 2,        -- goz.ref_tur
  sph            numeric(5,2),
  cyl            numeric(5,2),
  aks            smallint,
  add_yakin      numeric(4,2),                       -- "add" PG'de ayrılmış sözcük değil ama okunurluk için açık ad
  prizma         numeric(4,2),
  taban          smallint,                           -- 1 içe · 2 dışa · 3 yukarı · 4 aşağı
  va             numeric(4,2),                       -- bu düzeltmeyle elde edilen görme
  k1             numeric(5,2), k1_aks smallint,
  k2             numeric(5,2), k2_aks smallint,
  pd_uzak        numeric(4,1), pd_yakin numeric(4,1),
  vertex_mm      numeric(4,1),
  cihaz_id       integer references public.goz_cihaz(id),
  guven          smallint                            -- cihaz güven skoru
);
create index if not exists ix_goz_ref_muayene on public.goz_refraksiyon (goz_muayene_id, goz, tur);

-- ------------------------------------------------------ tonometri / pakimetri --
create table if not exists public.goz_tonometri (
  id             bigint generated by default as identity primary key,
  goz_muayene_id integer not null references public.goz_muayene(id) on delete cascade,
  goz            smallint not null,
  kaynak         smallint not null default 1,
  zaman          timestamptz not null default now(),
  yontem         smallint not null default 1,        -- goz.tono_yontem
  gib            numeric(4,1),
  olcumler       numeric[],                          -- cihazın tekil ölçümleri
  cct_um         smallint,
  duzeltilmis_gib numeric(4,1),
  hedef_gib      numeric(4,1),
  -- BAYRAK HESAPLIDIR (>21 yüksek, >30 panik): eşiği elle işaretlemeye
  --   bırakmak, yoğun bir günde panik değerin fark edilmemesi demektir.
  bayrak         smallint generated always as (
                   case when gib is null then 0 when gib > 30 then 2
                        when gib > 21 then 1 else 0 end) stored,
  damla_sonrasi_dk smallint,
  cihaz_id       integer references public.goz_cihaz(id)
);
create index if not exists ix_goz_tono_muayene on public.goz_tonometri (goz_muayene_id, goz);
create index if not exists ix_goz_tono_bayrak  on public.goz_tonometri (zaman desc) where bayrak > 0;

-- ------------------------------------------------- ön segment (biyomikroskopi) --
-- ALAN BAZLI SATIR (kapak, kornea, ön kamara, lens…): sabit kolonlar açmak,
--   yeni bir bulgu alanı eklemeyi şema değişikliğine bağlardı. Şablon
--   alanları da bu yapıya birebir oturur.
create table if not exists public.goz_on_segment (
  id             bigint generated by default as identity primary key,
  goz_muayene_id integer not null references public.goz_muayene(id) on delete cascade,
  goz            smallint not null,
  kaynak         smallint not null default 1,
  zaman          timestamptz not null default now(),
  alan           varchar(40) not null,               -- kapak · konjonktiva · kornea · on_kamara · iris · pupil · lens · gozyasi
  normal         smallint not null default 0,
  deger_metin    text not null default '',
  deger_kod      varchar(20) not null default '',    -- LOCS III · Van Herick 1-4 · hücre/flare 0-4+
  deger_sayi     numeric(8,2),                       -- BUT sn · Schirmer mm · pupil mm
  sema_json      jsonb,
  foto_dokuman_id integer
);
create index if not exists ix_goz_on_seg_muayene on public.goz_on_segment (goz_muayene_id, goz, alan);

-- ------------------------------------------------------------ fundus / arka --
create table if not exists public.goz_fundus (
  id             bigint generated by default as identity primary key,
  goz_muayene_id integer not null references public.goz_muayene(id) on delete cascade,
  goz            smallint not null,
  kaynak         smallint not null default 1,
  zaman          timestamptz not null default now(),
  yontem         smallint,                           -- goz.fundus_yontem
  dilate         smallint not null default 0,
  disk_metin     text not null default '',
  cd_yatay       numeric(3,2), cd_dikey numeric(3,2),
  disk_kanama    smallint not null default 0,
  ppa            smallint not null default 0,
  isnt_ihlal     smallint not null default 0,
  makula_metin   text not null default '',
  makula_bulgu   smallint[],
  damar_metin    text not null default '',
  periferi_metin text not null default '',
  vitreus        varchar(100) not null default '',
  dr_evre        smallint,                           -- goz.dr_evre
  dmo            smallint,                           -- goz.dmo
  amd_evre       smallint,                           -- goz.amd_evre
  sema_json      jsonb,
  foto_dokuman_id integer
);
create index if not exists ix_goz_fundus_muayene on public.goz_fundus (goz_muayene_id, goz);

-- ------------------------------------------- motilite / pupil / alan (tek satır) --
-- Bu grup GÖZ BAZLI DEĞİLDİR: şaşılık, stereopsis ve konverjans iki gözün
--   BİRLİKTE davranışıdır; OD/OS'e bölmek ölçümün anlamını bozardı.
create table if not exists public.goz_motilite (
  id             bigint generated by default as identity primary key,
  goz_muayene_id integer not null references public.goz_muayene(id) on delete cascade,
  zaman          timestamptz not null default now(),
  cover_uzak     varchar(40) not null default '',
  cover_yakin    varchar(40) not null default '',
  duksiyon_json  jsonb,                              -- 9 bakış pozisyonu · kısıtlılık -4..0
  prizma_olcum   jsonb,
  stereopsis     varchar(20) not null default '',
  worth          varchar(20) not null default '',
  nistagmus      varchar(60) not null default '',
  kyn_cm         smallint,
  pupil_od_mm    numeric(3,1), pupil_os_mm numeric(3,1),
  rapd           smallint not null default 0,        -- 0 yok · 1 OD · 2 OS
  renk_gorme     varchar(20) not null default '',
  konfrontasyon  varchar(60) not null default '',
  hertel_od      smallint, hertel_os smallint, hertel_taban smallint,
  mrd1_od        numeric(3,1), mrd1_os numeric(3,1)
);
create unique index if not exists ux_goz_motilite_muayene on public.goz_motilite (goz_muayene_id);

-- --------------------------------------------------------------- ek testler --
create table if not exists public.goz_ek_test (
  id             bigint generated by default as identity primary key,
  goz_muayene_id integer not null references public.goz_muayene(id) on delete cascade,
  goz            smallint not null default 3,
  kaynak         smallint not null default 1,
  zaman          timestamptz not null default now(),
  test           varchar(40) not null,               -- gonyoskopi · amsler · kontrast · schirmer · but · osdi · ekzoftalmometri
  deger_json     jsonb,
  deger_metin    text not null default '',
  deger_sayi     numeric(8,2)
);
create index if not exists ix_goz_ek_test_muayene on public.goz_ek_test (goz_muayene_id, test);

-- ================================================================= reçeteler ==
create table if not exists public.goz_gozluk_recetesi (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  muayene_id     integer references public.muayene(id),
  hasta_id       integer not null references public.taraf(id),
  hekim_id       integer references public.taraf(id),
  recete_no      varchar(20) not null default '',
  tur            smallint not null default 1,        -- goz.gozluk_tur
  kullanim       smallint,                           -- sürekli / okuma / bilgisayar
  od_sph numeric(5,2), od_cyl numeric(5,2), od_aks smallint, od_add numeric(4,2),
  od_prizma numeric(4,2), od_taban smallint, od_pd numeric(4,1), od_seg numeric(4,1),
  os_sph numeric(5,2), os_cyl numeric(5,2), os_aks smallint, os_add numeric(4,2),
  os_prizma numeric(4,2), os_taban smallint, os_pd numeric(4,1), os_seg numeric(4,1),
  pd_yakin       numeric(4,1),
  cam_malzeme    smallint,                           -- goz.cam_malzeme
  kaplamalar     smallint[],                         -- goz.kaplama
  tasarim        varchar(60) not null default '',
  not_optik      varchar(200) not null default '',
  gecerlilik_bitis date,
  sgk_hak        smallint not null default 0,
  imza_zamani    timestamptz,
  imza_hash      varchar(128) not null default '',
  optik_taraf_id integer references public.taraf(id),
  optik_teslim   date,
  qr_kod         varchar(60) not null default '',
  durum          smallint not null default 1,        -- goz.recete_durum
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_goz_gozluk_hasta on public.goz_gozluk_recetesi (hasta_id, ekleme_tarihi desc);
create unique index if not exists ux_goz_gozluk_no on public.goz_gozluk_recetesi (recete_no)
  where recete_no <> '';

create table if not exists public.goz_kontakt_lens (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  muayene_id     integer references public.muayene(id),
  hasta_id       integer not null references public.taraf(id),
  goz            smallint not null,
  lens_tur       smallint,                           -- goz.lens_tur
  marka_model    varchar(80) not null default '',
  sph numeric(5,2), cyl numeric(5,2), aks smallint, add_yakin numeric(4,2),
  bc  numeric(4,2), dia numeric(4,2),
  oturus         varchar(100) not null default '',
  va             numeric(4,2),
  deneme         smallint not null default 0,
  kullanim_saat  smallint,
  bakim_notu     varchar(200) not null default '',
  durum          smallint not null default 1,
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now()
);
create index if not exists ix_goz_lens_hasta on public.goz_kontakt_lens (hasta_id, ekleme_tarihi desc);

-- ============================================================== görüntüleme ==
create table if not exists public.goz_goruntuleme (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  muayene_id     integer references public.muayene(id),
  hasta_id       integer not null references public.taraf(id),
  goz            smallint not null default 3,
  tetkik         smallint not null,                  -- goz.tetkik
  hizmet_id      integer references public.hizmet(id),
  belge_satir_id integer references public.belge_satir(id),
  cihaz_id       integer references public.goz_cihaz(id),
  istem_zamani   timestamptz not null default now(),
  cekim_zamani   timestamptz,
  teknisyen_id   integer references public.taraf(id),
  dilate         smallint not null default 0,
  study_uid      varchar(64) not null default '',
  dokuman_ids    integer[],
  ham_dosya_yolu varchar(300) not null default '',
  kalite         smallint,                           -- sinyal / güvenilirlik
  degerlendirme  text not null default '',
  degerlendiren_id integer references public.taraf(id),
  degerlendirme_zamani timestamptz,
  -- AI ön okuma TASLAKTIR: hekim onayı olmadan sonuç sayılmaz (DR taramasında
  --   yanlış negatif, gözden kaçan körlük demektir).
  ai_on_okuma    jsonb,
  durum          smallint not null default 1,        -- goz.goruntuleme_durum
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_goz_gor_hasta on public.goz_goruntuleme (hasta_id, istem_zamani desc);
create index if not exists ix_goz_gor_durum on public.goz_goruntuleme (durum, istem_zamani);

-- Ayrıştırılmış ölçüm: TREND buradan çıkar. Ölçümler PDF'in içinde bırakılsaydı
--   "RNFL iki yılda ne kadar inceldi" sorusu ancak elle okunarak cevaplanırdı.
create table if not exists public.goz_goruntuleme_olcum (
  id             bigint generated by default as identity primary key,
  goruntuleme_id integer not null references public.goz_goruntuleme(id) on delete cascade,
  goz            smallint not null,
  olcum          varchar(40) not null,               -- rnfl_ort · gcc · cmt · md · psd · vfi · al · k1 · k2 · cct …
  deger          numeric(12,3),
  birim          varchar(10) not null default '',
  normal_pct     numeric(5,2),                       -- cihaz normatif yüzdesi (yalnız bayrak için)
  bayrak         smallint not null default 0
);
create index if not exists ix_goz_olcum_trend on public.goz_goruntuleme_olcum (goruntuleme_id, goz, olcum);

create table if not exists public.goz_biyometri (
  id             integer generated by default as identity primary key,
  goruntuleme_id integer not null references public.goz_goruntuleme(id) on delete cascade,
  goz            smallint not null,
  al numeric(6,2), k1 numeric(5,2), k1_aks smallint, k2 numeric(5,2), k2_aks smallint,
  acd numeric(5,2), lt numeric(5,2), wtw numeric(5,2), cct numeric(6,1),
  snr            smallint,
  hedef_ref      numeric(4,2),
  -- Formül karşılaştırma tablosu: {"SRK/T": {"22.0": -0.12, …}, "Barrett": …}
  --   Tek bir "hesaplanan güç" alanı, hangi formülle bulunduğunu ve
  --   alternatifleri saklamazdı - refraktif sürpriz incelemesi bunu ister.
  hesaplar       jsonb,
  secilen_iol_model varchar(60) not null default '',
  a_sabiti       numeric(6,3),
  guc            numeric(5,2),
  torik_silindir numeric(5,2),
  torik_aks      smallint,
  secen_id       integer references public.taraf(id),
  secim_zamani   timestamptz,
  stok_seri_lot_id integer
);
create index if not exists ix_goz_biyometri_gor on public.goz_biyometri (goruntuleme_id, goz);

-- =================================================================== işlemler ==
create table if not exists public.goz_islem (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  hasta_id       integer not null references public.taraf(id),
  muayene_id     integer references public.muayene(id),   -- kararın verildiği muayene
  belge_id       integer references public.belge(id),     -- işlem günü başvurusu
  goz            smallint not null,
  tur            smallint not null,                       -- goz.islem_tur
  islem_kod      varchar(20) not null default '',         -- SUT
  hizmet_id      integer references public.hizmet(id),
  endikasyon_icd varchar(10) not null default '',
  planlanan_tarih timestamptz,
  uygulama_zamani timestamptz,
  hekim_id       integer references public.taraf(id),
  yardimci_ids   integer[],
  salon          varchar(30) not null default '',
  anestezi       smallint,                                -- goz.anestezi
  anestezi_konsultasyon smallint not null default 0,
  onam_id        integer,
  -- TIME-OUT: kimlik, GÖZ, işlem ve malzeme teyidi. Yanlış göz ameliyatı
  --   önlenebilir bir olaydır; teyit kaydı tutulmazsa "yapıldı" demek de
  --   "yapılmadı" demek de kanıtsız kalır.
  time_out       jsonb,
  bulgular       text not null default '',
  komplikasyon   smallint not null default 0,             -- goz.komplikasyon
  komplikasyon_notu varchar(400) not null default '',
  postop_protokol_id integer,
  durum          smallint not null default 1,             -- goz.islem_durum
  ucret_belge_satir_id integer references public.belge_satir(id),
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_goz_islem_hasta  on public.goz_islem (hasta_id, planlanan_tarih desc);
create index if not exists ix_goz_islem_plan   on public.goz_islem (durum, planlanan_tarih);

create table if not exists public.goz_enjeksiyon (
  id             integer generated by default as identity primary key,
  islem_id       integer not null references public.goz_islem(id) on delete cascade,
  ilac           smallint,                                -- goz.enj_ilac
  doz_mg         numeric(6,3),
  doz_no         smallint,                                -- seri içindeki kaçıncı doz
  protokol       smallint,                                -- goz.enj_protokol
  aralik_hafta   smallint,
  giris_yeri     varchar(40) not null default '',
  igne           varchar(40) not null default '',
  stok_seri_lot_id integer,
  islem_sonrasi_gib numeric(4,1),
  isik_hissi     smallint,
  sonraki_planlanan date,
  oct_cmt_oncesi smallint
);
create unique index if not exists ux_goz_enj_islem on public.goz_enjeksiyon (islem_id);

create table if not exists public.goz_lazer (
  id             integer generated by default as identity primary key,
  islem_id       integer not null references public.goz_islem(id) on delete cascade,
  lazer_tur      smallint,                                -- goz.lazer_tur
  dalga_boyu_nm  smallint,
  guc_mw         numeric(8,2),
  enerji_mj      numeric(8,2),
  spot_um        smallint,
  sure_ms        smallint,
  spot_sayisi    smallint,
  alan           varchar(60) not null default '',
  lens           varchar(40) not null default '',
  seans_no       smallint
);
create unique index if not exists ux_goz_lazer_islem on public.goz_lazer (islem_id);

create table if not exists public.goz_ameliyat (
  id             integer generated by default as identity primary key,
  islem_id       integer not null references public.goz_islem(id) on delete cascade,
  ameliyat_tur   smallint,                                -- goz.ameliyat_tur
  biyometri_id   integer references public.goz_biyometri(id),
  iol_model      varchar(60) not null default '',
  iol_guc        numeric(5,2),
  iol_aks        smallint,
  uygulanan_iol_seri_lot_id integer,
  teknik         text not null default '',
  sure_dk        smallint,
  kanama_ml      smallint,
  intraop_komplikasyon smallint not null default 0,
  ameliyat_notu  text not null default '',
  patoloji_gonderildi smallint not null default 0,
  preop_checklist_tamam smallint not null default 0
);
create unique index if not exists ux_goz_ameliyat_islem on public.goz_ameliyat (islem_id);

create table if not exists public.goz_ameliyat_kontrol (
  id             bigint generated by default as identity primary key,
  islem_id       integer not null references public.goz_islem(id) on delete cascade,
  madde          varchar(120) not null,
  durum          smallint not null default 0,             -- 0 bekliyor · 1 tamam · 2 uygulanamaz
  kullanici_id   integer,
  zaman          timestamptz,
  not_metin      varchar(200) not null default ''
);
create index if not exists ix_goz_kontrol_islem on public.goz_ameliyat_kontrol (islem_id);

create table if not exists public.goz_islem_protokol (
  id             integer generated by default as identity primary key,
  ad             varchar(120) not null,
  islem_tur      smallint,
  ameliyat_tur   smallint,
  lazer_tur      smallint,
  -- [{"gun":1,"icerik":"VA, GİB, ön kamara"}, {"gun":7,…}] — postop randevular
  --   bu listeden ÜRETİLİR; hekimin her hastada aynı planı elle kurması,
  --   unutulan birinci gün kontrolü demektir.
  kontroller     jsonb not null default '[]'::jsonb,
  ilaclar        jsonb not null default '[]'::jsonb,
  aktif          smallint not null default 1
);

create table if not exists public.goz_islem_malzeme (
  id             bigint generated by default as identity primary key,
  islem_id       integer not null references public.goz_islem(id) on delete cascade,
  stok_id        integer references public.stok(id),
  seri_lot_id    integer,
  adet           numeric(12,3) not null default 1,
  uts_bildirim_id integer
);
create index if not exists ix_goz_malzeme_islem on public.goz_islem_malzeme (islem_id);

-- ================================================= kronik hastalık takibi ==
create table if not exists public.goz_hastalik_takip (
  id             integer generated by default as identity primary key,
  sube_id        integer not null default 0,
  hasta_id       integer not null references public.taraf(id),
  goz            smallint not null,
  hastalik       smallint not null,                       -- goz.hastalik
  icd_kod        varchar(10) not null default '',
  evre           varchar(30) not null default '',
  baslangic      date,
  hekim_id       integer references public.taraf(id),
  hedef_gib      numeric(4,1),
  bazal_json     jsonb,
  kontrol_periyot_ay smallint,
  ga_periyot_ay  smallint,
  oct_periyot_ay smallint,
  sonraki_kontrol date,
  progresyon_durum smallint not null default 1,           -- goz.progresyon
  son_analiz     timestamptz,
  tedavi_ozeti   text not null default '',
  durum          smallint not null default 1,
  ekleyen        integer not null default 0,
  ekleme_tarihi  timestamptz not null default now(),
  degistiren     integer not null default 0,
  degistirme_tarihi timestamptz
);
create index if not exists ix_goz_takip_hasta on public.goz_hastalik_takip (hasta_id, hastalik, goz);
create index if not exists ix_goz_takip_kontrol on public.goz_hastalik_takip (sonraki_kontrol)
  where durum = 1;

-- Materyalize göz özeti: hasta kartının üst şeridi. Her açılışta yedi tablodan
--   "son değer" toplamak, kartı hasta başına yedi sorguya bağlardı.
create table if not exists public.goz_hasta_ozet (
  hasta_id       integer not null references public.taraf(id),
  goz            smallint not null,
  son_bcva       numeric(4,2), son_bcva_tarih timestamptz,
  son_ref        varchar(40) not null default '',
  son_gib        numeric(4,1), son_gib_tarih timestamptz,
  son_cct        smallint,
  son_cd         numeric(3,2),
  son_rnfl       numeric(6,2), son_rnfl_tarih timestamptz,
  son_md         numeric(6,2),
  son_cmt        numeric(6,1),
  lens_locs      varchar(20) not null default '',
  aktif_tanilar  varchar(10)[],
  aktif_tedavi   varchar(200) not null default '',
  guncelleme     timestamptz not null default now(),
  primary key (hasta_id, goz)
);

-- ================================================== geç bağlanan yabancı anahtarlar ==
-- goz_muayene ile goz_islem birbirine bakıyor (postop kontrol ↔ işlem);
--   tablolar sırayla oluştuğu için FK'ler burada kuruluyor.
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'fk_goz_muayene_postop') then
    alter table public.goz_muayene
      add constraint fk_goz_muayene_postop foreign key (postop_islem_id)
      references public.goz_islem(id);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'fk_goz_muayene_takip') then
    alter table public.goz_muayene
      add constraint fk_goz_muayene_takip foreign key (takip_id)
      references public.goz_hastalik_takip(id);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'fk_goz_muayene_gozluk') then
    alter table public.goz_muayene
      add constraint fk_goz_muayene_gozluk foreign key (gozluk_recete_id)
      references public.goz_gozluk_recetesi(id);
  end if;
  if not exists (select 1 from pg_constraint where conname = 'fk_goz_islem_protokol') then
    alter table public.goz_islem
      add constraint fk_goz_islem_protokol foreign key (postop_protokol_id)
      references public.goz_islem_protokol(id);
  end if;
end $$;

-- ================================================================== hizmet ==
-- Göz tetkiki de satılan bir hizmettir (radyolojideki desenin aynısı): fiyat
--   fiyat listesinden, indirim kampanyadan gelir. Hizmet kartına yalnız
--   göze özgü iki alan eklenir.
alter table public.hizmet add column if not exists goz_tetkik smallint not null default 0;
alter table public.hizmet add column if not exists goz_tetkik_tur smallint;
comment on column public.hizmet.goz_tetkik is
  'Göz görüntüleme/tanısal testi mi (691) - goz_goruntuleme YALNIZ bu bayraklı hizmetten doğar.';
comment on column public.hizmet.goz_tetkik_tur is
  'Tetkik türü (691, kod_liste goz.tetkik).';
create index if not exists ix_hizmet_goz on public.hizmet (goz_tetkik_tur) where goz_tetkik = 1;

-- =================================================================== yetki ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'goz', 'Göz Kliniği', 'belge', 0, 36, 1
 where not exists (select 1 from public.yetki where kod = 'goz');

insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select v.kod, v.ad, 'goz', 1, v.sira, 1 from (values
    ('goz.on_tetkik',             'Ön tetkik (tekniker)',              1),
    ('goz.muayene',               'Göz muayenesi',                     2),
    ('goz.goruntuleme',           'Göz görüntüleme / tanısal test',     3),
    ('goz.goruntuleme.degerlendir','Görüntüleme değerlendirmesi',       4),
    ('goz.recete',                'Gözlük / kontakt lens reçetesi',    5),
    ('goz.islem',                 'Göz işlemleri (enjeksiyon/lazer/ameliyat)', 6),
    ('goz.islem.uygula',          'Göz işlemini uygula',               7),
    ('goz.takip',                 'Kronik göz hastalığı takibi',        8),
    ('goz.cihaz',                 'Göz cihazları',                     9)
  ) as v(kod, ad, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and (y.kod = 'goz' or y.kod like 'goz.%')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ============================================================ ünite akışı ==
-- Liste ekranının kaynağı: hastanın BULUNDUĞU istasyon (açık satır) + bekleme
--   süresi + dilatasyon hazırlığı. Kanban ve grid aynı görünümden beslenir.
create or replace view public.v_goz_unite_akis as
select b.id                             as belge_id,
       b.sube_id,
       b.taraf_id                       as hasta_id,
       t.unvan                          as hasta_adi,
       i.id                             as istasyon_id,
       i.istasyon,
       i.giris                          as istasyon_giris,
       i.oda,
       i.sira_no,
       i.personel_id,
       i.dilatasyon_zamani,
       i.dilatasyon_ilac,
       -- Dilatasyon 20 dk sonra hazır: hekimin hastayı erken çağırıp geri
       --   göndermesi, ünite akışındaki en sık tekrar eden kayıp.
       case when i.dilatasyon_zamani is null then null
            when i.dilatasyon_zamani + interval '20 minutes' <= now() then 1
            else 0 end                  as dilatasyon_hazir,
       extract(epoch from (now() - i.giris))::int / 60 as bekleme_dk,
       gm.id                            as goz_muayene_id,
       gm.muayene_turu,
       -- muayene'de hekim kolonu `personel_id` (Muayene modülü adlandırması);
       --   görünüm dışarıya `hekim_id` diye verir - göz ekranlarında alan adı
       --   hekimdir, iki ayrı ad ekranda karşılaşmasın.
       m.personel_id                    as hekim_id,
       h.unvan                          as hekim_adi
  from public.goz_ziyaret_istasyon i
  join public.belge b  on b.id = i.belge_id
  join public.taraf t  on t.id = i.hasta_id
  left join public.muayene m on m.belge_id = b.id
  left join public.goz_muayene gm on gm.muayene_id = m.id
  left join public.taraf h on h.id = m.personel_id
 where i.cikis is null;

comment on view public.v_goz_unite_akis is
  'Göz ünitesi akışı (691): hastanın açık istasyonu, bekleme süresi, dilatasyon hazırlığı.';
