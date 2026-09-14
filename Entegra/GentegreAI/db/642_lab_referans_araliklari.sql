-- =====================================================================
--  642_lab_referans_araliklari.sql
--  TETKİK REFERANS ARALIKLARI - hemogram (639) ve tam idrar (640)
--  parametreleri ile eksik kalan erişkin/çocuk bantları.
--
--  NEDEN GEREKLİ: sonuç bayrağı (`fn_lab_bayrak`) referans aralığından
--  hesaplanır. Referansı olmayan tetkikte her sonuç "N" (normal) çıkar -
--  yani 23 parametrelik hemogramın 20'si sessizce normal görünüyordu.
--
--  YAŞA GÖRE BANT ZORUNLU: çocukta lökosit ve lenfosit erişkinin çok
--  üstündedir (5 yaşında LYM% 40-75, erişkinde 20-45). Tek erişkin bandı
--  koymak, sağlıklı çocuğun yarım hemogramını bayraklı yapardı.
--  `fn_lab_referans` EN DAR aralığı seçer, cinsiyete özel olanı öne alır;
--  bu yüzden geniş erişkin bandı ile dar çocuk bandı birlikte durabilir.
--  Yaş bantları GÜN cinsinden: 0-28 yenidoğan, 29-364 süt çocuğu,
--  365-2189 (1-5y), 2190-4744 (6-12y), 4745-6569 (13-17y), 6570+ erişkin.
--
--  SAYISAL OLMAYAN TETKİKTE `metin` KULLANILIR: strip "negatif", idrar
--  rengi "sarı". alt/ust boş bırakılır - `fn_lab_bayrak` sayısal olmayan
--  değerde zaten bayrak üretmez, ama teknisyen beklenen sonucu ekranda
--  görmelidir.
--
--  KÜLTÜR (tur 4) ve GENETİK (tur 5) TETKİKLERE REFERANS GİRİLMEZ:
--  sonuçları rapor metnidir, aralıkla kıyaslanmaz. "Üreme olmadı"yı
--  referans diye yazmak, üreme olan kültürü "yüksek" göstermeye çalışmak
--  olurdu.
--
--  KAYNAK VE SORUMLULUK: buradaki değerler yaygın erişkin/çocuk literatür
--  aralıklarıdır ve KURUM VARSAYILANIDIR. Referans aralığı cihaza ve
--  yönteme bağlıdır; laboratuvar sorumlusu kendi kitine göre gözden
--  geçirmeden klinik kullanıma alınmamalıdır. `kaynak` alanı her satırda
--  bunu söyler; MEVCUT satırlara dokunulmaz (kurum kendi değerini
--  girdiyse korunur).
-- =====================================================================

insert into public.lab_tetkik_referans
       (tetkik_id, cinsiyet, yas_alt_gun, yas_ust_gun, alt, ust, metin,
        panik_alt, panik_ust, kaynak, sira)
