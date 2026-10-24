-- =============================================================================
--  1165  KURUM TİPİ ADI - "ERP (üretim/ticaret)" -> "ERP"
--
--  Kullanıcı (24.10.2026): "ERP (üretim/ticaret) rename ERP". Ad girişte ve
--  başlangıç ekranında (Profil / Şube) görünüyor. Kod (erp) değişmez. Yalnız
--  eski seed adını taşıyan satır güncellenir (elle verilmiş ad korunur). İdempotent.
-- =============================================================================

begin;

update public.kurum_tipi
   set ad = 'ERP'
 where kod = 'erp' and ad = 'ERP (üretim/ticaret)';

commit;
