-- ============================================================================
--  422 - DOKUMAN KARTI GORUNUMLERI (mockup dokuman_karti.html)
--
--  Kartin ONAY AKISI sekmesi adimlari gostermeli ama `dokuman_onay_adim`
--  dokumana DOLAYLI baglidir (dokuman -> dokuman_onay -> adim). Kart detay
--  tanimi dogrudan bir ust kolon ister; bu yuzden dokuman_id tasiyan bir
--  gorunum verilir. Detay SALT OKUNUR: karar vermek bir DUGMENIN isi
--  (dokuman-yonetim/onay/{id}/karar), satiri elle "onaylandi" yapmak onay
--  zincirini anlamsiz kilardi.
-- ============================================================================

create or replace view public.v_dokuman_onay_adim as
    select a.id,
           o.dokuman_id,
           o.id            as onay_id,
           s.surum_no,
           a.sira,
           a.ad,
           a.karar,
           a.karar_veren_id,
           a.karar_zamani,
           a.not_metni,
           o.durum         as onay_durum,
           o.guncel_adim,
           o.baslama
      from public.dokuman_onay_adim a
      join public.dokuman_onay o on o.id = a.onay_id
      left join public.dokuman_surum s on s.id = o.surum_id;

comment on view public.v_dokuman_onay_adim is
    'Dokuman kartinin Onay Akisi sekmesi (422): adimlar dokuman_id ile duz okunur.';
