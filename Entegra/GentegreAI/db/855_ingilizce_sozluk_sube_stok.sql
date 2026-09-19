-- ============================================================================
--  Gentegre AI — ŞUBE ADLARI VE STOK KATEGORİLERİ İNGİLİZCE (855)
--  855_ingilizce_sozluk_sube_stok.sql
--
--  Kullanıcı: *"şube ve stok adlarını da çevir"*.
--
--  ============ NE ÇEVRİLDİ ===========================================
--    · Şube adları (2): kurulumla gelen "Merkez" ve "Ankara Sube".
--    · Stok / hizmet KATEGORİLERİ (60): "Ortez / Protez", "Girişimsel
--      Kardiyoloji" - bunlar kurulum kataloğudur, listede ve ağaçta görünür.
--    · Ölçü birimleri (Adet, Kutu, Flakon…).
--
--  ============ STOK ADLARI ÇEVRİLMEDİ ================================
--  `stok` tablosunda 4.292 satır / 3.479 TEKİL ad var ve HEPSİ BÜYÜK HARF:
--  SUT/ÜTS tıbbi malzeme kataloğunun resmî tanımları ("TORAKOLOMBER
--  POSTERİOR MONOAKSİYEL (I) VİDA, TİTANYUM…"). Bunlar 854'teki SUT hizmet
--  adlarıyla aynı durumda: mevzuat metni, SGK'ya bu adla faturalanır ve
--  toplu makine çevirisi malzeme tanımında anlam kaydırır. Çevirisi
--  olmayan ad ekranda Türkçe kalır.
--
--  ============ ŞUBE ADINDA DİKKAT ====================================
--  Şube adı FATURA ÜSTÜNDE görünen ticari unvanın parçasıdır. Çeviri yalnız
--  EKRAN içindir; sunucu adı Türkçe tutar, e-Belge/MEDULA çıktısı
--  değişmez. Kurum şubesini yeniden adlandırırsa çeviri uygulanmaz.
--
--  Idempotent (`on conflict do update`).
-- ============================================================================
\set ON_ERROR_STOP on

insert into public.ceviri (kapsam, anahtar, dil, metin) values
    ('kod', 'Merkez', 1, 'Head office'),
    ('kod', 'Ankara Sube', 1, 'Ankara Branch'),
    ('kod', 'Akım Sitometri', 1, 'Flow cytometry'),
    ('kod', 'Alerji', 1, 'Allergy'),
    ('kod', 'Allogreft / Doku', 1, 'Allograft / tissue'),
    ('kod', 'Ameliyat ve Girişimler', 1, 'Surgery and interventions'),
    ('kod', 'Anestezi / Yoğun Bakım', 1, 'Anaesthesia / intensive care'),
    ('kod', 'Anjiyografi / Girişimsel', 1, 'Angiography / interventional'),
    ('kod', 'Artroplasti (Eklem Protezi)', 1, 'Arthroplasty (joint prosthesis)'),
    ('kod', 'Artroskopi / Endoskopik Cerrahi', 1, 'Arthroscopy / endoscopic surgery'),
    ('kod', 'Biyokimya', 1, 'Biochemistry'),
    ('kod', 'BT Bilgisayarlı Tomografi', 1, 'CT computed tomography'),
    ('kod', 'Cerrahi Sarf / Genel Cerrahi', 1, 'Surgical consumables / general surgery'),
    ('kod', 'Diğer Görüntüleme', 1, 'Other imaging'),
    ('kod', 'Diğer İşlemler', 1, 'Other procedures'),
    ('kod', 'Diğer Laboratuvar', 1, 'Other laboratory'),
    ('kod', 'Diğer Tıbbi Malzeme', 1, 'Other medical supplies'),
    ('kod', 'Diş İşlemi', 1, 'Dental procedure'),
    ('kod', 'Evde Bakım / Destek Cihazları', 1, 'Home care / assistive devices'),
    ('kod', 'Fonksiyon Testleri', 1, 'Function tests'),
    ('kod', 'Gastroenteroloji', 1, 'Gastroenterology'),
    ('kod', 'Genetik', 1, 'Genetics'),
    ('kod', 'Girişimsel Kardiyoloji', 1, 'Interventional cardiology'),
    ('kod', 'Girişimsel Radyoloji', 1, 'Interventional radiology'),
    ('kod', 'Göğüs Hastalıkları', 1, 'Pulmonology'),
    ('kod', 'Göz', 1, 'Ophthalmology'),
    ('kod', 'Hematoloji / Koagülasyon', 1, 'Haematology / coagulation'),
    ('kod', 'Hematoloji / Onkoloji', 1, 'Haematology / oncology'),
    ('kod', 'Hemostatik / Greft', 1, 'Haemostatic / graft'),
    ('kod', 'Hormon / Endokrin', 1, 'Hormones / endocrine'),
    ('kod', 'İlaç Düzeyi / Toksikoloji', 1, 'Drug levels / toxicology'),
    ('kod', 'Kadın Hastalıkları / Doğum', 1, 'Obstetrics / gynaecology'),
    ('kod', 'Kalp - Damar Cerrahisi', 1, 'Cardiovascular surgery'),
    ('kod', 'Kan İşlemleri', 1, 'Blood procedures'),
    ('kod', 'Kemik Dansitometri', 1, 'Bone densitometry'),
    ('kod', 'Konsultasyon', 1, 'Consultation'),
    ('kod', 'Kulak Burun Boğaz', 1, 'Ear, nose and throat'),
    ('kod', 'Laboratuvar', 1, 'Laboratory'),
    ('kod', 'Mamografi', 1, 'Mammography'),
    ('kod', 'Mikrobiyoloji / Kültür', 1, 'Microbiology / culture'),
    ('kod', 'Moleküler / Viroloji (PCR)', 1, 'Molecular / virology (PCR)'),
    ('kod', 'MR Manyetik Rezonans', 1, 'MRI magnetic resonance'),
    ('kod', 'Muayene İşlemi', 1, 'Examination procedure'),
    ('kod', 'Nefroloji / Diyaliz', 1, 'Nephrology / dialysis'),
    ('kod', 'Nöroşirurji', 1, 'Neurosurgery'),
    ('kod', 'Nükleer Tıp', 1, 'Nuclear medicine'),
    ('kod', 'Omurga Cerrahisi', 1, 'Spine surgery'),
    ('kod', 'Ortez / Protez', 1, 'Orthotics / prosthetics'),
    ('kod', 'Patoloji / Sitoloji', 1, 'Pathology / cytology'),
    ('kod', 'Radyoloji', 1, 'Radiology'),
    ('kod', 'Röntgen / Skopi', 1, 'X-ray / fluoroscopy'),
    ('kod', 'Sentetik Greft', 1, 'Synthetic graft'),
    ('kod', 'Seroloji / İmmünoloji', 1, 'Serology / immunology'),
    ('kod', 'Tıbbi Malzeme', 1, 'Medical supplies'),
    ('kod', 'Tıbbi Sarf (Genel)', 1, 'Medical consumables (general)'),
    ('kod', 'Transfüzyon', 1, 'Transfusion'),
    ('kod', 'Travma / Fiksasyon', 1, 'Trauma / fixation'),
    ('kod', 'TTB/HUV İşlemleri (SUT dışı)', 1, 'TTB/HUV procedures (outside SUT)'),
    ('kod', 'Tümör Rezeksiyon Protezi', 1, 'Tumour resection prosthesis'),
    ('kod', 'Ultrasonografi / Doppler', 1, 'Ultrasound / Doppler'),
    ('kod', 'Üroloji', 1, 'Urology'),
    ('kod', 'Yatak İşlemleri', 1, 'Bed charges'),
    ('kod', 'Adet', 1, 'Piece'),
    ('kod', 'Kutu', 1, 'Box'),
    ('kod', 'Paket', 1, 'Pack'),
    ('kod', 'Kilogram', 1, 'Kilogram'),
    ('kod', 'Gram', 1, 'Gram'),
    ('kod', 'Litre', 1, 'Litre'),
    ('kod', 'Mililitre', 1, 'Millilitre'),
    ('kod', 'Metre', 1, 'Metre'),
    ('kod', 'Santimetre', 1, 'Centimetre'),
    ('kod', 'Çift', 1, 'Pair'),
    ('kod', 'Takım', 1, 'Set'),
    ('kod', 'Ampul', 1, 'Ampoule'),
    ('kod', 'Flakon', 1, 'Vial'),
    ('kod', 'Tablet', 1, 'Tablet'),
    ('kod', 'Kapsül', 1, 'Capsule'),
    ('kod', 'Şişe', 1, 'Bottle'),
    ('kod', 'Tüp', 1, 'Tube'),
    ('kod', 'Rulo', 1, 'Roll'),
    ('kod', 'Koli', 1, 'Carton'),
    ('kod', 'Saat', 1, 'Hour'),
    ('kod', 'Gün', 1, 'Day'),
    ('kod', 'Seans', 1, 'Session'),
    ('kod', 'Kür', 1, 'Course')
on conflict (kapsam, anahtar, dil) do update set metin = excluded.metin,
    degistirme_tarihi = now();

do $$
declare v_en integer; v_stok integer;
begin
    select count(*) into v_en from public.ceviri where dil = 1;
    select count(distinct s.ad) into v_stok from public.stok s
     where not exists (select 1 from public.ceviri c where c.dil = 1 and c.anahtar = s.ad);
    raise notice '855 tamam: ingilizce sozluk % satir. Cevirisi olmayan stok adi: %.',
                 v_en, v_stok;
end $$;
