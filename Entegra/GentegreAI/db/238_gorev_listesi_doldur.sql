-- 238: Görev listesi kayıtlardan dolduruldu (kullanıcı: "departman ve görev
-- içeriği kayıtlardan doldur").
--
-- Departman listesi zaten Delphi'den taşınmıştı (34 değer). Görev ise eski
-- sistemde REHBERBILGI etiket/değer deseninde duruyordu ("Görevi" etiketi,
-- 22 kayıt / 12 farklı değer) ve göçte kaldırılan bu tabloyla birlikte
-- düşmüştü. Değerler listeye alınıyor; personel kayıtlarına ATAMA yapılmıyor
-- (göçte taraf id'leri değiştiği için REHBERBILGI.YER_ID ile güvenilir
-- eşleşme kurulamıyor - görev kartlardan combodan seçilecek).

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id,
       coalesce((select max(d2.deger) from public.kod_deger d2
                  where d2.liste_id = l.id), 0) + row_number() over (order by v.ad),
       v.ad,
       (coalesce((select max(d2.sira) from public.kod_deger d2
                   where d2.liste_id = l.id), 0) + row_number() over (order by v.ad) * 10),
       1, 0
  from public.kod_liste l
  cross join (values
      ('CEO'), ('Eğitim Yöneticisi'), ('Genel Müdür'), ('IT Destek'),
      ('İthalat İhracat Sorumlusu'), ('Muhasebe'), ('Satınalma Sorumlusu'),
      ('Satış Destek'), ('Satış Sorumlusu'), ('Servis Müdürü'),
      ('Servis Mühendisi'), ('Yönetici Asistanı')
  ) as v(ad)
 where l.kod = 'taraf.gorev'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and lower(trim(d.ad)) = lower(trim(v.ad)));
