-- =============================================================================
--  1281 - FİYAT LİSTESİ KALEM LOOKUP'I (stok kartı Fiyatlar sekmesi)  (09.11.2026)
--
--  Kullanıcı: "yeni stok kartı oluşturduğumda fiyatlar sekmesinde aktif alış/satış fiyatlarına göre satırlar
--  gelmeli" · "fiyatlar sekmesini gengrid yap, fiyat adı sütunu id yerine anlaşılır olsun". Stok kartının Fiyatlar
--  sekmesi artık `fiyat_listesi_satir` (KartKatalogu.Stok); liste seçimi bu görünümden - ad yönüyle birlikte
--  ("Satış · Perakende"), pasif liste seçilemez (aktif = durum). KodTablosu beyaz listesinde (KartDeposu.Okuma).
-- =============================================================================

create or replace view public.v_fiyat_listesi_kalem_lookup as
    select l.id,
           (case l.yon when 1 then 'Alış' else 'Satış' end || ' · ' || l.ad)::text as ad,
           l.durum as aktif
      from public.fiyat_listesi l;

comment on view public.v_fiyat_listesi_kalem_lookup is
    '1281: stok kartı Fiyatlar sekmesinde liste seçimi - ad yönüyle ("Satış · Perakende"), aktif = durum.';

do $kontrol$
begin
    raise notice '1281 tamam: v_fiyat_listesi_kalem_lookup (% liste)', (select count(*) from public.v_fiyat_listesi_kalem_lookup);
end $kontrol$;
