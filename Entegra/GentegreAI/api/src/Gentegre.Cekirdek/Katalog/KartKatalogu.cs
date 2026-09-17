namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Kart alani. Yazilabilir olmayan alanlar istek govdesinde gelse bile YOK SAYILMAZ -
/// hata verilir (API §3.2: sessizce yok saymak yok).
/// </summary>
public sealed record KartAlani(
    string Ad,                     // API adi: "faturaUnvan"
    string Kolon,                  // db kolonu: "fatura_unvan"
    string Tip,                    // metin | sayi | ondalik | para | tarih | zaman | kod | mantik
    bool Yazilabilir = true,
    bool Zorunlu = false,
    int? EnFazlaUzunluk = null,
    string? KodListesi = null,     // kod_liste.kod - kodAd sozlugu bundan cozulur
    IReadOnlyDictionary<string, string>? SabitKodlar = null,  // kod listesi DB'de yoksa
    // Kendi tablosu olan (kod_liste/kod_deger'e uymayan) secim kaynagi: "public.kategori".
    //   Tam secenek listesi VeriDeposu.KodTablosuBeyazListe'de whitelist'li tablolardan
    //   "select id, ad from <tablo> where aktif = 1 order by ad" ile cekilir.
    string? KodTablosu = null,
    // BAGLI SECIM: bu alanin secenekleri baska bir alanin degerine gore SUZULUR
    //   (or. Şube -> BagliAlan "bankaId"). Gorunum ust_id kolonunu doner; kart
    //   yalniz ust_id = secili ust olan satirlari gosterir. Ust degisince, artik
    //   gecerli olmayan alt deger TEMIZLENIR - yoksa "Ziraat + Akbank subesi"
    //   gibi tutarsiz kayit olusur.
    string? BagliAlan = null,
    // AGAC SECIMI (484, kullanici: "kategori combo yerine agac combo olmali").
    //   Secim kaynagi HIYERARSIK (kategori: "Radyoloji > BT > Beyin"). Duz
    //   listede yalniz yaprak adi gorunuyordu; ayni adi tasiyan iki dal
    //   ("Genel" hem Lab hem Radyoloji altinda) ayirt edilemiyordu.
    //   Bayrak varsa arayuz secenekleri AGAC SIRASINDA ve GIRINTILI cizer;
    //   veri yine tek id'dir. Gorunumun/tablonun `ust_id` kolonu olmali -
    //   `BagliAlan` ile ayni haritadan beslenir.
    bool Agac = false,
    // UST BILGISI (587): secenek -> ust haritasi metaya konur ama secenekler
    //   SUNUCUDA suzulmez. Suzen deger AYNI SATIRDA olmadiginda gerekir:
    //   anlasmali kurum kartinda sozlesme satirinin fiyat listesi, kartin
    //   BASKA bir yerindeki (1:1 detay) kurum turune gore daralir. `BagliAlan`
    //   satir icindeki alani gosterir; bu bayrak yalnizca haritayi acar,
    //   suzmeyi ekran yapar.
    bool UstBilgisi = false,
    // JENERIK ARAMA EKRANI (260, kullanici: "hasta secimi jenerik kisi
    //   seciminden ama sadece hastalar; hizmet secimi jenerik stok/hizmet
    //   arama ekranindan, sadece hizmetler"). Doluysa alan combo yerine
    //   "secili ad + …" kutusu olarak cizilir ve o arama modali acilir.
    //   Deger yine id'dir; adi cozmek icin KodTablosu da verilir.
    //   Gecerli degerler: "hasta", "hizmet".
    string? AramaKaynagi = null,
    string? Baslik = null,         // form etiketi; bos ise Ad'dan uretilir
    string? Grup = null,           // form bolumu / SEKME: "Kimlik", "Iletisim", "Mali"
    // Sekme DEGIL - ayni sekme icinde mockup'taki gibi kucuk alt-baslik
    //   (or. Genel sekmesinde "Tanım / Sınıflandırma" / "Vergi & Ana Birim").
    string? AltGrup = null,
    // Mockup'taki ".ikili" (or. Raf Ömrü: sayi + birim combo TEK etiket altinda yan yana).
    //   Baska bir alanin Ad'ini gosterir; o alan kendi SATIRINI almaz, buraya eklenir.
    string? EslesAlan = null,
    // ARKA PLAN alani: formda CIZILMEZ ama degeri tasinir (kaydetmede gonderilir).
    //   Cek/senet "Tür" boyle: kagidin turu hangi listeden gelindigiyle belli,
    //   ekranda yer kaplamasi gereksiz - ama kayda dogru deger gitmeli.
    bool Gizli = false,
    // TEKNIK KOD alani: DB kisiti dar bir alfabe istiyor (rol.kod ~ '^[a-z0-9._-]+$').
    //   Kullanici "Satış Müdürü" yazinca kayit CHECK ihlaliyle patliyordu; bu bayrak
    //   varsa deger ASCII-slug'a cevrilir, bos birakilmissa adi gecen alandan uretilir
    //   ("Satış Müdürü" -> "satis-muduru") ve benzersiz olana dek -2, -3 eklenir.
    string? SlugKaynak = null,
    /// <summary>
    /// URUN MODU SUZGECI (542, kullanici: "erp modunda tarife kolonu ve icerde
    /// tipi gorunmesin"). 0 tum kurulumlar · 1 yalniz Gentegre AI (ERP) ·
    /// 2 yalniz GenoTIP AI (HBYS). `AksiyonTanimi.UrunModu` ile AYNI dil.
    /// Saglik kurulumuna ozgu kavramlar (SUT / TTB-HUV tarifesi) ERP'de ekranda
    /// HIC gorunmesin diye var: bos combo gostermek "bunu ne yapacagim"
    /// sorusu uretiyor.
    /// </summary>
    int UrunModu = 0,
    /// <summary>
    /// ALAN DOGRULAMASI (bicim kurali). Bugun tek deger: "tckn" - T.C. kimlik
    /// numarasi NVI algoritmasiyla dogrulanir (KimlikDogrulama). Kural
    /// KATALOGDA durur ki sunucu ve ekran AYNI sozlesmeyi okusun: metada
    /// gelen `dogrulama` alanini arayuz de kontrol eder, kaydetmeyi beklemez.
    /// Zorunluluktan AYRI: bos deger gecerlidir (kimligi belirsiz hasta).
    /// </summary>
    string? Dogrulama = null
)
{
    /// <summary>Etiket verilmediyse camelCase addan uretilir: faturaUnvan -> "Fatura Unvan".</summary>
    public string Etiket => Baslik ?? AddanEtiket(Ad);

    private static string AddanEtiket(string ad)
    {
        var sonuc = new System.Text.StringBuilder(ad.Length + 4);
        for (var i = 0; i < ad.Length; i++)
        {
            if (i > 0 && char.IsUpper(ad[i])) sonuc.Append(' ');
            sonuc.Append(i == 0 ? char.ToUpperInvariant(ad[i]) : ad[i]);
        }
        return sonuc.ToString();
    }
}

