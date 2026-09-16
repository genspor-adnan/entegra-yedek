-- =====================================================================
--  720_ameliyat_fatura_stok.sql
--  AMELİYAT → FATURA ve SARF → STOK bağlantısının veri tarafı.
--
--  715'te ameliyatın işlemleri ve sarfı vardı ama hiçbiri para ya da stok
--  tarafına bağlanmıyordu: "bu ameliyat faturalandı mı", "bu malzeme
--  depodan düştü mü" soruları kayıttan yanıtlanamıyordu.
--
--  TEMEL KARAR — İKİ AYRI DEFTER, İKİ AYRI BELGE.
--    * ÜCRET  → hasta başvurusuna (tür 19) satır olarak yazılır. Tür 19
--      stok ve muhasebe ETKİLEMEZ (BelgeTuru); gerçek hareket faturaya
--      dönüşünce oluşur. Ameliyathane kendi fatura mantığını kurmuyor.
--    * MALZEME → stok çıkış fişiyle (tür 4) düşer; carisiz, yalnız stok
--      yönü verir (radyoloji sarfıyla aynı hat).
--    İkisi ÇİFT SAYIM ÜRETMEZ, tam da bu yüzden: başvuru satırı stoğa
--    dokunmaz, çıkış fişi hastaya yansımaz. Tek belgede birleştirseydik
--    faturalanmayan (pakete dahil) malzeme ya stoktan düşmez ya da hastaya
--    yazılırdı - ikisi de yanlış.
--
--  TEMEL KARAR — BAĞ SATIR DÜZEYİNDE. Ameliyata tek "faturalandı" bayrağı
--    koysaydık, sonradan eklenen bir işlem ya da implant o bayrağın altında
--    görünmez kalırdı. Her işlem ve her sarf kendi belge satırını taşır;
--    "faturalanmamış olan" sorgusu `belge_satir_id is null` ile yanıtlanır
--    ve tekrar faturalama aynı satırı ikinci kez yazmaz.
-- =====================================================================

-- --------------------------------------------------------- işlem → ücret
alter table public.ameliyat_islem
  add column if not exists belge_satir_id bigint;

comment on column public.ameliyat_islem.belge_satir_id is
  '720: bu islemin hasta basvurusundaki ucret satiri. NULL = henuz faturalanmadi.';

-- Faturalanmamış işlem araması: kısmi indeks, çünkü sorgunun tamamı
--   "NULL olanlar" üzerinde - dolu satırları indekslemek yer israfı.
create index if not exists ix_ameliyat_islem_faturasiz
  on public.ameliyat_islem (ameliyat_id) where belge_satir_id is null;

-- ---------------------------------------------------------- sarf → stok
-- `belge_satir_id` 715'te vardı ama neyi gösterdiği yazılmamıştı; ÜCRET
--   satırıdır. Stok çıkışı AYRI belgedir ve ayrı kolon ister - tek kolonda
--   tutsaydık "faturalandı" ile "depodan düştü" birbirinin yerine geçerdi.
comment on column public.ameliyat_sarf.belge_satir_id is
  '720: bu malzemenin hasta basvurusundaki UCRET satiri (faturaya = 1 olanlar). '
  'Stok cikisi ayri: cikis_belge_id.';

alter table public.ameliyat_sarf
  add column if not exists depo_id integer references public.depo(id);
alter table public.ameliyat_sarf
  add column if not exists cikis_belge_id integer references public.belge(id);

comment on column public.ameliyat_sarf.cikis_belge_id is
  '720: stok cikis fisi (tur 4). NULL = malzeme henuz depodan dusulmedi.';
comment on column public.ameliyat_sarf.depo_id is
  '720: cikisin yapildigi depo - fis basligindaki depo ile ayni, satirda da tutulur '
  'ki sonradan "hangi depodan gitti" sorusu fise gitmeden yanitlansin.';

create index if not exists ix_ameliyat_sarf_dusulmemis
  on public.ameliyat_sarf (ameliyat_id) where cikis_belge_id is null;

-- ------------------------------------------------------------- yetkiler
-- FATURALAMA ve STOK DÜŞÜMÜ AYRI AKSİYON YETKİSİ (tur = 1). Ameliyat
--   kaydını görebilen herkes hastaya ücret yazamamalı; malzemeyi depodan
--   düşmek de ayrı bir sorumluluk (sayımı tutan kişi başkası).
insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select v.kod, v.ad, 'Ameliyathane', 1, v.sira, 1 from (values
    ('ameliyathane.faturala',  'Ameliyatı faturaya aktar', 8::smallint),
    ('ameliyathane.stok_dus',  'Sarfı stoktan düş',        9::smallint)
  ) as v(kod, ad, sira)
 where not exists (select 1 from public.yetki y where y.kod = v.kod);

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select r.id, y.id, 1, 1, 1, 1, 0
  from public.rol r cross join public.yetki y
 where r.kod = 'yonetici'
   and y.kod in ('ameliyathane.faturala', 'ameliyathane.stok_dus')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ------------------------------------------------- ameliyathane sarf deposu
-- Hangi depodan düşüleceği AYAR: ameliyathanenin kendi deposu vardır ve
--   genel depodan düşmek sayımı bozar. Boşsa uç varsayılan depoya düşer -
--   radyolojideki (`radyoloji.sarf_depo`) desenin aynısı.
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'ameliyathane.sarf_depo', '', 'metin', 'firma',
       'Ameliyathane sarf çıkışının yapılacağı depo (boş = varsayılan depo)'
 where not exists (select 1 from public.referans where anahtar = 'ameliyathane.sarf_depo');
