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
            // 105 LABORATUVAR SONUC - ILK SURUM, SEMA HENUZ BILINMIYOR (632).
            //
            // Rehber paket ADINI veriyor, eleman adlarini vermiyor. 102, 103
            //   ve 106'nin zorunlu alanlari da kilavuzdan degil USS'nin hata
            //   mesajlarindan cikmisti: paket gonderilir, servis eksik
            //   elemanlari ADIYLA sayar, sema o yanittan yazilir.
            //
            // Bu yuzden simdilik yalniz SYSTakipNo var. SONUC GRUBU ACILMIYOR:
            //   "acilan grubun ici tam olmali" kurali geregi, adlarini
            //   bilmeden yarim bir grup gondermek olmayan bir tetkiki
            //   bildirmek olurdu. Tetkikler `lab_istem_satir`'da hazir
            //   bekliyor (kod, ad, sonuc, birim, referans, isaret,
            //   sonuc_tarihi) - eleman adlari ogrenilince tekrarli grup
            //   olarak buraya eklenecek.
            //
            // KAYNAK `lab_istem.id`; takip numarasi istemin BELGESINDEN gelir.
            "LAB_SONUC" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce(bb.sys_takip_no, ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.lab_istem i
                  join public.belge_basvuru bb on bb.id = i.belge_id
                 where i.id = @p0
                """,

            // ADSM AGIZ VE DIS SAGLIGI (876, KTS denetim maddesi D18) - ILK
            //   SURUM, SEMA HENUZ BILINMIYOR. 105'teki durumun aynisi:
            //   rehber paketin ADINI veriyor, USS numarasini ve eleman
            //   adlarini vermiyor. Bu yuzden simdilik yalniz SYSTakipNo var
            //   ve paket turu KAPALI kurulu (876, `aktif = 0`) - eksik
            //   adlarla yarim grup gondermek, olmayan bir islemi bildirmek
            //   olurdu.
            //
            //   ICERIK HAZIR BEKLIYOR: `v_dis_agiz_dis_paket` basvuru basina
            //   yapilan dis islemlerini, mevcut odontogram durumunu ve DMFT'yi
            //   topluyor. Eleman adlari ogrenilince yazilacak tek sey, o
            //   gorunumun kolonlarini yollara baglamak.
            //
            //   KAYNAK basvuru belgesidir (`belge.id`) - dis seansi bir
            //   basvuruya baglidir, USS de hastayi basvuru uzerinden tanir.
            "ADSM_AGIZ_DIS" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce(v.sys_takip_no, ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.v_dis_agiz_dis_paket v
                 where v.belge_id = @p0
                """,

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

            // 408 AY SONU VERI SETI (885). 407 tesis toplamini gonderiyor,
            //   408 ayni olcutleri KLINIK (brans) kirilimiyla istiyor.
            //
            //   IKI SEVIYELI TEKRAR: once klinik grubu
            //   (KLINIK_KODU_KALITE_BILGISI[k]), onun altinda olcut grubu
            //   (KLINIK_KALITE_BILGISI[o]). Indeksler AYNI SATIRDAN turer -
            //   klinik indeksini ayri saymak, ikinci klinigin olcutlerini
            //   birincinin altina yazardi.
            //
            //   KAYIT YERI ve olcut kod sistemi 407 ile ayni; klinik kodu
            //   kendi SKRS listesinden (c04bee57-…).
            "AY_SONU" => """
                select 'AY_SONU_VERI_SETI/KAYIT_YERI',
                       coalesce((select e.kurum_kodu from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'entegrasyon_hesap.kurum_kodu', 'SKRS Kurum',
                       coalesce((select e.kurum_kodu from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'c3eade04-4f91-5dab-e043-14031b0ac9f9'
                  from public.enabiz_ay_sonu a where a.id = @p0
                union all select 'AY_SONU_VERI_SETI/KALITE_YIL', a.yil::text,
                       'enabiz_ay_sonu.yil', '', '', ''
                  from public.enabiz_ay_sonu a where a.id = @p0
                union all select 'AY_SONU_VERI_SETI/KALITE_AY', a.ay::text,
                       'enabiz_ay_sonu.ay', '', '', ''
                  from public.enabiz_ay_sonu a where a.id = @p0
                union all
                select k2.uss_alan, k2.deger, k2.kaynak, k2.skrs_liste, k2.skrs_kod, k2.skrs_sistem
                  from (
                  with klinikler as (
                    select distinct s.klinik_kodu,
                           dense_rank() over (order by s.klinik_kodu) as kx
                      from public.enabiz_ay_sonu_satir s where s.ay_sonu_id = @p0
                  ),
                  satirlar as (
                    select s.klinik_kodu, s.skrs_kod, s.sayi, k.kx,
                           row_number() over (partition by s.klinik_kodu order by s.skrs_kod) as ox
                      from public.enabiz_ay_sonu_satir s
                      join klinikler k on k.klinik_kodu = s.klinik_kodu
                     where s.ay_sonu_id = @p0
                  )
                  -- KLINIK KODU her klinik grubunda BIR KEZ.
                  select 'AY_SONU_VERI_SETI/KLINIK_KODU_KALITE_BILGISI[' || k.kx
                         || ']/KLINIK_KODU',
                         k.klinik_kodu, 'departman.kod', 'SKRS Klinik',
                         k.klinik_kodu, 'c04bee57-c5d4-443d-e040-7b0a6f146a3d',
                         k.kx * 1000
                    from klinikler k
                  union all
                  select 'AY_SONU_VERI_SETI/KLINIK_KODU_KALITE_BILGISI[' || s.kx
                         || ']/KLINIK_KALITE_BILGISI[' || s.ox || ']/' || a.alan,
                         a.deger, a.kaynak, a.skrs_liste, a.skrs_kod, a.skrs_sistem,
                         s.kx * 1000 + s.ox * 10 + a.sira
                    from satirlar s
                    cross join lateral (values
                      ('KLINIK_KALITE_TANIM',
                       public.fn_skrs_ad('enabiz.gun_sonu_olcut', s.skrs_kod::integer),
                       'enabiz_ay_sonu_satir.skrs_kod', 'SKRS Gun Sonu Ozet',
                       public.fn_skrs_kod('enabiz.gun_sonu_olcut', s.skrs_kod::integer),
                       public.fn_skrs_guid('enabiz.gun_sonu_olcut'), 1),
                      ('KLINIK_KALITE_SAYI', s.sayi::text,
                       'enabiz_ay_sonu_satir.sayi', '', '', '', 2)
                    ) as a(alan, deger, kaynak, skrs_liste, skrs_kod, skrs_sistem, sira)
                  order by 7
                ) as k2(uss_alan, deger, kaynak, skrs_liste, skrs_kod, skrs_sistem, sira)
                """,

            // 407 GUN SONU VERI SETI (884, KTS maddeleri H13 / D24).
            //
            //   TAKIP NUMARASI YOK: gun sonu bir HASTAYA degil TESISE aittir.
            //   Semada HASTA_TAKIP_BILGISI hic yok - paketin kimligi
            //   KAYIT_YERI (tesis SKRS kodu) ve tarihtir.
            //
            //   KAYIT_YERI kurum kodundan gelir (`entegrasyon_hesap.kurum_kodu`,
            //   602'deki KurumSistemi guid'i ile kodlu) - 101'deki
            //   healthcareProvider ile AYNI deger.
            //
            //   OLCUT SATIRLARI TEKRARLI GRUP: her olcut bir
            //   KLINIK_KALITE_BILGISI. SIFIR SAYILAR DA GONDERILIR - "o gun
            //   hic yatis olmadi" bilgisi, satirin hic olmamasindan farklidir
            //   (Bakanlik eksik gonderim ile sifir isi ayirt edebilmeli).
            "GUN_SONU" => """
                select 'GUN_SONU_VERI_SETI/KAYIT_YERI',
                       coalesce((select e.kurum_kodu from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'entegrasyon_hesap.kurum_kodu', 'SKRS Kurum',
                       coalesce((select e.kurum_kodu from public.entegrasyon_hesap e
                                  where e.kod = 'ENABIZ' limit 1), ''),
                       'c3eade04-4f91-5dab-e043-14031b0ac9f9'
                  from public.enabiz_gun_sonu g where g.id = @p0
                union all select 'GUN_SONU_VERI_SETI/GUN_SONU_BILGISI[1]/GUN_SONU_TARIH',
                       to_char(g.tarih, 'YYYYMMDD') || '2359',
                       'enabiz_gun_sonu.tarih', '', '', ''
                  from public.enabiz_gun_sonu g where g.id = @p0
                union all
                select k2.uss_alan, k2.deger, k2.kaynak, k2.skrs_liste, k2.skrs_kod, k2.skrs_sistem
                  from (
                  with satirlar as (
                    select s.skrs_kod, s.sayi,
                           row_number() over (order by s.skrs_kod) as ix
                      from public.enabiz_gun_sonu_satir s
                     where s.gun_sonu_id = @p0
                  )
                  select 'GUN_SONU_VERI_SETI/GUN_SONU_BILGISI[1]/KLINIK_KALITE_BILGISI['
                         || s.ix || ']/' || a.alan,
                         a.deger, a.kaynak, a.skrs_liste, a.skrs_kod, a.skrs_sistem,
                         s.ix * 10 + a.sira
                    from satirlar s
                    cross join lateral (values
                      ('KLINIK_KALITE_TANIM',
                       public.fn_skrs_ad('enabiz.gun_sonu_olcut', s.skrs_kod::integer),
                       'enabiz_gun_sonu_satir.skrs_kod', 'SKRS Gun Sonu Ozet',
                       public.fn_skrs_kod('enabiz.gun_sonu_olcut', s.skrs_kod::integer),
                       public.fn_skrs_guid('enabiz.gun_sonu_olcut'), 1),
                      ('KLINIK_KALITE_SAYI', s.sayi::text,
                       'enabiz_gun_sonu_satir.sayi', '', '', '', 2)
                    ) as a(alan, deger, kaynak, skrs_liste, skrs_kod, skrs_sistem, sira)
                  order by 7
                ) as k2(uss_alan, deger, kaynak, skrs_liste, skrs_kod, skrs_sistem, sira)
                """,

            // 409 RADYOLOJI SONUC KAYIT (883, KTS maddeleri H10 / D19).
            //   Sema rehberden okundu (19.09.2026).
            //
            //   KAYNAK = ONAYLANMIS RAPOR (`radyoloji_rapor.id`). Tetik
            //   onaydadir: onaylanmamis rapor hastanin dosyasina da girmez,
            //   e-Nabiz'a hic girmemeli (105'teki kural).
            //
            //   ISLEM_REFERANS_NUMARASI 102'DE GONDERILEN NUMARANIN AYNISI
            //   olmali (semanin kendi notu): 102'de `belge_satir.id`
            //   gonderiyoruz, burada da istemin belge satiri.
            //
            //   BOLUMLER SONUC GRUBUNA DONUSUR. Yazdirilmayan bolum (ic not)
            //   GONDERILMEZ - hastanin dosyasina dusmemeli.
            // ASI VERI SETI (207, KTS H10). Sema rehber.enabiz.gov.tr'den
            //   okundu; alan adlari ve SKRS guid'leri oradan birebir.
            //   Kaynak `asi_uygulama.id`. ZORUNLU ogeler: takip no, izlemin
            //   yapildigi yer, ASI, ASI_DOZU - otekiler DOLUYSA gider;
            //   bos ogeyi gondermek, veri yokken veri varmis gibi gostermek
            //   olurdu.
            //
            //   SKRS DEGERI kod listesinden okunur; liste henuz cekilmemisse
            //   ham deger (doz numarasi gibi) gider ve eksik alan raporunda
            //   gorunur - sessiz bir bosluk kalmaz.
            // BEBEK / COCUK IZLEM (209, KTS H10). Sema rehberden okundu;
            //   alan adlari ve SKRS guid'leri birebir.
            //
            //   BIRIM TUZAGI: pakette KILO **GRAM**; ekran kilogram tutuyor,
            //   cevrim BURADA - iki yerde cevirmek, bir gun birinin
            //   unutulmasi demekti.
            //
            //   IZLEM_ISLEM_TURU 207 ile AYNI SKRS listesini kullanir
            //   (5fff8778...); ayri bir liste acmak ayni kodlari iki yerde
            //   tutmak olurdu.
            // GEBE IZLEM (221, KTS H10). Sema rehberden okundu; alan
            //   adlari ve SKRS guid'leri birebir.
            //
            //   KILO BURADA KILOGRAM: 209'daki gram cevrimi YOK - ikisini
            //   ayni sanip cevirmek, gebeyi 70 ton gosterirdi.
            //
            //   RISK FAKTORLERI TEKRARLI GRUP: [1], [2] ... siraya gore
            //   uretilir; bir izlemde birden cok risk olabilir.
            // GEBELIK BILDIRIM (223, KTS H10). Sema rehberden: yalniz iki
            //   zorunlu oge - son adet tarihi ve bir onceki dogum durumu.
            //
            //   TAKIP NUMARASI DOSYANIN KENDI BASVURUSU OLMADIGI ICIN
            //   izlemlerinden okunur: gebelik dosyasi bir basvuruya bagli
            //   degil, izlemler bagli. Hic izlemi olmayan dosya paket
            //   uretmez - gonderilecek bir basvuru yoktur.
            //
            //   SAT'i olmayan dosya (yalniz beklenen dogumla acilmis) da
            //   oge uretmez; tahmini tarih gondermek Bakanlik tarafindaki
            //   izlem takvimini kaydirirdi.
            // GEBELIK SONUCU (224, KTS H10 - son paket). Sema rehberden.
            //
            //   ZORUNLU IKILI: sonlanma tarihi ve gebelik sonucu. Dogum
            //   yontemi, bebek sayilari ve sezaryan endikasyonu yalniz
            //   DOLUYSA gider - dusukle sonuclanan gebelige dogum yontemi
            //   yazmak, veri uydurmak olurdu.
            //
            //   TAKIP NUMARASI: sonucun kendi basvurusu varsa ondan, yoksa
            //   gebeligin izlemlerinden - dogum baska bir basvuruda kayda
            //   gecmis olabilir.
            "GEBELIK_SONUCU" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = coalesce(s.belge_id,
                                        (select max(i.belge_id) from public.gebe_izlem i
                                          where i.gebelik_id = s.gebelik_id))), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.gebelik_sonuc s where s.id = @p0
                union all select 'GEBELIK_SONUCU_VERI_SETI/GEBELIK_SONLANMA_TARIHI',
                       coalesce(to_char(s.sonlanma_tarihi, 'YYYYMMDDHH24MI'), ''), 'gebelik_sonuc.sonlanma_tarihi', '', '', ''
                  from public.gebelik_sonuc s where s.id = @p0 and true
                union all select 'GEBELIK_SONUCU_VERI_SETI/GEBELIK_SONUCU',
                       coalesce(nullif(d.ad, ''), s.sonuc::text),
                       'gebelik_sonuc.sonuc', 'gebe.sonuc',
                       coalesce(nullif(d.skrs_kod, ''), s.sonuc::text),
                       'b5070ebb-a700-46dd-8f50-bee87e4b4596'
                  from public.gebelik_sonuc s
                  left join public.kod_liste l on l.kod = 'gebe.sonuc'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = s.sonuc
                 where s.id = @p0 and s.sonuc is not null
                union all select 'GEBELIK_SONUCU_VERI_SETI/DOGUM_YONTEMI',
                       coalesce(nullif(d.ad, ''), s.dogum_yontemi::text),
                       'gebelik_sonuc.dogum_yontemi', 'gebe.dogum_yontemi',
                       coalesce(nullif(d.skrs_kod, ''), s.dogum_yontemi::text),
                       'c03d71af-54c5-4245-aea4-ad58e876e8bd'
                  from public.gebelik_sonuc s
                  left join public.kod_liste l on l.kod = 'gebe.dogum_yontemi'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = s.dogum_yontemi
                 where s.id = @p0 and s.dogum_yontemi is not null
                union all select 'GEBELIK_SONUCU_VERI_SETI/DOGUMUN_GERCEKLESTIGI_YER',
                       coalesce(nullif(d.ad, ''), s.dogum_yeri::text),
                       'gebelik_sonuc.dogum_yeri', 'gebe.dogum_yeri',
                       coalesce(nullif(d.skrs_kod, ''), s.dogum_yeri::text),
                       'bc2104af-0c2b-4a9d-a450-c0827effe607'
                  from public.gebelik_sonuc s
                  left join public.kod_liste l on l.kod = 'gebe.dogum_yeri'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = s.dogum_yeri
                 where s.id = @p0 and s.dogum_yeri is not null
                union all select 'GEBELIK_SONUCU_VERI_SETI/DOGUMA_YARDIM_EDEN',
                       coalesce(nullif(d.ad, ''), s.doguma_yardim::text),
                       'gebelik_sonuc.doguma_yardim', 'gebe.doguma_yardim',
                       coalesce(nullif(d.skrs_kod, ''), s.doguma_yardim::text),
                       'a85c1ba7-3ae9-44c5-b0d0-613f92c5281b'
                  from public.gebelik_sonuc s
                  left join public.kod_liste l on l.kod = 'gebe.doguma_yardim'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = s.doguma_yardim
                 where s.id = @p0 and s.doguma_yardim is not null
                union all select 'GEBELIK_SONUCU_VERI_SETI/CANLI_DOGAN_BEBEK_SAYISI',
                       s.canli_bebek::text, 'gebelik_sonuc.canli_bebek', '', '', ''
                  from public.gebelik_sonuc s where s.id = @p0 and s.canli_bebek is not null
                union all select 'GEBELIK_SONUCU_VERI_SETI/OLU_DOGAN_BEBEK_SAYISI',
                       s.olu_bebek::text, 'gebelik_sonuc.olu_bebek', '', '', ''
                  from public.gebelik_sonuc s where s.id = @p0 and s.olu_bebek is not null
                union all select 'GEBELIK_SONUCU_VERI_SETI/SEZARYAN_ENDIKASYON',
                       coalesce(nullif(d.ad, ''), s.sezaryan_endikasyon::text),
                       'gebelik_sonuc.sezaryan_endikasyon', 'gebe.sezaryan_endikasyon',
                       coalesce(nullif(d.skrs_kod, ''), s.sezaryan_endikasyon::text),
                       'd7d14450-eaf1-7321-e040-7c0a04164cc0'
                  from public.gebelik_sonuc s
                  left join public.kod_liste l on l.kod = 'gebe.sezaryan_endikasyon'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = s.sezaryan_endikasyon
                 where s.id = @p0 and s.sezaryan_endikasyon is not null
                union all select 'GEBELIK_SONUCU_VERI_SETI/ENDIKASYON_NEDENLERI_BILGISI/ENDIKASYON_NEDENLERI',
                       coalesce(nullif(d.ad, ''), s.endikasyon_neden::text),
                       'gebelik_sonuc.endikasyon_neden', 'gebe.endikasyon_neden',
                       coalesce(nullif(d.skrs_kod, ''), s.endikasyon_neden::text),
                       'd7d15411-dbc7-f5bd-e040-7c0a041665a6'
                  from public.gebelik_sonuc s
                  left join public.kod_liste l on l.kod = 'gebe.endikasyon_neden'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = s.endikasyon_neden
                 where s.id = @p0 and s.endikasyon_neden is not null
                """,

            "GEBELIK_BILDIRIM" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = (select max(i.belge_id)
                                                   from public.gebe_izlem i
                                                  where i.gebelik_id = g.id)), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.gebelik g where g.id = @p0
                union all select 'GEBELIK_BILDIRIM_VERI_SETI/BIR_ONCEKI_DOGUM_DURUMU',
                       coalesce(nullif(d.ad, ''), g.onceki_dogum::text),
                       'gebelik.onceki_dogum', 'gebe.onceki_dogum',
                       coalesce(nullif(d.skrs_kod, ''), g.onceki_dogum::text),
                       'd7e6d65a-b82a-6717-e040-7c0a021654a2'
                  from public.gebelik g
                  left join public.kod_liste l on l.kod = 'gebe.onceki_dogum'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = g.onceki_dogum
                 where g.id = @p0 and g.onceki_dogum is not null
                union all select 'GEBELIK_BILDIRIM_VERI_SETI/SON_ADET_TARIHI',
                       coalesce(to_char(g.sat, 'YYYYMMDD0000'), ''),
                       'gebelik.sat', '', '', ''
                  from public.gebelik g where g.id = @p0 and g.sat is not null
                """,

            "GEBE_IZLEM" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = i.belge_id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.gebe_izlem i where i.id = @p0
                union all select 'GEBE_IZLEM/KACINCI_GEBE_IZLEM',
                       coalesce(nullif(d.ad, ''), i.kacinci_izlem::text),
                       'gebe_izlem.kacinci_izlem', 'gebe.kacinci_izlem',
                       coalesce(nullif(d.skrs_kod, ''), i.kacinci_izlem::text),
                       'a280b762-8804-4049-b587-7c471ff2cbee'
                  from public.gebe_izlem i
                  left join public.kod_liste l on l.kod = 'gebe.kacinci_izlem'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.kacinci_izlem
                 where i.id = @p0 and i.kacinci_izlem is not null
                union all select 'GEBE_IZLEM/IZLEM_ISLEM_TURU',
                       coalesce(nullif(d.ad, ''), i.islem_turu::text),
                       'gebe_izlem.islem_turu', 'asi.islem_turu',
                       coalesce(nullif(d.skrs_kod, ''), i.islem_turu::text),
                       '5fff8778-89a4-4045-b33e-a7ffe0de0179'
                  from public.gebe_izlem i
                  left join public.kod_liste l on l.kod = 'asi.islem_turu'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.islem_turu
                 where i.id = @p0 and i.islem_turu is not null
                union all select 'GEBE_IZLEM/DEMIR_LOJISTIGI_VE_DESTEGI',
                       coalesce(nullif(d.ad, ''), i.demir::text),
                       'gebe_izlem.demir', 'cocuk.demir',
                       coalesce(nullif(d.skrs_kod, ''), i.demir::text),
                       '83c966d5-1054-451c-87c6-19a0e11b287b'
                  from public.gebe_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.demir'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.demir
                 where i.id = @p0 and i.demir is not null
                union all select 'GEBE_IZLEM/D_VITAMINI_LOJISTIGI_VE_DESTEGI',
                       coalesce(nullif(d.ad, ''), i.d_vitamini::text),
                       'gebe_izlem.d_vitamini', 'cocuk.d_vitamini',
                       coalesce(nullif(d.skrs_kod, ''), i.d_vitamini::text),
                       '672986f8-5e0d-43a6-b417-37bdc59cd09b'
                  from public.gebe_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.d_vitamini'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.d_vitamini
                 where i.id = @p0 and i.d_vitamini is not null
                union all select 'GEBE_IZLEM/GESTASYONEL_DIYABET_TARAMASI',
                       coalesce(nullif(d.ad, ''), i.gdm::text),
                       'gebe_izlem.gdm', 'gebe.gdm',
                       coalesce(nullif(d.skrs_kod, ''), i.gdm::text),
                       'eac44682-3583-47f3-8066-7310aac49a21'
                  from public.gebe_izlem i
                  left join public.kod_liste l on l.kod = 'gebe.gdm'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.gdm
                 where i.id = @p0 and i.gdm is not null
                union all select 'GEBE_IZLEM/IDRARDA_PROTEIN',
                       coalesce(nullif(d.ad, ''), i.idrar_protein::text),
                       'gebe_izlem.idrar_protein', 'gebe.idrar_protein',
                       coalesce(nullif(d.skrs_kod, ''), i.idrar_protein::text),
                       'f3d218b5-1a31-4e67-a5f2-72f2d412a802'
                  from public.gebe_izlem i
                  left join public.kod_liste l on l.kod = 'gebe.idrar_protein'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.idrar_protein
                 where i.id = @p0 and i.idrar_protein is not null
                union all select 'GEBE_IZLEM/KONJENITAL_ANOMALI_VARLIGI',
                       coalesce(nullif(d.ad, ''), i.anomali::text),
                       'gebe_izlem.anomali', 'gebe.anomali',
                       coalesce(nullif(d.skrs_kod, ''), i.anomali::text),
                       '484b2fc2-d1a2-4675-872e-c2c56e72d921'
                  from public.gebe_izlem i
                  left join public.kod_liste l on l.kod = 'gebe.anomali'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.anomali
                 where i.id = @p0 and i.anomali is not null
                union all select 'GEBE_IZLEM/HEMOGLOBIN',
                       trim(to_char(i.hemoglobin, 'FM999990.99')), 'gebe_izlem.hemoglobin', '', '', ''
                  from public.gebe_izlem i where i.id = @p0 and i.hemoglobin is not null
                union all select 'GEBE_IZLEM/FETUS_KALP_SESI_BILGISI/FETUS_KALP_SESI',
                       i.fetus_kalp_sesi::text, 'gebe_izlem.fetus_kalp_sesi', '', '', ''
                  from public.gebe_izlem i where i.id = @p0 and i.fetus_kalp_sesi is not null
                union all select 'GEBE_IZLEM/TANSIYON_BILGISI/SISTOLIK_KAN_BASINCI_DEGERI',
                       i.sistolik::text, 'gebe_izlem.sistolik', '', '', ''
                  from public.gebe_izlem i where i.id = @p0 and i.sistolik is not null
                union all select 'GEBE_IZLEM/TANSIYON_BILGISI/DIASTOLIK_KAN_BASINCI_DEGERI',
                       i.diastolik::text, 'gebe_izlem.diastolik', '', '', ''
                  from public.gebe_izlem i where i.id = @p0 and i.diastolik is not null
                union all select 'GEBE_IZLEM/BOY_KILO_BILGILERI/BOY',
                       trim(to_char(i.boy_cm, 'FM999990.99')), 'gebe_izlem.boy_cm', '', '', ''
                  from public.gebe_izlem i where i.id = @p0 and i.boy_cm is not null
                union all select 'GEBE_IZLEM/BOY_KILO_BILGILERI/KILO',
                       trim(to_char(i.kilo_kg, 'FM999990.99')), 'gebe_izlem.kilo_kg', '', '', ''
                  from public.gebe_izlem i where i.id = @p0 and i.kilo_kg is not null
                union all
                select 'GEBELIKTE_RISK_FAKTORLERI_BILGISI[' || x.ix::text
                       || ']/GEBELIKTE_RISK_FAKTORLERI',
                       x.ad, 'gebe_izlem_risk.risk', 'gebe.risk', x.skrs,
                       'ad9ae051-f75d-4180-b57f-38f45132a1b0'
                  from (
                    select row_number() over (order by r.sira, r.id) as ix,
                           coalesce(nullif(d.ad, ''), r.risk::text) as ad,
                           coalesce(nullif(d.skrs_kod, ''), r.risk::text) as skrs
                      from public.gebe_izlem_risk r
                      left join public.kod_liste l on l.kod = 'gebe.risk'
                      left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                           and d.deger = r.risk
                     where r.izlem_id = @p0) x
                """,

            "COCUK_IZLEM" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = i.belge_id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.cocuk_izlem i where i.id = @p0
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/KACINCI_IZLEM',
                       coalesce(nullif(d.ad, ''), i.kacinci_izlem::text), 'cocuk_izlem.kacinci_izlem', 'cocuk.kacinci_izlem',
                       coalesce(nullif(d.skrs_kod, ''), i.kacinci_izlem::text),
                       '402e5a45-f723-4309-9cb8-686358dee75a'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.kacinci_izlem'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.kacinci_izlem
                 where i.id = @p0 and i.kacinci_izlem is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/IZLEM_ISLEM_TURU',
                       coalesce(nullif(d.ad, ''), i.islem_turu::text), 'cocuk_izlem.islem_turu', 'asi.islem_turu',
                       coalesce(nullif(d.skrs_kod, ''), i.islem_turu::text),
                       '5fff8778-89a4-4045-b33e-a7ffe0de0179'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'asi.islem_turu'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.islem_turu
                 where i.id = @p0 and i.islem_turu is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/IZLEM_TARIHI',
                       coalesce(to_char(i.izlem_tarihi, 'YYYYMMDDHH24MI'), ''), 'cocuk_izlem.izlem_tarihi', '', '', ''
                  from public.cocuk_izlem i where i.id = @p0 and true
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/BOY_KILO_BILGILERI/BOY',
                       trim(to_char(i.boy_cm, 'FM999990.99')), 'cocuk_izlem.boy_cm', '', '', ''
                  from public.cocuk_izlem i where i.id = @p0 and i.boy_cm is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/BOY_KILO_BILGILERI/KILO',
                       trim(to_char(round(i.kilo_kg * 1000), 'FM999999990')), 'cocuk_izlem.kilo_kg (gram)', '', '', ''
                  from public.cocuk_izlem i where i.id = @p0 and i.kilo_kg is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/BAS_CEVRESI',
                       trim(to_char(i.bas_cevresi_cm, 'FM999990.99')), 'cocuk_izlem.bas_cevresi_cm', '', '', ''
                  from public.cocuk_izlem i where i.id = @p0 and i.bas_cevresi_cm is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/DOGUM_AGIRLIGI',
                       i.dogum_agirligi_g::text, 'cocuk_izlem.dogum_agirligi_g', '', '', ''
                  from public.cocuk_izlem i where i.id = @p0 and i.dogum_agirligi_g is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/HEMOGLOBIN',
                       trim(to_char(i.hemoglobin, 'FM999990.99')), 'cocuk_izlem.hemoglobin', '', '', ''
                  from public.cocuk_izlem i where i.id = @p0 and i.hemoglobin is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/HEMATOKRIT',
                       trim(to_char(i.hematokrit, 'FM999990.99')), 'cocuk_izlem.hematokrit', '', '', ''
                  from public.cocuk_izlem i where i.id = @p0 and i.hematokrit is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/BEBEGIN_BESLENME_DURUMU',
                       coalesce(nullif(d.ad, ''), i.beslenme::text), 'cocuk_izlem.beslenme', 'cocuk.beslenme',
                       coalesce(nullif(d.skrs_kod, ''), i.beslenme::text),
                       '7f29ff54-3810-4875-9dda-01ac0d70fa21'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.beslenme'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.beslenme
                 where i.id = @p0 and i.beslenme is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/D_VITAMINI_LOJISTIGI_VE_DESTEGI',
                       coalesce(nullif(d.ad, ''), i.d_vitamini::text), 'cocuk_izlem.d_vitamini', 'cocuk.d_vitamini',
                       coalesce(nullif(d.skrs_kod, ''), i.d_vitamini::text),
                       '672986f8-5e0d-43a6-b417-37bdc59cd09b'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.d_vitamini'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.d_vitamini
                 where i.id = @p0 and i.d_vitamini is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/DEMIR_LOJISTIGI_VE_DESTEGI',
                       coalesce(nullif(d.ad, ''), i.demir::text), 'cocuk_izlem.demir', 'cocuk.demir',
                       coalesce(nullif(d.skrs_kod, ''), i.demir::text),
                       '83c966d5-1054-451c-87c6-19a0e11b287b'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.demir'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.demir
                 where i.id = @p0 and i.demir is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/GKD_TARAMA_SONUCU',
                       coalesce(nullif(d.ad, ''), i.gkd::text), 'cocuk_izlem.gkd', 'cocuk.gkd',
                       coalesce(nullif(d.skrs_kod, ''), i.gkd::text),
                       '03dee8e4-6d54-4009-9b53-84c11d302e14'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.gkd'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.gkd
                 where i.id = @p0 and i.gkd is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/GORME_TARAMA_SONUCU',
                       coalesce(nullif(d.ad, ''), i.gorme::text), 'cocuk_izlem.gorme', 'cocuk.gorme',
                       coalesce(nullif(d.skrs_kod, ''), i.gorme::text),
                       'bb174db7-75ea-4bd4-a3e9-cf2a908511cb'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.gorme'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.gorme
                 where i.id = @p0 and i.gorme is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/KRITIK_DKH_TARAMA_SONUCU',
                       coalesce(nullif(d.ad, ''), i.dkh::text), 'cocuk_izlem.dkh', 'cocuk.dkh',
                       coalesce(nullif(d.skrs_kod, ''), i.dkh::text),
                       'e57b0379-a276-4bf5-88f2-fcea2d8a9b25'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.dkh'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.dkh
                 where i.id = @p0 and i.dkh is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/KRITIK_DKH_TARAMA_YAPILMAMA_NEDENI',
                       coalesce(nullif(d.ad, ''), i.dkh_yapilmama::text), 'cocuk_izlem.dkh_yapilmama', 'cocuk.dkh_yapilmama',
                       coalesce(nullif(d.skrs_kod, ''), i.dkh_yapilmama::text),
                       '2bdf99c8-0c7f-4cc8-8f96-ce622344e88c'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.dkh_yapilmama'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.dkh_yapilmama
                 where i.id = @p0 and i.dkh_yapilmama is not null
                union all select 'BEBEK_COCUK_IZLEM_VERI_SETI/NTP_TAKIP_BILGISI',
                       coalesce(nullif(d.ad, ''), i.ntp::text), 'cocuk_izlem.ntp', 'cocuk.ntp',
                       coalesce(nullif(d.skrs_kod, ''), i.ntp::text),
                       'b409d9c0-fe50-43e0-afab-889cf87a2855'
                  from public.cocuk_izlem i
                  left join public.kod_liste l on l.kod = 'cocuk.ntp'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = i.ntp
                 where i.id = @p0 and i.ntp is not null
                """,

            "ASI" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = u.belge_id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.asi_uygulama u where u.id = @p0
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/IZLEMIN_YAPILDIGI_YER',
                       coalesce(nullif(d.ad, ''), u.izlem_yeri::text), 'asi_uygulama.izlem_yeri', 'asi.izlem_yeri',
                       coalesce(nullif(d.skrs_kod, ''), u.izlem_yeri::text),
                       'c3eade04-4f91-5dab-e043-14031b0ac9f9'
                  from public.asi_uygulama u
                  left join public.kod_liste l on l.kod = 'asi.izlem_yeri'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = u.izlem_yeri
                 where u.id = @p0 and u.izlem_yeri is not null
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ASI',
                       a.ad, 'asi.skrs_kod', 'asi.asi', a.skrs_kod,
                       'c3dbbb53-3b59-06e1-e043-14031b0a9fe6'
                  from public.asi_uygulama u
                  join public.asi a on a.id = u.asi_id
                 where u.id = @p0 and coalesce(a.skrs_kod, '') <> ''
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ASI_DOZU',
                       u.doz_no::text, 'asi_uygulama.doz_no', 'asi.doz',
                       coalesce(nullif(d.skrs_kod, ''), u.doz_no::text),
                       'da92a50e-b1a8-4e6a-be8c-2b6ca2c0a58b'
                  from public.asi_uygulama u
                  left join public.kod_liste l on l.kod = 'asi.doz'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = u.doz_no
                 where u.id = @p0
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ASI_BARKODU',
                       u.barkod, 'asi_uygulama.barkod', '', '', ''
                  from public.asi_uygulama u
                 where u.id = @p0 and trim(u.barkod) <> ''
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ASININ_UYGULAMA_SEKLI',
                       coalesce(nullif(d.ad, ''), u.uygulama_sekli::text), 'asi_uygulama.uygulama_sekli',
                       'asi.uygulama_sekli',
                       coalesce(nullif(d.skrs_kod, ''), u.uygulama_sekli::text),
                       'f20210e0-d780-4961-87eb-3323000b7dbb'
                  from public.asi_uygulama u
                  left join public.kod_liste l on l.kod = 'asi.uygulama_sekli'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = u.uygulama_sekli
                 where u.id = @p0 and u.uygulama_sekli is not null
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ASININ_UYGULAMA_YERI',
                       coalesce(nullif(d.ad, ''), u.uygulama_yeri::text), 'asi_uygulama.uygulama_yeri',
                       'asi.uygulama_yeri',
                       coalesce(nullif(d.skrs_kod, ''), u.uygulama_yeri::text),
                       'eb66330f-2b96-40a7-931e-fc9aed2b9409'
                  from public.asi_uygulama u
                  left join public.kod_liste l on l.kod = 'asi.uygulama_yeri'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = u.uygulama_yeri
                 where u.id = @p0 and u.uygulama_yeri is not null
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ASI_ISLEM_TURU',
                       coalesce(nullif(d.ad, ''), u.islem_turu::text), 'asi_uygulama.islem_turu', 'asi.islem_turu',
                       coalesce(nullif(d.skrs_kod, ''), u.islem_turu::text),
                       '5fff8778-89a4-4045-b33e-a7ffe0de0179'
                  from public.asi_uygulama u
                  left join public.kod_liste l on l.kod = 'asi.islem_turu'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = u.islem_turu
                 where u.id = @p0 and u.islem_turu is not null
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ASI_OZEL_DURUM_NEDENI',
                       coalesce(nullif(d.ad, ''), u.ozel_durum::text), 'asi_uygulama.ozel_durum', 'asi.ozel_durum',
                       coalesce(nullif(d.skrs_kod, ''), u.ozel_durum::text),
                       '0a8f681f-4ed0-4830-9dc9-a0295686398b'
                  from public.asi_uygulama u
                  left join public.kod_liste l on l.kod = 'asi.ozel_durum'
                  left join public.kod_deger d on d.liste_id = l.id and d.dil = 0
                       and d.deger = u.ozel_durum
                 where u.id = @p0 and u.ozel_durum is not null
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ISLEM_YAPAN',
                       coalesce(p.vkno, ''), 'taraf.vkno', '', '', ''
                  from public.asi_uygulama u
                  left join public.taraf p on p.id = u.uygulayan_id
                 where u.id = @p0 and coalesce(p.vkno, '') <> ''
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ASI_SORGU_NUMARASI',
                       u.sorgu_no, 'asi_uygulama.sorgu_no', '', '', ''
                  from public.asi_uygulama u
                 where u.id = @p0 and trim(u.sorgu_no) <> ''
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/BILGI_ALINAN_KISI_ADI_SOYADI',
                       u.bilgi_alinan_ad, 'asi_uygulama.bilgi_alinan_ad', '', '', ''
                  from public.asi_uygulama u
                 where u.id = @p0 and trim(u.bilgi_alinan_ad) <> ''
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/BILGI_ALINAN_KISI_TEL',
                       u.bilgi_alinan_tel, 'asi_uygulama.bilgi_alinan_tel', '', '', ''
                  from public.asi_uygulama u
                 where u.id = @p0 and trim(u.bilgi_alinan_tel) <> ''
                union all select 'ASI_VERI_SETI/ASI_BILGISI[1]/ASI_YAPILMA_ZAMANI',
                       coalesce(to_char(u.uygulama_zamani, 'YYYYMMDDHH24MI'), ''),
                       'asi_uygulama.uygulama_zamani', '', '', ''
                  from public.asi_uygulama u where u.id = @p0
                """,

            "RADYOLOJI_SONUC" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = i.belge_id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.radyoloji_rapor r
                  join public.radyoloji_istem i on i.id = r.istem_id
                 where r.id = @p0
                union all select 'RADYOLOJI_SONUC_KAYIT/RADYOLOJI_BILGISI[1]/RADYOLOJI_LOINC',
                       coalesce(h.loinc, ''), 'hizmet.loinc', 'SKRS LOINC',
                       coalesce(h.loinc, ''), '39aef8d6-9b53-4b56-8c73-2f53b0599094'
                  from public.radyoloji_rapor r
                  join public.radyoloji_istem i on i.id = r.istem_id
                  left join public.hizmet h on h.id = i.hizmet_id
                 where r.id = @p0 and coalesce(h.loinc, '') <> ''
                union all select 'RADYOLOJI_SONUC_KAYIT/RADYOLOJI_BILGISI[1]/ISLEM_REFERANS_NUMARASI',
                       coalesce(i.belge_satir_id::text, ''), 'belge_satir.id', '', '', ''
                  from public.radyoloji_rapor r
                  join public.radyoloji_istem i on i.id = r.istem_id
                 where r.id = @p0
                union all select 'RADYOLOJI_SONUC_KAYIT/RADYOLOJI_BILGISI[1]/RAPOR_ONAYLANMA_ZAMANI',
                       coalesce(to_char(r.onay_tarihi, 'YYYYMMDDHH24MI'), ''),
                       'radyoloji_rapor.onay_tarihi', '', '', ''
                  from public.radyoloji_rapor r where r.id = @p0
                -- SONUC GRUBU: rapor bolumleri (baslik + metin), sirasiyla.
                union all
                select b2.uss_alan, b2.deger, b2.kaynak, '', '', ''
                  from (
                  with bolumler as (
                    select b.baslik, b.metin,
                           row_number() over (order by b.sira, b.id) as ix
                      from public.radyoloji_rapor_bolum b
                     where b.rapor_id = @p0 and b.yazdir = 1
                       and coalesce(btrim(b.metin), '') <> ''
                  )
                  select 'RADYOLOJI_SONUC_KAYIT/RADYOLOJI_BILGISI[1]/RAPOR_SONUC_BILGISI['
                         || b.ix || ']/' || a.alan,
                         a.deger, a.kaynak, b.ix * 10 + a.sira
                    from bolumler b
                    cross join lateral (values
                      ('SONUC_BASLIK', b.baslik, 'radyoloji_rapor_bolum.baslik', 1),
                      ('SONUC_ACIKLAMA', left(b.metin, 4000),
                       'radyoloji_rapor_bolum.metin', 2)
                    ) as a(alan, deger, kaynak, sira)
                  order by 4
                ) as b2(uss_alan, deger, kaynak, sira)
                """,

            // 214 BULASICI HASTALIK BILDIRIM (882, KTS maddesi H5 - eski
            //   denetimde "Hatalı"). Sema rehberden okundu (19.09.2026).
            //
            //   KAYNAK = `bzbh_bildirim.id`. Iki zorunlu alan (VAKA_TIPI ve
            //   KLINIK_BELIRTILERIN_BASLADIGI_TARIH) tanidan cikarilamaz,
            //   bildirim kartinda HEKIM girer; paket ancak o zaman uretilir.
            //
            //   KIMLIK BILGISI GRUBU ACILIYOR: hastanin kimlik numarasi, ad,
            //   soyad, dogum tarihi ve cinsiyeti. Bildirim, hastanin kendi
            //   basvurusundan bagimsiz olarak il saglik mudurlugune gider;
            //   kimlik alanlari bos gitse vaka kime ait belli olmazdi.
            //
            //   ADRES GRUPLARI (MERNIS_ADRESI / BEYAN_ADRESI) ACILMIYOR: il
            //   ve ilce SKRS kod sistemleriyle kodlu ve bizim adres
            //   kayitlarimizda o kodlar HENUZ YOK. Yarim grup gondermek -
            //   "acilan grubun ici tam olmali" - hatali adres bildirmekti.
            "BZBH_BILDIRIM" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = b.belge_id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.bzbh_bildirim b where b.id = @p0
                union all select 'BULASICI_HASTALIK_BILDIRIM/PAKETE_AIT_ISLEM_ZAMANI',
                       to_char(now(), 'YYYYMMDDHH24MI'), '(uretim zamani)', '', '', ''
                  from public.bzbh_bildirim b where b.id = @p0
                union all select 'BULASICI_HASTALIK_BILDIRIM/BULASICI_HASTALIK_TANI_ZAMANI',
                       coalesce(to_char(b.tani_zamani, 'YYYYMMDDHH24MI'), ''),
                       'bzbh_bildirim.tani_zamani', '', '', ''
                  from public.bzbh_bildirim b where b.id = @p0
                union all select 'BULASICI_HASTALIK_BILDIRIM/VAKA_TIPI',
                       public.fn_skrs_ad('bzbh.vaka_tipi', b.vaka_tipi),
                       'bzbh_bildirim.vaka_tipi', 'SKRS Vaka Tipi',
                       public.fn_skrs_kod('bzbh.vaka_tipi', b.vaka_tipi),
                       public.fn_skrs_guid('bzbh.vaka_tipi')
                  from public.bzbh_bildirim b where b.id = @p0
                union all select 'BULASICI_HASTALIK_BILDIRIM/KLINIK_BELIRTILERIN_BASLADIGI_TARIH',
                       coalesce(to_char(b.belirti_tarihi, 'YYYYMMDD') || '0000', ''),
                       'bzbh_bildirim.belirti_tarihi', '', '', ''
                  from public.bzbh_bildirim b where b.id = @p0
                -- TANI GRUBU: ikisi de zorunlu. TANI_TURU "ana tani" (SKRS 1).
                union all select 'BULASICI_HASTALIK_BILDIRIM/TANI_BILGISI/TANI_TURU',
                       public.fn_skrs_ad('tani.turu', 1::integer),
                       '(ana tani)', 'SKRS Tani Turu',
                       public.fn_skrs_kod('tani.turu', 1::integer),
                       public.fn_skrs_guid('tani.turu')
                  from public.bzbh_bildirim b where b.id = @p0
                union all select 'BULASICI_HASTALIK_BILDIRIM/TANI_BILGISI/ICD10',
                       b.icd_kod, 'bzbh_bildirim.icd_kod', 'ICD-10',
                       b.icd_kod, 'c3eaabad-8c4c-56ee-e043-14031b0a5530'
                  from public.bzbh_bildirim b where b.id = @p0
                -- KIMLIK GRUBU
                union all select 'BULASICI_HASTALIK_BILDIRIM/BILDIRIM_KIMLIK_BILGISI/HASTA_KIMLIK_NUMARASI',
                       coalesce(t.vkno, ''), 'taraf.vkno', '', '', ''
                  from public.bzbh_bildirim b join public.taraf t on t.id = b.hasta_id
                 where b.id = @p0
                -- AD / SOYAD `taraf.unvan`dan BOLUNUR: hasta kartinda ad ve soyad
                --   ayri kolonlar DEGIL (bilincli karar, bkz. veri modeli notu).
                --   Son kelime soyad, oncesi ad sayilir - "AYSE NUR YILMAZ" ->
                --   "AYSE NUR" + "YILMAZ". Tek kelimelik unvanda ikisi de ayni.
                union all select 'BULASICI_HASTALIK_BILDIRIM/BILDIRIM_KIMLIK_BILGISI/AD',
                       case when position(' ' in btrim(t.unvan)) = 0 then btrim(t.unvan)
                            else btrim(left(btrim(t.unvan),
                                            length(btrim(t.unvan))
                                            - position(' ' in reverse(btrim(t.unvan))))) end,
                       'taraf.unvan (ad kismi)', '', '', ''
                  from public.bzbh_bildirim b join public.taraf t on t.id = b.hasta_id
                 where b.id = @p0
                union all select 'BULASICI_HASTALIK_BILDIRIM/BILDIRIM_KIMLIK_BILGISI/SOYAD',
                       case when position(' ' in btrim(t.unvan)) = 0 then btrim(t.unvan)
                            else btrim(right(btrim(t.unvan),
                                             position(' ' in reverse(btrim(t.unvan))) - 1)) end,
                       'taraf.unvan (soyad kismi)', '', '', ''
                  from public.bzbh_bildirim b join public.taraf t on t.id = b.hasta_id
                 where b.id = @p0
                union all select 'BULASICI_HASTALIK_BILDIRIM/BILDIRIM_KIMLIK_BILGISI/DOGUM_TARIHI',
                       coalesce(to_char(th.dogum_tarihi, 'YYYYMMDD') || '0000', ''),
                       'taraf_hasta.dogum_tarihi', '', '', ''
                  from public.bzbh_bildirim b
                  left join public.taraf_hasta th on th.id = b.hasta_id
                 where b.id = @p0
                union all select 'BULASICI_HASTALIK_BILDIRIM/BILDIRIM_KIMLIK_BILGISI/CINSIYET',
                       public.fn_skrs_ad('hasta.cinsiyet', th.cinsiyet::integer),
                       'taraf_hasta.cinsiyet', 'SKRS Cinsiyet',
                       public.fn_skrs_kod('hasta.cinsiyet', th.cinsiyet::integer),
                       public.fn_skrs_guid('hasta.cinsiyet')
                  from public.bzbh_bildirim b
                  join public.taraf_hasta th on th.id = b.hasta_id
                 where b.id = @p0 and coalesce(th.cinsiyet, 0) > 0
                """,

            // 411 DOKTOR MESAJI (881, KTS maddeleri H7/D14 - ayrica H1/D16
            //   numune reddi ve D17 randevu iptali ayni paketten gider).
            //
            //   877'de mesaji NabizHBYS.svc uzerinde ayri bir SOAP metoduyla
            //   gondermeyi tasarlamistik; dogrusu bu: mesaj bir USS PAKETI.
            //   Yani 101/102/103 ile ayni kuyruk, ayni SYSSendMessage.
            //
            //   KAYNAK = `enabiz_mesaj.id`. Takip numarasi mesajin kendi
            //   basvurusundan, yoksa HASTANIN o gunku basvurusundan alinir:
            //   otomatik mesajlarda (numune reddi) basvuru bagini olay
            //   kuruyor, elle yazilan mesajda hekim bir basvuruda olmayabilir.
            "HASTA_MESAJI" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = m.belge_id), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.enabiz_mesaj m where m.id = @p0
                union all select 'DOKTOR_MESAJI_VERI_SETI/HASTA_MESAJLARI_TURU',
                       public.fn_skrs_ad('enabiz.hasta_mesaj_turu', m.mesaj_turu),
                       'enabiz_mesaj.mesaj_turu', 'SKRS Hasta Mesajlari',
                       public.fn_skrs_kod('enabiz.hasta_mesaj_turu', m.mesaj_turu),
                       public.fn_skrs_guid('enabiz.hasta_mesaj_turu')
                  from public.enabiz_mesaj m where m.id = @p0
                union all select 'DOKTOR_MESAJI_VERI_SETI/MESAJ_DETAYI',
                       left(m.metin, 400), 'enabiz_mesaj.metin', '', '', ''
                  from public.enabiz_mesaj m where m.id = @p0
                union all select 'DOKTOR_MESAJI_VERI_SETI/MESAJ_TARIHI',
                       to_char(m.ekleme_tarihi, 'YYYYMMDDHH24MI'),
                       'enabiz_mesaj.ekleme_tarihi', '', '', ''
                  from public.enabiz_mesaj m where m.id = @p0
                """,

            // 252 KONSULTASYON KAYIT (880, KTS maddesi H2/D20 - eski denetimde
            //   "Hatalı"). Sema rehberden okundu (19.09.2026):
            //   KONSULTASYON_BILGISI grubu tekrarli; biz TEK konsultasyonu
            //   gonderiyoruz (kaynak zaten o konsultasyon muayenesidir), o
            //   yuzden indeks sabit [1].
            //
            //   KAYNAK = KONSULTASYON MUAYENESI. Bizde konsultasyon ayri bir
            //   tablo degil, `ust_muayene_id` ile bagli bir MUAYENE satiridir
            //   (465): soru isteyenin cumlesi, yanit cevaplayanin karari ayni
            //   satirda.
            //
            //   TAKIP NUMARASI UST MUAYENENIN BASVURUSUNDAN da okunur:
            //   konsultasyon muayenesi ayri bir basvuru acmaz, hastanin ayni
            //   basvurusunun altinda yasar.
            "KONSULTASYON" => """
                select 'HASTA_TAKIP_BILGISI/SYSTakipNo',
                       coalesce((select bb.sys_takip_no from public.belge_basvuru bb
                                  where bb.id = coalesce(k.belge_id, u.belge_id)), ''),
                       'belge_basvuru.sys_takip_no', '', '', ''
                  from public.muayene k
                  left join public.muayene u on u.id = k.ust_muayene_id
                 where k.id = @p0
                union all select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/ISLEM_REFERANS_NUMARASI',
                       coalesce(nullif(k.muayene_no, ''), k.id::text),
                       'muayene.muayene_no', '', '', ''
                  from public.muayene k where k.id = @p0
                union all select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/KONSULTASYON_BASLAMA_ZAMANI',
                       coalesce(to_char(coalesce(k.baslangic, k.muayene_tarihi),
                                        'YYYYMMDDHH24MI'), ''),
                       'muayene.baslangic', '', '', ''
                  from public.muayene k where k.id = @p0
                union all select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/KONSULTASYON_BITIS_ZAMANI',
                       coalesce(to_char(coalesce(k.bitis, k.tamamlanma), 'YYYYMMDDHH24MI'), ''),
                       'muayene.bitis', '', '', ''
                  from public.muayene k where k.id = @p0
                -- TALEBI YAPAN: UST muayenenin hekimi (konsultasyonu o istedi).
                union all select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/KONSULTASYON_TALEBINI_YAPAN_HEKIM_KIMLIK_NUMARASI',
                       coalesce((select t.vkno from public.taraf t where t.id = u.personel_id), ''),
                       'ust muayene personel.vkno', '', '', ''
                  from public.muayene k
                  left join public.muayene u on u.id = k.ust_muayene_id
                 where k.id = @p0
                union all select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/KONSULTASYON_TALEBINE_CEVAP_VEREN_HEKIM_KIMLIK_NUMARASI',
                       coalesce((select t.vkno from public.taraf t where t.id = k.personel_id), ''),
                       'muayene personel.vkno', '', '', ''
                  from public.muayene k where k.id = @p0
                -- NOT GRUBU ZORUNLU: soru ve yanit ayri iki not satiri.
                --   Yanit bos ise o satir hic yazilmaz - acilan grubun ici
                --   tam olmali (105'te ogrenilen kural).
                union all select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/KONSULTASYON_NOTU_BILGISI[1]/KONSULTASYON_NOTU_BASLIK',
                       'Konsültasyon isteği', '(sabit baslik)', '', '', ''
                  from public.muayene k where k.id = @p0
                union all select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/KONSULTASYON_NOTU_BILGISI[1]/KONSULTASYON_NOTU_ACIKLAMA',
                       left(coalesce(nullif(k.konsultasyon_soru, ''), 'Konsültasyon istendi.'), 400),
                       'muayene.konsultasyon_soru', '', '', ''
                  from public.muayene k where k.id = @p0
                union all select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/KONSULTASYON_NOTU_BILGISI[2]/KONSULTASYON_NOTU_BASLIK',
                       'Konsültasyon yanıtı', '(sabit baslik)', '', '', ''
                  from public.muayene k where k.id = @p0 and coalesce(k.karar, '') <> ''
                union all select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/KONSULTASYON_NOTU_BILGISI[2]/KONSULTASYON_NOTU_ACIKLAMA',
                       left(k.karar, 400), 'muayene.karar', '', '', ''
                  from public.muayene k where k.id = @p0 and coalesce(k.karar, '') <> ''
                -- TANILAR: konsultasyon muayenesinin kendi tanilari (103 ile
                --   AYNI kod sistemleri - guid'ler rehberde birebir ayni).
                union all
                select k2.uss_alan, k2.deger, k2.kaynak, k2.skrs_liste, k2.skrs_kod, k2.skrs_sistem
                  from (
                  with tanilar as (
                    select t.icd_kod, t.tur,
                           row_number() over (order by t.sira, t.id) as ix
                      from public.tani t
                     where t.muayene_id = @p0 and coalesce(t.icd_kod, '') <> ''
                  )
                  select 'HASTA_KONSULTASYON_BILGILERI/KONSULTASYON_BILGISI[1]/TANI_BILGISI['
                         || t.ix || ']/' || a.alan,
                         a.deger, a.kaynak, a.skrs_liste, a.skrs_kod, a.skrs_sistem,
                         t.ix * 10 + a.sira
                    from tanilar t
                    cross join lateral (values
                      ('TANI_TURU',
                       public.fn_skrs_ad('tani.turu', t.tur),
                       'tani.tur', 'SKRS Tani Turu',
                       public.fn_skrs_kod('tani.turu', t.tur),
                       public.fn_skrs_guid('tani.turu'), 1),
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
