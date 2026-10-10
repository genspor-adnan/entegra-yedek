-- =============================================================================
--  1012 - "YÖNETİM" MENÜ GRUBU "SİSTEM" OLDU, DÖKÜMLER AYRI SATIR
--
--  Kullanıcı (10.10.2026): "yönetim grup adı yerine alternatif ne olabilir" ->
--  "Sistem yap, Dökümleri de ... Yönetim bölgesi altında sistem'den sonraya
--  taşı" (tek tıklık satır). Grup, bölgesiyle aynı adı taşıyordu ("Yönetim ›
--  Yönetim").
--
--  1) KAYITLI MENÜ DÜZENİ: grup düğümü adıyla saklanır (menu_duzen.sistem_kod,
--     dugum_tur 2 = grup). "Yönetim" grubunun sırası / gizliliği / görünen adı
--     yeni ada taşınır; aynı şubede "Sistem" satırı zaten varsa dokunulmaz.
--     Bölge düğümü "Yönetim" adını KORUR (bölge değişmedi).
--  2) YARDIM KATALOĞU: Sistem grubundaki ekranlar ve Dökümler tasarımcısı.
-- =============================================================================

update public.menu_duzen m
   set sistem_kod = 'Sistem'
 where m.dugum_tur = 2 and m.sistem_kod = 'Yönetim'
   and not exists (select 1 from public.menu_duzen x
                    where x.sube_id = m.sube_id and x.dugum_tur = 2 and x.sistem_kod = 'Sistem');

-- Alt başlık / ekran düğümünün üstü "Yönetim" ise o GRUPTUR (bölgenin
--   altında grup durur, ekran durmaz) - yeni adı izler.
update public.menu_duzen
   set ust_kod = 'Sistem'
 where dugum_tur in (3, 4) and ust_kod = 'Yönetim';

update public.ai_rehber_ekran e
   set menu_grup = 'Sistem',
       yol = 'Yönetim › Sistem › ' || e.menu_ad
 where e.kaynak in ('duyurular', 'yz-kontor', 'sube', 'genel-ayarlar', 'demo-verisi', 'iceri-alma')
   and e.menu_grup = 'Yönetim';

update public.ai_rehber_ekran
   set menu_grup = 'Dökümler', yol = 'Yönetim › Dökümler'
 where kaynak = 'dokumler' and menu_grup = 'Yönetim';