public sealed record DetayTanimi(
    string Ad,                     // "adresler"
    string Tablo,                  // "public.taraf_adres"
    string UstKolon,               // "taraf_id"
    IReadOnlyList<KartAlani> Alanlar,
    string IdKolonu = "id",
    string Sirala = "id",
    // 019'da tum sube_id kolonlari NOT NULL yapildi; detay eklerken oturumun
    //   subesi yazilir. Tabloda sube_id yoksa null verilir.
    string? SubeKolonu = "sube_id",
    // islem_log.tablo_id. 0 ise kartin tablo kodu kullanilir. Detay satirinin
    //   logu ust_tablo_id / ust_kayit_id ile karta baglanir.
    int LogTabloId = 0,
    string? Baslik = null,         // sekme basligi; bos ise Ad'dan uretilir
    bool SaltOkunur = false,       // satir ekle/sil hic gosterilmez (or. hesaplanmis/derlenmis veri)
    // Sekme KOSULLU: verilen mantik alani isaretli degilse sekme hic acilmaz
    //   (or. stok "Paket" sekmesi yalniz paket=1 iken). Bos sekme gostermek,
    //   kullaniciya doldurulacak bir sey varmis izlenimi verir.
    string? KosulAlani = null,
    // 1:1 uzanti (UstKolon = "id"): tablonun PK'si ust kayitla AYNI, ikinci
    //   satir zaten yazilamaz. Ekranda "+ Satır" dugmesi ilk satirdan sonra
    //   gizlenir - kullaniciya yazilamayacak satir teklif etmeyelim.
    bool TekSatir = false,
    // SAYFALI DETAY (525): 0 = tek seferde. Fiyat listesi satiri gibi on
    //   binlik detaylarda kart yaniti megabaytlara cikiyor ve tarayici 14 bin
    //   satiri cizerken kilitleniyordu - deger verilince kartla YALNIZ ILK
    //   SAYFA gelir, gerisi `/api/kart/{kaynak}/{id}/detay/{ad}` ucundan.
    int SayfaBoyu = 0,
    // ---- Sayfali detayin SUNUCU TARAFI SUZGECLERI (526) ----
    // Sayfalama gelince ekrandaki arama/cip/kategori yalniz ACIK SAYFAYI
    //   suzuyordu; kullanici "arama ve filtreler aktif olan TUM satirlar
    //   uzerinden olmali" dedi. Suzgec bu yuzden SQL'e indi - istekten SQL
    //   metni GELMEZ, yalniz burada tanimli ifadeler kullanilir.
    //
    // Aranacak ALAN ADLARI (kolon ifadeleri katalogdan alinir).
    IReadOnlyList<string>? AraAlanlari = null,
    // Kategori suzgecinin bakacagi alan; secilen dal ALT AGACIYLA uygulanir.
    string? KategoriAlani = null,
    // Cip kodu -> SQL kosulu ("stok" -> "stok_id is not null"). Kosul
    //   KATALOGDA yazilidir; istek yalniz kodu secer.
    IReadOnlyDictionary<string, string>? Cipler = null,
    // KART ACILISINDA uygulanan cip (531): cip secimi sunucuya gidiyordu ama
    //   kartin ILK sayfasi suzgecsiz geliyordu - fiyat listesi acilinca pasif
    //   kalemler gorunuyor, kullanici cipe dokununca kayboluyordu.
    string? VarsayilanCip = null,
    // YENI SATIR VARSAYILANLARI: istekte gelmeyen alanlara kayit sirasinda
    //   yazilir. Kartin KIMLIGINI belirleyen bayraklar icindir - ornegin dis
    //   hekim kartinda taraf_personel.dis_hekim = 1 (305): kullaniciya
    //   "ben dis hekimim" kutusu isaretlettirmek, ayni tabloyu paylasan iki
    //   kart arasindaki farki kullanicinin sorumluluguna atmak olurdu.
    //   ANAHTAR DB KOLONU (alan adi degil) - dogrudan insert'e girer.
    IReadOnlyDictionary<string, object?>? YeniSatirVarsayilanlari = null
)
{
    public string Etiket => Baslik ?? (Ad.Length > 0 ? char.ToUpperInvariant(Ad[0]) + Ad[1..] : Ad);
}

