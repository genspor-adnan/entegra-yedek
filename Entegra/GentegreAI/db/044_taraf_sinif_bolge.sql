-- ============================================================================
--  Gentegre AI — Cari "Sınıf" ve "Bölge" alanlari
--  044_taraf_sinif_bolge.sql
--
--  Kullanici: "sektör altına Sınıf combo sağına Bölge Combo". MSSQL REHBER.SINIF/BOLGE
--  karsiliklari (GENINI BOLUM -2203 Ops_CariKart_Sinif, -2210 Ops_CariKart_Bolge) - kod_liste
--  otomatik adlandirmayla ("liste_2203"/"liste_2210") zaten goc etmisti, sadece kullanilmiyordu
--  (ayni durum 043_taraf_ilk_temas'taki gibi).
-- ============================================================================
\set ON_ERROR_STOP on

update public.kod_liste set kod = 'taraf.sinif', ad = 'Cari Sinif'
 where eski_bolum = -2203 and kod = 'liste_2203';

update public.kod_liste set kod = 'taraf.bolge', ad = 'Cari Bolge'
 where eski_bolum = -2210 and kod = 'liste_2210';
