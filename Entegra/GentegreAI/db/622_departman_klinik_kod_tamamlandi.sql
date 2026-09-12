-- =====================================================================
--  622_departman_klinik_kod_tamamlandi.sql
--  KODU BOŞ KALAN BÖLÜMLERİN SKRS KLİNİK KODLARI.
--
--  619 adı SKRS klinik adıyla birebir örtüşen 81 bölümü kodladı, 52 bölüm
--  boş kaldı. Bu göç, boş kalanlardan KARŞILIĞI KESİN OLAN 23'ünü doldurur.
--  Eşleşmeme sebepleri yazım farkıydı - "Gastroentereolji" (iki harf
--  eksik), "Çocuk Kallp" (fazla harf), "Kulak Burun Boğaz" (SKRS'de
--  "...HASTALIKLARI" ekli), "Farmakoloji" (SKRS'de "TIBBİ FARMAKOLOJİ"),
--  "Deri ve Zührevi Hastalıklar" (SKRS'de "...HASTALIKLARI"). Bunlar
--  tahmin değil: her biri tek bir SKRS kliniğine karşılık geliyor.
--
--  BÖLÜM ADLARI DÜZELTİLMEZ. "Gastroentereolji" yazım hatası ama hastanenin
--  kendi adlandırmasıdır; e-Nabız'a giden koddur, ad değil.
--
--  DOLDURULMAYAN 29 BÖLÜM, iki ayrı sebeple:
--
--  1) KLİNİK DEĞİL (25 bölüm): Arşiv, Güvenlik, Bilgi İşlem, Muhasebe,
--     Satınalma, Mutfak, Temizlik, İnsan Kaynakları, Kalite Yönetimi,
--     Hasta Hakları, Hasta Kabul, Çağrı Merkezi, Faturalama, Eğitim
--     Birimi, Depo, Teknik Servis, Sterilizasyon, Başhekimlik, İdari
--     Birimler, İdari ve Mali İşler, Halkla İlişkiler ve üç GRUP BAŞLIĞI
--     (Cerrahi Bilimler, Dahili Bilimler, Laboratuvar ve Temel Bilimler,
--     Diğer Bölümler). SKRS KLİNİKLER listesi klinik listesidir; arşive
--     klinik kodu vermek, arşivden hasta başvurusu açılırsa e-Nabız'a
--     olmayan bir kliniği bildirmek olurdu. Bu bölümlerden başvuru
--     açılmaz; kod boş kalması DOĞRU durumdur.
--
--  2) KODU BAŞKA BÖLÜM KULLANIYOR (4 bölüm): `departman.kod` benzersiz.
--       · Cerrahi Yoğun Bakım       -> GENEL CERRAHİ YOĞUN BAKIM (197007)
--                                      "Genel Cerrahi Yoğun Bakım"da
--       · Yoğun Bakım               -> GENEL YOĞUN BAKIM (197)
--                                      "Genel Yoğun Bakım"da
--       · Görüntüleme / Nükleer     -> RADYOLOJİ (178) "Radyoloji"de,
--                                      NÜKLEER TIP (169) "Nükleer Tıp"ta
--       · Yenidoğan Açık Yatak      -> NEONATOLOJİ (167) "Neonatoloji"de
--     Bunlar ya aynı kliniğin ikinci servisi ya da üst başlık. İkisi de
--     hastanenin kararı: ya bölüm birleştirilir ya biri pasife alınır.
--     Kod uydurmak, iki farklı servisi USS'de tek klinikmiş gibi ya da
--     yanlış klinikte göstermek olurdu.
-- =====================================================================

