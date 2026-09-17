namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Liste sorgusunun BEYAZ LISTESI. Istekten gelen hicbir metin SQL'e gecmez;
/// alan adlari yalnizca buradaki tanimlarla eslesirse kullanilir, degerler her
/// zaman parametre olarak baglanir.
/// </summary>
public sealed record KolonTanimi(
    string Ad,                 // API/JSON adi: "tarafUnvan"
    string Sql,                // SQL ifadesi: "b.taraf_unvan"
    string Tip,                // metin | sayi | para | tarih | kod | mantik
    string Baslik,
    string Hizalama = "sol",   // sol | orta | sag
    string? Bicim = null,      // "#,##0.00", "dd.MM.yyyy"
    bool Varsayilan = true,    // kolon seciciye varsayilan gorunur gelir
    bool Siralanabilir = true,
    bool Filtrelenebilir = true,
    string? YetkiAlani = null, // alan yetkisi adi; null ise kolon adi kullanilir
    int? Genislik = null,      // px - varsayilan (icerige gore) genislik gridde tasarsa (or. uzun metin)
    // GRUPLU listede yalniz GRUP icinde toplanabilen kolon (ekstrede doviz
    //   tutarlari): USD borcuyla TL borcunu toplamak anlamsizdir, o yuzden bu
    //   kolonlar grup ara toplaminda VAR, en alttaki genel toplamda YOK.
    bool SadeceGrupToplami = false,
    // Grubun KAPANIS degeri: toplanmaz, grubun SON satirindaki deger alinir
    //   (yuruyen bakiye boyledir - toplami degil son degeri anlamlidir).
    bool GrupKapanisi = false,
    // KOD KOLONUNUN SOZLUGU (492): "1 Biyokimya, 2 Hematoloji..." - listenin
    //   ust seridinde bu kolona gore suzen combo cizilebilsin diye metaya
    //   konur. Ayni harita kart metasinda da kullanilir; iki yerde
    //   yazilmamasi icin buraya REFERANS verilir, kopyalanmaz.
    IReadOnlyDictionary<string, string>? Kodlar = null,
    /// <summary>
    /// URUN MODU SUZGECI (542, kullanici: "erp modunda tarife kolonu ve icerde
    /// tipi gorunmesin"). 0 tum kurulumlar · 1 yalniz Gentegre AI (ERP) ·
    /// 2 yalniz GenoTIP AI (HBYS). `AksiyonTanimi.UrunModu` ile AYNI dil.
    /// Saglik kurulumuna ozgu kavramlar (SUT / TTB-HUV tarifesi) ERP'de ekranda
    /// HIC gorunmesin diye var: bos combo gostermek "bunu ne yapacagim"
    /// sorusu uretiyor.
    /// </summary>
    int UrunModu = 0
)
{
    public string AlanAdi => YetkiAlani ?? Ad;
    public bool MetinMi => Tip == "metin";
    public bool SayiMi => Tip is "sayi" or "para" or "kod";
}

