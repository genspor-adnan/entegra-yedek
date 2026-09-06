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
    bool GrupKapanisi = false
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
        Ekle(Kurum());
        Ekle(Departman());
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
        // ÜTS (223): bildirim gecmisi + askidaki urunler.
        Ekle(UtsBildirim());
        Ekle(UtsEnvanter());
        Ekle(Rol());
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
        Ekle(StokFisi(3));
        Ekle(StokFisi(4));
    }

    private static void Ekle(KaynakTanimi k) => Kaynaklar[k.Ad] = k;

}
