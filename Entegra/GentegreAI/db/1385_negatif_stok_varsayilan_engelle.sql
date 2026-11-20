-- 1385: negatif stok varsayılanı ENGELLE (kullanıcı 20.11.2026: "Stokta 10 adet olan ürüne 11 adet satış faturası
-- kesilebiliyor.. 5 giriş fişi girip 6 çıkış fişi ile çıkış yapılabiliyor. satış belgeleri adetten fazla çıkamaz" →
-- karar: "Varsayılan Engelle, ayar kalsın").
--
-- 107 ayarı 1 (Uyar) ile kurmuştu: çıkış belgesi bakiyeden fazla düşürünce yalnız uyarı verip kaydediyordu. Varsayılan
-- artık 2 (Engelle); kurulumlardaki 1 (Uyar) değeri 2'ye çekilir. 0 (Serbest) BİLEREK seçilmiş sayılır, dokunulmaz.
-- İsteyen firma Stok Ayarları › Negatif stok davranışı'ndan yine "Uyar" seçebilir.
-- Eski değer _yedek_referans_1385'e yazılır (geri dönüş: deger'i yedekten geri yazın).

create table if not exists public._yedek_referans_1385 as
  select r.*, now() as yedek_zamani from public.referans r where false;

insert into public._yedek_referans_1385
select r.*, now() from public.referans r
 where r.anahtar = 'stok.negatif_davranis'
   and not exists (select 1 from public._yedek_referans_1385 y where y.anahtar = r.anahtar);

update public.referans
   set deger = '2', degistirme_tarihi = now()
 where anahtar = 'stok.negatif_davranis' and deger = '1';

-- Kurulumda satır hiç yoksa (eski / kısmi kurulum) Engelle ile eklenir.
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
values ('stok.negatif_davranis', '2', 'sayi', 'firma', 'Stok negatife düştüğünde: 0 serbest, 1 uyar, 2 engelle')
on conflict (anahtar) do nothing;

update public.help
   set metin = replace(metin, 'Girişleri gecikmeli işleyen firmalarda "Uyar", seri/lot ya da konsinye takibi yapanlarda "Engelle" uygundur.',
                       'Varsayılan "Engelle"dir (1385): satış ve çıkış belgeleri stoktan fazla çıkamaz. Girişleri gecikmeli işleyen firma "Uyar" seçebilir.')
 where anahtar = 'ayar.stok.negatif_davranis';

do $$
declare v text;
begin
    select deger into v from public.referans where anahtar = 'stok.negatif_davranis';
    raise notice '1385 tamam: negatif stok davranisi = %', v;
end $$;
