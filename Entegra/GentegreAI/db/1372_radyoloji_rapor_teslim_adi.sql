-- =============================================================================
--  1372  MENÜ ADI: "Sonuç Teslim" -> "Radyoloji Rapor Teslim" (kullanıcı 18.11.2026: "ana menüde liste olarak
--        Sonuç Teslim rename Radyoloji Rapor Teslim")
--
--  Menü adı web'deki liste tanımından gelir (listeTanimlari.Radyoloji.ts). Aynı ad yetki matrisinde (yetki.ad -
--  "matris = menü birebir"), AI rehberinde (ai_rehber_ekran; ekran önerisi) ve İngilizce menü sözlüğünde (ceviri,
--  anahtar = Türkçe metin) de geçer. Yalnız SİSTEMİN yazdığı eski değer değişir (kurumun elle verdiği ad / çeviri
--  korunur). İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

update public.yetki set ad = 'Radyoloji Rapor Teslim (Radyoloji)'
 where kod = 'radyoloji.teslim' and ad = 'Sonuç Teslim (Radyoloji)';

update public.ai_rehber_ekran
   set baslik = 'Radyoloji Rapor Teslim', yol = 'Radyoloji › Radyoloji Rapor Teslim', menu_ad = 'Radyoloji Rapor Teslim',
       anahtar = 'Radyoloji Rapor Teslim Sonuç Teslim Radyoloji radyoloji rapor teslim'
 where kaynak = 'radyoloji-teslim' and baslik = 'Sonuç Teslim';

insert into public.ceviri (kapsam, anahtar, dil, metin)
select 'menu', 'Radyoloji Rapor Teslim', 1, 'Radiology Report Delivery'
 where not exists (select 1 from public.ceviri where kapsam = 'menu' and anahtar = 'Radyoloji Rapor Teslim' and dil = 1);

commit;
