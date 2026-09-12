-- =====================================================================
--  553_rad_lab_alt_kategori.sql
--  RADYOLOJİ ve LABORATUVAR kategorilerine ALT KATEGORİ ağacı.
--
--  Kullanıcı: "radyoloji ve laboratuvar (tahlil) kategorileri için alt
--  kategoriler ekle ve listeye bağla."
--
--  DURUM: 546 hizmet başlıklarını kategoriye çevirdi ama ağaç TEK SEVİYE
--  kaldı: "Laboratuvar" altında 2.929, "Radyoloji" altında 868 kalem tek
--  yığın hâlinde duruyor. Kategori süzgeci bu hâliyle işe yaramıyor -
--  seçince yine binlerce satır geliyor.
--
--  KAYNAK SORUNU: alt bölümü söyleyen bir VERİ YOK.
--    - `hizmet.modalite` boş (10.066'nın hepsi),  `radyoloji` bayrağı 0,
--    - `hizmet.loinc` boş,
--    - SKRS ambarı (`skrs_sut`) yalnız SUT EK listesini (`ust_no`) biliyor:
--      8 = laboratuvar, 7 = tetkik/radyoloji. Alt kırılım vermiyor,
--    - SUT kod blokları alfabetik dolduruluyor (L100… L119 sırayla A'dan
--      Z'ye), yani kod öneki de bölüm bilgisi taşımıyor.
--
--  BU YÜZDEN KURAL ADA BAKAR. Aşağıdaki eşleme SIRAYLA denenir, ilk tutan
--  kazanır; hiçbiri tutmazsa kalem "Diğer" alt dalında kalır - yanlış bir
--  dala atmaktansa görünür biçimde sınıflandırılmamış bırakmak yeğdir.
--  Kategori kullanıcı tarafından elle de değiştirilebilir (hizmet kartında
--  yazılabilir alan); bu göç YALNIZ üst dalda duran kalemleri taşır, elle
--  taşınmışa dokunmaz.
--
--  TEKRAR ÇALIŞTIRILABİLİR: alt kategoriler `kod` ile eşleşir (varsa
--  eklenmez), atama yalnız kategorisi hâlâ ÜST dal olan satırlara uygulanır.
-- =====================================================================

do $$
declare
    v_rad  integer;
    v_lab  integer;
    v_sayi integer;
    v_alt  record;
begin
    -- AD SONUNDA BOSLUK VAR: SKRS dokumunden gelen basliklar kirpilmamis
    --   ("Radyoloji "). Duz esitlik bu yuzden tutmuyor - kod birincil,
    --   kirpilmis ad yedek anahtar.
    select id into v_rad from public.kategori
     where tur = 2 and (kod = 'SUT.7' or btrim(ad) = 'Radyoloji') order by id limit 1;
    select id into v_lab from public.kategori
     where tur = 2 and (kod = 'SUT.8' or btrim(ad) = 'Laboratuvar') order by id limit 1;
    if v_rad is null or v_lab is null then
        raise notice '553: Radyoloji/Laboratuvar kategorisi yok - atlandi.';
        return;
    end if;

    -- ---------------------------------------------------- alt kategoriler ----
    -- kod = üst.kısaltma, ad = ekranda görünen. Sıra `ad`a göre çizilir.
    insert into public.kategori (kod, ad, ust_id, tur, aktif)
    select x.kod, x.ad, x.ust, 2, 1
      from (values
        ('RAD.RONTGEN',  'Röntgen / Skopi',            v_rad),
        ('RAD.USG',      'Ultrasonografi / Doppler',   v_rad),
        ('RAD.BT',       'Bilgisayarlı Tomografi',     v_rad),
        ('RAD.MR',       'Manyetik Rezonans',          v_rad),
        ('RAD.MAMO',     'Mamografi',                  v_rad),
        ('RAD.ANJIO',    'Anjiyografi / Girişimsel',   v_rad),
        ('RAD.NUKLEER',  'Nükleer Tıp',                v_rad),
        ('RAD.KEMIK',    'Kemik Dansitometri',         v_rad),
        ('RAD.FONK',     'Fonksiyon Testleri',         v_rad),
        ('RAD.DIGER',    'Diğer Görüntüleme',          v_rad),
        ('LAB.BIYOKIMYA','Biyokimya',                  v_lab),
        ('LAB.HORMON',   'Hormon / Endokrin',          v_lab),
        ('LAB.HEMATO',   'Hematoloji / Koagülasyon',   v_lab),
        ('LAB.MIKRO',    'Mikrobiyoloji / Kültür',     v_lab),
        ('LAB.SEROLOJI', 'Seroloji / İmmünoloji',      v_lab),
        ('LAB.MOLEKUL',  'Moleküler / Viroloji (PCR)', v_lab),
        ('LAB.AKIM',     'Akım Sitometri',             v_lab),
        ('LAB.PATOLOJI', 'Patoloji / Sitoloji',        v_lab),
        ('LAB.GENETIK',  'Genetik',                    v_lab),
        ('LAB.ILAC',     'İlaç Düzeyi / Toksikoloji',  v_lab),
        ('LAB.ALERJI',   'Alerji',                     v_lab),
        ('LAB.DIGER',    'Diğer Laboratuvar',          v_lab)
      ) as x(kod, ad, ust)
     where not exists (select 1 from public.kategori k where k.kod = x.kod and k.tur = 2);

    -- ------------------------------------------------------------ atama ----
    -- SIRA ÖNEMLİ: ilk tutan kural kazanır. Daha DAR kural önce yazılır -
    --   "PCR" hem viroloji hem genetikte geçiyor, ayrımı sonraki kelime yapar.
    for v_alt in
        select * from (values
            -- ---- RADYOLOJİ ----
            (1, v_rad, 'RAD.NUKLEER',
             '(SİNTİGRAF|SINTIGRAF|PET[- ]?(BT|CT)?|NÜKLEER|RADYONÜKLİD|TC-99|I-131|GALYUM|MIBG)', null),
            (2, v_rad, 'RAD.MR',      '(MANYETİK REZONANS|\mMR\M|MRG|MR ANJ)', null),
            (3, v_rad, 'RAD.BT',      '(TOMOGRAF|\mBT\M|BİLGİSAYARLI TOMO)', null),
            (4, v_rad, 'RAD.MAMO',    '(MAMOGRA)', null),
            (5, v_rad, 'RAD.USG',     '(ULTRASON|USG|DOPPLER|EKOKARDİYOGRAF)', null),
            (6, v_rad, 'RAD.ANJIO',   '(ANJİO|ANJIO|ANGIO|EMBOLİZASYON|STENT|BALON|PERKÜTAN)', null),
            (7, v_rad, 'RAD.KEMIK',   '(KEMİK MİNERAL|DANSİTOMET|DEXA)', null),
            (8, v_rad, 'RAD.RONTGEN', '(GRAFİ|RÖNTGEN|FİLM|RADYOGRAF|SKOPİ|FLOROSKOP)', null),
            -- Solunum/alerji/efor testleri görüntüleme değil ama bu dalda
            --   duruyorlar: kendi alt başlıkları olsun.
            (9, v_rad, 'RAD.FONK',    '(TEST|EFOR|SOLUNUM|SPİROMET|EMG|EEG|ODYO)', null),
            (10, v_rad, 'RAD.DIGER',  '.', null),

            -- ---- LABORATUVAR ----
            (11, v_lab, 'LAB.GENETIK',
             '(DİZİ ANALİZ|MUTASYON|KARYOTİP|FISH|GENİ|GEN ANALİZ|DNA DİZİ|EKZOM|KROMOZOM)', 'G1'),
            (12, v_lab, 'LAB.PATOLOJI',
             '(SİTOLOJ|PATOLOJ|BİYOPSİ|REZEKSİYON|FROZEN|İMMÜNHİSTO|HİSTOKİMYA|MATERYAL)', null),
            (13, v_lab, 'LAB.AKIM',   '(\mCD[0-9]+|AKIM SİTOMETRİ|FLOW)', null),
            (14, v_lab, 'LAB.ALERJI', '(ALERJEN|ALLERJ|IGE ANTİKORU|PRICK|POLENİ)', null),
            (15, v_lab, 'LAB.MOLEKUL',
             '(PCR|VİRUS|VİRÜS|\mHBV\M|\mHCV\M|\mHIV\M|RNA|VİRAL YÜK|NAAT)', null),
            (16, v_lab, 'LAB.MIKRO',
             '(KÜLTÜR|ANTİBİYOGRAM|DİREKT BAKI|PARAZİT|MANTAR|ARB|GRAM BOYA|MİKROSKOB)', null),
            (17, v_lab, 'LAB.SEROLOJI',
             '(ANTİKOR|ANTİJEN|\mIG[GMAE]\M|ELISA|\mIFA\M|VDRL|RPR|ROMATOİD|KOMPLEMAN|IMMUNOBLOT)', null),
            (18, v_lab, 'LAB.ILAC',
             '(SERUM/PLAZMA\)|ALKALOİT|AMFETAMİN|OPİAT|KANNABİ|TOKSİK|İLAÇ DÜZEY|KAN DÜZEYİ)', null),
            (19, v_lab, 'LAB.HEMATO',
             '(HEMOGRAM|PERİFERİK YAYMA|SEDİMANTASYON|PROTROMBİN|\mAPTT\M|FİBRİNOJEN|KAN GRUBU|COOMBS|TROMBOSİT|ERİTROSİT|LÖKOSİT|PIHTILASMA|PIHTILAŞMA|FAKTÖR [VX])', null),
            (20, v_lab, 'LAB.HORMON',
             '(HORMON|\mTSH\M|\mFT[34]\M|\mT[34]\M|\mACTH\M|KORTİZOL|İNSÜLİN|PROLAKTİN|\mFSH\M|\mLH\M|ÖSTRADİOL|TESTOSTERON|PARATHORMON|UYARI TESTİ|BASKILAMA TESTİ|TİROGLOBULİN)', null),
            (21, v_lab, 'LAB.BIYOKIMYA', '.', null)
        ) as t(sira, ust, alt_kod, kural, kod_oneki)
        order by sira
    loop
        update public.hizmet h
           set kategori = (select k.id from public.kategori k
                            where k.kod = v_alt.alt_kod and k.tur = 2 limit 1)
         where h.baslik_mi = 0
           -- YALNIZ UST DALDA DURANLAR: elle baska dala tasinmis kalem
           --   (ya da onceki kural tutmus olan) yerinde kalir.
           and h.kategori = v_alt.ust
           and (h.ad ~* v_alt.kural
                or (v_alt.kod_oneki is not null and h.kod like v_alt.kod_oneki || '%'));
    end loop;

    select count(*) into v_sayi
      from public.hizmet h
      join public.kategori k on k.id = h.kategori
     where k.ust_id in (v_rad, v_lab);
    raise notice '553: % hizmet alt kategoriye baglandi.', v_sayi;
end $$;
