-- =============================================================================
--  1260  "Ürün Ağacı Kartı" → "Ürün Ağacı (Reçete) Kartı" (kullanıcı 04.11.2026) - 1256'nın kart karşılığı.
--  Yetki adı (uretim.urun_agaci); kod / rota değişmez. Web kart başlığı listeTanimlari.Stok.ts (kartBaslik).
-- =============================================================================
\set ON_ERROR_STOP on

update public.yetki set ad = 'Ürün Ağacı (Reçete) Kartı'
 where kod = 'uretim.urun_agaci' and ad = 'Ürün Ağacı Kartı';

do $$ begin raise notice '1260 tamam: Ürün Ağacı (Reçete) Kartı'; end $$;
