-- =============================================================================
--  1164  POS LİSTESİ - yardım kataloğu / menü çevirisi adı
--
--  Kullanıcı (24.10.2026): "POS Hesabı Listesi rename POS Listesi, menüde de POS
--  Listesi olarak görünsün". Menü adı istemcide (listeTanimlari menuAd); burada
--  yardım kataloğundaki (ai_rehber_ekran) ad ve İngilizce menü çevirisi.
--  Menü kodu (pos-hesap) değişmez - GenProfil menü düzenleri o kodla tutuyor.
--  Var olan çeviriye dokunulmaz (kurumun elle girdiği geri alınmasın). İdempotent.
-- =============================================================================

begin;

update public.ai_rehber_ekran
   set baslik = 'POS Listesi', menu_ad = 'POS Listesi',
       anahtar = 'POS Listesi POS hesapları POS Banka hesap komisyon valör'
 where rota = '/pos-hesap' and baslik <> 'POS Listesi';

insert into public.ceviri (kapsam, anahtar, dil, metin)
select 'menu', 'POS Listesi', 1, 'POS List'
 where not exists (select 1 from public.ceviri c
                    where c.kapsam = 'menu' and c.anahtar = 'POS Listesi' and c.dil = 1);

do $kontrol$
begin
    raise notice '1164 tamam: rehber %, çeviri %',
        (select baslik from public.ai_rehber_ekran where rota = '/pos-hesap'),
        (select metin from public.ceviri where kapsam = 'menu' and anahtar = 'POS Listesi' and dil = 1);
end $kontrol$;

commit;
