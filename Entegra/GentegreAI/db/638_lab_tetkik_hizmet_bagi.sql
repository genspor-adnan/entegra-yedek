-- =====================================================================
--  638_lab_tetkik_hizmet_bagi.sql
--  TETKİK KATALOĞU HİZMETLERE BAĞLANIR + HEMOGRAM PANELİ.
--
--  Başvuru kaydedilince ücretlendirilmiş tetkikler için istem açılıyor
--  (637). Bağ tek yerden kuruluyor: `lab_tetkik.hizmet_id` - tetkik
--  kartındaki "Hizmet (fiyat/fatura)" alanı. Bu veritabanında 23 tetkiğin
--  HİÇBİRİNDE dolu değildi, dolayısıyla hiçbir başvuru istem açmıyordu:
--  hastadan hemogram parası alınıyor, laboratuvara tüp düşmüyordu.
--
--  PANEL DÜZENİ (kullanici: "panel duzeni ... dogrusunu tam yap"):
--  Hemogram SUT'ta TEK kalemdir (L107020); lökosit, hemoglobin ve
--  trombosit AYRI FATURALANMAZ - onların SUT kodu yoktur. Ama laboratuvar
--  üçünü ayrı sonuç olarak verir. Model bunu zaten biliyor:
--    * faturalanan  -> `lab_panel.hizmet_id` (paket hizmeti)
--    * çalışılanlar -> `hizmet_paket` içeriği, her biri bir tetkiğe bağlı
--  `fn_hizmet_paket_ac` yaprakları döndürüyor, istem üç satır açılıyor ve
--  aynı tüpe (EDTA) bağlanıyor - hastadan tek tüp alınıyor.
--
--  İÇERİK HİZMETLERİ SUT KODU TAŞIMAZ: `LAB-WBC` gibi kurum içi kodlar.
--  Onlara SUT kodu uydurmak, olmayan bir kalemi faturalanabilir göstermek
--  olurdu. Paket bayrağı (`hizmet.paket`) faturanın yalnız L107020'den
--  kesilmesini söyler.
--
--  YALNIZ BOŞ OLAN DOLDURULUR (`coalesce(hizmet_id, 0) = 0`): kurumun elle
--  kurduğu bir bağ varsa üzerine yazılmaz.
--
--  EŞLEŞMELER SUT KATALOĞUNDAN, uydurma yok. Kardiyomiyopati panelinin
--  SUT'ta kendi kodu YOK - jenerik "YENİ NESİL DNA DİZİLEME PANELİ, 41 GEN
--  VE ÜZERİ" (G100430) ile faturalanır, pratikte de öyle yapılıyor.
-- =====================================================================

-- ------------------------------------------- hemogram içerik hizmetleri
insert into public.hizmet (kod, ad, baslik_mi, ust_id, grubu, tur, kdv,
                           birim, durum, kategori, paket, sube_id)
select v.kod, v.ad, 0, h.ust_id, 0, 0, h.kdv, h.birim, 1, h.kategori, 0, h.sube_id
  from (values ('LAB-WBC', 'Lökosit (hemogram içeriği)'),
               ('LAB-HGB', 'Hemoglobin (hemogram içeriği)'),
               ('LAB-PLT', 'Trombosit (hemogram içeriği)')) v(kod, ad)
  join public.hizmet h on h.kod = 'L107020'
 where not exists (select 1 from public.hizmet x where x.kod = v.kod);

-- Paket bayrağı: fatura YALNIZ hemogramdan kesilir, içerik kalemlerinden
--   ayrıca ücret alınmaz.
update public.hizmet set paket = 1 where kod = 'L107020' and paket <> 1;

insert into public.hizmet_paket (paket_hizmet_id, icerik_hizmet_id, sira, adet, sube_id)
select p.id, i.id, v.sira, 1, p.sube_id
  from (values ('LAB-WBC', 10::smallint), ('LAB-HGB', 20), ('LAB-PLT', 30)) v(kod, sira)
  join public.hizmet i on i.kod = v.kod
  join public.hizmet p on p.kod = 'L107020'
 where not exists (select 1 from public.hizmet_paket hp
                    where hp.paket_hizmet_id = p.id and hp.icerik_hizmet_id = i.id);