select t.id, v.cinsiyet, v.yas_alt, v.yas_ust, v.alt, v.ust, v.metin,
       v.panik_alt, v.panik_ust,
       'Kurum varsayılanı (literatür) - cihaz/kit doğrulaması gerekir', v.sira
  from (values
    -- kod, cinsiyet(0 hepsi/1 E/2 K), yas_alt, yas_ust, alt, ust, metin,
    --      panik_alt, panik_ust, sira
    -- ================================================= HEMOGRAM (639)
    -- --- Eritrosit serisi
    ('RBC', 0::smallint,    0,    28, 4.10::numeric, 6.70::numeric, '', null::numeric, null::numeric, 10::smallint),
    ('RBC', 0,             29,   364, 3.80, 5.20, '', null, null, 10),
    ('RBC', 0,            365,  2189, 4.00, 5.20, '', null, null, 10),
    ('RBC', 0,           2190,  4744, 4.00, 5.20, '', null, null, 10),
    ('RBC', 1,           4745, 54750, 4.50, 5.90, '', 2.00, 8.00, 10),
    ('RBC', 2,           4745, 54750, 4.00, 5.20, '', 2.00, 8.00, 10),
    ('HCT', 0,              0,    28, 44.0, 70.0, '', null, null, 11),
    ('HCT', 0,             29,   364, 29.0, 41.0, '', null, null, 11),
    ('HCT', 0,            365,  2189, 33.0, 43.0, '', null, null, 11),
    ('HCT', 0,           2190,  4744, 34.0, 45.0, '', null, null, 11),
    ('HCT', 1,           4745, 54750, 40.0, 52.0, '', 20.0, 60.0, 11),
    ('HCT', 2,           4745, 54750, 36.0, 48.0, '', 20.0, 60.0, 11),
    -- HGB erişkin bandı zaten var; eksik olan ÇOCUK bantları.
    ('HGB', 0,              0,    28, 14.0, 24.0, '', 7.0, 22.0, 12),
    ('HGB', 0,             29,   364,  9.5, 13.5, '', 7.0, 20.0, 12),
    ('HGB', 0,            365,  2189, 11.0, 14.0, '', 7.0, 20.0, 12),
    ('HGB', 0,           2190,  4744, 11.5, 15.5, '', 7.0, 20.0, 12),
    ('HGB', 1,           4745,  6569, 13.0, 16.0, '', 7.0, 20.0, 12),
    ('HGB', 2,           4745,  6569, 12.0, 16.0, '', 7.0, 20.0, 12),
    ('MCV', 0,              0,    28, 95.0, 121.0, '', null, null, 13),
    ('MCV', 0,             29,   364, 70.0, 86.0, '', null, null, 13),
    ('MCV', 0,            365,  2189, 75.0, 87.0, '', null, null, 13),
    ('MCV', 0,           2190,  4744, 77.0, 95.0, '', null, null, 13),
    ('MCV', 0,           4745, 54750, 80.0, 100.0, '', null, null, 13),
    ('MCH', 0,            365,  4744, 24.0, 31.0, '', null, null, 14),
    ('MCH', 0,           4745, 54750, 27.0, 33.0, '', null, null, 14),
    ('MCHC', 0,             0, 54750, 32.0, 36.0, '', null, null, 15),
    ('RDW-CV', 0,           0, 54750, 11.5, 14.5, '', null, null, 16),
    ('RDW-SD', 0,           0, 54750, 35.0, 56.0, '', null, null, 17),
    -- --- Lökosit serisi
    ('WBC', 0,              0,    28,  9.0, 30.0, '', 1.0, 50.0, 20),
    ('WBC', 0,             29,   364,  6.0, 17.5, '', 1.0, 50.0, 20),
    ('WBC', 0,            365,  2189,  5.0, 15.5, '', 1.0, 50.0, 20),
    ('WBC', 0,           2190,  4744,  4.5, 13.5, '', 1.0, 50.0, 20),
    ('WBC', 0,           4745,  6569,  4.5, 11.0, '', 1.0, 50.0, 20),
    ('NEU%', 0,           365,  2189, 20.0, 45.0, '', null, null, 21),
    ('NEU%', 0,          2190,  4744, 35.0, 65.0, '', null, null, 21),
    ('NEU%', 0,          4745, 54750, 40.0, 70.0, '', null, null, 21),
    ('LYM%', 0,            29,   364, 40.0, 75.0, '', null, null, 22),
    ('LYM%', 0,           365,  2189, 40.0, 75.0, '', null, null, 22),
    ('LYM%', 0,          2190,  4744, 25.0, 50.0, '', null, null, 22),
    ('LYM%', 0,          4745, 54750, 20.0, 45.0, '', null, null, 22),
    ('MON%', 0,             0, 54750,  2.0, 10.0, '', null, null, 23),
    ('EOS%', 0,             0, 54750,  1.0,  6.0, '', null, null, 24),
    ('BAS%', 0,             0, 54750,  0.0,  2.0, '', null, null, 25),
    -- Mutlak sayılar: NEU# alt sınırı PANİK (nötropenik hasta izole edilir).
    ('NEU#', 0,           365,  2189,  1.50, 8.50, '', 0.50, null, 26),
    ('NEU#', 0,          2190,  4744,  1.80, 8.00, '', 0.50, null, 26),
    ('NEU#', 0,          4745, 54750,  1.80, 7.00, '', 0.50, null, 26),
    ('LYM#', 0,            29,   364,  4.00, 10.50, '', null, null, 27),
    ('LYM#', 0,           365,  2189,  2.00, 8.00, '', null, null, 27),
    ('LYM#', 0,          2190,  4744,  1.50, 5.00, '', null, null, 27),
    ('LYM#', 0,          4745, 54750,  1.00, 4.00, '', null, null, 27),
    ('MON#', 0,             0, 54750,  0.20, 1.00, '', null, null, 28),
    ('EOS#', 0,             0, 54750,  0.00, 0.50, '', null, null, 29),
    ('BAS#', 0,             0, 54750,  0.00, 0.10, '', null, null, 30),
    -- --- Trombosit serisi (PLT erişkin bandı zaten var)
    ('PLT', 0,              0,  4744, 150.0, 450.0, '', 20.0, 1000.0, 31),
    ('MPV', 0,              0, 54750,  7.4, 10.4, '', null, null, 32),
    ('PDW', 0,              0, 54750,  9.0, 17.0, '', null, null, 33),
    ('PCT', 0,              0, 54750,  0.15, 0.40, '', null, null, 34),

    -- ============================================== TAM İDRAR (640)
    -- Fiziksel bakı ve strip: METİN referans (sayısal kıyas yok).
    ('IRENK',    0, 0, 54750, null, null, 'Sarı / açık sarı', null, null, 40),
    ('IGORUNUM', 0, 0, 54750, null, null, 'Berrak',           null, null, 41),
    ('IDANSITE', 0, 0, 54750, 1.003, 1.030, '',               null, null, 42),
    ('IPH',      0, 0, 54750, 4.5, 8.0, '',                   null, null, 43),
    ('IPRO', 0, 0, 54750, null, null, 'Negatif', null, null, 44),
    ('IGLU', 0, 0, 54750, null, null, 'Negatif', null, null, 45),
    ('IKET', 0, 0, 54750, null, null, 'Negatif', null, null, 46),
    ('IBIL', 0, 0, 54750, null, null, 'Negatif', null, null, 47),
    ('IURO', 0, 0, 54750, null, null, 'Normal (0,2-1 mg/dL)', null, null, 48),
    ('INIT', 0, 0, 54750, null, null, 'Negatif', null, null, 49),
    ('ILE',  0, 0, 54750, null, null, 'Negatif', null, null, 50),
    ('IKAN', 0, 0, 54750, null, null, 'Negatif', null, null, 51),
    -- Sediment: sayılanlar sayısal, diğerleri metin.
    ('ISLEU', 0, 0, 54750, 0, 5, '', null, null, 52),
    ('ISERI', 0, 0, 54750, 0, 3, '', null, null, 53),
    ('ISEPI', 0, 0, 54750, null, null, 'Nadir (0-5 /HPF)', null, null, 54),
    ('ISSIL', 0, 0, 54750, null, null, 'Görülmedi (nadir hyalin normal)', null, null, 55),
    ('ISKRI', 0, 0, 54750, null, null, 'Görülmedi', null, null, 56),
    ('ISBAK', 0, 0, 54750, null, null, 'Görülmedi', null, null, 57),
    ('ISMAY', 0, 0, 54750, null, null, 'Görülmedi', null, null, 58),
    ('ISMUK', 0, 0, 54750, null, null, 'Görülmedi', null, null, 59),
    ('ISPAR', 0, 0, 54750, null, null, 'Görülmedi', null, null, 60)
  ) v(kod, cinsiyet, yas_alt, yas_ust, alt, ust, metin, panik_alt, panik_ust, sira)
  join public.lab_tetkik t on t.kod = v.kod
 where not exists (
        select 1 from public.lab_tetkik_referans r
         where r.tetkik_id = t.id and r.cinsiyet = v.cinsiyet
           and r.yas_alt_gun = v.yas_alt and r.yas_ust_gun = v.yas_ust);

