-- ============================================================================
--  Gentegre AI — "Muhasebe" ana menüsü (çeviri)
--  353_muhasebe_menu.sql
--
--  Kullanıcı: "Stok'tan sonra Muhasebe ana menü oluştur; altına sırayla Hesap
--  Planı, Muhasebe Fişleri, Fiş Satırları, Masraf Merkezleri, İşlem Türleri
--  menülerini al" + "e-Belge menüsünü Satış ana menü altında en sona taşı".
--
--  Menü YAPISI istemcide (web/src/sayfalar/listeTanimlari.ts `menuGrup`) —
--  bu dosya yalnız yeni GRUP ADININ çevirisini ekler; alt menü adlarının
--  (Hesap Planı, Muhasebe Fişleri…) çevirileri zaten var, grup değişti diye
--  yeniden yazılmaz. Yetki kodları da değişmedi (hesap_plani, muhasebe_fis,
--  masraf_merkezi, kasa_islem_turu) - menü taşıması yetkiye dokunmaz.
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.ceviri (kapsam, anahtar, dil, metin, ekleyen)
select 'menu', v.anahtar, v.dil, v.metin, 0
  from (values ('Muhasebe', 1, 'Accounting'),
               ('Muhasebe', 2, 'Buchhaltung')) as v(anahtar, dil, metin)
 where not exists (select 1 from public.ceviri c
                    where c.kapsam = 'menu' and c.anahtar = v.anahtar and c.dil = v.dil);

do $$
begin
    raise notice '353 tamam: Muhasebe menü çevirisi (% satır)',
                 (select count(*) from public.ceviri where kapsam='menu' and anahtar='Muhasebe');
end $$;
