-- ============================================================================
--  416 - IPTAL EDILEN PAKET IDEMPOTENCY ANAHTARINI TUTMAZ
--
--  415'teki benzersiz indeks (paket_turu, kaynak, islem, icerik_hash) IPTAL
--  EDILMIS paketleri de kapsiyordu. "Kaynaktan yeniden uret" once eski paketi
--  iptal edip yenisini aciyor; kaynak degismediyse icerik hash'i de ayni
--  kaliyor ve yeni satir 23505 ile reddediliyordu:
--
--      "Ayni kayit zaten var (ux_enabiz_paket_icerik)"
--
--  Sonuc: paket iptal edilmis, yenisi acilmamis - kayit tamamen kayboluyordu.
--  Idempotency YASAYAN paketler icindir; iptal edilmis bir paket "bu olay
--  zaten bildirildi" anlamina gelmez.
-- ============================================================================

drop index if exists public.ux_enabiz_paket_icerik;

create unique index ux_enabiz_paket_icerik
    on public.enabiz_paket(paket_turu_id, kaynak_tur, kaynak_id, islem, icerik_hash)
 where durum <> 5;
