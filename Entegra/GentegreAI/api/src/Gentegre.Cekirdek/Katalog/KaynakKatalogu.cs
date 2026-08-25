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
        Ekle(Kisi());
        Ekle(Belge());
        Ekle(Stok());
        Ekle(StokBirim());
        Ekle(Personel());
        Ekle(Hasta());
        Ekle(Hizmet());
        Ekle(Masraf());
        Ekle(MaliHareket());
        Ekle(EBelge());
        Ekle(IslemLog());
        Ekle(Rol());
        // Kasa alt sistemi (071-080)
        Ekle(Hesap());
        Ekle(CekSenet());
        Ekle(Proje());
        Ekle(Gorev());
        Ekle(BankaListesi());
        Ekle(MasrafMerkezi());
        Ekle(HesapPlani());
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
        Ekle(Irsaliye());
        Ekle(StokTransfer());
        Ekle(StokTalep());
        Ekle(StokFisi(3));
        Ekle(StokFisi(4));
    }

    private static void Ekle(KaynakTanimi k) => Kaynaklar[k.Ad] = k;

}
