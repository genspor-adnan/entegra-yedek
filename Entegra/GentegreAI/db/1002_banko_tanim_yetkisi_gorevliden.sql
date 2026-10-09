-- =============================================================================
--  1002 - BANKOLAR TANIM EKRANI BANKO ÇALIŞANININ MENÜSÜNDEN ÇIKAR
--
--  Kullanıcı (09.10.2026): "hasan rolü ile girdim finans görünüyor..
--  görünmemeli.. sanırım bankolardan kaldı kaldır onu".
--
--  TEŞHİS. 998 bölmesinden sonra Banko Görevlisi'nin Finans grubunda tek
--  öğe kalmıştı: Bankolar (yetki `banko`). Bankolar aynı gün kullanıcı
--  isteğiyle Finans'a geri alınmıştı ("banko TANIMI kasa/POS kurulumudur") -
--  ekran yeri doğru, yanlış olan görevlinin o tanım ekranını görmesi.
--
--  `banko` yalnız TANIM ekranını (liste + kart) açar. Oturum akışı - banko
--  seçimi dahil (`/api/banko-oturum/uygun-bankolar`) - `banko_oturum` ile
--  çalışır; görevli oturumu Kayıt Kabul > Banko Oturumları > Yeni'den açar.
--  Yani yetkiyi almak işi bozmaz.
--
--  KAPSAM: yalnız GÖRME hakkı olan banko çalışanları (görevli, danışma,
--  vezne). Tanımı düzenleyen `banko_sorumlusu` ve `yonetici` korunur.
--  Kurumun kendi eklediği roller dokunulmaz. Betik idempotent.
-- =============================================================================

begin;

delete from public.rol_yetki ry
 using public.rol r, public.yetki y
 where ry.rol_id = r.id and ry.yetki_id = y.id
   and y.kod = 'banko'
   and r.kod in ('banko_gorevlisi', 'danisma', 'vezne')
   and ry.ekle = 0 and ry.degistir = 0 and ry.sil = 0;

commit;

-- Kontrol:
--   select r.kod from rol_yetki ry join rol r on r.id = ry.rol_id
--     join yetki y on y.id = ry.yetki_id where y.kod = 'banko';
--   -> banko_sorumlusu, yonetici
