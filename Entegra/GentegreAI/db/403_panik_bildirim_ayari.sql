-- ============================================================================
--  403 - PANIK DEGER BILDIRIM AYARLARI (Faz 0 · 399)
--
--  Lab isteminde bir test "Panik" (isaret = 3) isaretlenip sonucu girilince
--  isteyen hekime bildirim kuyruga konur (oncelik 1; panik.deger sablonunun
--  saat penceresi yoktur - gece de gider).
--
--    lab.panik_bildirim_acik : 1 acik / 0 kapali
--    lab.panik_ek_numara     : NOBET numarasi. Isteyen hekimin telefonu yoksa
--                              ya da her panikte ikinci bir hat isteniyorsa
--                              buraya da gider. Bos birakilabilir.
--
--  NOT: panik ESIK KATALOGU (referans araliklari, oto-onay) Faz 2'nin isidir;
--  Faz 0'da tetik satirin ISARETIDIR. Esik katalogu gelince isareti kural
--  motoru koyacak, bildirim tarafi degismeyecek.
-- ============================================================================

insert into public.referans (anahtar, deger, aciklama)
select v.anahtar, v.deger, v.aciklama
  from (values
    ('lab.panik_bildirim_acik', '1', 'Panik değer bildirimi gönderilsin mi (1/0)'),
    ('lab.panik_ek_numara', '', 'Panik değerde ayrıca haber verilecek nöbet numarası')
  ) as v(anahtar, deger, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);
