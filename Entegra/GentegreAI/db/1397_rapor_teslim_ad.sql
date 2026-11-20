-- =============================================================================
--  1397  MENÜ / BAŞLIK ADI: "Radyoloji Rapor Teslim" -> "Rapor Teslim" (kullanıcı 20.11.2026: "liste adını ve
--        başlığı da Rapor Teslim yap")
--
--  Liste artık radyoloji raporlarını ve laboratuvar sonuçlarını birlikte gösterir (1396) - ad türden bağımsız.
--  1372 ile aynı yerler: yetki matrisi adı, AI rehberi ekranı, İngilizce menü sözlüğü. Yalnız SİSTEMİN yazdığı eski
--  değer değişir (kurumun elle verdiği ad / çeviri korunur). İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on
begin;

update public.yetki set ad = 'Rapor Teslim (Radyoloji)'
 where kod = 'radyoloji.teslim' and ad = 'Radyoloji Rapor Teslim (Radyoloji)';

update public.ai_rehber_ekran
   set baslik = 'Rapor Teslim', yol = 'Radyoloji › Rapor Teslim', menu_ad = 'Rapor Teslim',
       anahtar = 'Rapor Teslim Radyoloji Rapor Teslim Sonuç Teslim Radyoloji Laboratuvar radyoloji rapor lab sonuç teslim'
 where kaynak = 'radyoloji-teslim' and baslik = 'Radyoloji Rapor Teslim';

insert into public.ceviri (kapsam, anahtar, dil, metin)
select 'menu', 'Rapor Teslim', 1, 'Report Delivery'
 where not exists (select 1 from public.ceviri where kapsam = 'menu' and anahtar = 'Rapor Teslim' and dil = 1);

commit;