-- PANİK SINIRI TETKİK KARTINA DA: referans satırı bulunamazsa (yaş bandı
--   dışı, cinsiyet eşleşmedi) `SonucYazAsync` tetkiğin kendi panik
--   sınırına düşer. Kritik analitte bu geri düşüş boş kalmamalı.
--   Kurum daha önce bir sınır girdiyse DOKUNULMAZ.
update public.lab_tetkik t
   set panik_alt = v.p_alt, panik_ust = v.p_ust, degistirme_tarihi = now()
  from (values
        ('HGB', 7.0::numeric, 20.0::numeric), ('PLT', 20.0, 1000.0),
        ('WBC', 1.0, 50.0), ('GLU', 40.0, 450.0), ('K', 2.8, 6.2),
        ('NA', 120.0, 160.0), ('CA', 6.5, 13.0), ('INR', null, 5.0)
       ) v(kod, p_alt, p_ust)
 where t.kod = v.kod
   and coalesce(t.panik_alt, t.panik_ust) is null;

do $kontrol$
declare
    v_toplam int; v_refsiz int;
begin
    select count(*) into v_toplam from public.lab_tetkik_referans;
    select count(*) into v_refsiz
      from public.lab_tetkik t
     where t.tur in (1, 2, 3) and t.durum = 0
       and not exists (select 1 from public.lab_tetkik_referans r
                        where r.tetkik_id = t.id);
    raise notice '642 tamam: % referans satiri, referanssiz sayisal/metin tetkik %',
        v_toplam, v_refsiz;
end $kontrol$;
