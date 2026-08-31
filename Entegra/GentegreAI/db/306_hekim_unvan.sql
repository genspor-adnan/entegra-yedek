-- 306: Hekim UNVAN oneki (Dr. / Uzm.Dr. / Prof.Dr. ...) referans listesi.
--
-- Kullanici: "avatar ve ad arasına Ünvan combo ekle, referansa yaz
-- (-/Dr./Uzm.Dr./Doç.Dr./Prof.Dr./Dt./Dr.Dt.), unvan alanında tutabilirsin".
--
-- YENI KOLON ACILMADI: onek taraf.unvan icinde saklanir - unvan zaten
-- ad+soyaddan turetilen goruntuleme adidir ("Kerem ATALAY"), onekle birlikte
-- "Op. Dr. Kerem ATALAY" olur ve her yerde (arama, liste, rapor ciktisi)
-- hekim boyle gorunur. Kart acilirken unvanin basindaki bilinen onek
-- ayristirilip comboya konur.

insert into public.kod_liste (kod, ad)
select 'hekim.unvan', 'Hekim Ünvanı'
 where not exists (select 1 from public.kod_liste where kod = 'hekim.unvan');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif)
select l.id, v.deger, v.ad, v.deger, 1
  from public.kod_liste l
 cross join (values
    (1, 'Dr.'),
    (2, 'Uzm.Dr.'),
    (3, 'Doç.Dr.'),
    (4, 'Prof.Dr.'),
    (5, 'Dt.'),
    (6, 'Dr.Dt.'),
    (7, 'Op.Dr.')
  ) as v(deger, ad)
 where l.kod = 'hekim.unvan'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger);

comment on table public.kod_deger is
  'Kod listesi degerleri. hekim.unvan (306): hekim adinin onune gelen unvan.';
