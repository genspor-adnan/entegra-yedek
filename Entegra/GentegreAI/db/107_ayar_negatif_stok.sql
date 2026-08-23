-- ============================================================================
--  Gentegre AI — Stok Ayarları > Genel: negatif stok davranışı
--  107_ayar_negatif_stok.sql
--
--  Stok bakiyesi eksiye dustugunde ne olacagi KODA GOMULUYDU: her zaman yalnizca
--  UYARI donuyordu (BelgeDeposu.DepoyaYaz "bakiye negatife dustu"), belge yine
--  kaydediliyordu. Sayimla calisan musteride bu dogru, seri/lot izleyen ya da
--  konsinye calisan musteride yanlis - stogu olmayan mal satiliyordu.
--
--    stok.negatif_davranis = 0 Serbest (ses cikarma)
--                            1 Uyar    (kaydet ama uyari dondur)  <- eski davranis
--                            2 Engelle (belgeyi reddet)
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
values ('stok.negatif_davranis', '1', 'sayi', 'firma',
        'Stok negatife düştüğünde: 0 serbest, 1 uyar, 2 engelle')
on conflict (anahtar) do nothing;

insert into public.help (anahtar, dil, baslik, metin) values
('ayar.stok.negatif_davranis', 0, 'Negatif stok davranışı',
 'Bir çıkış belgesi (satış, transfer, çıkış fişi) depodaki bakiyeden fazlasını '
 || 'düşürmeye çalıştığında ne yapılacağını belirler.'
 || E'\n\n'
 || '• Serbest: hiçbir şey söylenmez, bakiye eksiye düşer.' || E'\n'
 || '• Uyar: belge kaydedilir, ekranda uyarı görünür.' || E'\n'
 || '• Engelle: belge kaydedilmez, kullanıcı önce girişi yapmalıdır.'
 || E'\n\n'
 || 'Girişleri gecikmeli işleyen firmalarda "Uyar", seri/lot ya da konsinye '
 || 'takibi yapanlarda "Engelle" uygundur. Kural sunucuda uygulanır.')
on conflict (anahtar, dil) do update
   set baslik = excluded.baslik, metin = excluded.metin;

do $$
declare v text;
begin
    select deger into v from public.referans where anahtar = 'stok.negatif_davranis';
    raise notice '107 tamam: negatif stok davranisi = %', v;
end $$;