/// <summary>Silmeyi engelleyen bag. Adet > 0 ise 422 IS_KURALI doner (API §3.3).</summary>
public sealed record SilmeEngeli(string Tablo, string Kolon, string Aciklama);

/// <summary>
/// DOVIZ KURALI — karttaki para birimi / kur / tutar ucgeni.
///
/// Yerel para (SUBENIN <c>para_birimi</c> ayari, 666) disinda bir birim secilirse kur
/// islem tarihinin kurundan OTOMATIK gelir ve yerel karsilik hesaplanir.
/// Kullanici kuru elle degistirebilir (banka/anlasma kuru); yerel tutar HER
/// ZAMAN sunucuda tutar x kur olarak yeniden hesaplanir - arayuzden gelen
/// yerel tutara guvenilmez (API §3.2: hesaplanan alan istemciden alinmaz).
///
/// Yerel parada kur 1'e sabitlenir; "TL kaydin kuru 41" gibi bir sey olusamaz.
/// </summary>
public sealed record DovizKurali(
    string CinsAlani,      // "dovizCinsi"
    string KurAlani,       // "dovizKuru"
    string TutarAlani,     // "tutar"
    string YerelAlani,     // "yerelTutar" - Yazilabilir:false olmali
    string? TarihAlani = null);  // kurun okunacagi tarih alani ("tarih")

