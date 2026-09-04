-- ============================================================================
--  374 - taraf_acil_kisi.KIMLIK_NO
--
--  Kullanici: hasta yakinlari gridinde e-Posta'nin sagina "Kimlik No".
--
--  NEDEN GEREKLI: yakinin kimlik numarasi kayit kabulde ISLEVSEL bir bilgidir -
--  refakatci kaydi, muvafakat/onam formu ve fatura sorumlusu hep bu numaraya
--  bagli. Bugune kadar not alani ('aciklama') icine yaziliyordu; orada
--  aranamiyor ve dogrulanamiyordu.
--
--  TIP: varchar(20), TC kimlik (11) ile yabanci kimlik / pasaport numarasini
--  ayni kolonda tasir - yakin YABANCI olabilir ve o zaman 11 haneli sayi yok.
--  Bu yuzden numerik degil metin, ve ZORUNLU DEGIL: yakinin kimligi cogu
--  basvuruda sorulmaz, zorunlu kilmak var olan kayitlari da kirardi.
-- ============================================================================

alter table public.taraf_acil_kisi
  add column if not exists kimlik_no varchar(20);

comment on column public.taraf_acil_kisi.kimlik_no is
  'Yakinin kimlik numarasi (374): TC kimlik ya da yabanci kimlik/pasaport - '
  'bu yuzden metin, 11 hane zorunlulugu YOK. Refakatci kaydi, onam formu ve '
  'fatura sorumlulugu icin kullanilir. Bos birakilabilir.';
