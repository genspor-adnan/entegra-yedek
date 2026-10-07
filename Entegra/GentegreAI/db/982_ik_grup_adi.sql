-- 982 · MENÜ GRUBU "İK & Prim" → "İK"
--
-- Kullanıcı 07.10.2026: *"İK & Prim rename İK her yerde"*. Grup adı menü
-- tanımlarında (kod) değişti; adı VERİ olarak taşıyan iki yer burada
-- güncellenir:
--
--   * `dokum_tanimi.menu_grup`  — dökümün hangi menü grubunda çıktığı (690).
--   * `ai_rehber_ekran`         — bağlamsal yardımın ekran dizini (871):
--                                 yol, menü grubu ve arama anahtarı.
--   * `menu_duzen`              — kurumun kendi düzenlemesi: eski adla yazılmış
--                                 satır yeni adla eşleşmezdi ve o grup
--                                 ayarlarını (gizleme, sıra) kaybederdi.
--
-- Göç dosyaları TARİHTİR, düzenlenmez: 689/690/871 oldukları gibi kaldı,
-- değişiklik bu dosyada.
update public.dokum_tanimi
   set menu_grup = 'İK'
 where menu_grup = 'İK & Prim';

update public.ai_rehber_ekran
   set yol       = replace(yol, 'İK & Prim', 'İK'),
       menu_grup = replace(menu_grup, 'İK & Prim', 'İK'),
       anahtar   = replace(anahtar, 'İK & Prim', 'İK')
 where yol like '%İK & Prim%' or menu_grup = 'İK & Prim'
    or anahtar like '%İK & Prim%';

-- Kurumun menü düzeni: grup satırı ve bir alt başlığın üst kodu.
update public.menu_duzen set sistem_kod = 'İK' where sistem_kod = 'İK & Prim';
update public.menu_duzen set ust_kod    = 'İK' where ust_kod    = 'İK & Prim';