public sealed record KartTanimi(
    string Ad,                     // yol parcasi: "cari"
    string YetkiKodu,
    string Tablo,                  // "public.taraf"
    IReadOnlyList<KartAlani> Alanlar,
    int LogTabloId,                // ISLEMLOG.TABLOID (eski GENINI -11110 listesi)
    IReadOnlyList<DetayTanimi>? Detaylar = null,
    IReadOnlyList<SilmeEngeli>? SilmeEngelleri = null,
    string IdKolonu = "id",
    string? SabitKosul = null,
    string? SubeKolonu = null,
    string? KapsamKolonu = null,
    IReadOnlyDictionary<string, object?>? YeniKayitVarsayilanlari = null,
    // YENI kayitta acilir acilmaz taraf (cari) secim ekrani acilsin mi - deger,
    //   secimin yazilacagi alan adidir ("tarafId"). Belge kartindaki desenin
    //   generic kartlardaki karsiligi; kullanici isterse sonra degistirir.
    string? AcilistaTarafSecimi = null,
    // Kartta para birimi / kur / tutar ucgeni varsa (cek-senet): yerel para
    //   disinda bir birim secilince kur otomatik gelir, yerel tutar hesaplanir.
    DovizKurali? Doviz = null
)
{
    private Dictionary<string, KartAlani>? _dizin;

    public KartAlani? Alan(string ad)
    {
        _dizin ??= Alanlar.ToDictionary(a => a.Ad, StringComparer.Ordinal);
        return _dizin.TryGetValue(ad, out var a) ? a : null;
    }

    public DetayTanimi? Detay(string ad)
        => Detaylar?.FirstOrDefault(d => d.Ad.Equals(ad, StringComparison.Ordinal));
}

public static partial class KartKatalogu
{
    private static readonly Dictionary<string, KartTanimi> Kartlar =
        new(StringComparer.OrdinalIgnoreCase);

    public static KartTanimi? Bul(string ad) => Kartlar.TryGetValue(ad, out var k) ? k : null;
    public static IEnumerable<KartTanimi> Tumu => Kartlar.Values;

