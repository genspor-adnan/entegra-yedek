-- 1353 - KVKK / ETK onayının geçerliliği (17.11.2026).
--   Kullanıcı: "kvkk için 2 opsiyonum var: 1- Her şube için ayrı KVKK onayı al  2- X gün sonra tekrar KVKK onayı al".
--   Onay başvuruda tutuluyor (1351/1352); yeni başvuruda hastanın GEÇERLİ son onayı (SMS 4 ya da ıslak imza 3) aranır,
--   varsa KVKK / ETK onunla dolar - yoksa yeniden alınır. Ret (1) taşınmaz: her başvuruda yeniden sorulur.
--     basvuru.kvkk_sube_bazli    0 = onay tüm şubelerde geçerli · 1 = her şube için ayrı onay
--     basvuru.kvkk_gecerlilik_gun 0 = süresiz · X = onaydan X gün sonra yeniden onay alınır
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'basvuru.kvkk_sube_bazli', '0', 'sayi', 'firma',
       'KVKK/ETK onayi: 0 tum subelerde gecerli, 1 her sube icin ayri onay (1353).'
 where not exists (select 1 from public.referans where anahtar = 'basvuru.kvkk_sube_bazli');
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select 'basvuru.kvkk_gecerlilik_gun', '0', 'sayi', 'firma',
       'KVKK/ETK onayi kac gun gecerli: 0 suresiz, X gun sonra yeniden onay alinir (1353).'
 where not exists (select 1 from public.referans where anahtar = 'basvuru.kvkk_gecerlilik_gun');

insert into public.help (anahtar, dil, baslik, metin)
select v.anahtar, 0, v.baslik, v.metin
  from (values
    ('basvuru.kvkk_sube_bazli', 'KVKK onayı şube bazlı',
     'Açıksa hastanın bir şubede verdiği KVKK / ETK onayı yalnız o şubede geçerlidir; başka şubedeki ilk başvuruda yeniden onay alınır. Kapalıysa onay tüm şubelerde geçerlidir.'),
    ('basvuru.kvkk_gecerlilik_gun', 'KVKK onayı geçerlilik (gün)',
     'Onayın kaç gün geçerli olduğu. 0 = süresiz. Örn. 365: onaydan bir yıl sonraki ilk başvuruda KVKK / ETK boş gelir, yeniden onay (SMS kodu ya da ıslak imza) alınır. Geçerli onay varsa yeni başvuruda KVKK / ETK onunla dolar ve hangi başvurudan geldiği gösterilir.')
  ) v(anahtar, baslik, metin)
 where not exists (select 1 from public.help h where h.anahtar = v.anahtar and h.dil = 0);
