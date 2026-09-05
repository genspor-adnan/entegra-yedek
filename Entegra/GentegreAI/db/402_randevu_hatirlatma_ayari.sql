-- ============================================================================
--  402 - RANDEVU HATIRLATMA AYARLARI (Faz 0 · 399)
--
--  Randevu kaydedilince hatirlatma bildirimi kuyruga konur (kayit aninda,
--  planlanan = randevu saati - N saat). Iki ayar:
--    randevu.hatirlatma_acik : 1 acik / 0 kapali. SMS UCRETLI - her kurum
--                              istemez, kapatilabilmeli.
--    randevu.hatirlatma_saat : randevudan kac saat once (varsayilan 24).
-- ============================================================================

insert into public.referans (anahtar, deger, aciklama)
select v.anahtar, v.deger, v.aciklama
  from (values
    ('randevu.hatirlatma_acik', '1', 'Randevu hatırlatma bildirimi gönderilsin mi (1/0)'),
    ('randevu.hatirlatma_saat', '24', 'Randevudan kaç saat önce hatırlatma gönderilsin')
  ) as v(anahtar, deger, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);
