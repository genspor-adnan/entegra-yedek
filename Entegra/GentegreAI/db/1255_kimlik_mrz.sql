-- =============================================================================
--  1255  KİMLİĞİ OKUT (MRZ) - hasta kartına kimlik belgesi alanları + kayıt kabul ayarları
--
--  Mockup: Ekranlar/Kayıt Kabul/kimlik_mrz_okut.html. Kullanıcı 03.11.2026: "kimlikte mrz kodu ne demek? ondan
--  hasta kimlik kaydı nasıl yapılır" → mockup; 04.11.2026: "mrz'yi uygula".
--
--  MRZ (ICAO 9303) kimlik kartı arkası (3 × 30) / pasaport (2 × 44) makinece okunur bölge. OCR tarayıcıda, alan
--  ayrıştırma + kontrol haneleri + T.C. algoritması sunucuda (MrzCozucu, POST /api/kimlik/mrz-coz). Görüntü ve ham
--  MRZ SAKLANMAZ (KVKK); okutma işlem loguna düşer (953, islem 'mrz').
--
--  VERİ YAPISI DEĞİŞMEZ - hasta kartına yalnız belge türü / seri no / son kullanma eklenir (taraf_hasta, ozluk
--  detayı). Uyruk (SKRS hasta.uyruk) ve pasaport no zaten var.
--
--  Ayarlar (Kayıt Kabul Ayarları › Hasta; EkranKodlari.KayitKabulAyarAnahtarlari):
--    kayit.kimlik_okutma        0 kapalı · 1 kamera · 2 tarayıcı / dosya · 3 ikisi (varsayılan 3)
--    kayit.suresi_dolmus_belge  0 uyar · 1 engelle (varsayılan uyar - acil hasta durmasın)
--    kayit.ocr_esik             OCR güven eşiği % (50-100, varsayılan 90) - altı "yeniden okut"
-- =============================================================================
\set ON_ERROR_STOP on

alter table public.taraf_hasta
    add column if not exists belge_turu        smallint,
    add column if not exists belge_seri_no     varchar(20),
    add column if not exists belge_son_kullanma date;

comment on column public.taraf_hasta.belge_turu is
  'Kimlik belgesi türü: 1 kimlik kartı · 2 pasaport · 3 diğer (ikamet, sürücü belgesi). MRZ okutmada belge kodundan dolar (1255).';
comment on column public.taraf_hasta.belge_seri_no is
  'Kimlik belgesi seri / belge no (kimlik kartı A12B34567, pasaportta pasaport no ile aynı). MRZ okutmadan ya da elle (1255).';
comment on column public.taraf_hasta.belge_son_kullanma is
  'Kimlik belgesinin son kullanma tarihi. Dolmuşsa kimlik alanında uyarı rozeti; kayit.suresi_dolmus_belge = 1 ise aktarım engellenir (1255).';

-- ------------------------------------------------------------- ayarlar -----
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'kayit.kimlik_okutma', '3', 'sayi', 'firma',
       'Kimlik okutma (MRZ): 0 kapali, 1 kamera, 2 tarayici / dosya, 3 ikisi (1255).'
 where not exists (select 1 from public.referans where anahtar = 'kayit.kimlik_okutma');
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'kayit.suresi_dolmus_belge', '0', 'sayi', 'firma',
       'Suresi dolmus kimlik belgesi: 0 uyar (kayit engellenmez), 1 engelle (1255).'
 where not exists (select 1 from public.referans where anahtar = 'kayit.suresi_dolmus_belge');
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'kayit.ocr_esik', '90', 'sayi', 'firma',
       'MRZ OCR guven esigi (%): altinda kalan okuma karta aktarilmaz, yeniden okutulur (1255).'
 where not exists (select 1 from public.referans where anahtar = 'kayit.ocr_esik');

insert into public.help (anahtar, dil, baslik, metin)
values
 ('kayit.kimlik_okutma', 0, 'Kimlik okutma',
  'Hasta kartındaki "Kimliği Okut" düğmesi kimlik kartının arka yüzündeki ya da pasaportun alt kenarındaki makinece okunur bölgeyi (MRZ, ICAO 9303) okur: kimlik no, ad / soyad, doğum tarihi, cinsiyet, uyruk, belge no ve geçerlilik dolar; kayıtlı hasta varsa açılır. Kapalı: düğme görünmez. Kamera: bankodaki web kamerası. Tarayıcı / dosya: tarayıcıdan gelen resim ya da MRZ okuyucu cihaz (klavye gibi metin verir). Görüntü sunucuya ve diske gitmez; yalnız çözülen alanlar karta yazılır, okutma işlem loguna düşer.'),
 ('kayit.suresi_dolmus_belge', 0, 'Süresi dolmuş belge',
  'Okutulan kimlik belgesinin geçerliliği dolmuşsa ne olacağı. Uyar: kayıt engellenmez (acil hasta durmasın), kimlik alanına uyarı rozeti düşer. Engelle: alanlar karta aktarılmaz, hasta güncel belgeyle kaydedilir.'),
 ('kayit.ocr_esik', 0, 'OCR güven eşiği',
  'Kameradan / dosyadan okumada tanıma güveni bu yüzdenin altında kalırsa alanlar karta aktarılmaz ve "yeniden okut" istenir. Kontrol haneleri tutmayan alan her durumda kırmızı çizilir ve aktarılmaz. MRZ metni yapıştırılırsa ya da okuyucu cihazdan gelirse eşik uygulanmaz.')
on conflict (anahtar, dil) do nothing;

do $$ begin raise notice '1255 tamam: taraf_hasta.belge_turu / belge_seri_no / belge_son_kullanma, kayit.kimlik_okutma / suresi_dolmus_belge / ocr_esik'; end $$;
