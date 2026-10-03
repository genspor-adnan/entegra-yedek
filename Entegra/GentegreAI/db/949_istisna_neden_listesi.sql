-- =====================================================================
--  949_istisna_neden_listesi.sql
--  İZİN & İSTİSNA "AÇIKLAMA / NEDEN" SEÇİMLİ (kullanıcı: "Açıklama / neden
--  combo seçimli olsun").
--
--  Bağlı kod listesi (544 deseni): `calisma.istisna_neden`, üst listesi
--  `calisma.istisna_tur` - nedenler TÜRE göre süzülür (İzin seçiliyken izin
--  nedenleri). Kart seçilen nedenin ADINI `aciklama`ya yazar (kolon metin
--  kalır; eski kayıtlar ve "Diğer" ile serbest metin bozulmaz). Kurum listeyi
--  kartın yanındaki "…" ile düzenler (ayar yetkisi).
--
--  Başlangıç değerleri yalnız EKSİKSE yazılır - kurumun düzenlediği liste
--  yeniden çalıştırmada ezilmez. Idempotent.
-- =====================================================================
\set ON_ERROR_STOP on

insert into public.kod_liste (kod, ad)
select 'calisma.istisna_neden', 'Çalışma İstisnası Nedeni'
 where not exists (select 1 from public.kod_liste where kod = 'calisma.istisna_neden');

update public.kod_liste l
   set ust_liste_id = (select u.id from public.kod_liste u where u.kod = 'calisma.istisna_tur')
 where l.kod = 'calisma.istisna_neden' and l.ust_liste_id is null;

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen, ust_deger)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0, v.ust
  from public.kod_liste l
  cross join (values
      -- 1 İzin
      (1,  'Yıllık izin', 1), (2, 'Mazeret izni', 1), (3, 'Rapor / hastalık', 1),
      (4, 'Ücretsiz izin', 1), (5, 'Nöbet sonrası izin', 1), (6, 'Diğer', 1),
      -- 2 Kongre / eğitim
      (11, 'Kongre / sempozyum', 2), (12, 'Kurs / eğitim', 2), (13, 'Toplantı / idari görev', 2),
      (14, 'Diğer', 2),
      -- 3 Saat değişikliği
      (21, 'Ameliyat / girişim', 3), (22, 'Toplantı / idari görev', 3), (23, 'Nöbet düzeni', 3),
      (24, 'Diğer', 3),
      -- 4 Ek mesai
      (31, 'Bekleyen randevu yoğunluğu', 4), (32, 'Kontrol hastaları', 4), (33, 'Kampanya / tarama', 4),
      (34, 'Diğer', 4),
      -- 5 Kapalı
      (41, 'Resmi tatil', 5), (42, 'Bayram', 5), (43, 'Cihaz / oda bakımı', 5), (44, 'Taşınma / tadilat', 5),
      (45, 'Diğer', 5)
  ) as v(deger, ad, ust)
 where l.kod = 'calisma.istisna_neden'
   and not exists (select 1 from public.kod_deger d where d.liste_id = l.id);

do $$
begin
    raise notice '949 tamam: calisma.istisna_neden (% değer).',
        (select count(*) from public.kod_deger d join public.kod_liste l on l.id = d.liste_id
          where l.kod = 'calisma.istisna_neden');
end $$;
