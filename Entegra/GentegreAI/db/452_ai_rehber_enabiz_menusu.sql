-- =====================================================================
-- 452 - REHBER KATALOĞU: e-Nabız ana menüsü
--
-- e-Nabız Gönderim Kuyruğu, Yönetim › Ortak Platform altından çıkıp
-- **Radyolojiden sonra** kendi ana menüsüne alındı (istemci menüsü
-- `listeTanimlari.ts`). Rehber ekranı menüdeki yeriyle tarif ediyor:
-- katalog güncellenmezse asistan kullanıcıyı artık var olmayan bir menü
-- yoluna gönderir.
--
-- ROTA DEĞİŞMEDİ (`/enabiz-paket`): yalnız menü yolu ve arama anahtarı
-- güncelleniyor - eski link, favori ve rehber adımı kırılmasın.
-- =====================================================================

update public.ai_rehber_ekran
   set yol       = 'e-Nabız › Gönderim Kuyruğu',
       menu_grup = 'e-Nabız',
       menu_ad   = 'Gönderim Kuyruğu',
       anahtar   = 'e-Nabız Gönderim Kuyruğu e-Nabız enabiz paket gonderim kuyrugu '
                   || 'saglik bakanligi bildirim'
 where rota = '/enabiz-paket';

do $$
begin
    raise notice '452 tamam: e-Nabız ekranı % satır güncellendi',
        (select count(*) from public.ai_rehber_ekran where menu_grup = 'e-Nabız');
end $$;
