-- =====================================================================
--  725_eczane_satinalma_modul.sql
--  API kataloğu turu: 722/723/724 ekranlarının menüde görünebilmesi için
--  eksik kalan İKİ kayıt — modül tanımı ve iki yetki kodu.
--
--  NEDEN MODÜL: hastane eczanesi ya da satınalma birimi olmayan kurumda o
--    menü grubu HİÇ çizilmemeli. Modüle bağlamasaydık, poliklinik kurulumunda
--    da "Kemoterapi Hazırlama" menüde durur ve olmayan bir yetenek vaat
--    ederdi (`MENU_GRUP_MODUL` sözleşmesi).
--
--  BİYOMEDİKAL (723) MODÜL AÇMIYOR. Cihaz/kalibrasyon/iş emri ekranları
--    mevcut **Demirbaş** menü grubunda duruyor ve `urunModu: 2` ile
--    süzülüyor: ERP demirbaş ekranı hiçbir kurulumda kapatılamamalı -
--    kapatılan modül geri açılamazdı. Ayrı bir `biyomedikal` modülü,
--    aynı envanteri iki menü dalına bölerdi.
--
--  ÜÇ YENİ YETKİ. 723/724 yetkileri yazılırken iş emri `demirbas.ariza` ve
--    `demirbas.bakim` olarak İKİYE ayrılmıştı; oysa bakım ve arıza TEK
--    tablodadır (`demirbas_is_emri`, tür ayırır) ve tek listedir - listenin
--    tek bir yetki kodu olmalı. Aynı şekilde fatura kontrolü `satinalma.kabul`
--    ile okunuyordu: mal kabul "sipariş ettiğimiz mi", fatura kontrolü
--    "tutar tuttu mu" sorusudur; birinin yetkisi diğerini vermemeli.
--    Eski kodlar KALDIRILMADI - aksiyon yetkisi olarak duruyorlar.
--    Üçüncüsü `satinalma.sozlesme`: sözleşme fiyatı SİPARİŞİ BAĞLAR, yani
--    parayı belirler; "tedarikçi yönetimi" (skor/olay okuma) yetkisiyle
--    aynı kapıdan geçemez.
-- =====================================================================

-- ============================================================ modül ==
insert into public.kurum_modul (kod, ad, sira)
select v.kod, v.ad, v.sira from (values
    ('eczane',    'Eczane',    46::smallint),
    ('satinalma', 'Satınalma', 47)
  ) as v(kod, ad, sira)
 where not exists (select 1 from public.kurum_modul m where m.kod = v.kod);

-- KURUM TİPİ VARSAYILANI: eczane yalnız yatan hasta kabul eden kurumlarda
--   varsayılan açık (hastane). Tıp merkezinde eczane olabilir ama kural
--   değil - kapalı gelir, isteyen açar.
-- Satınalma her kurum tipinde anlamlıdır (ERP dahil): talep/onay/bütçe
--   zinciri hastaneye özgü değildir. Varsayılan AÇIK değil ama TANIMLI -
--   kurum profilinden açılabilsin.
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select v.kurum_tipi, v.modul, v.varsayilan from (values
    ('hastane',     'eczane',    1::smallint),
    ('tip_merkezi', 'eczane',    0),
    ('hastane',     'satinalma', 1),
    ('tip_merkezi', 'satinalma', 0),
    ('erp',         'satinalma', 0),
    ('dis',         'satinalma', 0),
    ('dal_goz',     'satinalma', 0),
    ('dal_ftr',     'satinalma', 0),
    ('lab',         'satinalma', 0),
    ('goruntuleme', 'satinalma', 0),
    ('goruntuleme_lab', 'satinalma', 0)
  ) as v(kurum_tipi, modul, varsayilan)
 where not exists (select 1 from public.kurum_tipi_modul k
                    where k.kurum_tipi = v.kurum_tipi and k.modul = v.modul);

-- ============================================================ yetki ==
insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select v.kod, v.ad, v.grup, 0::smallint, v.sira, 1 from (values
    ('demirbas.isemri',   'İş emri (bakım & arıza)', 'Demirbaş',  8::smallint),
    ('satinalma.fatura',   'Fatura kontrolü',         'Satınalma', 14),
    ('satinalma.sozlesme', 'Tedarikçi sözleşmesi',    'Satınalma', 15)
  ) as v(kod, ad, grup, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

-- Yöneticiye ver (722/723/724'teki desenin aynısı).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and y.kod in ('demirbas.isemri', 'satinalma.fatura', 'satinalma.sozlesme')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);
