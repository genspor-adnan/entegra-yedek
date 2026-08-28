-- ============================================================================
--  Gentegre AI — DOVIZ KOD LISTESI + VARSAYILAN DOVIZ AYARI
--  219_doviz_listesi_ayar.sql
--
--  Genel Ayarlar > Genel yeni duzeni (kullanici): Urun modu | Yerel para
--  birimi | Doviz - para/doviz combolari 'genel.doviz' kod listesinden
--  beslenir ve combonun ETIKETINE tiklaninca jenerik kod listesi duzenleme
--  ekrani acilir (KodListeUclari + KodListesiModali).
-- ============================================================================

insert into public.kod_liste (kod, ad)
select 'genel.doviz', 'Döviz Listesi'
 where not exists (select 1 from public.kod_liste where kod = 'genel.doviz');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, v.deger, v.ad, v.sira, 1
  from (values (1, 'TL', 10), (2, 'USD', 20), (3, 'EUR', 30), (4, 'GBP', 40))
       as v(deger, ad, sira)
  join public.kod_liste l on l.kod = 'genel.doviz'
 where not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

-- Varsayilan doviz ayari (yerel paranin yaninda onerilen yabanci doviz).
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'genel.varsayilan_doviz', 'USD', 'metin', 'firma',
       'Varsayılan döviz (belge/kur ekranlarında önerilir)'
 where not exists (select 1 from public.referans
                    where anahtar = 'genel.varsayilan_doviz');

do $$ begin
    raise notice '219 tamam: genel.doviz kod listesi + genel.varsayilan_doviz ayari.';
end $$;
