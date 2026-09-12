-- =====================================================================
--  611_departman_skrs_klinik.sql
--  DEPARTMANIN SKRS KLİNİK KODU AYRI BİR ALAN.
--
--  `departman.kod` bugüne kadar e-Nabız'a KLİNİK_KODU olarak
--  gönderiliyordu. Yanlıştı: o kodlar SKRS'nin "PERSONEL BRANŞ KODU"
--  listesinden geliyor, KLİNİKLER listesinden değil. İki listede aynı
--  sayı bambaşka şeyi gösteriyor - departman 1 "Acil Yoğun Bakım"
--  (branş 1) SKRS KLİNİKLER'de 1 = "ACİL TIP", departman "Acil"in
--  kodu 102, KLİNİKLER'de 102 = "ADLI TIP". Yani her paket yanlış
--  kliniği bildiriyordu.
--
--  Çözüm: klinik kodu AYRI kolonda tutulur. `kod` branş kodu olarak
--  yerinde kalır (personel/branş ekranları onu kullanıyor).
--
--  Doldurma KESİN eşleşmeyle sınırlı: departman adının sözcük kümesi
--  SKRS klinik adınınkiyle birebir aynı olanlar. Kalanı BOŞ bırakılır -
--  "Arşiv", "Güvenlik", "Bilgi İşlem" gibi klinik olmayan bölümler de
--  var; benzeyen bir adı tahminle seçmek, yanlış kliniği bildirmenin
--  başka bir yolu olurdu. Boş kalanları hastane departman kartından
--  seçer; kodu olmayan departmanda alan boş gider.
-- =====================================================================

alter table public.departman
  add column if not exists skrs_klinik_kod varchar(10) not null default '';

comment on column public.departman.skrs_klinik_kod is
  '611: SKRS KLINIKLER kodu (USS 101 KLINIK_KODU). `kod` branş kodudur, '
  'bu ayri alandir. Bos = departmanin SKRS klinik karsiligi secilmemis.';