    static KartKatalogu()
    {
        Ekle(Cari());
        Ekle(Aday());
        Ekle(Randevu());
        Ekle(Kisi());
        Ekle(Personel());
        Ekle(Hasta());
        Ekle(HastaAday());
        Ekle(DisHekim());
        Ekle(Kurum());
        Ekle(Departman());
        Ekle(Kampanya());
        Ekle(Kategori());
        Ekle(RadyolojiIstem());
        Ekle(RadyolojiSablon());
        Ekle(RadyolojiProtokol());

        // Klinik Kalite (711)
        Ekle(KlinikGosterge());
        Ekle(KlinikGostergeDonem());

        // Ameliyathane (715)
        Ekle(Ameliyat());
        Ekle(AmeliyatTalep());
        Ekle(AmeliyatSalon());
        // Acil servis (716)
        Ekle(AcilBasvuru());
        Ekle(AcilYatak());

        // Eczane (722). KONTROLLU DEFTERIN KARTI YOK: satir silinemez ve
        //   duzeltme ayri satirla yapilir - generic kartin "duzenle/sil"
        //   modeli oraya uymaz, yazma isi kendi ucundan gecer.
        Ekle(EczaneKontrol());
        Ekle(EczaneDoz());
        Ekle(EczaneHazirlama());
        Ekle(EczaneIade());
        Ekle(EczaneImha());
        Ekle(KontrolluSayim());
        // Biyomedikal (723). CIHAZ KARTI AYRI DEGIL: klinik muhendislik
        //   kunyesi yukaridaki `Demirbas()` kartina UrunModu 2 alanlar olarak
        //   eklendi - ayni satirin iki duzenleme ekrani olmasin.
        Ekle(DemirbasKalibrasyon());
        Ekle(DemirbasIsEmri());
        // Satinalma (724). SIPARIS/FATURA KARTI YOK: onlar `belge` (tur 9/11).
        Ekle(SatinalmaButce());
        // IZIN (743): talep ve yillik izin hakki.
        Ekle(PersonelIzin());
        Ekle(PersonelIzinHak());
        // AVANS (753): talep, odeme ve mahsup plani.
        Ekle(PersonelAvans());
        // RESMI TATIL (749): is gunu hesabinin dayandigi takvim.
        Ekle(ResmiTatil());
        // ONAY AKISI (742): kurumun imza duzeni - basamaklar, esikler.
        Ekle(OnayAkis());
        // ONAY VEKALETI (741): imza yetkisinin gecici devri.
        Ekle(OnayVekalet());
        Ekle(SatinalmaTalep());
        Ekle(SatinalmaTeklif());
        Ekle(SatinalmaKabul());
        Ekle(TedarikciSozlesme());
        Ekle(TedarikciOlay());

        Ekle(PrimPlani());
        Ekle(EntegrasyonHesap());
        Ekle(RadyolojiCihaz());

        // GOZ (691/693): olcumler DETAY SEKMESIDIR, kart alani degil - ayni
        //   ziyarette ayni olcum birden cok kez yapilir (otoref -> subjektif
        //   -> sikloplejik) ve her satirin kaynagi/zamani ayridir.
        Ekle(GozMuayeneKarti());
        Ekle(GozGoruntulemeKarti());
        Ekle(GozIslemKarti());
        Ekle(GozGozlukReceteKarti());
        Ekle(GozTakipKarti());
        Ekle(GozCihazKarti());
        Ekle(DikteTerimKarti());
        Ekle(GozKontaktLensKarti());
        Ekle(GozIslemProtokolKarti());

        // DIS KLINIGI (706).
        // MEDULA (707).
        Ekle(MedulaRaporKarti());
        Ekle(CalismaSablonKarti());
        Ekle(FtrDegerlendirmeKarti()); Ekle(FtrProgramKarti()); Ekle(FtrSeansKarti()); Ekle(FtrOlcekKarti()); Ekle(FtrUniteKarti());
        Ekle(CalismaIstisnaKarti());
        Ekle(FormSablonKarti()); Ekle(FormKuralKarti());   // form motoru (740)
        Ekle(IsgFirmaKarti()); Ekle(IsgCalisanKarti()); Ekle(IsgMuayeneKarti()); Ekle(IsgZiyaretKarti()); Ekle(IsgOlayKarti());   // isg (741)
        Ekle(MedulaKesintiKarti());
        Ekle(MedulaDonemKarti());
        Ekle(MedulaFaturaKarti());

        Ekle(DisPlanKarti());
        Ekle(DisSeansKarti());
        Ekle(DisLabIsemriKarti());
        Ekle(DisUnitKarti());
        Ekle(DisLabKarti());
        Ekle(DisOdemePlaniKarti());

        // YATAN HASTA (695): yatis karti modulun merkezi - order, izlem, sivi,
        //   risk, yatak hareketi ve epikriz onun DETAYLARI. Ayri kartlara
        //   bolunseydi "bu hastada ne oluyor" sorusu bes ekrana dagilirdi.
        Ekle(YatisKarti());
        Ekle(YatakKarti());
        Ekle(OdaKarti());
        Ekle(YatisOrderKarti());
        Ekle(PersonelGorev());
        Ekle(Rol());
        // Kullanici karti (Yonetim > Guvenlik): hesap acilmaz/silinmez, duzenlenir.
        Ekle(Kullanici());
        Ekle(Stok());
        // Kasa alt sistemi ana verileri (071-074). Kasa ISLEMI kart degil - belge
        //   gibi ayri sozlesme (baslik + bacak), KasaUclari ile yazilir.
        Ekle(Hesap());
        Ekle(Proje());
        Ekle(Gorev());
        Ekle(Firsat());
        Ekle(Banka());
        Ekle(MasrafMerkezi());
        Ekle(HesapPlani());

        // Numaralama (152): Genel Ayarlar > Numaralama ekranindaki dort grid.
        Ekle(MuayeneKarti());
        Ekle(MuayeneSablonKarti());
        Ekle(MetinMakroKarti());
        Ekle(ReceteKarti());
        Ekle(HastaAlerjiKarti());
        Ekle(HastaIlacKarti());
        Ekle(HastaKronikTaniKarti());
        Ekle(HastaGecmisOlayKarti());
        Ekle(DokumanKarti());
        // Dokuman kategorisi ve klasoru (431): ekle/degistir/sil,
        //   kullanilan kayit SilmeEngelleri ile korunur.
        Ekle(DokumanKategoriKarti());
        Ekle(DokumanKlasorKarti());
        Ekle(LabIstemKarti());
        // FAZ 0 ortak platform (398-401): onam metni ve bildirim sablonu.
        Ekle(OnamMetniKarti());
        Ekle(BildirimSablonKarti());
        Ekle(ZamanliIsKarti());
        Ekle(NumaraHasta());
        Ekle(NumaraBasvuru());
        Ekle(NumaraHastaBelge());
        Ekle(NumaraTedarik());
        Ekle(NumaraSatis());
        Ekle(NumaraAlis());
        Ekle(NumaraTahsilat());
        Ekle(NumaraOdeme());
        Ekle(EBelgeSeri());
        Ekle(Sube());
        Ekle(CekSenet());
        Ekle(Depo());
        Ekle(Hizmet());
        // Fiyat listesi (201): kural + materyalize satirlar
        Ekle(FiyatListesi());
        // Demirbas (216)
        Ekle(Demirbas());
        // CIHAZ ARA KATMANI (432).
        Ekle(CihazKarti());

        // SIGORTA v1 (430): kurum hesabi ve kod eslemesi (provizyonun karti YOK).
        Ekle(SigortaHesapKarti());
        Ekle(SigortaKodEslemeKarti());
        // URETIM v1 (429): urun agaci (BOM), uretim emri, is merkezi.
        Ekle(UrunAgaciKarti());
        Ekle(UretimEmriKarti());
        Ekle(IsMerkeziKarti());
        // LAB v1 (433/434): tetkik katalogu (+referans), panel, cihaz eslemesi.
        Ekle(LabTetkikKarti());
        Ekle(LabPanelKarti());
        Ekle(LabCihazEslemeKarti());
        Ekle(EnabizKodEslemeKarti());
        // MIKROBIYOLOJI (436): besiyeri, organizma, antibiyotik kataloglari.
        //   Kulturun KENDI karti yok - kultur bir surectir, adimlari uclardan
        //   yurur (bkz. KartKatalogu.Mikro.cs).
        Ekle(LabBesiyeriKarti());
        Ekle(LabOrganizmaKarti());
        Ekle(LabAntibiyotikKarti());
        // GENETIK (439): gen ve panel kataloglari. Vakanin/varyantin karti
        //   yok - ikisi de surec kaydi, uclardan yurur.
        Ekle(LabGenKarti());
        Ekle(LabGenetikPanelKarti());
        // KALITE KONTROL (442). KK OLCUMUNUN KARTI YOK: olcum serbest
        //   duzenlenebilir olsaydi z skoru ve kural degerlendirmesi elle
        //   ezilebilirdi - kalite kaydinin degeri degistirilememesinden gelir.
        Ekle(LabKkLotKarti());
        Ekle(LabKkKuralKarti());
        Ekle(LabDkkKarti());
        Ekle(LabCihazOlayKarti());
        Ekle(LabIndeksEsikKarti());
        // DIS LABORATUVAR (445). GONDERIMIN KARTI YOK: gonderim bir surectir
        //   ve "teslim edildi" zamani geriye donuk degistirilememeli.
        Ekle(LabDisLabKarti());
        // Belge KARTI degil, ayri sozlesme (§4 belge kaydetme) - burada yer almaz.
    }

    private static void Ekle(KartTanimi k) => Kartlar[k.Ad] = k;

}

