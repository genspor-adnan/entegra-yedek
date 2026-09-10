-- =====================================================================
--  532_fiyat_listesi_grup_dusur.sql
--  `fiyat_listesi.grup` kolonu düşer.
--
--  Kullanıcı: "fiyat listesinden grubu kaldır, alan olarak da iptal."
--
--  518'de TARİFE TİPİ ayrı kolon oldu (0 genel · 1 Özel · 2 TTB/HUV · 3 SUT)
--  çünkü `grup` iki soruyu birden taşıyordu: ticari sınıf (Perakende/Bayi)
--  ve tarife tipi. Tip kendi kolonuna taşındıktan sonra `grup` aynı sayıyı
--  ikinci kez gösteriyordu - kartta "Grubu: SUT (SGK)" ve hemen yanında
--  "Tarife Tipi: SUT (SGK)".
--
--  Hiçbir görünüm/fonksiyon okumuyordu (arandı); yalnız kart alanı, liste
--  kolonu ve varsayılan sıralama kullanıyordu - üçü de kaldırıldı.
-- =====================================================================

create table if not exists public._yedek_fiyat_listesi_grup_532 as
select id, grup from public.fiyat_listesi;

alter table public.fiyat_listesi drop column if exists grup;

-- Kod listesi de kalkar: karşılığı olmayan liste, ayar ekranında ölü kayıt.
delete from public.kod_deger
 where liste_id in (select id from public.kod_liste where kod = 'fiyat_listesi.grup');
delete from public.kod_liste where kod = 'fiyat_listesi.grup';
