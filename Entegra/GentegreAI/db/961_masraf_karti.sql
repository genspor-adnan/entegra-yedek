-- ============================================================================
--  Gentegre AI — MASRAF BEYANI KARTI
--  961_masraf_karti.sql
--
--  Kullanıcı: "Masraf beyanları listesinde masraf kartı için mockup yap" →
--  "mockup uygun, uygula" (Ekranlar/IK/masraf_karti.html).
--
--  1. personel_masraf.konu (seçimli, kod listesi `ik.masraf_konu`) ve
--     ilgili_izin_id (kongre / saha ziyareti beyanını izin talebine bağlar).
--  2. masraf.personel_gunluk_sinir: gider kaleminin personel beyanında günlük
--     sınırı (ör. yemek 400 ₺). Boş = sınır yok. Aşım UYARIDIR, engel değil.
--  3. referans `ik.masraf_gecmis_gun` = 60: bundan eski harcama uyarılır.
--  Yalnız dev docker.
-- ============================================================================

alter table public.personel_masraf add column if not exists konu varchar(100) not null default '';
alter table public.personel_masraf add column if not exists ilgili_izin_id integer
    references public.personel_izin (id) on delete set null;

alter table public.masraf add column if not exists personel_gunluk_sinir numeric(18,2);

insert into public.referans (anahtar, deger, aciklama)
select 'ik.masraf_gecmis_gun', '60',
       'Masraf beyaninda bundan eski harcama uyarilir (gun, 0 = denetim yok).'
 where not exists (select 1 from public.referans where anahtar = 'ik.masraf_gecmis_gun');

insert into public.kod_liste (kod, ad)
select 'ik.masraf_konu', 'Masraf Beyanı Konusu'
 where not exists (select 1 from public.kod_liste where kod = 'ik.masraf_konu');

insert into public.kod_deger (liste_id, deger, ad, dil, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, 0, v.deger, 1, 0
  from (values (1, 'Kongre katılımı'), (2, 'Eğitim / kurs'), (3, 'Saha / şube ziyareti'),
               (4, 'Temsil / ağırlama'), (5, 'Ofis / küçük alım'), (6, 'Ulaşım'), (9, 'Diğer')) v(deger, ad)
  join public.kod_liste l on l.kod = 'ik.masraf_konu'
 where not exists (select 1 from public.kod_deger x where x.liste_id = l.id and x.deger = v.deger and x.dil = 0);
