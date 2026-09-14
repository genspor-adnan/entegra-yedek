namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Fatura / irsaliye / e-Belge listeleri ve belge donusumu.
///
/// KaynakKatalogu tek dosyada 1389 satira ulasmisti; tanimlar konu basina
/// partial dosyalara ayrildi. Sozluk, Bul/Tumu ve kayit sirasi ana dosyada.
/// </summary>
public static partial class KaynakKatalogu
{
    // -------------------------------------------------------------- belge ----
    private static KaynakTanimi Belge() => new(
        Ad: "belge",
        YetkiKodu: "belge",
        Kaynak: "public.belge b " +
                "left join public.kasa_islem_turu bt on bt.kod = b.tur " +
                // F8 donusum zinciri: kaynak baslik bagindan okunur.
                "left join public.belge kb on kb.id = b.kaynak_id and b.kaynak_tur = 30 " +
                "left join public.kasa_islem_turu kt2 on kt2.kod = kb.tur " +
                "left join public.sube sb on sb.id = b.sube_id " +
                // Muhasebe fisi (190): numarasi listede gorunsun.
                "left join public.muhasebe_fis mf on mf.id = b.muhasebe_fis_id " +
                // Satis temsilcisi (teklif listesi kolonu): personel de taraf.
                "left join public.taraf st on st.id = b.satici_id",
        SubeKolonu: "b.sube_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        KapsamKolonu: "b.taraf_id",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "b.id",             "sayi",  "Id",          Varsayilan: false),
            // Ham TUR kodu gizli: "Belge Türü" zaten adini gosteriyor, ikisi
            //   yan yana ayni bilgiyi tekrarliyordu (cip/filtre ham kodu kullanir).
            new("tur",           "b.tur",            "kod",   "Tür Kodu",    Hizalama: "orta",
                                                                            Genislik: 70, Varsayilan: false),
            new("turAdi",        "bt.ad",            "metin", "Belge Türü",  Genislik: 130),
            // F8: siparis/irsaliye ne kadari donusturuldu (0 acik / 1 kismi / 2 kapandi)
            new("kapanmaAdi",
                """
                case coalesce(b.kapanma_durum, 0)
                     when 0 then 'Açık' when 1 then 'Kısmi' when 2 then 'Kapandı'
                     else '' end
                """,                             "metin", "Kapanma", Hizalama: "orta",
                                                 Bicim: "rozet", Genislik: 100,
                                                 Varsayilan: false, Filtrelenebilir: false),
            new("kapanmaDurum",  "b.kapanma_durum",  "kod",   "Kapanma Kodu",Hizalama: "orta", Varsayilan: false),
            new("belgeSeri",     "b.belge_seri",     "metin", "Seri",        Genislik: 70, Varsayilan: false),
            // Teklif listesinde EN SOLDA (kolonSirasi) - diger belge
            //   listelerinde istege bagli (kolon menusunden acilir).
            // satici_id 0/NULL "atanmadi" demek - 0 kaydi "Tanımsız Cari"
            //   oldugundan bos gosterilir.
            new("saticiAdi",
                "case when coalesce(b.satici_id, 0) = 0 then '' " +
                "else coalesce(st.unvan, '') end",
                                                 "metin", "Satış Temsilcisi",
                                                 Genislik: 150, Varsayilan: false,
                                                 Siralanabilir: false, Filtrelenebilir: false),
            new("belgeNo",       "b.belge_no",       "metin", "Belge No",    Genislik: 155),
            // e-BELGE DURUMU ROZET: ham kod (0/1/11/51...) listede hicbir sey
            //   anlatmiyordu. Metin hem TURU hem ASAMAYI soyler; gonderilmis
            //   belge "✓" ile ve yesil rozetle ayrilir (163/164 kodlari).
            new("efaturaDurum",
                """
                case coalesce(b.efatura_durum, 0)
                     when 0  then ''
                     when 1  then 'e-Fatura'    when 2  then 'e-Fatura ✓'
                     when 11 then 'e-Arşiv'     when 12 then 'e-Arşiv ✓'
                     when 51 then 'e-İrsaliye'  when 52 then 'e-İrsaliye ✓'
                     else 'Bilinmiyor' end
                """,                             "metin", "e-Fatura", Hizalama: "orta",
                                                 Bicim: "rozet", Genislik: 110,
                                                 Siralanabilir: false, Filtrelenebilir: false),
            // Senaryo ve fatura tipi e-Fatura durumunun SAGINDA (kullanici):
            //   "hangi belge, hangi senaryoda, ne tipte" ucu yan yana okunur.
            //   Liste katmani kod listesi cozmez; metin SQL'de uretilir.
            new("senaryoAdi",
                """
                case coalesce(b.senaryo, 0)
                     when 1 then 'Temel'   when 2 then 'Ticari'
                     when 3 then 'İhracat' when 7 then 'Kamu'
                     when 8 then 'İlaç / Tıbbi Cihaz'
                     else '' end
                """,                             "metin", "Senaryo", Hizalama: "orta",
                                                 Bicim: "rozet", Genislik: 130,
                                                 Filtrelenebilir: false),
            new("tipiAdi",
                """
                case coalesce(b.tipi, 0)
                     when 2  then 'İade'          when 3  then 'Fiyat Farkı'
                     when 5  then 'Kur Farkı'     when 9  then 'İhraç Kayıtlı'
                     when 22 then 'Tevkifatlı'    when 24 then 'KDV İstisna'
                     when 25 then 'SGK'           when 26 then 'İhracat'
                     else '' end
                """,                             "metin", "Tipi", Hizalama: "orta",
                                                 Bicim: "rozet", Genislik: 120,
                                                 Filtrelenebilir: false),
            new("tipi",          "b.tipi",           "sayi",  "Tip Kodu",    Hizalama: "orta", Varsayilan: false),
            new("senaryo",       "b.senaryo",        "sayi",  "Senaryo Kodu",Hizalama: "orta", Varsayilan: false),
            new("belgeTarihi",   "b.belge_tarihi",   "tarih", "Tarih",       Hizalama: "orta",
                                                                Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("tarafId",       "b.taraf_id",       "sayi",  "Cari Id",     Varsayilan: false),
            new("tarafUnvan",    "b.taraf_unvan",    "metin", "Cari",        Genislik: 260),
            // KAYNAK / HEDEF: donusum zincirinin iki ucu (irsaliye listesindeki
            //   ile ayni). Kaynak baslik bagindan; hedef SATIR bagindan turer -
            //   bir belge birden fazla belgeye bolunebilir, numaralar birlestirilir.
            //   Iptal (durum=2) hedefler sayilmaz.
            new("kaynak",
                "case when kb.id is null then '' " +
                "else coalesce(kt2.ad, '') || case when kb.belge_no <> '' " +
                "then ' ' || kb.belge_no else '' end end",
                                                      "metin", "Kaynak",      Genislik: 170,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("hedef",
                // Bir belge BIRDEN COK ve FARKLI TURDE hedefe bolunebilir (bir
                //   kismi faturaya, kalani tahakkuka): hepsi virgulle yazilir.
                //   Numarasi verilmemis hedefte YALNIZ tur adi gorunur - eski
                //   ifade "Satış İrsaliyesi 0" yaziyordu. Siralama tur+no ile
                //   sabit: string_agg sirasiz calisir, ayni belge her acilista
                //   farkli sirada gorunuyordu.
                "coalesce((select string_agg(distinct trim(coalesce(ht.ad, '') || ' ' || " +
                "                            case when coalesce(hb.belge_no, '') in ('', '0') " +
                "                                 then '' else hb.belge_no end), ', ' " +
                "                            order by trim(coalesce(ht.ad, '') || ' ' || " +
                "                                     case when coalesce(hb.belge_no, '') in ('', '0') " +
                "                                          then '' else hb.belge_no end)) " +
                "            from public.belge_satir hs " +
                "            join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30 " +
                "            join public.belge hb on hb.id = hs.belge_id " +
                "            left join public.kasa_islem_turu ht on ht.kod = hb.tur " +
                "           where ks.belge_id = b.id and hb.durum <> 2), '')",
                                                      "metin", "Hedef",       Genislik: 190,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            // BASVURU (279) kolonlari: odemeyi ustlenen kurum ve - randevudan
            //   acilan basvurularda - poliklinik ile hekim. Bu ucu belgede
            //   kolon degil: kurum id'den ada cozulur, poliklinik/hekim
            //   BELGEYE BAGLI RANDEVUDAN gelir (randevu.belge_id, indeks 282).
            //   Varsayilan kapali - ERP listelerinde kalabaligi artirmasin,
            //   basvuru listesi kolonSirasi ile aciyor.
            new("odeyenKurumAdi",
                "coalesce((select ok.unvan from public.taraf ok " +
                "           where ok.id = (select bb.odeyen_kurum_id " +
                "                            from public.belge_basvuru bb " +
                "                           where bb.id = b.id)), '')",
                                                      "metin", "Ödeyen Kurum", Genislik: 180,
                                                      Varsayilan: false, Siralanabilir: false),
            // SOZLESME ADI - KURUMUN SAGINDA (kullanici: "başvurularda kurum
            //   sağına Sözleşme ekle… listede"). Ayni sigortayla ÖSS / TSS /
            //   Karma police AYRI SARTLARLA calisir ve odeme rotasini o
            //   belirler; listede yalniz kurum adi durunca iki basvurunun
            //   neden farkli dagildigi gorunmuyordu. Ad yoksa police turu
            //   (alt kurum) yazilir - sozlesme adsiz kurulmus olabilir.
            new("sozlesmeAdi",
                // KOD DEGERI LISTESINDEN BAGLANIR (602): eskiden once
                //   `kod_deger` deger uzerinden baglaniyor, liste kosulu
                //   ise ONDAN SONRAKI join'de duruyordu - yani `kd`yi hic
                //   daraltmiyordu. Ayni sayi baska bir listede de varsa alt
                //   sorgu IKI SATIR donup listeyi 500 ile dusuruyordu
                //   ("more than one row returned by a subquery"): 301 ve 302
                //   hem `kurum.alt_kurum` hem `hekim.brans` listesinde var ve
                //   SGK sozlesmelerinin alt kurum kodlari tam da bunlar.
                //   Dogru sira: once LISTE, sonra o listenin degeri.
                "coalesce((select coalesce(nullif(sz.ad, ''), kd.ad, '') " +
                "            from public.belge_basvuru bb " +
                "            join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id " +
                "            left join public.kod_liste kl " +
                "                   on kl.kod = 'kurum.alt_kurum' " +
                "            left join public.kod_deger kd " +
                "                   on kd.liste_id = kl.id " +
                "                  and kd.deger = sz.alt_kurum and kd.dil = 0 " +
                "           where bb.id = b.id), '')",
                                                      "metin", "Sözleşme", Genislik: 160,
                                                      Varsayilan: false, Siralanabilir: false,
                                                      Filtrelenebilir: false),
            // ONCE BELGENIN KENDI ALANI (296, belge_basvuru), yoksa randevudan:
            //   randevusuz acilan basvuruda bilgi artik belgede duruyor; eski
            //   kayitlarda ve randevudan donusenlerde randevu yedegi kalir.
            new("poliklinik",
                "coalesce((select d.ad from public.belge_basvuru bb " +
                "            join public.departman d on d.id = bb.bolum_id " +
                "           where bb.id = b.id), " +
                "         (select d.ad from public.randevu r " +
                "            join public.departman d on d.id = r.bolum " +
                "           where r.belge_id = b.id order by r.id limit 1), '')",
                                                      "metin", "Bölüm", Genislik: 150,
                                                      Varsayilan: false, Siralanabilir: false,
                                                      Filtrelenebilir: false),
            new("doktor",
                "coalesce((select hk.unvan from public.belge_basvuru bb " +
                "            join public.taraf hk on hk.id = bb.personel_id " +
                "           where bb.id = b.id), " +
                "         (select hk.unvan from public.randevu r " +
                "            join public.taraf hk on hk.id = r.hekim_id " +
                "           where r.belge_id = b.id order by r.id limit 1), '')",
                                                      "metin", "Doktor", Genislik: 160,
                                                      Varsayilan: false, Siralanabilir: false,
                                                      Filtrelenebilir: false),
            // BASVURU TAMAMLANMA YUZDESI (kullanici: liste kolonu "%"). Kart
            //   uzerindeki tamamlanma seridinin (370) AYNI kurallari - hesap
            //   iki yerde ayri yazilmasin diye asama tanimi birebir taşındı
            //   (web: belgeKarti/basvuruAsamalari.ts):
            //     Basvuru      - kayit var (listedeki her satir)
            //     Provizyon    - YALNIZ OSS(2)/SGK(3) akisinda; durum 1 ya da 3
            //     Ucretlendirme- genel toplam > 0
            //     Tahsilat     - ucret var ve acik borc <= 0,005 (kurus artigi)
            //     Faturalama   - kapanma_durum = 2
            //   Yuzde CIZILEN asamalardan hesaplanir: provizyonsuz kurumda
            //   (Ozel) asama sayisi 4, otekilerde 5 - kullanilmayan asama
            //   yuzdeyi asagi cekmemeli.
            new("tamamlanma",
                """
                (
                  select round(100.0 * (
                           1
                         + case when b.genel_toplam > 0 then 1 else 0 end
                         + case when b.genel_toplam > 0
                                 and b.genel_toplam - coalesce((
                                       select sum(ki.tutar) from public.kasa_islem ki
                                        where ki.belge_id = b.id and ki.durum = 2), 0) <= 0.005
                                then 1 else 0 end
                         + case when coalesce(b.kapanma_durum, 0) = 2 then 1 else 0 end
                         + case when k.tur in (2, 3)
                                 and (case when k.tur = 2 then bp.oss_durum else bp.sgk_durum end)
                                     in (1, 3)
                                then 1 else 0 end
                         ) / case when k.tur in (2, 3) then 5 else 4 end)
                    from public.belge_basvuru bb2
                    left join public.taraf_kurum k on k.id = bb2.odeyen_kurum_id
                    left join public.belge_provizyon bp on bp.id = b.id
                   where bb2.id = b.id
                )
                """,                              "sayi", "Tamamlanma", Hizalama: "sag",
                                                  Bicim: "yuzde", Genislik: 110,
                                                  Varsayilan: false),
            // TAHSILAT DURUMU (kullanici: serit "Tahsilat" combosu):
            //   0 yok · 1 kismi · 2 tamamlandi. Kolonun kendisi gorunmez -
            //   listede zaten Tahsilat TUTARI var; bu yalniz suzme icin.
            //   Esik tamamlanma seridiyle AYNI: kurusun altindaki fark
            //   kapanmis sayilir (yuvarlama artigi "kismi" gostermesin).
            new("tahsilatDurum",
                """
                case
                  when coalesce((select sum(ki.tutar) from public.kasa_islem ki
                                  where ki.belge_id = b.id and ki.durum = 2), 0) <= 0 then 0
                  when b.genel_toplam - coalesce((select sum(ki.tutar) from public.kasa_islem ki
                                  where ki.belge_id = b.id and ki.durum = 2), 0) <= 0.005 then 2
                  else 1
                end
                """,                              "sayi", "Tahsilat Durumu",
                                                  Hizalama: "orta", Varsayilan: false),
            // BASVURU SERIT SUZGECLERI icin HAM ID'ler (kullanici: "Odeyen
            //   combo, bolum agac combo, Doktor combo"). Adlar metin kolonu
            //   olarak zaten var ama filtre ADA gore calisamaz: ayni adli iki
            //   kurum ya da unvan degisikligi filtreyi kaydirirdi. Gorunur
            //   kolon degil - yalniz suzme icin (gizliKolonlar'da da tutulur).
            //   Ada cozen kolonlarla AYNI kaynaklardan okunur: once belgenin
            //   kendi basvuru satiri, yoksa belgeye bagli randevu.
            // HASTA (658): dis kurum numunesinde CARI gonderen kurumdur,
            //   hasta ayri alanda durur - "basvuruda hasta adi yok"
            //   (kullanici). Normal basvuruda ayni kisiyi gosterir.
            //   HASTA_ID BOSSA BELGENIN TARAFI (kullanici: "basvuru listesinde
            //   4056 ID ad soyad gorunmuyor"): normal basvuruda hasta zaten
            //   belgenin tarafidir ve `belge_basvuru.hasta_id` yalniz DIS KURUM
            //   akisinda ayri doldurulur - bos kalan 8 eski satirda kolon bos
            //   goruniyordu. Yedek kaynak HASTA OLAN tarafla sinirli: dis kurum
            //   numunesinde cari GONDEREN KURUMDUR, onun adini "hasta" diye
            //   yazmak yanlis bilgi olurdu.
            new("hastaAdi",
                "coalesce((select coalesce(nullif(trim(h.unvan), ''), " +
                "                  trim(h.ad || ' ' || h.soyad)) " +
                "            from public.belge_basvuru bb " +
                "            join public.taraf h on h.id = bb.hasta_id " +
                "           where bb.id = b.id), " +
                "         (select coalesce(nullif(trim(t2.unvan), ''), " +
                "                  trim(t2.ad || ' ' || t2.soyad)) " +
                "            from public.taraf t2 " +
                "           where t2.id = b.taraf_id " +
                "             and (t2.hasta = 1 or t2.grup = 101)))",
                                                      "metin", "Hasta", Genislik: 200,
                                                      Siralanabilir: false),
            new("hastaId",
                "coalesce((select bb.hasta_id from public.belge_basvuru bb where bb.id = b.id), " +
                "         (select t3.id from public.taraf t3 where t3.id = b.taraf_id " +
                "            and (t3.hasta = 1 or t3.grup = 101)))",
                                                      "sayi", "Hasta Id",
                                                      Varsayilan: false, Siralanabilir: false),
            new("odeyenKurumId",
                "(select bb.odeyen_kurum_id from public.belge_basvuru bb " +
                "  where bb.id = b.id)",
                                                      "sayi", "Ödeyen Kurum Id",
                                                      Varsayilan: false, Siralanabilir: false),
            // SOZLESME / ALT KURUM / SGK KATKISI (469): odeme rotasinin
            //   girdileri. Kart bunlari okuyup yaziyor; listede gorunur kolon
            //   degiller ama kart acilirken deger buradan gelir.
            new("sozlesmeId",
                "(select bb.sozlesme_id from public.belge_basvuru bb where bb.id = b.id)",
                                                      "sayi", "Sözleşme Id",
                                                      Varsayilan: false, Siralanabilir: false),
            new("altKurum",
                "(select bb.alt_kurum from public.belge_basvuru bb where bb.id = b.id)",
                                                      "kod", "Alt Kurum",
                                                      Varsayilan: false, Siralanabilir: false),
            new("sgkKullan",
                "(select bb.sgk_kullan from public.belge_basvuru bb where bb.id = b.id)",
                                                      "mantik", "SGK Katkısı",
                                                      Varsayilan: false, Siralanabilir: false),
            new("altKurumAdi",
                "coalesce((select d.ad from public.belge_basvuru bb " +
                "            join public.kod_deger d on d.deger = bb.alt_kurum and d.dil = 0 " +
                "            join public.kod_liste l on l.id = d.liste_id " +
                "                                   and l.kod = 'kurum.alt_kurum' " +
                "           where bb.id = b.id), '')",
                                                      "metin", "Poliçe / Alt Kurum",
                                                      Hizalama: "orta", Bicim: "rozet",
                                                      Genislik: 150, Varsayilan: false,
                                                      Filtrelenebilir: false),
            new("bolumId",
                "coalesce((select bb.bolum_id from public.belge_basvuru bb " +
                "           where bb.id = b.id), " +
                "         (select r.bolum from public.randevu r " +
                "           where r.belge_id = b.id order by r.id limit 1))",
                                                      "sayi", "Bölüm Id",
                                                      Varsayilan: false, Siralanabilir: false),
            new("doktorId",
                "coalesce((select bb.personel_id from public.belge_basvuru bb " +
                "           where bb.id = b.id), " +
                "         (select r.hekim_id from public.randevu r " +
                "           where r.belge_id = b.id order by r.id limit 1))",
                                                      "sayi", "Doktor Id",
                                                      Varsayilan: false, Siralanabilir: false),
            // TAHSILAT (basvuru listesi): belgeye baglanmis kasa islemlerinin
            //   toplami - hasta pesin oderse "ne kadari tahsil edildi" genel
            //   toplamin yaninda okunur.
            //   YALNIZ GERCEKLESEN sayilir (kasa_islem.durum = 2): 0 taslak ve
            //   1 planli henuz para degil, 3 iptal edilmis. Kolon "tahsil
            //   edilen tutar" demek - plani da toplayan bir sayi yaniltir.
            new("tahsilat",
                "coalesce((select sum(ki.tutar) from public.kasa_islem ki " +
                "           where ki.belge_id = b.id and ki.durum = 2), 0)",
                                                      "para", "Tahsilat", Hizalama: "sag",
                                                      Genislik: 120, Varsayilan: false,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            // ODEME PAYLARI (kullanici: "hasta / ÖSS / SUT toplamları - istatistik
            //   alırken kolay olur mu"). Fiziksel kolon ACILMADI: uc rakam da
            //   `belge_satir_dagilim` kovalarinin toplamidir - belgede kopyasini
            //   tutmak, her satir/dagilim/provizyon/tahsilat degisiminde tetikle
            //   senkron tutulacak TURETILMIS veri demek; bir yol kacarsa
            //   istatistik sessizce yanlis cikar. Liste burada TOPLAR: grid,
            //   suzgec, CSV ve analiz sekmesi aynI rakami kullanir.
            //
            //   KDV DAHIL: kovalar matrahtir, listedeki Genel Toplam ise brut -
            //   yan yana okunan iki rakam ayni dilde olsun (serit de boyle, 589).
            //   Uc kolon ayni desende: satirin kovasi x (1 + kdv/100).
            new("hastaPayi",
                // Kurus artigi temizlenir: matrahi brutlestirmek 200,002 gibi
                //   sayilar uretiyor (0,0909... x 11) - listede iki hane yazar.
                // SGK KATILIM PAYI KDV'SIZ EKLENIR (593, kullanici: "açık
                //   tahsilatta 850 olması gerekirken 860 yazıyor, SGK katılıma
                //   KDV mi ekliyor?"): ciro disi EMANET, ayardaki sabit tutar -
                //   uzerine KDV binmez, kovada oldugu gibi durur.
                "coalesce(round((select sum((dg.hasta_provizyon + dg.hasta_ek_katki) " +
                "                     * (1 + coalesce(bs.kdv, 0) / 100.0) " +
                "                   + dg.sgk_katilim_payi) " +
                "            from public.belge_satir bs " +
                "            join public.belge_satir_dagilim dg on dg.belge_satir_id = bs.id " +
                "           where bs.belge_id = b.id), 2), 0)",
                                                      "para", "Hasta Payı", Hizalama: "sag",
                                                      Bicim: "#,##0.00", Genislik: 120,
                                                      Varsayilan: false, Siralanabilir: false,
                                                      Filtrelenebilir: false),
            new("ossPayi",
                "coalesce(round((select sum(dg.oss * (1 + coalesce(bs.kdv, 0) / 100.0)) " +
                "            from public.belge_satir bs " +
                "            join public.belge_satir_dagilim dg on dg.belge_satir_id = bs.id " +
                "           where bs.belge_id = b.id), 2), 0)",
                                                      "para", "Sigorta (ÖSS/TSS)", Hizalama: "sag",
                                                      Bicim: "#,##0.00", Genislik: 130,
                                                      Varsayilan: false, Siralanabilir: false,
                                                      Filtrelenebilir: false),
            new("sgkPayi",
                "coalesce(round((select sum(dg.sgk * (1 + coalesce(bs.kdv, 0) / 100.0)) " +
                "            from public.belge_satir bs " +
                "            join public.belge_satir_dagilim dg on dg.belge_satir_id = bs.id " +
                "           where bs.belge_id = b.id), 2), 0)",
                                                      "para", "SGK (SUT)", Hizalama: "sag",
                                                      Bicim: "#,##0.00", Genislik: 120,
                                                      Varsayilan: false, Siralanabilir: false,
                                                      Filtrelenebilir: false),
            new("tarafVkno",     "b.taraf_vkno",     "metin", "Vergi/Kimlik No",    Genislik: 120, Varsayilan: false),
            new("matrah",        "b.matrah",         "para",  "Matrah",      Hizalama: "sag",
                                                                Bicim: "#,##0.00", Genislik: 120),
            new("kdvTutari",     "b.kdv_tutari",     "para",  "KDV",         Hizalama: "sag",
                                                                Bicim: "#,##0.00", Genislik: 110),
            new("genelToplam",   "b.genel_toplam",   "para",  "Genel Toplam",Hizalama: "sag",
                                                                Bicim: "#,##0.00", Genislik: 130),
            new("acikKapaliAdi",
                "case when coalesce(b.acik_kapali, 0) = 1 then 'Kapalı' else 'Açık' end",
                                                  "metin", "Açık / Kapalı", Hizalama: "orta",
                                                  Bicim: "rozet", Genislik: 110,
                                                  Varsayilan: false, Filtrelenebilir: false),
            new("acikKapali",    "b.acik_kapali",    "kod",   "Açık/Kapalı Kodu", Hizalama: "orta",
                                                                            Varsayilan: false),
            new("durumAdi",
                """
                case coalesce(b.durum, 0)
                     when 0 then 'Kesin' when 1 then 'Taslak' when 2 then 'İptal'
                     else 'Bilinmiyor' end
                """,                             "metin", "Durum", Hizalama: "orta",
                                                 Bicim: "rozet", Genislik: 100,
                                                 Filtrelenebilir: false),
            new("durum",         "b.durum",          "kod",   "Durum Kodu",  Hizalama: "orta",
                                                                            Varsayilan: false),
            // Teklif durumu (218) - teklif listesinin cipleri/guard'i icin.
            new("teklifKonusu",  "b.teklif_konusu",  "metin", "Konusu",      Genislik: 150,
                                                                            Varsayilan: false),
            // Ham e-Belge kodu (230): ÜTS verme secim listesi "hazirlanmis/
            //   gonderilmis" suzmesi icin filtrelenebilir sayi (gorunen
            //   'efaturaDurum' CASE metni filtrelenemiyor).
            new("efaturaKodu",   "coalesce(b.efatura_durum, 0)",
                                                 "sayi", "e-Belge Kodu", Hizalama: "orta",
                                                 Varsayilan: false, Siralanabilir: false),
            // ÜTS bildirim rozeti (230): verme secim listesi ve fatura listesi.
            new("utsDurumAdi",
                "case b.uts_durum when 2 then 'Bildirildi' when 1 then 'Kısmi' " +
                "else 'Bildirilmedi' end",
                                                 "metin", "ÜTS", Hizalama: "orta",
                                                 Bicim: "rozet", Genislik: 100,
                                                 Varsayilan: false, Filtrelenebilir: false),
            new("utsDurum",      "b.uts_durum",      "kod",   "ÜTS Kodu",    Hizalama: "orta",
                                                                            Varsayilan: false),
            new("teklifDurum",   "b.teklif_durum",   "kod",   "Teklif Durum Kodu",
                Hizalama: "orta", Varsayilan: false),
            new("teklifDurumAdi",
                """
                case coalesce(b.teklif_durum, 1)
                     when 1 then 'Hazırlanıyor' when 2 then 'Sunuldu' when 3 then 'Kabul'
                     when 4 then 'Red' when 5 then 'İptal' else '' end
                """,                            "metin", "Durumu", Hizalama: "orta",
                                                 Bicim: "rozet", Genislik: 110,
                                                 Filtrelenebilir: false),
            new("vadeGun",       "b.vade_gun",       "sayi",  "Vade",        Hizalama: "sag", Genislik: 80,
                                                                Varsayilan: false),
            new("aciklama",      "b.aciklama",       "metin", "Açıklama",    Genislik: 240, Varsayilan: false),
            // Alan yetkisine ornek: rol_alan_yetki'de 'belge.maliyetOrt' izin 0 ise
            //   bu kolon yanittan CIKARILIR ve /kolonlar listesinde de gorunmez.
            new("maliyetOrt",    "b.maliyet_ort",    "para",  "Ort. Maliyet",Hizalama: "sag",
                                                                            Bicim: "#,##0.0000", Varsayilan: false),
            new("subeAdi",       "coalesce(sb.ad, '')", "metin", "Şube",     Genislik: 120,
                                                                            Varsayilan: false),
            new("subeId",        "b.sube_id",        "sayi",  "Şube Kodu",   Varsayilan: false),
            // MUHASEBE FISI (190): belge muhasebeye girdi mi tek bakista gorunsun.
            //   Bos ise fis yok - "Fişi Aç" aksiyonu da pasif kalir.
            new("fisNo",         "coalesce(mf.fis_no, '')", "metin", "Fiş No",
                                                      Hizalama: "orta", Genislik: 110, Varsayilan: false),
            new("fisId",         "coalesce(b.muhasebe_fis_id, 0)", "sayi", "Fiş Id", Varsayilan: false),
            // DONUSUM ZINCIRI (F8) ID'leri: "Kaynak/Hedef Belgeyi Aç" aksiyonlari
            //   metin kolonundan id cikaramaz. Hedef birden fazla olabilir -
            //   EN ESKI hedef acilir (zincirde bir sonraki adim).
            new("kaynakId",      "coalesce(b.kaynak_id, 0)", "sayi", "Kaynak Id", Varsayilan: false),
            new("hedefId",
                "coalesce((select min(hs.belge_id) from public.belge_satir hs " +
                "            join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30 " +
                "            join public.belge hb on hb.id = hs.belge_id " +
                "           where ks.belge_id = b.id and hb.durum <> 2), 0)",
                                                      "sayi", "Hedef Id", Varsayilan: false)
        });

    // ----------------------------------------------------------- personel ----

    // ---------------------------------------------------------- irsaliye ----
    // Ekranlar/satis_irsaliye_listesi.html kolonlariyla BIREBIR. Ayni `belge`
    //   tablosu ama AYRI kaynak: irsaliye listesi sevkiyat odakli (arac/sofor,
    //   cikis deposu, kaynak siparis, faturalama durumu) - bu kolonlari genel
    //   belge listesine eklemek onu 20 kolonluk bir seye cevirirdi.
    private static KaynakTanimi Irsaliye() => new(
        Ad: "irsaliye",
        YetkiKodu: "belge",
        Kaynak: """
            public.belge b
            left join public.depo  cd on cd.id = b.cikis_depo_id
            join public.v_belge_sevkiyat sv on sv.belge_id = b.id
            left join public.taraf te on te.id = sv.teslim_eden_id
            left join public.taraf sc on sc.id = b.satici_id
            left join public.belge kb on kb.id = b.kaynak_id and b.kaynak_tur = 30
            left join public.kasa_islem_turu kt2 on kt2.kod = kb.tur
            """,
        SabitKosul: "b.tur in (10, 14, 109, 119)",
        SubeKolonu: "b.sube_id",
        KapsamKolonu: "b.taraf_id",
        VarsayilanSirala: "b.belge_tarihi desc, b.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",            "b.id",             "sayi",  "Id",        Varsayilan: false),
            // Liste katmaninda kod_liste cozumu YOK (yalniz kartta var); bu yuzden
            //   kullaniciya gorunen kolonlar SQL'de metne cevrilir, ham kodlar gizli
            //   kalir (cip filtreleri onlari kullanir).
            //
            // TIP kolonu YOK: mockup SVK/NUM/IPT gosteriyor ama gocten gelen
            //   `belge.tipi` 10 farkli deger tasiyor (415 kaydin hepsi "1") ve anlami
            //   belgesiz. Ekran zaten YALNIZ satis irsaliyelerini gosterdigi icin her
            //   satirda ayni kisaltmayi tekrarlamanin bilgi degeri de yoktu.
            new("tipi",          "b.tipi",           "sayi",  "Tip Kodu",  Hizalama: "orta", Varsayilan: false),
            new("belgeNo",       "b.belge_no",       "metin", "İrsaliye No", Genislik: 155),
            // e-IRSALIYE DURUMU (kullanici: "irsaliye no saginda gidip gitmedigini
            //   anlayayim"). Kodlar e-Belge turune gore ayri: e-Irsaliye 51
            //   hazirlandi / 52 gonderildi. Eskiden burada FATURA kodlari (1/2/3/4)
            //   yaziyordu - hazirlanmis irsaliye "Kağıt" gorunuyordu.
            new("eIrsaliye",
                """
                case coalesce(b.efatura_durum, 0)
                     when 0  then 'Kağıt'
                     when 51 then 'e-İrsaliye'
                     when 52 then 'e-İrsaliye ✓'
                     when 53 then 'Kabul'
                     when 54 then 'Red'
                     else 'Bilinmiyor' end
                """,                                 "metin", "e-İrsaliye", Hizalama: "orta",
                                                      Bicim: "rozet", Genislik: 120,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("belgeTarihi",   "b.belge_tarihi",   "tarih", "Tarih",     Hizalama: "orta",
                                                      Bicim: "dd.MM.yyyy HH:mm", Genislik: 130),
            new("tarafUnvan",    "b.taraf_unvan",    "metin", "Müşteri",   Genislik: 220),
            new("cikisDepo",     "cd.ad",            "metin", "Çıkış Deposu"),
            // KAYNAK / HEDEF: F8 donusum zincirinin iki ucu. Kaynak baslik bagindan
            //   (belge.kaynak_id) okunur; hedef ise SATIR bagindan turetilir -
            //   bir irsaliye birden fazla faturaya bolunebilir, o yuzden distinct
            //   belge numaralari birlestirilir. Iptal (durum=2) hedefler sayilmaz.
            new("kaynak",
                "case when kb.id is null then '' " +
                "else coalesce(kt2.ad, '') || case when kb.belge_no <> '' " +
                "then ' ' || kb.belge_no else '' end end",
                                                      "metin", "Kaynak",    Genislik: 170,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("hedef",
                // Bir belge BIRDEN COK ve FARKLI TURDE hedefe bolunebilir (bir
                //   kismi faturaya, kalani tahakkuka): hepsi virgulle yazilir.
                //   Numarasi verilmemis hedefte YALNIZ tur adi gorunur - eski
                //   ifade "Satış İrsaliyesi 0" yaziyordu. Siralama tur+no ile
                //   sabit: string_agg sirasiz calisir, ayni belge her acilista
                //   farkli sirada gorunuyordu.
                "coalesce((select string_agg(distinct trim(coalesce(ht.ad, '') || ' ' || " +
                "                            case when coalesce(hb.belge_no, '') in ('', '0') " +
                "                                 then '' else hb.belge_no end), ', ' " +
                "                            order by trim(coalesce(ht.ad, '') || ' ' || " +
                "                                     case when coalesce(hb.belge_no, '') in ('', '0') " +
                "                                          then '' else hb.belge_no end)) " +
                "            from public.belge_satir hs " +
                "            join public.belge_satir ks on ks.id = hs.kaynak_id and hs.kaynak_tur = 30 " +
                "            join public.belge hb on hb.id = hs.belge_id " +
                "            left join public.kasa_islem_turu ht on ht.kod = hb.tur " +
                "           where ks.belge_id = b.id and hb.durum <> 2), '')",
                                                      "metin", "Hedef",     Genislik: 190,
                                                      Siralanabilir: false, Filtrelenebilir: false),
            new("kaynakBelgeNo", "kb.belge_no",      "metin", "Kaynak Belge No", Varsayilan: false),
            // Plaka ve sofor tek kolonda: mockup "07 ABC 145 / Hasan Celik" gosteriyor.
            new("aracSofor",
                "case when btrim(sv.arac_plaka || sv.sofor_ad) = '' then '' " +
                "else btrim(sv.arac_plaka) || " +
                "case when sv.sofor_ad <> '' then ' / ' || sv.sofor_ad else '' end end",
                                                      "metin", "Araç / Şoför", Genislik: 170,
                                                      Varsayilan: false),
            // Teslim eden bos ise satis temsilcisi gosterilir (mockup'taki davranis).
            new("teslimEden",    "coalesce(te.unvan, sc.unvan)", "metin", "Teslim Eden",
                                                      Varsayilan: false),
            // Faturalama durumu GIZLI: Hedef kolonu zaten hangi faturaya donustugunu
            //   (ya da donusmedigini) gosteriyor; ikisi ayni bilgiyi tekrarliyordu.
            //   Cip filtreleri kapanmaDurum uzerinden calismaya devam eder.
            new("faturalama",
                "case b.kapanma_durum when 2 then 'Faturalandı' when 1 then 'Kısmi' else 'Faturalanmadı' end",
                                                      "metin", "Faturalama", Hizalama: "orta",
                                                      Varsayilan: false),
            new("kapanmaDurum",  "b.kapanma_durum",  "sayi",  "Faturalama Kodu", Hizalama: "orta", Varsayilan: false),
            new("efaturaDurum",  "b.efatura_durum",  "sayi",  "e-Belge Kodu", Hizalama: "orta", Varsayilan: false),
            // Miktar GIZLI: satir-basi alt sorgu (her satirda bir belge_satir taramasi)
            //   ve irsaliyede farkli birimler (adet/kg/metre) toplanip tek sayi olarak
            //   gosterildiginde yaniltici. Kolon seciciden acilabilir.
            new("miktar",
                "(select coalesce(sum(s.miktar), 0) from public.belge_satir s where s.belge_id = b.id)",
                                                      "para",  "Miktar",    Hizalama: "sag", Bicim: "#,##0.##",
                                                      Siralanabilir: false, Filtrelenebilir: false,
                                                      Varsayilan: false),
            new("genelToplam",   "b.genel_toplam",   "para",  "Tutar",     Hizalama: "sag", Bicim: "#,##0.00"),
            new("teslimSekli",
                "case sv.teslim_sekli when 1 then 'Alıcı adresine teslim' when 2 then 'Alıcı kendi aracıyla' " +
                "when 3 then 'Kargo / nakliye' when 4 then 'Depoda teslim' when 5 then 'Yurt dışı sevk' " +
                "else 'Belirtilmemiş' end",
                                                      "metin", "Teslim Şekli", Hizalama: "orta", Varsayilan: false),
            new("irsaliyeTarihi","b.irsaliye_tarihi","tarih", "Sevk Zamanı", Hizalama: "orta",
                                                      Bicim: "dd.MM.yyyy HH:mm", Varsayilan: false),
            new("aracPlaka",     "sv.arac_plaka",    "metin", "Plaka",     Varsayilan: false),
            new("soforAd",       "sv.sofor_ad",      "metin", "Şoför",     Varsayilan: false),
            new("tur",           "b.tur",            "sayi",  "Tür Kodu",  Hizalama: "orta", Varsayilan: false),
            new("durumAdi",      "case b.durum when 1 then 'Taslak' when 2 then 'İptal' else 'Kesin' end",
                                                      "metin", "Durum",     Hizalama: "orta"),
            new("durum",         "b.durum",          "sayi",  "Durum Kodu", Hizalama: "orta", Varsayilan: false),
            new("subeId",        "b.sube_id",        "sayi",  "Şube",      Varsayilan: false)
        });

    // -------------------------------------------------------------- depo ----
    // Belge kartinda cikis/giris deposu ADIYLA secilir (GenLookup kaynagi).

    // ------------------------------------------------------------ e-belge ----
    private static KaynakTanimi EBelge() => new(
        Ad: "e-belge",
        YetkiKodu: "e_belge",
        Kaynak: "public.e_belge e left join public.taraf t on t.id = e.taraf_id",
        SubeKolonu: "e.sube_id",
        VarsayilanSirala: "e.ekleme_tarihi desc, e.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",             "e.id",               "sayi",  "Id",        Varsayilan: false),
            new("eklemeTarihi",   "e.ekleme_tarihi",    "tarih", "Tarih",     Hizalama: "orta", Bicim: "dd.MM.yyyy"),
            new("belgeTuru",      "e.belge_turu",       "kod",   "Belge Turu", Hizalama: "orta"),
            new("yon",            "e.yon",              "kod",   "Yon",       Hizalama: "orta"),
            new("belgeNo",        "e.belge_no",         "metin", "Belge No"),
            new("tarafUnvan",     "t.unvan",            "metin", "Cari"),
            new("gondericiVkno",  "e.gonderici_vkno",   "metin", "Gonderici VKN", Varsayilan: false),
            new("durum",          "e.durum",            "kod",   "Durum",     Hizalama: "orta"),
            new("gibDurumKodu",   "e.gib_durum_kodu",   "metin", "GIB Kodu",  Varsayilan: false),
            new("servisDurumAdi", "e.servis_durum_adi", "metin", "Servis Durumu"),
            new("uuid",           "e.uuid",             "metin", "UUID",      Varsayilan: false)
        });

    // ---------------------------------------------------------- islem log ----
    // UInfo karsiligi. islem_log tarihe gore BOLUMLENMIS: varsayilan siralama
    //   tarih desc oldugu icin son kayitlar ilk bolumden gelir.
    //
    // islem_tipi ve tablo_id ham sayisal kodlar (Gentegre.Veri.Depolar.LogIslemi /
    //   KartTanimi.LogTabloId) - burada okunabilir metne cevriliyor ki UInfo gibi
    //   kullanici "2/71" degil "Degisiklik/Cari" gorsun.
    //
    // Kod/Ad (eski LOGCOZUM karsiligi): tablo_id'ye gore DOGRU tabloya (taraf/stok/
    //   belge/rol) LEFT JOIN ile kayit_id cozulur. Yalniz kart-seviyeli tablolar
    //   (71/73 taraf, 88 stok, 30 belge, 903 rol) cozulur - detay satirlari (adres,
    //   barkod, fiyat, izin, egitim... 340-907 arasi) icin Kod/Ad bos kalir; kayit
    //   silinmisse de (join eslesmez) bos kalir - "bilgi" JSON'daki anlik degerler
    //   burada kullanilmaz, cunku alan adlari tabloya gore degisir (tek SQL'de
    //   duzgun genellenemez).

    // ------------------------------------------------- acik belge satirlari ----
    // "Hangi siparislerin nesi teslim edilmedi" raporu. Donusum ekrani ayri bir
    //   uctan (GET /api/belge/{id}/acik-satirlar) okur; bu liste genel gorunum.
    private static KaynakTanimi BelgeAcikSatir() => new(
        Ad: "belge-acik-satir",
        YetkiKodu: "belge",
        Kaynak: "public.v_belge_acik_satir a",
        SubeKolonu: "a.sube_id",
        KapsamKolonu: "a.taraf_id",
        VarsayilanSirala: "a.belge_tarihi asc, a.belge_id asc, a.sira asc",
        Kolonlar: new KolonTanimi[]
        {
            new("satirId",         "a.satir_id",         "sayi",  "Satır Id", Varsayilan: false),
            new("belgeId",         "a.belge_id",         "sayi",  "Belge Id", Varsayilan: false),
            new("belgeTurAdi",     "a.belge_tur_adi",    "metin", "Belge Türü"),
            new("belgeTur",        "a.belge_tur",        "sayi",  "Tür Kodu", Hizalama: "orta", Varsayilan: false),
            new("belgeNo",         "a.belge_no",         "metin", "Belge No"),
            new("belgeTarihi",     "a.belge_tarihi",     "tarih", "Tarih",    Hizalama: "orta", Bicim: "dd.MM.yyyy HH:mm"),
            new("tarafUnvan",      "a.taraf_unvan",      "metin", "Cari",     Genislik: 220),
            new("stokKodu",        "a.stok_kodu",        "metin", "Stok Kodu"),
            new("stokAdi",         "a.stok_adi",         "metin", "Stok",     Genislik: 240),
            new("aciklama",        "a.aciklama",         "metin", "Açıklama", Varsayilan: false),
            new("miktar",          "a.miktar",           "para",  "Miktar",   Hizalama: "sag", Bicim: "#,##0.##"),
            new("kapatilanMiktar", "a.kapatilan_miktar", "para",  "Dönüşen",  Hizalama: "sag", Bicim: "#,##0.##"),
            new("kalanMiktar",     "a.kalan_miktar",     "para",  "Kalan",    Hizalama: "sag", Bicim: "#,##0.##"),
            new("birimFiyat",      "a.birim_fiyat",      "para",  "Birim Fiyat", Hizalama: "sag", Bicim: "#,##0.00", Varsayilan: false),
            new("belgeDovizi",     "a.belge_dovizi",     "metin", "Döviz",    Hizalama: "orta", Varsayilan: false),
            new("kapanmaDurum",    "a.kapanma_durum",    "kod",   "Kapanma",  Hizalama: "orta", Varsayilan: false),
            new("subeId",          "a.sube_id",          "sayi",  "Şube",     Varsayilan: false)
        });

    // ------------------------------------------------------- gelen belge ----
    // KUTU (187): bize kesilen e-Fatura/e-Arsiv belgeleri. Ayni `e_belge`
    //   tablosu, yon = 2. Liste kutu odakli: kim gonderdi, ne kadar, yanit
    //   verildi mi. Giden belgelerle karistirmamak icin AYRI kaynak.
    private static KaynakTanimi GelenBelge() => new(
        Ad: "gelen-belge",
        YetkiKodu: "belge",
        Kaynak: """
            public.e_belge e
            left join public.taraf t on t.id = e.taraf_id
            """,
        SabitKosul: "e.yon = 2",
        SubeKolonu: "e.sube_id",
        KapsamKolonu: "e.taraf_id",
        VarsayilanSirala: "e.belge_tarihi desc nulls last, e.id desc",
        Kolonlar: new KolonTanimi[]
        {
            new("id",              "e.id",                "sayi",  "Id",       Varsayilan: false),
            new("belgeNo",         "e.belge_no",          "metin", "Belge No", Genislik: 175),
            new("belgeTuruAdi",    "public.fn_ebelge_tur_adi(e.belge_turu)",
                                                          "metin", "Tür",      Hizalama: "orta",
                                                           Bicim: "rozet", Genislik: 105,
                                                           Siralanabilir: false, Filtrelenebilir: false),
            new("durumAdi",        "public.fn_gelen_durum_adi(e.durum)",
                                                          "metin", "Durum",    Hizalama: "orta",
                                                           Bicim: "rozet", Genislik: 125,
                                                           Siralanabilir: false, Filtrelenebilir: false),
            new("belgeTarihi",     "e.belge_tarihi",      "tarih", "Tarih",    Hizalama: "orta",
                                                           Bicim: "dd.MM.yyyy", Genislik: 105),
            // Gonderici carimiz degilse taraf bos kalir - JSON'dan gelen unvan gosterilir.
            new("gondericiUnvan",  "coalesce(nullif(t.unvan, ''), e.gonderici_unvan)",
                                                          "metin", "Gönderici", Genislik: 260),
            new("gondericiVkno",   "e.gonderici_vkno",    "metin", "Vergi/Kimlik No", Hizalama: "orta", Genislik: 115),
            new("tutar",           "e.tutar",             "para",  "Tutar",    Hizalama: "sag",
                                                           Bicim: "#,##0.00", Genislik: 125),
            new("vergiTutar",      "e.vergi_tutar",       "para",  "KDV",      Hizalama: "sag",
                                                           Bicim: "#,##0.00", Genislik: 115, Varsayilan: false),
            new("paraBirimi",      "e.para_birimi",       "metin", "Döviz",    Hizalama: "orta",
                                                           Genislik: 70, Varsayilan: false),
            new("profil",          "e.profil",            "metin", "Profil",   Hizalama: "orta", Genislik: 130),
            new("okunduAdi",       "case when e.okundu = 1 then 'Okundu' else 'Yeni' end",
                                                          "metin", "Okundu",   Hizalama: "orta",
                                                           Genislik: 90, Siralanabilir: false,
                                                           Filtrelenebilir: false, Varsayilan: false),
            new("yanitAciklama",   "e.yanit_aciklama",    "metin", "Yanıt Notu", Varsayilan: false),
            new("gibAciklama",     "e.gib_durum_aciklama", "metin", "GİB Durumu", Varsayilan: false),
            new("durum",           "e.durum",             "sayi",  "Durum Kodu", Varsayilan: false),
            new("belgeTuru",       "e.belge_turu",        "sayi",  "Tür Kodu", Varsayilan: false),
            new("tarafId",         "e.taraf_id",          "sayi",  "Cari Id",  Varsayilan: false),
            new("subeId",          "e.sube_id",           "sayi",  "Şube",     Varsayilan: false)
        });
}
