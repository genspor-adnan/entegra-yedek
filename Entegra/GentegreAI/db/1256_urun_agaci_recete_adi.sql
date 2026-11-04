-- =============================================================================
--  1256  "Ürün Ağacı Listesi" → "Ürün Ağacı (Reçete) Listesi" (kullanıcı 04.11.2026: "rename her yerde")
--
--  KOBİ üretimcisi "reçete" der; ekran, menü, yetki adı, rehber ve çeviri aynı adı taşısın. Kod / rota / yetki
--  kodu DEĞİŞMEZ (uretim.urun_agaci.liste, /urun-agaci). Web liste tanımı (listeTanimlari.Stok.ts) aynı commit'te.
-- =============================================================================
\set ON_ERROR_STOP on

update public.yetki set ad = 'Ürün Ağacı (Reçete) Listesi'
 where kod = 'uretim.urun_agaci.liste' and ad = 'Ürün Ağacı Listesi';

update public.ai_rehber_ekran
   set baslik  = 'Ürün Ağacı (Reçete) Listesi',
       yol     = 'Üretim › Ürün Ağacı (Reçete) Listesi',
       menu_ad = 'Ürün Ağacı (Reçete) Listesi',
       anahtar = 'Ürün Ağacı (Reçete) Listesi Ürün Ağaçları Reçete Üretim urun agaci recete bom'
 where kaynak = 'urun-agaci' and rota = '/urun-agaci';

-- Menü çevirisi: anahtar Türkçe metnin kendisi (656); kurumun elle girdiği varsa dokunulmaz.
insert into public.ceviri (kapsam, anahtar, dil, metin)
select 'menu', 'Ürün Ağacı (Reçete) Listesi', 1, 'Bill of Materials (Recipe) List'
 where not exists (select 1 from public.ceviri where kapsam = 'menu' and anahtar = 'Ürün Ağacı (Reçete) Listesi' and dil = 1);

do $$ begin raise notice '1256 tamam: Ürün Ağacı (Reçete) Listesi'; end $$;