update public.departman d
   set skrs_klinik_kod = v.kod
  from (values
         (2, '197001'),  -- Acil Cerrahi Yoğun Bakım -> ACİL CERRAHİ YOĞUN BAKIM
         (4, '197003'),  -- Acil Yoğun Bakım -> ACİL YOĞUN BAKIM
         (5, '102'),  -- Adli Tıp -> ADLI TIP
         (6, '105'),  -- Ağız Yüz ve Çene Cerrahisi -> AĞIZ, YÜZ VE ÇENE CERRAHISI
         (7, '106'),  -- Aile Hekimliği -> AILE HEKIMLIĞI
         (8, '107'),  -- Algoloji -> ALGOLOJI
         (9, '197004'),  -- Ameliyathane Yoğun Bakım -> AMELİYATHANE YOĞUN BAKIM
         (10, '108'),  -- Anatomi -> ANATOMI
         (11, '109'),  -- Anesteziyoloji ve Reanimasyon -> ANESTEZIYOLOJI VE REANIMASYON
         (12, '197006'),  -- Beyin Cerrahi Yoğun Bakım -> BEYİN CERRAHİ YOĞUN BAKIM
         (13, '112'),  -- Beyin ve Sinir Cerrahisi -> BEYIN VE SINIR CERRAHISI
         (14, '113'),  -- Cerrahi Onkoloji -> CERRAHI ONKOLOJI
         (16, '115'),  -- Çocuk Acil -> ÇOCUK ACIL
         (17, '197008'),  -- Çocuk Cerrahi Yoğun Bakım -> ÇOCUK CERRAHİ YOĞUN BAKIM
         (18, '116'),  -- Çocuk Cerrahisi -> ÇOCUK CERRAHISI
         (19, '118'),  -- Çocuk Endokrinolojisi -> ÇOCUK ENDOKRINOLOJISI
         (20, '119'),  -- Çocuk Enfeksiyon Hastalıkları -> ÇOCUK ENFEKSIYON HASTALIKLARI
         (21, '197009'),  -- Çocuk Enfeksiyon Yoğun Bakım -> ÇOCUK ENFEKSİYON YOĞUN BAKIM
         (22, '120'),  -- Çocuk Gastroenterolojisi -> ÇOCUK GASTROENTEROLOJISI
         (23, '121'),  -- Çocuk Genetik Hastalıkları -> ÇOCUK GENETIK HASTALIKLARI
         (24, '199'),  -- Çocuk Göğüs Hastalıkları -> ÇOCUK GÖĞÜS HASTALIKLARI
         (26, '124'),  -- Çocuk İmmunolojisi ve Alerji Hastalıkları -> ÇOCUK İMMÜNOLOJISI VE ALERJI HASTALIKLARI
         (28, '126'),  -- Çocuk Kardiyolojisi -> ÇOCUK KARDIYOLOJISI
         (29, '127'),  -- Çocuk Metabolizma Hastalıkları -> ÇOCUK METABOLIZMA HASTALIKLARI
         (30, '128'),  -- Çocuk Nefrolojisi -> ÇOCUK NEFROLOJISI
         (31, '129'),  -- Çocuk Nörolojisi -> ÇOCUK NÖROLOJISI
         (33, '132'),  -- Çocuk Sağlığı ve Hastalıkları -> ÇOCUK SAĞLIĞI VE HASTALIKLARI
         (34, '133'),  -- Çocuk Ürolojisi -> ÇOCUK ÜROLOJISI
         (35, '134'),  -- Çocuk ve Ergen Ruh Sağlığı ve Hastalıkları -> ÇOCUK VE ERGEN RUH SAĞLIĞI VE HASTALIKLARI
         (39, '137'),  -- El cerrahisi -> EL CERRAHISI
         (42, '140'),  -- Enfeksiyon Hastalıkları ve Klinik Mikrobiyoloji -> ENFEKSIYON HASTALIKLARI VE KLINIK MIKROBIYOLOJI
         (46, '143'),  -- Fizyoloji -> FIZYOLOJI
         (51, '147'),  -- Genel Cerrahi -> GENEL CERRAHİ
         (52, '197007'),  -- Genel Cerrahi Yoğun Bakım -> GENEL CERRAHİ YOĞUN BAKIM
         (53, '197'),  -- Genel Yoğun Bakım -> GENEL YOĞUN BAKIM
         (54, '148'),  -- Geriatri -> GERIATRI
         (55, '197016'),  -- Göğüs Cerrahi  Yoğun Bakım -> GÖĞÜS CERRAHİ YOĞUN BAKIM
         (56, '149'),  -- Göğüs Cerrahisi -> GÖĞÜS CERRAHISI
         (57, '150'),  -- Göğüs Hastalıkları -> GÖĞÜS HASTALIKLARI
         (59, '151'),  -- Göz Hastalıkları -> GÖZ HASTALIKLARI
         (60, '152'),  -- Halk Sağlığı -> HALK SAĞLIĞI
         (61, '155'),  -- Hematoloji -> HEMATOLOJI
         (62, '197018'),  -- Hematoloji Yoğun Bakım -> HEMATOLOJİ YOĞUN BAKIM
         (63, '157'),  -- İç Hastalıkları -> İÇ HASTALIKLARI
         (64, '158'),  -- İmmunoloji ve Alerji Hastalıkları -> İMMÜNOLOJI VE ALERJI HASTALIKLARI
         (66, '160'),  -- Jinekolojik Onkoloji Cerrahisi -> JINEKOLOJIK ONKOLOJI CERRAHISI
         (67, '197019'),  -- Kadın Doğum Yoğun Bakım -> KADIN DOĞUM YOĞUN BAKIM
         (68, '161'),  -- Kadın Hastalıkları ve Doğum -> KADIN HASTALIKLARI VE DOĞUM
         (69, '162'),  -- Kalp Damar Cerrahisi -> KALP VE DAMAR CERRAHISI
         (70, '163'),  -- Kardiyoloji -> KARDIYOLOJI
         (71, '164'),  -- Klinik Nörofizyoloji -> KLINIK NÖROFIZYOLOJI
         (72, '197020'),  -- Koroner Yoğun Bakım -> KORONER YOĞUN BAKIM
         (74, '197021'),  -- KVC Yoğun Bakım -> KVC YOĞUN BAKIM
         (75, '166'),  -- Nefroloji -> NEFROLOJI
         (76, '197022'),  -- Nefroloji Yoğun Bakım -> NEFROLOJİ YOĞUN BAKIM
         (77, '167'),  -- Neonatoloji -> NEONATOLOJI
         (78, '168'),  -- Nöroloji -> NÖROLOJI
         (79, '197023'),  -- Nöroloji Yoğun Bakım -> NÖROLOJİ YOĞUN BAKIM
         (80, '169'),  -- Nükleer Tıp -> NÜKLEER TIP
         (81, '197024'),  -- Onkoloji Yoğun Bakım -> ONKOLOJİ YOĞUN BAKIM
         (82, '197025'),  -- Organ Nakli Yoğun Bakım -> ORGAN NAKLİ YOĞUN BAKIM
         (83, '171'),  -- Ortopedi ve Travmatoloji -> ORTOPEDI VE TRAVMATOLOJI
         (84, '197026'),  -- Ortopedi Yoğun Bakım -> ORTOPEDİ YOĞUN BAKIM
         (86, '197027'),  -- Pediatri Yoğun Bakım -> PEDİATRİ YOĞUN BAKIM
         (87, '172'),  -- Periferik Damar Cerrahisi -> PERIFERIK DAMAR CERRAHISI
         (88, '173'),  -- Perinatoloji -> PERINATOLOJI
         (89, '175'),  -- Plastik, Rekonstrüktif ve Estetik Cerrahi -> PLASTIK, REKONSTRÜKTIF VE ESTETIK CERRAHI
         (90, '197028'),  -- Post-Op Yoğun Bakım -> POST-OP YOĞUN BAKIM
         (91, '177'),  -- Radyasyon Onkolojisi -> RADYASYON ONKOLOJISI
         (92, '178'),  -- Radyoloji -> RADYOLOJI
         (93, '180'),  -- Romatoloji -> ROMATOLOJI
         (94, '181'),  -- Ruh Sağlığı ve Hastalıkları -> RUH SAĞLIĞI VE HASTALIKLARI
         (95, '183'),  -- Spor Hekimliği -> SPOR HEKIMLIĞI
         (96, '184'),  -- Sualtı Hekimliği ve Hiperbarik Tıp -> SUALTI HEKIMLIĞI VE HIPERBARIK TIP
         (97, '186'),  -- Tıbbi Biyokimya -> TIBBI BIYOKIMYA
         (98, '189'),  -- Tıbbi Genetik -> TIBBI GENETIK
         (99, '191'),  -- Tıbbi Mikrobiyoloji -> TIBBI MIKROBIYOLOJI
         (100, '192'),  -- Tıbbi Onkoloji -> TIBBI ONKOLOJI
         (101, '196'),  -- Üroloji -> ÜROLOJI
         (102, '197029'),  -- Üroloji Yoğun Bakım -> ÜROLOJİ YOĞUN BAKIM
         (103, '197030')  -- Yanık Yoğun Bakım -> YANIK YOĞUN BAKIM
       ) as v(id, kod)
 where d.id = v.id and d.skrs_klinik_kod = '';

