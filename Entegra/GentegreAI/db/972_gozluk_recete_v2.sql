-- 972 GÖZLÜK REÇETESİ v2 (mockup Ekranlar/Goz/goz_gozluk_recetesi_v2.html · goz_gozluk_recete_listesi_v2.html)
--
--   * kaplamalar smallint[] -> varchar ("1,3"): kart motoru dizi kolonu yazamıyordu, kolon hiç
--     kullanılmamıştı (691'den beri boş ya da elle). Değerler korunur.
--   * deger_kaynak: OD/OS değerlerinin nereden alındığı (subjektif / sikloplejik / mevcut gözlük /
--     önceki reçete / elle) - reçeteyi okuyan "bu değer nereden" sorusunu cevaplasın.
--   * goz.gozluk_kullanim ve goz.kaplama kod listeleri.

do $$
begin
  if exists (select 1 from information_schema.columns
              where table_schema = 'public' and table_name = 'goz_gozluk_recetesi'
                and column_name = 'kaplamalar' and udt_name = '_int2') then
    alter table public.goz_gozluk_recetesi
      alter column kaplamalar drop default;
    alter table public.goz_gozluk_recetesi
      alter column kaplamalar type varchar(120) using coalesce(array_to_string(kaplamalar, ','), '');
    update public.goz_gozluk_recetesi set kaplamalar = '' where kaplamalar is null;
    alter table public.goz_gozluk_recetesi
      alter column kaplamalar set default '', alter column kaplamalar set not null;
  end if;
end $$;

alter table public.goz_gozluk_recetesi
    add column if not exists deger_kaynak varchar(40) not null default '';

insert into public.kod_liste (kod, ad)
select v.kod, v.ad from (values ('goz.gozluk_kullanim', 'Gözlük Kullanımı'), ('goz.kaplama', 'Gözlük Camı Kaplaması')) v(kod, ad)
 where not exists (select 1 from public.kod_liste where kod = v.kod);

insert into public.kod_deger (liste_id, deger, ad, dil, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, 0, v.deger, 1, 0
  from (values ('goz.gozluk_kullanim', 1, 'Sürekli'), ('goz.gozluk_kullanim', 2, 'Uzak için'),
               ('goz.gozluk_kullanim', 3, 'Okuma'), ('goz.gozluk_kullanim', 4, 'Bilgisayar'),
               ('goz.kaplama', 1, 'Antirefle'), ('goz.kaplama', 2, 'Sertlik'), ('goz.kaplama', 3, 'Mavi ışık'),
               ('goz.kaplama', 4, 'Fotokromik'), ('goz.kaplama', 5, 'Polarize'), ('goz.kaplama', 6, 'UV400')) v(liste, deger, ad)
  join public.kod_liste l on l.kod = v.liste
 where not exists (select 1 from public.kod_deger x where x.liste_id = l.id and x.deger = v.deger and x.dil = 0);