/// <summary>
/// Bir liste kaynagi. YetkiKodu = yetki tablosundaki kaynak kodu (or. 'cari').
/// SubeKolonu dolu ise HAREKET tablosudur ve sube filtresi SUNUCUDA eklenir;
/// bos ise ana veridir (subeler arasi ortak - 019'daki model).
/// </summary>
public sealed record KaynakTanimi(
    string Ad,                     // yol parcasi: "cari", "belge"
    string YetkiKodu,
    string Kaynak,                 // FROM ifadesi: "public.taraf t"
    IReadOnlyList<KolonTanimi> Kolonlar,
    string? SubeKolonu = null,     // "b.sube_id"
    // Sube filtresi duz esitlikten farkliysa: "{sube}" yer tutuculu SQL ifadesi.
    //   Depo boyle - sube kendi depolarina ek olarak MERKEZIN depolarini da
    //   gorebiliyor (173), tek kolonla anlatilamiyor. Doluysa SubeKolonu yerine
    //   bu kullanilir.
    string? SubeKosulu = null,
    /// <summary>
    /// KULLANIM PUANI SIRALAMASI (550) - `Gorunum = "kullanim"`.
    ///
    /// Katalog 10 bin kalemlik; kurumun gercekte yaptigi is bunun kucuk bir alt
    /// kumesi. Kullanim sayaci (`kalem_kullanim`) bunu KENDILIGINDEN ogrenir;
    /// liste yalnizca ona gore siralar. Join ifadesindeki `{bolum}` yer tutucusu
    /// PARAMETREYLE doldurulur - istekten SQL metni gelmez.
    /// </summary>
    string? KullanimJoin = null,
    string? KullanimSirala = null,
    string? SabitKosul = null,     // "t.musteri = 1 or t.tedarikci = 1"
    string VarsayilanSirala = "id desc",
    string? KapsamKolonu = null,   // kullanici_kapsam (tur=1) suzmesi icin taraf id kolonu
    // GRUPLU LISTE (ekstreler): satirlar bu kolonun degerine gore obeklenir, her
    //   obegin sonuna ARA TOPLAM satiri gelir (or. "dovizCinsi": once TL
    //   hareketleri ve toplami, sonra USD...). Grup toplamlari sunucuda, butun
    //   suzulmus kume uzerinde hesaplanir - sayfa basina degil.
    string? GrupKolonu = null,
    // Gruplarin SIRASI bu kolona gore (or. "dovizSira": yerel para 0, digerleri 1).
    //   Verilmezse grup kolonunun kendisi kullanilir.
    string? GrupSiraKolonu = null
)
{
    private Dictionary<string, KolonTanimi>? _dizin;

    public KolonTanimi? Kolon(string ad)
    {
        _dizin ??= Kolonlar.ToDictionary(k => k.Ad, StringComparer.Ordinal);
        return _dizin.TryGetValue(ad, out var k) ? k : null;
    }
}

public static partial class KaynakKatalogu
{
    private static readonly Dictionary<string, KaynakTanimi> Kaynaklar =
        new(StringComparer.OrdinalIgnoreCase);

    public static KaynakTanimi? Bul(string ad)
        => Kaynaklar.TryGetValue(ad, out var k) ? k : null;

    public static IEnumerable<KaynakTanimi> Tumu => Kaynaklar.Values;

