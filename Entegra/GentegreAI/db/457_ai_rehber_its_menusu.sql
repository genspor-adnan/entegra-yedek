-- =====================================================================
-- 457 - REHBER KATALOĞU: İTS menüsü Stok & Hizmet altına
--
-- İTS Bildirimleri, Yönetim › Ortak Platform altındaydı. İTS (ilaç karekod)
-- ile ÜTS (tıbbi cihaz) ayrı kurum ve ayrı servis ama aynı iş: karekod
-- bildirimi. Menüde yan yana dursunlar diye İTS, Stok & Hizmet altında
-- **ÜTS'den hemen önce** kendi alt başlığını aldı (kullanıcı).
--
-- Rota DEĞİŞMEDİ (`/its-bildirim`); rehber ekranı menüdeki yeriyle tarif
-- ettiği için katalogdaki yol/menü adı güncelleniyor.
-- =====================================================================

update public.ai_rehber_ekran
   set yol = 'Stok & Hizmet › İTS › Bildirimler',
       menu_grup = 'Stok & Hizmet', menu_ad = 'Bildirimler',
       anahtar = 'İTS Bildirimleri ilac karekod bildirimi its stok hizmet '
                 || 'bildirim kuyrugu'
 where rota = '/its-bildirim';

do $$
begin
    raise notice '457 tamam: İTS ekrani % satir guncellendi',
        (select count(*) from public.ai_rehber_ekran
          where rota = '/its-bildirim' and menu_grup = 'Stok & Hizmet');
end $$;
