-- ============================================================================
--  Gentegre AI — Cari "İlk Temas" alani
--  043_taraf_ilk_temas.sql
--
--  Kullanici: "kategori sağına İlk Temas combo gelsin". MSSQL REHBER.TEMAS karsiligi
--  (GENINI BOLUM -2207, Ops_CariKart_Temas) - goc sirasinda taraf'a hic tasinmamis
--  (kolon yoktu), ama kod_liste/kod_deger otomatik adlandirmayla ("liste_2207") zaten
--  goc etmisti (11 satir: Fuar/Eski Musteri/Tanidik/...). Grup/Kategori/Sektor'daki
--  035 desenine uyup ISIM DUZELTILIYOR (yeniden insert degil).
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.taraf add column if not exists ilk_temas smallint;

update public.kod_liste set kod = 'taraf.ilk_temas', ad = 'Cari Ilk Temas'
 where eski_bolum = -2207 and kod = 'liste_2207';
