-- =============================================================================
--  1247  SATINALMA "SİPARİŞ TAKİBİ" -> "ALIŞ SİPARİŞİ LİSTESİ"
--
--  Kullanıcı 02.11.2026: "Sipariş Takibi (Sipariş Listesi) rename Alış Siparişi Listesi.. tüm menü ve başlıklarda".
--  Menü / liste başlığı web tanımında (listeTanimlari.Satinalma.ts); burada bağlamsal yardım / komut arama ekran
--  kataloğu (ai_rehber_ekran, 871) aynı ada çekilir. Yalnız hâlâ eski adı taşıyan satır güncellenir.
--  İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

update public.ai_rehber_ekran
   set baslik  = 'Alış Siparişi Listesi',
       yol     = 'Satınalma › Alış Siparişi Listesi',
       menu_ad = 'Alış Siparişi Listesi',
       anahtar = 'Alış Siparişi Listesi Satınalma alis siparisi listesi siparis takibi satinalmasiparis'
 where kaynak = 'satinalmaSiparis'
   and baslik = 'Sipariş Takibi';

commit;