-- SKRS klinik karşılığı SEÇİLMEMİŞ departmanlar (52 adet):
--   1    Acil
--   3    Acil Dahili Yoğun Bakım
--   15   Cerrahi Yoğun Bakım
--   25   Çocuk Hematolojisi ve Onkoloji
--   27   Çocuk Kallp ve Damar Cerrahisi
--   32   Çocuk Romotolojisi
--   36   Çocuk Yoğun Bakım
--   37   Dahili Yoğun Bakım
--   38   Deri ve Zührevi Hastalıklar
--   40   Endokrin ve Metabolizma Hastalıkları
--   41   Endokrinoloji Yoğun Bakım Ünitesi
--   43   Enfeksiyon Yoğun Bakım Ünitesi
--   44   Farmakoloji
--   45   Fiziksel tıp ve Rehabiltasyon
--   47   Gastroentereolji
--   48   Gastroentereolji Cerrahisi
--   49   Gastroentroloji  Yoğun Bakım
--   50   Gastroentroloji Cerrahi Yoğun Bakım
--   58   Göğüs Yoğun Bakım
--   65   İş ve Meslek Hastalıları
--   73   Kulak Burun Boğaz
--   85   Patoloji
--   104  Yenidoğan Açık Yatak
--   105  Yenidoğan Cerrahisi Yoğun Bakım
--   106  Yenidoğan Yoğun Bakım Küvöz
--   113  Dahili Bilimler
--   114  Yoğun Bakım
--   115  Diğer Bölümler
--   116  Laboratuvar ve Temel Bilimler
--   117  Görüntüleme / Nükleer
--   118  Cerrahi Bilimler
--   119  İdari Birimler
--   120  Muhasebe ve Finans
--   121  Güvenlik
--   122  Hasta Hakları
--   123  İdari ve Mali İşler Müdürlüğü
--   124  Kalite Yönetimi
--   125  Arşiv
--   126  Depo / Ambar
--   127  Satınalma
--   128  Teknik Servis / Biyomedikal
--   129  Sterilizasyon Ünitesi
--   130  Faturalama ve Provizyon
--   131  Eğitim Birimi
--   132  Temizlik Hizmetleri
--   133  Halkla İlişkiler / Pazarlama
--   134  Mutfak / Yemekhane
--   135  Başhekimlik
--   136  Çağrı Merkezi / Randevu
--   137  Bilgi İşlem
--   138  İnsan Kaynakları
--   139  Hasta Kabul / Danışma

do $$
begin
    raise notice '611 tamam: % departmanda SKRS klinik kodu var, %'' bos',
        (select count(*) from public.departman where skrs_klinik_kod <> ''),
        (select count(*) from public.departman where skrs_klinik_kod = '');
end $$;