    static KaynakKatalogu()
    {
        Ekle(Cari());
        Ekle(Aday());
        Ekle(Randevu());
        Ekle(Kisi());
        Ekle(Belge());
        Ekle(Stok());
        Ekle(StokBirim());
        Ekle(Personel());
        Ekle(Hasta());
        Ekle(DisHekim());
        Ekle(BasvuruHekim());
        Ekle(Kurum());
        Ekle(Departman());
        Ekle(CalismaSablon());
        Ekle(FtrDegerlendirme()); Ekle(FtrProgram()); Ekle(FtrSeans()); Ekle(FtrOlcek()); Ekle(FtrUnite());
        Ekle(CalismaIstisna());
        Ekle(FormSablon()); Ekle(FormIstek()); Ekle(FormKural());   // form motoru (740)
        Ekle(IsgFirma()); Ekle(IsgCalisan()); Ekle(IsgMuayene()); Ekle(IsgZiyaret()); Ekle(IsgOlay());   // isg (741)
        Ekle(Kampanya());
        Ekle(Kategori());
        Ekle(RadyolojiIstem());
        Ekle(RadyolojiSablon());
        Ekle(RadyolojiProtokol());
        Ekle(RadyolojiCihaz());
        // TAKIP LISTELERI (318): veri rapor ekranindan giriliyordu ama toplu
        //   gorulemiyordu - "acik kritik bulgu / cevap bekleyen konsultasyon /
        //   alinmamis sonuc" sorularinin ekrani.
        Ekle(RadyolojiKritik());
        Ekle(RadyolojiKonsultasyon());
        Ekle(RadyolojiTeslim());

        // GOZ (691): genel muayenenin USTUNE oturur - unite akisi, goz
        //   muayeneleri, goruntuleme, islem hatti, gozluk recetesi, kronik
        //   hastalik takibi ve cihazlar. Olcum tablolari (gorme/refraksiyon/
        //   tonometri...) LISTE DEGIL, kartin icinde OD/OS ikili cizilir.
        Ekle(GozAkis());
        Ekle(GozMuayene());
        Ekle(GozGoruntuleme());
        Ekle(GozIslem());
        Ekle(GozGozlukRecete());
        Ekle(GozTakip());
        Ekle(GozCihaz());
        Ekle(DikteTerim());
        // Ikincil listeler: recetenin ozel hali + kurulum/bakim ekranlari.
        Ekle(GozKontaktLens());
        Ekle(GozIslemProtokol());
        Ekle(GozCihazMesaj());
        Ekle(GozHastaOzet());

        // DIS KLINIGI (706): hasta listesi (karta giris), planlar, seanslar,
        //   lab is emirleri, odeme planlari, ayarlar (unit / lab).
        // MEDULA (707): takipler, hizmet kayitlari, faturalar, donemler, kesintiler, raporlar, kuyruk.
        Ekle(MedulaTakip());
        Ekle(MedulaIslem());
        Ekle(MedulaFatura());
        Ekle(MedulaDonem());
        Ekle(MedulaKesinti());
        Ekle(MedulaRapor());
        Ekle(MedulaKuyruk());

        Ekle(DisHasta());
        Ekle(DisPlan());
        Ekle(DisSeans());
        Ekle(DisLabIsemri());
        Ekle(DisOdemePlani());
        Ekle(DisUnit());
        Ekle(DisLab());

        // YATAN HASTA (695): servis listesi, yatak panosu, order ve doz
        //   kuyrugu. Izlem (vital/sivi/risk) LISTE DEGIL - hep bir hastanin
        //   egrisi sorulur, servis genelinde "butun vitaller" diye bir soru yok.
        Ekle(Yatan());
        Ekle(YatakPanosu());
        Ekle(YatisOrder());
        Ekle(OrderUygulama());
        Ekle(YatisIzlem());
        Ekle(YatisTahakkuk());
        Ekle(Oda());

        // PRIM / HAKEDIS (324): prim tahsil edildikce dogar - hakedis satiri
        //   tahsilat dagitimindan uretilir.
        Ekle(PrimPlani());
        Ekle(PrimAday());
        Ekle(EntegrasyonHesap());
        Ekle(PrimRol());
        Ekle(HakedisSatir());
        Ekle(Hakedis());
        Ekle(KurumIcmal());
        Ekle(PersonelGorev());
        Ekle(Hizmet());
        Ekle(Masraf());
        Ekle(MaliHareket());
        Ekle(EBelge());
        Ekle(IslemLog());
        Ekle(GirisLog());
        // ÜTS (223): bildirim gecmisi + askidaki urunler.
        Ekle(UtsBildirim());
        Ekle(UtsEnvanter());
        Ekle(Rol());
        // Kullanicilar (Yonetim > Guvenlik): hesap yonetimi tek ekranda.
        Ekle(Kullanici());
        // Kasa alt sistemi (071-080)
        Ekle(Hesap());
        Ekle(CekSenet());
        Ekle(Proje());
        Ekle(Gorev());
        Ekle(BankaListesi());
        Ekle(MasrafMerkezi());
        Ekle(HesapPlani());

        // Numaralama (152): Genel Ayarlar > Numaralama ekranindaki dort grid.
        Ekle(PrimRolAday());
        Ekle(Muayene());
        Ekle(HekimCalismaListesi());
        Ekle(MuayeneSablon());
        Ekle(MetinMakro());
        Ekle(Recete());
        Ekle(HastaAlerji());
        Ekle(HastaIlac());
        // Hasta tibbi gecmisi (420): kronik tani, gecmis olay, ozet.
        Ekle(HastaKronikTani());
        Ekle(HastaGecmisOlay());
        Ekle(HastaTibbiOzet());
        Ekle(EnabizPaket());
        // ITS ilac bildirimleri (427) - UTS ile ayri liste.
        Ekle(ItsBildirim());
        // CIHAZ ARA KATMANI (432): cihazlar ve gelen mesaj kuyrugu.
        Ekle(Cihaz());
        Ekle(CihazMesaj());

        // SIGORTA v1 (430): provizyonlar, kurum hesaplari, kod eslemesi, gunluk.
        Ekle(SigortaProvizyon());
        Ekle(SigortaHesap());
        Ekle(SigortaKodEsleme());
        Ekle(SigortaIstekLog());
        // URETIM v1 (429): urun agaci (BOM), uretim emri, is merkezi.
        Ekle(UrunAgaci());
        Ekle(UretimEmri());
        Ekle(IsMerkezi());
        // Dokuman v1 (419): kaynak ustu liste + katalog + onay kuyrugu.
        Ekle(Dokuman());
        Ekle(DokumanKategori());
        Ekle(DokumanKlasor());
        Ekle(DokumanOnayKuyrugu());
        // LAB v1 (433/434): istem + tetkik katalogu, panel, numune, sonuc,
        //   cihaz test eslemesi.
        Ekle(LabIstem());
        Ekle(LabTetkik());
        Ekle(LabPanel());
        Ekle(LabNumune());
        Ekle(LabSonuc());
        Ekle(LabCihazEsleme());
        Ekle(EnabizKodEsleme());
        // MIKROBIYOLOJI (436): kultur calisma listesi + kataloglar.
        Ekle(LabKultur());
        Ekle(LabBesiyeri());
        Ekle(LabOrganizma());
        Ekle(LabAntibiyotik());
        // GENETIK (439): vaka calisma alani, varyant havuzu, run'lar,
        //   gen ve panel kataloglari.
        Ekle(LabGenetikVaka());
        Ekle(LabVaryant());
        Ekle(LabGenetikRun());
        Ekle(LabGen());
        Ekle(LabGenetikPanel());
        // KALITE KONTROL (442): IKK olcumleri, kontrol lotlari, Westgard
        //   kural seti, dis kalite ve cihaz olaylari.
        Ekle(LabKkOlcum());
        Ekle(LabKkLot());
        Ekle(LabKkKural());
        Ekle(LabDkk());
        Ekle(LabCihazOlay());
        // Serum indeksi esikleri (444): test bazli HIL sinirlari.
        Ekle(LabIndeksEsik());
        // DIS LABORATUVAR (445): gonderimler ve dis lab tanimlari.
        Ekle(LabDisGonderim());
        Ekle(LabDisLab());
        // FAZ 0 ortak platform (398-401): onam, bildirim, klinik kataloglar.
        Ekle(OnamMetni());
        Ekle(Onam());
        Ekle(BildirimSablon());
        Ekle(Bildirim());
        Ekle(Icd());
        Ekle(Ilac());
        Ekle(ZamanliIs());
        Ekle(NumaraHasta());
        Ekle(NumaraBasvuru());
        Ekle(NumaraHastaBelge());
        Ekle(NumaraTedarik());
        Ekle(NumaraIk());
        Ekle(BelgeYaziSablonu());
        // Teknik servis (773): cagri -> is emri -> ziyaret uc katmani.
        Ekle(ServisCagri());
        Ekle(ServisIsEmri());
        Ekle(ServisZiyaret());
        Ekle(ServisEmanet());
        Ekle(TarafCihaz());
        Ekle(ServisSozlesme());
        Ekle(NumaraSatis());
        Ekle(NumaraAlis());
        Ekle(NumaraTahsilat());
        Ekle(NumaraOdeme());
        Ekle(EBelgeSeri());
        Ekle(Sube());
        Ekle(EBelgeXslt());
        Ekle(KasaIslemTuru());
        Ekle(Firsat());
        Ekle(HesapEkstre());
        Ekle(CariEkstre());
        // Kasa motoru (076, F2)
        Ekle(KasaIslem());
        Ekle(MuhasebeFis());
        Ekle(MuhasebeFisSatir());
        Ekle(PlanVade());
        // Belge donusumu (F8)
        Ekle(BelgeAcikSatir());
        Ekle(Depo());
        // Fiyat listesi (201)
        Ekle(FiyatListesi());
        Ekle(FiyatListesiSatir());
        // Demirbas (216)
        Ekle(Demirbas());
        Ekle(Irsaliye());
        // Gelen e-Belge kutusu (187)
        Ekle(GelenBelge());
        Ekle(StokTransfer());
        Ekle(StokTalep());
        // Klinik Kalite (711)
        Ekle(KlinikGosterge());
        Ekle(KlinikGostergeDonem());
        Ekle(KlinikGostergeKod());
        // Ameliyathane (715)
        Ekle(Ameliyat());
        Ekle(AmeliyatTalep());
        Ekle(AmeliyatSalon());
        // Acil servis (716)
        Ekle(AcilBasvuru());
        Ekle(AcilCagri());
        Ekle(AcilYatak());
        // Eczane (722)
        Ekle(EczaneKontrol());
        Ekle(EczaneDoz());
        Ekle(EczaneHazirlama());
        Ekle(EczaneIade());
        Ekle(EczaneImha());
        Ekle(KontrolluDefter());
        Ekle(EczaneMiad());
        // Biyomedikal (723) - envanterin ERP listesi yukarida `Demirbas()`.
        Ekle(DemirbasCihaz());
        Ekle(DemirbasKalibrasyon());
        Ekle(DemirbasIsEmri());
        // Satinalma (724)
        // ONAY GELEN KUTUSU (738): tum modullerin bekleyen onaylari.
        Ekle(OnayKutusu());
        Ekle(PersonelIzinKaynagi());
        Ekle(IzinBakiyeKaynagi());
        Ekle(PersonelAvansKaynagi());
        Ekle(PersonelMasrafKaynagi());
        Ekle(BelgeTalepKaynagi());
        Ekle(ResmiTatilKaynagi());
        Ekle(OnayAkisKaynagi());
        Ekle(OnayVekaletKaynagi());
        Ekle(SatinalmaTalep());
        Ekle(SatinalmaTeklif());
        Ekle(SatinalmaSiparis());
        Ekle(SatinalmaKabul());
        Ekle(SatinalmaFatura());
        Ekle(SatinalmaTedarikci());
        Ekle(SatinalmaButce());
        Ekle(StokFisi(3));
        Ekle(StokFisi(4));
    }

    /// <summary>
    /// Kaynagi kataloga yazar; once KOLON ADI TEKRARINI yakalar.
    ///
    /// Ayni ada sahip iki kolon (or. bir alan sonradan ikinci kez eklenince)
    /// listeyi SUZULENE KADAR bozmuyor: `Kolon(ad)` dizini ilk suzme/siralama
    /// isteginde kuruluyor ve orada "An item with the same key has already been
    /// added" ile 500 donuyordu - liste acilisi calistigi icin hata kaynaktan
    /// cok uzakta goruluyor. Burada acilista, kaynagin adiyla birlikte patlar.
    /// </summary>
    private static void Ekle(KaynakTanimi k)
    {
        var tekrar = k.Kolonlar.GroupBy(x => x.Ad, StringComparer.Ordinal)
                               .Where(g => g.Count() > 1)
                               .Select(g => g.Key)
                               .ToArray();
        if (tekrar.Length > 0)
            throw new InvalidOperationException(
                $"Kaynak '{k.Ad}': tekrarlanan kolon adi: {string.Join(", ", tekrar)}");

        Kaynaklar[k.Ad] = k;
    }

}