update public.departman d
   set kod = v.kod
  from (values
         (1,   '101'),     -- Acil                             -> ACİL TIP
         (3,   '197002'),  -- Acil Dahili Yoğun Bakım          -> ACİL DAHİLİYE YOĞUN BAKIM
         (25,  '123'),     -- Çocuk Hematolojisi ve Onkoloji   -> ÇOCUK HEMATOLOJİSİ VE ONKOLOJİSİ
         (27,  '125'),     -- Çocuk Kallp ve Damar Cerrahisi   -> ÇOCUK KALP VE DAMAR CERRAHİSİ
         (32,  '131'),     -- Çocuk Romotolojisi               -> ÇOCUK ROMATOLOJİSİ
         (36,  '135'),     -- Çocuk Yoğun Bakım                -> ÇOCUK YOĞUN BAKIMI
         (37,  '197010'),  -- Dahili Yoğun Bakım               -> DAHİLİYE YOĞUN BAKIM
         (38,  '136'),     -- Deri ve Zührevi Hastalıklar      -> DERİ VE ZÜHREVİ HASTALIKLARI
         (40,  '139'),     -- Endokrin ve Metabolizma Hast.    -> ENDOKRİNOLOJİ VE METABOLİZMA HASTALIKLARI
         (41,  '197011'),  -- Endokrinoloji YB Ünitesi         -> ENDOKRİNOLOJİ YOĞUN BAKIM
         (43,  '197012'),  -- Enfeksiyon YB Ünitesi            -> ENFEKSİYON YOĞUN BAKIM
         (44,  '188'),     -- Farmakoloji                      -> TIBBİ FARMAKOLOJİ
         (45,  '142'),     -- Fiziksel tıp ve Rehabiltasyon    -> FİZİKSEL TIP VE REHABİLİTASYON
         (47,  '144'),     -- Gastroentereolji                 -> GASTROENTEROLOJİ
         (48,  '145'),     -- Gastroentereolji Cerrahisi       -> GASTROENTEROLOJİ CERRAHİSİ
         (49,  '197014'),  -- Gastroentroloji Yoğun Bakım      -> GASTROENTEROLOJİ YOĞUN BAKIM
         (50,  '197013'),  -- Gastroentroloji Cerrahi YB       -> GASTROENTEROLOJİK CERRAHİ YOĞUN BAKIM
         (58,  '197017'),  -- Göğüs Yoğun Bakım                -> GÖĞÜS HASTALIKLARI YOĞUN BAKIM
         (65,  '159'),     -- İş ve Meslek Hastalıları         -> İŞ VE MESLEK HASTALIKLARI
         (73,  '165'),     -- Kulak Burun Boğaz                -> KULAK BURUN BOĞAZ HASTALIKLARI
         (85,  '194'),     -- Patoloji                         -> TIBBİ PATOLOJİ
         (105, '197031'),  -- Yenidoğan Cerrahisi Yoğun Bakım  -> YENİDOĞAN CERRAHİ YOĞUN BAKIM
         (106, '197032')   -- Yenidoğan Yoğun Bakım Küvöz      -> YENİDOĞAN YOĞUN BAKIM
       ) as v(id, kod)
 where d.id = v.id and coalesce(d.kod, '') = '';

-- Yazılan her kod SKRS listesinde GERÇEKTEN var mı? Olmayan kod, üretici
-- tarafından zaten pakete yazılmaz ama sessizce kaybolmasındansa burada
-- görülsün.
do $$
declare v_gecersiz integer;
begin
    select count(*) into v_gecersiz
      from public.departman d
     where coalesce(d.kod, '') <> '' and d.kod ~ '^[0-9]+$'
       and public.fn_skrs_kod('klinik.kod', d.kod::integer) = '';
    if v_gecersiz > 0 then
        raise warning '622: % bolumun kodu SKRS klinik listesinde YOK', v_gecersiz;
    end if;

    raise notice '622 tamam: % bolumde SKRS klinik kodu, % bos (klinik olmayan birimler)',
        (select count(*) from public.departman where coalesce(kod, '') <> ''),
        (select count(*) from public.departman where coalesce(kod, '') = '');
end $$;
