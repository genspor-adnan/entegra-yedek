namespace Gentegre.Api.Servisler;

/// <summary>
/// USS paketlerinin ALAN SORGULARI - paket başına bir SQL.
///
/// Üreticiden ayrı dosyada, çünkü beş paketin sorgusu tek metotta 600 satırı
/// buluyordu: hangi paketin nerede bittiğini görmek, aradığın alanı bulmaktan
/// uzun sürüyordu. Sorgular BURADA durur, seçim ve çalıştırma üreticide
/// (<c>AlanlariCozAsync</c>).
///
/// SORGU SÖZLEŞMESİ - altı kolon, bu sırayla:
///   1 uss_alan     USS alan YOLU ("VERI_SETI/GRUP[n]/ALAN")
///   2 deger        alanın okunabilir değeri (`value` özniteliğine gider)
///   3 kaynak_alan  değerin NEREDEN geldiği (paket kartında görünür)
///   4 skrs_liste   SKRS kod sisteminin adı (yalnız gösterim)
///   5 skrs_kod     USS'ye giden ASIL kod - boşsa eleman hiç yazılmaz
///   6 skrs_sistem  codeSystemGuid
///
/// Parametre tek: <c>@p0</c> = kaynak kayıt kimliği (başvuru / muayene).
/// </summary>
public sealed partial class EnabizPaketUretici
{
    private static string AlanSorgusu(string paketKodu)
        => paketKodu switch
        {
            // 301 HASTA KAYIT SILME - 101'in USS'deki karsiligini siler (602).
            //   Tek alani, 101'in yanitinda donen SYSTakipNo'dur; ayni
            //   basvurunun gonderilmis paketinden okunur. Alan olarak da
            //   yazilir (govde XmlUretAsync'te ondan uretilir): boylece paket
            //   kartinda HANGI KAYDIN silindigi gorunur ve icerik hash'i
            //   dogar - ayni basvuru icin ikinci bir silme paketi acilmaz.
            "HASTA_KABUL_SIL" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = b.id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.belge b where b.id = @p0
                """,

            // 302 HIZMET SILME - 102 ile bildirilen islemleri geri alir (628).
            //
            // Kaynak BASVURUDUR: silinecek islemler, o basvurunun USS'ye
            //   GONDERILMIS 102 paketlerinde ne bildirdiysek onlardir.
            //   Referanslar paketin kendi alanlarindan okunur - belgeden
            //   yeniden uretmek yanlis olurdu: kalem bu arada silinmis
            //   olabilir ve USS'de duran kayit yine de temizlenmeli.
            //
            // SEMA SIRASI (prod:302): once SilinecekHizmetBilgisi, SONRA
            //   HASTA_TAKIP_BILGISI. 101/102'nin tersine - kilavuz boyle
            //   yaziyor, sira baglayici oldugu icin aynen uyulur.
            "HASTA_ISLEM_SIL" => """
                select k.uss_alan, k.deger, k.kaynak,
                       k.skrs_liste, k.skrs_kod, k.skrs_sistem
                  from (
                  select 'SilinecekHizmetBilgisi/SilinecekHizmet[' || x.ix
                             || ']/ISLEM_REFERANS_NUMARASI',
                         x.referans, 'gonderilmis 102 paketi', '', '', '', x.ix
                    from (
                      select distinct on (a.deger) a.deger as referans,
                             dense_rank() over (order by a.deger) as ix
                        from public.enabiz_paket p
                        join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                        join public.enabiz_paket_alan a on a.paket_id = p.id
                       where p.kaynak_tur = 1 and p.kaynak_id = @p0
                         and t.uss_paket_kodu = '102' and p.durum = 3
                         and a.uss_alan like '%ISLEM_REFERANS_NUMARASI'
                         and coalesce(a.deger, '') <> ''
                    ) x
                  union all
                  select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                         coalesce(bb.sys_takip_no, ''),
                         'belge_basvuru.sys_takip_no', '', '', '', 9999
                    from public.belge_basvuru bb where bb.id = @p0
                  order by 7
                ) as k(uss_alan, deger, kaynak, skrs_liste, skrs_kod, skrs_sistem, sira)
                """,

            // 102 HASTA ISLEM - hizmet / ilac / malzeme bildirimi (623).
            //
            // Kilavuz: "Bu paket hasta dosyasina hizmet, ilac, malzeme, vaka
            //   basi veya paket islem eklendiginde gonderilir." Bizdeki
            //   karsiligi BELGE KALEMIDIR.
            //
            // TEKRARLI GRUP: her kalem bir `ISLEM_BILGISI`. Yol parcasindaki
            //   `[n]` indeksi kalemleri birbirinden ayirir; XML'e yazilmaz
            //   (EnabizGonderimi.XmlUretAsync). Indeks satirin SIRASIDIR -
            //   kalem silinip eklendiginde numaralar kaymasin diye
            //   row_number kullanilir, satir kimligi degil.
            //
            // ALAN SIRASI KILAVUZLA BIREBIR: sema `sequence` olabilir, 101'de
            //   oyleydi (E1013/E1016). Karsiligi olmayan alanlar atlanir -
            //   SKRS kodlu bos eleman zaten yazilamiyor (611), kodsuz bos
            //   eleman ise bu pakette gereksiz.
            "HASTA_ISLEM" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce(bb.sys_takip_no, ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.belge_basvuru bb where bb.id = @p0
                union all
                -- Disardaki select 6 kolon dondurur; `sira` yalniz SIRALAMA
                --   icindir (kalemler dogru duzende yazilsin) ve disari
                --   cikmaz - union all kollarinin kolon sayisi esit olmali.
                select k2.uss_alan, k2.deger, k2.kaynak,
                       k2.skrs_liste, k2.skrs_kod, k2.skrs_sistem
                  from (
                  with kalem as (
                    select bs.id, bs.tur, bs.hizmet_id, bs.stok_id,
                           bs.miktar, b.belge_tarihi, bb.bolum_id, bs.ekleyen,
                           row_number() over (order by bs.sira, bs.id) as ix,
                           -- HIZMET TURU (SKRS d03e562d): 1 DIGER (SUT/paket),
                           --   2 ILAC, 3 MALZEME. Ilac, stok kartinin ilac
                           --   kaydi olup olmamasindan anlasilir - ayri bir
                           --   "bu ilactir" bayragi tutmuyoruz.
                           case when bs.tur = 2 then 1
                                when exists (select 1 from public.ilac i
                                              where i.stok_id = bs.stok_id) then 2
                                else 3 end as skrs_tur,
                           -- ISLEM KODU: hizmette SUT kodu (hizmet.kod),
                           --   ilacta barkod, malzemede stok kodu.
                           case when bs.tur = 2
                                then coalesce((select h.kod from public.hizmet h
                                                where h.id = bs.hizmet_id), '')
                                else coalesce(
                                       (select i.barkod from public.ilac i
                                         where i.stok_id = bs.stok_id limit 1),
                                       (select st.kod from public.stok st
                                         where st.id = bs.stok_id), '')
                           end as islem_kodu,
                           case when bs.tur = 2
                                then coalesce((select h.ad from public.hizmet h
                                                where h.id = bs.hizmet_id), '')
                                else coalesce((select st.ad from public.stok st
                                                where st.id = bs.stok_id), '')
                           end as islem_adi,
                           -- Tutarlar DAGILIMDAN: kuruma yansiyan SGK + OSS,
                           --   hastaya yansiyan provizyon + ek katki + SGK
                           --   katilim payi. Kilavuz ikisini de ozel ve
                           --   universite hastanelerinden istiyor.
                           coalesce(dg.sgk, 0) + coalesce(dg.oss, 0) as kurum_tutar,
                           coalesce(dg.hasta_provizyon, 0)
                             + coalesce(dg.hasta_ek_katki, 0)
                             + coalesce(dg.sgk_katilim_payi, 0) as hasta_tutar,
                           -- Alan listesinde okunakli dursun diye burada
                           --   cozulur: klinik kodu sayisal degilse (kurumun
                           --   kendi kodlamasi) NULL kalir ve alan bos gider.
                           nullif((select d.kod from public.departman d
                                    where d.id = bb.bolum_id
                                      and d.kod ~ '^[0-9]+$'), '')::int as klinik_kodu,
                           coalesce((select t.vkno from public.taraf t
                                      where t.id = bs.ekleyen), '') as kaydeden_tckn,
                           coalesce((select t.vkno from public.taraf t
                                      where t.id = bb.personel_id), '') as hekim_tckn
                      from public.belge_satir bs
                      join public.belge b on b.id = bs.belge_id
                      join public.belge_basvuru bb on bb.id = b.id
                      left join public.belge_satir_dagilim dg on dg.belge_satir_id = bs.id
                     where bs.belge_id = @p0
                  )
                  -- SEMADAKI ALANLAR EKSIKSIZ, SIRA KILAVUZLA BIREBIR (623).
                  --   Kilavuz bu alanlarin cogunu "Zorunlu: Hayir" diye
                  --   isaretliyor ama USS govdeyi XSD ile dogruluyor ve
                  --   yazilmayanlari sayip donduruyor: "E1016 ... eksik veya
                  --   dokumanda bulunmamasi gerekiyor GERCEKLESME_ZAMANI,
                  --   RANDEVU_ZAMANI, KULLANICI_KIMLIK_NUMARASI,
                  --   CIHAZ_NUMARASI, GIRISIMSEL_ISLEM_KODU" (canli deneme,
                  --   paket 466). 101'de ayni ders YATIS_BILGISI ile
                  --   alinmisti: "zorunlu degil" ile "olmayabilir" ayni sey
                  --   degil - alan BOS gidebilir, EKSIK gidemez.
                  --
                  -- ALANLAR TEK LISTEDE: her alan icin ayri bir `union all`
                  --   kolu yaziliyordu (15 kol, ~200 satir) ve hepsi ayni
                  --   yol-onekini, ayni `from kalem k`i tekrar ediyordu.
                  --   Yan yana duran alanlarin sirasini gormek zordu - oysa
                  --   USS'nin istedigi tam olarak O SIRA. Alanlar artik
                  --   asagida SIRAYLA okunan tek bir VALUES listesidir;
                  --   son kolon (sira) semadaki yerleridir.
                  select 'HASTA_ISLEM_BILGILERI/ISLEM_BILGISI[' || k.ix
                             || ']/' || a.alan,
                         a.deger, a.kaynak, a.skrs_liste, a.skrs_kod,
                         a.skrs_sistem, k.ix * 100 + a.sira
                    from kalem k
                    cross join lateral (values
                      ('KLINIK_KODU',
                       public.fn_skrs_ad('klinik.kod', k.klinik_kodu),
                       'departman.kod (SKRS klinik)', 'SKRS Klinik',
                       coalesce(public.fn_skrs_kod('klinik.kod', k.klinik_kodu), ''),
                       public.fn_skrs_guid('klinik.kod'), 1),

                      -- Kilavuz: "istek zamani gonderilmemelidir" - islemin
                      --   YAPILDIGI an. Kalemde ayri gerceklesme damgasi yok.
                      ('GERCEKLESME_ZAMANI', '', '(karsiligi yok)', '', '', '', 2),

                      ('ISLEM_TURU',
                       public.fn_skrs_ad('hizmet.skrs_turu', k.skrs_tur),
                       'belge_satir.tur / ilac kaydi', 'SKRS Hizmet Turu',
                       public.fn_skrs_kod('hizmet.skrs_turu', k.skrs_tur),
                       public.fn_skrs_guid('hizmet.skrs_turu'), 3),

                      ('ISLEM_KODU', k.islem_kodu,
                       'hizmet.kod / ilac.barkod / stok.kod', '', '', '', 4),
                      ('ISLEM_ADI', k.islem_adi, 'hizmet.ad / stok.ad', '', '', '', 5),

                      -- Girisimsel Islem Listesi ayri bir kodlama; hizmet
                      --   kartinda karsiligi tutulmuyor.
                      ('GIRISIMSEL_ISLEM_KODU', '', '(karsiligi yok)', '', '', '', 6),

                      ('ISLEM_ZAMANI', to_char(k.belge_tarihi, 'YYYYMMDDHH24MI'),
                       'belge.belge_tarihi', '', '', '', 7),
                      ('ADET', trim(to_char(k.miktar, 'FM9999999990.00')),
                       'belge_satir.miktar', '', '', '', 8),
                      ('HASTA_TUTARI', trim(to_char(k.hasta_tutar, 'FM9999999990.00')),
                       'belge_satir_dagilim (hasta)', '', '', '', 9),
                      ('KURUM_TUTARI', trim(to_char(k.kurum_tutar, 'FM9999999990.00')),
                       'belge_satir_dagilim (kurum)', '', '', '', 10),

                      -- Randevudan acilan basvuruda doldurulabilir; kalemin
                      --   kendi randevusu yok.
                      ('RANDEVU_ZAMANI', '', '(karsiligi yok)', '', '', '', 11),

                      -- Islemi KAYDEDEN kullanicinin TCKN'si; kimlik numarasi
                      --   zorunlu olmadigi icin bos kalabilir.
                      ('KULLANICI_KIMLIK_NUMARASI', k.kaydeden_tckn,
                       'taraf.vkno (kaydeden)', '', '', '', 12),

                      ('CIHAZ_NUMARASI', '', '(karsiligi yok)', '', '', '', 13),
                      ('ISLEM_REFERANS_NUMARASI', k.id::text,
                       'belge_satir.id', '', '', '', 14),

                      -- ISLEM_HEKIM_BILGISI grubu: ACILDIYSA ICI DE TAM OLMALI.
                      --   Grup opsiyonel (GEN_ISLEM_BILGISI gibi hic
                      --   acilmayabilir) ama bir kez acildi mi USS icindeki
                      --   alanlari da ariyor: "E1016 ... eksik
                      --   PUAN_HAKEDIS_ZAMANI" (canli deneme, paket 479).
                      --   Hekimi bildirmek istiyoruz, o yuzden grup acilir ve
                      --   dordu de yazilir. ISLEM_PUANI / PUAN_HAKEDIS_ZAMANI
                      --   hekim performans puanlamasidir; prim modulumuz ayri
                      --   calisiyor, USS'ye bildirilen bir puan uretmiyoruz.
                      ('ISLEM_HEKIM_BILGISI/ASISTAN_HEKIM_KIMLIK_NUMARASI', '',
                       '(karsiligi yok)', '', '', '', 15),
                      ('ISLEM_HEKIM_BILGISI/HEKIM_KIMLIK_NUMARASI', k.hekim_tckn,
                       'taraf.vkno (hekim)', '', '', '', 16),
                      ('ISLEM_HEKIM_BILGISI/ISLEM_PUANI', '',
                       '(karsiligi yok)', '', '', '', 17),
                      ('ISLEM_HEKIM_BILGISI/PUAN_HAKEDIS_ZAMANI', '',
                       '(karsiligi yok)', '', '', '', 18)
                    ) as a(alan, deger, kaynak, skrs_liste, skrs_kod, skrs_sistem, sira)
                  order by 7
                ) as k2(uss_alan, deger, kaynak, skrs_liste, skrs_kod,
                        skrs_sistem, sira)
                """,

            // 101 HASTA KAYIT - USS'nin GERCEK alan adlari ve yollari (605).
            //   Alan adi artik "VERI_SETI/ALAN" yolu tasir; SKRS kodlu alanlar
            //   5. ve 6. kolonda kod + codeSystemGuid dondurur (bos ise duz
            //   deger yazilir). Tarihler USS bicimi: yyyyMMddHHmm.
            //   Sema: dokuman/09_ENABIZ_USS_SEMASI.md
            "HASTA_KABUL" => """
                select 'HASTA_KIMLIK_BILGILERI/HASTA_KIMLIK_NUMARASI',
                       coalesce(h.vkno, ''), 'taraf.vkno', '', '', ''
                  from public.belge b join public.taraf h on h.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/AD',
                       coalesce(nullif(h.ad, ''), h.unvan), 'taraf.ad', '', '', ''
                  from public.belge b join public.taraf h on h.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/SOYAD',
                       coalesce(h.soyad, ''), 'taraf.soyad', '', '', ''
                  from public.belge b join public.taraf h on h.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/DOGUM_TARIHI',
                       coalesce(to_char(th.dogum_tarihi, 'YYYYMMDD') || '0000', ''),
                       'taraf_hasta.dogum_tarihi', '', '', ''
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- KOD LISTESI ARTIK SKRS'NIN KENDISI (609/610): yerel deger
                --   dogrudan SKRS kodudur, ceviri katmani yok. Ad da listeden
                --   okunur - SKRS'nin yazdigi metinle birebir gider.
                union all select 'HASTA_KIMLIK_BILGILERI/CINSIYET',
                       public.fn_skrs_ad('hasta.cinsiyet', th.cinsiyet),
                       'kod_deger[hasta.cinsiyet]', 'SKRS Cinsiyet',
                       public.fn_skrs_kod('hasta.cinsiyet', th.cinsiyet),
                       public.fn_skrs_guid('hasta.cinsiyet')
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- UYRUK: USS ISO harf kodunu (TR) KABUL ETMIYOR, MERNIS
                --   kodunu (9980) istiyor - canli denemede code="TR" "E1008
                --   Code 'TR' ... bulunamadi", code="9980" ile alan gecti.
                --   609 hasta kartindaki uyrugu MERNIS koduna cevirdi, alan
                --   artik dogrudan o kodu tasiyor.
                union all select 'HASTA_KIMLIK_BILGILERI/UYRUK',
                       public.fn_skrs_ad('hasta.uyruk', th.uyruk),
                       'taraf_hasta.uyruk (MERNIS)', 'SKRS Ulke',
                       public.fn_skrs_kod('hasta.uyruk', th.uyruk),
                       public.fn_skrs_guid('hasta.uyruk')
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- HASTA TIPI: USS'nin istedigi liste, SKRS'nin klinik
                --   "HASTA TIPI"si (bebek/gebe/obez...) DEGIL, GP_HASTA_TIPI:
                --   VATANDAS_KAYIT / YABANCI_KAYIT / VATANSIZ / YENIDOGAN /
                --   KIMLIKSIZ. Bu hasta kartindan KESIN turetilir (610), o
                --   yuzden artik bos gitmiyor. Once liste-basi `limit 1` ile
                --   rastgele kod seciliyordu ve erkek hastaya "15-49 KADIN
                --   HASTALAR" yaziyordu (basvuru 1092) - yanlis liste, yanlis
                --   kod. Simdi hem liste dogru hem deger hastanin kendisinden.
                union all select 'HASTA_KIMLIK_BILGILERI/HASTA_TIPI',
                       public.fn_skrs_ad('hasta.tipi', th.hasta_tipi),
                       'taraf_hasta.hasta_tipi', 'SKRS Hasta Kayit Tipi',
                       public.fn_skrs_kod('hasta.tipi', th.hasta_tipi),
                       public.fn_skrs_guid('hasta.tipi')
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- SEMADAKI KIMLIK ALANLARI EKSIKSIZ GIDER (602): USS govdeyi
                --   XSD ile dogruluyor ve yazilmayan elemani sema ihlali
                --   sayiyor - "E1014 ... eksik elemanlar var: UYRUK,
                --   ANNE_KIMLIK_NUMARASI, DOGUM_SIRASI, ..." (paket 194).
                --   Degeri olanlar karttan, olmayanlar BOS gider; bos gitmek
                --   gecerli, hic gitmemek degil.
                union all select 'HASTA_KIMLIK_BILGILERI/ANNE_KIMLIK_NUMARASI',
                       coalesce(th.anne_tckn, ''), 'taraf_hasta.anne_tckn', '', '', ''
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/BABA_KIMLIK_NUMARASI',
                       coalesce(th.baba_tckn, ''), 'taraf_hasta.baba_tckn', '', '', ''
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/PASAPORT_NO',
                       coalesce(th.pasaport_no, ''), 'taraf_hasta.pasaport_no', '', '', ''
                  from public.belge b
                  left join public.taraf_hasta th on th.id = b.taraf_id
                 where b.id = @p0
                -- Karsiligi olmayan sema alanlari: BOS ama VAR.
                --   DOGUM_SIRASI cogul dogumda sira (bizde tutulmuyor),
                --   BEYAN_DOGUM_TARIHI kimliksiz hastanin beyani,
                --   KIMLIKSIZ_HASTA_BILGISI ve YABANCI_* yabanci/kimliksiz
                --   vakalar icin - hicbirinin yerel karsiligi yok.
                union all select 'HASTA_KIMLIK_BILGILERI/DOGUM_SIRASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/YABANCI_HASTA_KIMLIK_NUMARASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/KIMLIKSIZ_HASTA_BILGISI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/BEYAN_DOGUM_TARIHI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                -- ADRES_BILGISI ZORUNLU GRUP (602): kilavuzda "Evet", eksik
                --   olunca USS "E1013 Xml dokumaninda eksik elemanlar var:
                --   ADRES_BILGISI" donuyor (gercek vaka, paket 183).
                --   Adres VARSAYILAN olani, yoksa ilk aktif kayit; hasta
                --   kartinda adres hic yoksa alanlar bos gider ve grup yine
                --   de yazilir - USS grubun VARLIGINI ariyor.
                -- ADRES GRUBUNUN ILK IKI ALANI (602): USS "E1016 ... eksik
                --   veya dokumanda bulunmamasi gerekiyor ADRES_KODU" dondu
                --   (paket 205). Kilavuzdaki sira: ADRES_KODU_SEVIYESI,
                --   ADRES_KODU, ACIK_ADRES, ACIK_ADRES_ILCE - XSD sequence
                --   olabilecegi icin AYNI SIRAYLA uretilir. Ikisinin de yerel
                --   karsiligi yok (SKRS adres kodlama sistemi), bos gider.
                union all select 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ADRES_KODU_SEVIYESI',
                       '', '(karsiligi yok)', 'SKRS Adres Kodu Seviyesi',
                       '', 'aa0e83ba-e9db-4817-80da-577fd6a17373'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ADRES_KODU',
                       '', '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES',
                       coalesce((select a.adres from public.taraf_adres a
                                  where a.taraf_id = b.taraf_id and a.aktif = 1
                                  order by a.varsayilan desc, a.id limit 1), ''),
                       'taraf_adres.adres', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES_ILCE',
                       coalesce((select a.ilce from public.taraf_adres a
                                  where a.taraf_id = b.taraf_id and a.aktif = 1
                                  order by a.varsayilan desc, a.id limit 1), ''),
                       'taraf_adres.ilce', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_KIMLIK_BILGILERI/TELEFON_NUMARASI',
                       coalesce(h.telefon, ''), 'taraf.telefon', '', '', ''
                  from public.belge b join public.taraf h on h.id = b.taraf_id
                 where b.id = @p0
                -- ====================== HASTA_BASVURU_BILGILERI ======================
                -- SIRA KILAVUZLA BIREBIR (602): USS govdeyi XSD ile dogruluyor,
                --   sema `sequence` ise eleman SIRASI da baglayicidir. Alanlar
                --   kilavuzun 101 ornegindeki sirayla uretilir; karsiligi
                --   olmayanlar BOS ama VAR - eksik eleman sema ihlali sayiliyor
                --   ("E1013 ... eksik elemanlar var: YATIS_BILGISI", paket 216).
                union all select 'HASTA_BASVURU_BILGILERI/SPK_KODU', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/HTS_KODU', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/AMBULANS_AKILLI_BILEKLIK_NUMARASI',
                       coalesce(bb.ambulans_bileklik_no, ''),
                       'belge_basvuru.ambulans_bileklik_no', '', '', ''
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/AMBULANS_HASTA_NO',
                       coalesce(bb.ambulans_hasta_no, ''),
                       'belge_basvuru.ambulans_hasta_no', '', '', ''
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/AMBULANS_TAKIP_NUMARASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/PAKETE_AIT_ISLEM_ZAMANI',
                       to_char(now(), 'YYYYMMDDHH24MI'), '(uretim zamani)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/DIS_ISTEM_NUMARASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/HIZMET_SUNUCU',
                       coalesce((select e.ad from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'entegrasyon_hesap.kurum_kodu (tesis)', 'SKRS Kurum',
                       coalesce((select e.kurum_kodu from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'c3eade04-4f91-5dab-e043-14031b0ac9f9'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/KAYIT_YERI',
                       coalesce((select e.ad from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'entegrasyon_hesap.kurum_kodu (tesis)', 'SKRS Kurum',
                       coalesce((select e.kurum_kodu from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'c3eade04-4f91-5dab-e043-14031b0ac9f9'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/PROTOKOL_NUMARASI',
                       coalesce(b.belge_no, ''), 'belge.belge_no', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/HASTANE_REFERANS_NUMARASI',
                       b.id::text, 'belge.id', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/SGK_TAKIP_NUMARASI',
                       coalesce((select bp.sgk_takip_no from public.belge_provizyon bp
                                  where bp.id = b.id), ''),
                       'belge_provizyon.sgk_takip_no', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/KABUL_ZAMANI',
                       to_char(b.belge_tarihi, 'YYYYMMDDHH24MI'),
                       'belge.belge_tarihi', '', '', ''
                  from public.belge b where b.id = @p0
                -- KLINIK: `departman.kod`un KENDISI SKRS klinik kodudur (619) -
                --   ayri kolon yok, bir kod iki yerde durmaz.
                --
                --   619 oncesi buradaki degerler SKRS'nin KLINIKLER degil
                --   PERSONEL BRANS listesinden geliyordu ve her paket yanlis
                --   klinigi bildiriyordu ("Acil" bolumunun kodu 102,
                --   KLINIKLER'de 102 = ADLI TIP). Goc kodlari duzeltti,
                --   karsiligi bulunamayanlari BOSALTTI.
                --
                --   Kod yine de LISTEDE ARANIR: elle girilmis, SKRS'de
                --   bulunmayan bir kod pakete YAZILMAZ. Boylece bos birakilan
                --   52 bolumden biri sonradan gelisiguzel doldurulursa
                --   sessizce yanlis klinik gitmez.
                union all select 'HASTA_BASVURU_BILGILERI/KLINIK_KODU',
                       public.fn_skrs_ad('klinik.kod',
                           nullif((select d.kod from public.departman d
                                    where d.id = bb.bolum_id
                                      and d.kod ~ '^[0-9]+$'), '')::int),
                       'departman.kod (SKRS klinik)', 'SKRS Klinik',
                       coalesce(
                         public.fn_skrs_kod('klinik.kod',
                           nullif((select d.kod from public.departman d
                                    where d.id = bb.bolum_id
                                      and d.kod ~ '^[0-9]+$'), '')::int),
                         (select k.skrs_kod from public.enabiz_kod_esleme k
                           where k.esleme_turu = 'KLINIK' and k.yerel_id = bb.bolum_id
                             and k.aktif = 1 limit 1),
                         ''),
                       public.fn_skrs_guid('klinik.kod')
                  from public.belge_basvuru bb where bb.id = @p0
                -- SOSYAL GUVENCE: basvurunun KENDI alt kurumundan (SSK,
                --   Bag-Kur, Emekli Sandigi, ozel sigorta...). Kurum kimligi
                --   uzerinden esleme aranmasi yanlisti: ayni kurumun farkli
                --   police turleri farkli guvence demek.
                union all select 'HASTA_BASVURU_BILGILERI/SOSYAL_GUVENCE_DURUMU',
                       public.fn_skrs_hedef_ad('kurum.alt_kurum', bb.alt_kurum),
                       'belge_basvuru.alt_kurum', 'SKRS Sosyal Guvence',
                       public.fn_skrs_kod('kurum.alt_kurum', bb.alt_kurum),
                       public.fn_skrs_guid('kurum.alt_kurum')
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/HEKIM_KIMLIK_NUMARASI',
                       coalesce((select t.vkno from public.taraf t
                                  where t.id = bb.personel_id), ''),
                       'taraf.vkno (hekim)', '', '', ''
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/VAKA_TURU',
                       public.fn_skrs_hedef_ad('basvuru.gelis_nedeni', bb.gelis_nedeni),
                       'belge_basvuru.gelis_nedeni', 'SKRS Vaka Turu',
                       public.fn_skrs_kod('basvuru.gelis_nedeni', bb.gelis_nedeni),
                       public.fn_skrs_guid('basvuru.gelis_nedeni')
                  from public.belge_basvuru bb where bb.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/MHRS_RANDEVU_NUMARASI', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = b.id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/TRIAJ', '',
                       '(karsiligi yok)', 'SKRS Triaj',
                       '', '1ddcbef5-4006-41fe-87c0-6190c9801708'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/BASVURU_HIZMET_ALIMI_BILGISI', '',
                       '(karsiligi yok)', 'SKRS Hizmet Alimi',
                       '', 'c9d56fee-d143-4602-ad7b-ba131ef92ad9'
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/E_SEVK_KODU', '',
                       '(karsiligi yok)', '', '', ''
                  from public.belge b where b.id = @p0
                -- YATIS_BILGISI: AYAKTA basvuruda da GRUP OLARAK bulunmali,
                --   icindekiler bos. Yatis modulu gelince buradan doldurulur.
                union all select 'HASTA_BASVURU_BILGILERI/YATIS_BILGISI/YATIS_KABUL_ZAMANI', '',
                       '(yatis yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/YATIS_BILGISI/YATAK_NO', '',
                       '(yatis yok)', '', '', ''
                  from public.belge b where b.id = @p0
                union all select 'HASTA_BASVURU_BILGILERI/YATIS_BILGISI/YATIS_GUNUBIRLIK_MI', '',
                       '(yatis yok)', '', '', ''
                  from public.belge b where b.id = @p0
                -- YATISIN ACILIYETI: grubun icindeki TEK ZORUNLU alan.
                --   Ayakta basvuruda da kod istiyor - grubu bos birakinca
                --   "E1016 ... eksik veya dokumanda bulunmamasi gerekiyor
                --   YATISIN_ACILIYETI", grubu hic yazmayinca "E1013 ...
                --   eksik elemanlar var: YATIS_BILGISI". SKRS listesinde
                --   bunun kendi kodu var: 3 = ACILIYET DURUMU ATANMAMIS -
                --   yatis olmayan basvurunun DOGRU karsiligi, uydurma degil.
                --   Yatis modulu gelince gercek aciliyet buradan yazilacak.
                union all select 'HASTA_BASVURU_BILGILERI/YATIS_BILGISI/YATISIN_ACILIYETI',
                       public.fn_skrs_ad('yatis.aciliyet', 3),
                       'yatis yok -> ACILIYET DURUMU ATANMAMIS',
                       'SKRS Yatis Aciliyeti',
                       public.fn_skrs_kod('yatis.aciliyet', 3),
                       public.fn_skrs_guid('yatis.aciliyet')
                  from public.belge b where b.id = @p0
                """,

            // 103 MUAYENE BILGISI - USS adlari (605).
            //   Her paket (101 haric) once HASTA_TAKIP_BILGISI/SYSTakipNo
            //   tasir: 101'in yanitinda donen numara, basvurunun USS'deki
            //   kimligidir. O olmadan muayene hangi basvuruya baglanacagini
            //   bilemez - bu yuzden ZORUNLU ilk alan.
            // 103 MUAYENE - kilavuz semasi (prod:103, 625).
            //
            // Uc veri seti var: MUAYENE_BILGILERI, HASTA_RECETE_BILGILERI ve
            //   HASTA_RAPOR_BILGILERI. Ucu de OPSIYONEL; yalniz SYSTakipNo
            //   zorunlu. Recete ve rapor setleri YAZILMAZ - iceriklerini
            //   uretmiyoruz ve 101/102'de ogrenildigi gibi ACILAN GRUBUN ICI
            //   TAM OLMALI: bos bir recete seti gondermek, olmayan bir receteyi
            //   bildirmek olurdu.
            //
            // TANI_BILGISI TEKRARLI: her tani bir grup, `[n]` indeksiyle
            //   ayrilir (indeks govdeye yazilmaz). Grup kilavuzda ZORUNLU -
            //   tanisi olmayan muayene paketi zaten uretilmemeli.
            "MUAYENE" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = m.belge_id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.muayene m where m.id = @p0
                -- Sema sirasi: CHECK_UP, SIGARA, PAKET ZAMANI, BASLANGIC, BITIS.
                --   Ilk ikisi SKRS kodlu ve karsiligimiz yok - KODSUZ YAZILMAZ
                --   (611), o yuzden hic uretilmiyorlar.
                union all select 'MUAYENE_BILGILERI/PAKETE_AIT_ISLEM_ZAMANI',
                       to_char(now(), 'YYYYMMDDHH24MI'), '(uretim zamani)', '', '', ''
                  from public.muayene m where m.id = @p0
                union all select 'MUAYENE_BILGILERI/MUAYENE_BASLANGIC_TARIHI',
                       coalesce(to_char(m.baslangic, 'YYYYMMDDHH24MI'), ''),
                       'muayene.baslangic', '', '', ''
                  from public.muayene m where m.id = @p0
                union all select 'MUAYENE_BILGILERI/MUAYENE_BITIS_TARIHI',
                       coalesce(to_char(coalesce(m.bitis, m.tamamlanma),
                                        'YYYYMMDDHH24MI'), ''),
                       'muayene.bitis', '', '', ''
                  from public.muayene m where m.id = @p0
                -- EPIKRIZ: baslik + aciklama. Grup acildigi icin IKISI DE
                --   yazilir; aciklama hekimin sikayet/oykü metnidir.
                union all select 'MUAYENE_BILGILERI/EPIKRIZ_BILGISI/EPIKRIZ_BILGISI_BASLIK',
                       'Muayene', '(sabit baslik)', '', '', ''
                  from public.muayene m where m.id = @p0
                union all select 'MUAYENE_BILGILERI/EPIKRIZ_BILGISI/EPIKRIZ_BILGISI_ACIKLAMA',
                       left(coalesce(m.sikayet, ''), 400), 'muayene.sikayet', '', '', ''
                  from public.muayene m where m.id = @p0
                union all
                select k2.uss_alan, k2.deger, k2.kaynak,
                       k2.skrs_liste, k2.skrs_kod, k2.skrs_sistem
                  from (
                  with tanilar as (
                    select t.icd_kod, t.tur,
                           row_number() over (order by t.sira, t.id) as ix
                      from public.tani t
                     where t.muayene_id = @p0 and coalesce(t.icd_kod, '') <> ''
                  )
                  select 'MUAYENE_BILGILERI/TANI_BILGISI[' || t.ix || ']/' || a.alan,
                         a.deger, a.kaynak, a.skrs_liste, a.skrs_kod, a.skrs_sistem,
                         t.ix * 10 + a.sira
                    from tanilar t
                    cross join lateral (values
                      ('TANI_TURU',
                       public.fn_skrs_ad('tani.turu', t.tur),
                       'tani.tur', 'SKRS Tani Turu',
                       public.fn_skrs_kod('tani.turu', t.tur),
                       public.fn_skrs_guid('tani.turu'), 1),
                      -- ICD10 kendi kod sisteminde: kodun KENDISI hem deger
                      --   hem koddur, ayri bir esleme tablosu yok.
                      ('ICD10', t.icd_kod, 'tani.icd_kod', 'ICD-10',
                       t.icd_kod, 'c3eaabad-8c4c-56ee-e043-14031b0a5530', 2)
                    ) as a(alan, deger, kaynak, skrs_liste, skrs_kod, skrs_sistem, sira)
                  order by 7
                ) as k2(uss_alan, deger, kaynak, skrs_liste, skrs_kod, skrs_sistem, sira)
                """,

            // 106 HASTA CIKIS - USS adlari (605).
            // 106 HASTA CIKIS - USS adlari (605/627).
            //
            // KAYNAK MUAYENEDIR, BELGE DEGIL: paket muayene tamamlanirken
            //   uretilir ve `@p0` muayenenin kimligidir. Sorgu dogrudan
            //   `belge.id = @p0` ariyordu; muayene kimligiyle belge
            //   bulunamayinca alan listesi BOS donuyor ve paket hic
            //   uretilmiyordu - hata da vermiyordu, cunku bos alan listesi
            //   "uretilecek bir sey yok" demek. 103 gonderilirken 106'nin
            //   kuyrukta hic gorunmemesinin sebebi buydu.
            "HASTA_CIKIS" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = m.belge_id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.muayene m where m.id = @p0
                -- CIKIS ZAMANI = MUAYENENIN TAMAMLANMASI: hastanin cikisi
                --   muayenenin bittigi andir. Belgenin degistirme damgasi
                --   degil - o, baska bir kaydetmeyle de ilerler.
                union all select 'HASTA_CIKIS_BILGILERI/CIKIS_ZAMANI',
                       coalesce(to_char(coalesce(m.tamamlanma, m.bitis),
                                        'YYYYMMDDHH24MI'), ''),
                       'muayene.tamamlanma', '', '', ''
                  from public.muayene m where m.id = @p0
                -- CIKIS SEKLI MUAYENENIN ALANI (627): USS'de ZORUNLU, bos
                --   birakilinca "E1014 ... eksik elemanlar var: CIKIS_SEKLI"
                --   ile paket reddediliyor (canli deneme, paket 652). Kodlu
                --   alan oldugu icin kodsuz da yazilamaz - deger uretmek
                --   zorunlu. Varsayilani 7 (iyilesderek cikis), sevk/olum
                --   gibi haller hekimin secimi.
                union all select 'HASTA_CIKIS_BILGILERI/CIKIS_SEKLI',
                       public.fn_skrs_ad('cikis.sekli', m.cikis_sekli),
                       'muayene.cikis_sekli', 'SKRS Cikis Sekli',
                       public.fn_skrs_kod('cikis.sekli', m.cikis_sekli),
                       public.fn_skrs_guid('cikis.sekli')
                  from public.muayene m where m.id = @p0
                """,

            _ => "",
        };
}
