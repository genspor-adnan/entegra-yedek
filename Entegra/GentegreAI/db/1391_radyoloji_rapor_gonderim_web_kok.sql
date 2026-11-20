-- 1391: rapor bağlantısının web adresi şube ayarında (1389).
--
-- İşçi SMS / e-postayı İSTEK OLMADAN yazar; bağlantının kök adresini (https://kurum.com/ai gibi, alt yol dahil)
-- isteğin Origin'inden çıkaramaz. Adres Radyoloji › Rapor Gönderimi ayarı kaydedilirken web'in kendi adresinden
-- yazılır; kullanıcı isterse elle düzeltir (ör. hastaya giden alan adı farklıysa).
alter table public.radyoloji_rapor_gonderim_ayar add column if not exists web_kok varchar(200) not null default '';