-- --------------------------------------------------------------- panel
--  Bölüm 2 = hematoloji (tetkiklerin kendi bölümüyle aynı).
insert into public.lab_panel (kod, ad, bolum, hizmet_id, durum, sube_id)
select 'HEMOGRAM', 'Tam Kan Sayımı (Hemogram)', 2, h.id, 0, h.sube_id
  from public.hizmet h
 where h.kod = 'L107020'
   and not exists (select 1 from public.lab_panel p where p.kod = 'HEMOGRAM');

-- ------------------------------------------------- tetkik -> hizmet bağı
update public.lab_tetkik t
   set hizmet_id = h.id, degistirme_tarihi = now()
  from (values
        -- BİYOKİMYA / HEMATOLOJİ (SUT laboratuvar kodları)
        ('CRP',  'L101850'),   -- C REAKTİF PROTEİN (CRP)
        ('NA',   'L106910'),   -- SODYUM (SERUM/PLAZMA)
        ('K',    'L106150'),   -- POTASYUM (SERUM/PLAZMA)
        ('KRE',  'L104780'),   -- KREATİNİN (SERUM/PLAZMA)
        ('CA',   'L103860'),   -- KALSİYUM (SERUM/PLAZMA)
        ('URE',  'L107420'),   -- ÜRE (SERUM/PLAZMA)
        ('ALT',  'L100300'),   -- ALANİN AMİNOTRANSFERAZ (ALT)
        ('AST',  'L101280'),   -- ASPARTAT AMİNOTRANSFERAZ (AST)
        ('GLU',  'L102890'),   -- GLUKOZ (SERUM/PLAZMA)
        ('TSH',  'L107380'),   -- TSH
        -- INR ayrı kalem değil: protrombin zamanının raporlanan biçimi.
        ('INR',  'L106430'),   -- PROTROMBİN ZAMANI (KOAGÜLOMETRE)
        -- HEMOGRAM İÇERİĞİ: kurum içi kodlar, SUT'ta ayrı kalem yok.
        ('WBC',  'LAB-WBC'),
        ('HGB',  'LAB-HGB'),
        ('PLT',  'LAB-PLT'),
        -- MİKROBİYOLOJİ
        ('KBAL', '905675'),    -- BALGAM KÜLTÜRÜ
        ('KIDR', '905671'),    -- İDRAR KÜLTÜRÜ
        ('KKAN', '906010'),    -- KAN KÜLTÜRÜ (AEROB-ANAEROB)
        ('KGAI', '905672'),    -- GAİTA KÜLTÜRÜ
        ('KBOG', '905670'),    -- BOĞAZ KÜLTÜRÜ
        ('KYAR', '905674'),    -- YARA KÜLTÜRÜ
        -- GENETİK
        ('GEN-BRCA',    'G100580'),  -- AİLESEL MEME/OVER KANSERİ (BRCA1/2)
        ('GEN-TROMBO',  'G101720'),  -- TROMBOFİLİ PANELİ
        ('GEN-KARDIYO', 'G100430')   -- YNS DİZİLEME PANELİ, 41 GEN VE ÜZERİ
       ) v(tetkik_kod, hizmet_kod)
  join public.hizmet h on h.kod = v.hizmet_kod
 where t.kod = v.tetkik_kod
   and coalesce(t.hizmet_id, 0) = 0;

do $kontrol$
declare
    v_bagli integer;
    v_toplam integer;
    v_icerik integer;
begin
    select count(*) filter (where hizmet_id is not null), count(*)
      into v_bagli, v_toplam from public.lab_tetkik;
    select count(*) into v_icerik
      from public.hizmet_paket hp
      join public.hizmet p on p.id = hp.paket_hizmet_id and p.kod = 'L107020';
    raise notice '638 tamam: %/% tetkik hizmete bagli, hemogram paneli % icerik',
        v_bagli, v_toplam, v_icerik;
end $kontrol$;
