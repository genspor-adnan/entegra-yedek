-- =====================================================================
--  729_akis_ayarlari.sql
--  Eczane / biyomedikal / satınalma AKIŞ UÇLARININ okuduğu kurum ayarları.
--
--  NEDEN AYAR, NEDEN KOD DEĞİL. Onay eşiği ("kaç liradan sonra mali işler
--    imzalar") kurumun kendi kararıdır; koda sabit yazsaydık her kurumda
--    aynı rakam geçerli olurdu ve değiştirmek için sürüm beklenirdi.
--
--  BOŞ BIRAKILAN AYAR = UCUN KENDİ VARSAYILANI. Değerleri burada boş
--    bırakıyoruz: uç, ayar yoksa kod içindeki varsayılanı kullanıyor ve o
--    varsayılanın GEREKÇESİ kuralın yanında duruyor. Buraya rakam yazsaydık
--    gerekçe bir yerde, değer başka yerde kalırdı.
--
--  DEPO AYARLARI `radyoloji.sarf_depo` / `ameliyathane.sarf_depo` desenine
--    uyuyor: boşsa varsayılan depo. Eczanenin ve teknik servisin kendi
--    deposu vardır; genel depodan düşmek iki birimin sayımını da bozar.
-- =====================================================================

insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
select v.anahtar, '', v.tip, 'firma', v.aciklama from (values
    ('eczane.depo', 'metin',
     'Eczane giriş/çıkış fişlerinin kesileceği depo (boş = varsayılan depo)'),
    ('demirbas.parca_depo', 'metin',
     'Teknik servis parça çıkışının yapılacağı depo (boş = varsayılan depo)'),

    -- ONAY ZİNCİRİ EŞİKLERİ. Tutar bu eşiği AŞARSA o basamak zincire eklenir.
    --   Birim sorumlusu basamağı her talepte vardır, eşiği yoktur: talebi
    --   açanın âmiri, talebin gerçekten o birimin işi olduğunu söyleyen tek
    --   kişidir.
    ('satinalma.esik_satinalma', 'sayi',
     'Satınalma birimi onayı için alt tutar sınırı (boş = her talepte, 0)'),
    ('satinalma.esik_mali', 'sayi',
     'Mali işler onayı için alt tutar sınırı (boş = 50.000)'),
    ('satinalma.esik_ust', 'sayi',
     'Üst yönetim onayı için alt tutar sınırı (boş = 250.000)'),

    -- SÖZLÜ ONAYIN YAZILI TAMAMLANMA SÜRESİ. Süresiz bırakılsaydı "sözlü
    --   onay aldık" kalıcı bir kaçış yolu olurdu.
    ('satinalma.sozlu_onay_saat', 'sayi',
     'Sözlü onayın yazılı tamamlanma süresi, saat (boş = 24)'),

    -- ÜÇLÜ EŞLEŞTİRME TOLERANSI. Kuruş farkları fatura kontrolünü boğmasın;
    --   tolerans sıfır olsaydı her yuvarlama farkı "fark var" sayılırdı.
    ('satinalma.eslestirme_tolerans_kurus', 'sayi',
     'Fatura eşleştirmesinde yok sayılacak fark, kuruş (boş = 100 = 1 TL)')
  ) as v(anahtar, tip, aciklama)
 where not exists (select 1 from public.referans r where r.anahtar = v.anahtar);

-- ------------------------------------------------ onay basamağı benzersiz
-- AYNI TALEPTE AYNI BASAMAK İKİ KEZ OLMAZ. Uç zaten kontrol ediyor ama iki
--   eşzamanlı "onaya gönder" isteği aynı basamağı iki kez yazabilirdi ve
--   zincir "bekleyen basamak" hesabında ikiye bölünürdü.
create unique index if not exists ux_satinalma_onay_basamak
  on public.satinalma_onay (talep_id, basamak);
