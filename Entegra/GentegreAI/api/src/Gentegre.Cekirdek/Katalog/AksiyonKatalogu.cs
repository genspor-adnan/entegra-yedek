using Gentegre.Cekirdek.Yetki;

namespace Gentegre.Cekirdek.Katalog;

/// <summary>
/// Bir aksiyonun tanimi (API §7). Arac cubugu, sag tus menusu ve komut paleti
/// AYNI KATALOGDAN uretilir - Delphi'de bu uc yer ayri ayri kodlaniyordu ve
/// zamanla birbirinden ayrisiyordu.
/// </summary>
public sealed record AksiyonTanimi(
    string Kod,                    // "belge.yeni", "ebelge.gonder"
    string Ad,
    string Grup,
    /// <summary>
    /// Hangi yuzeyde gorunur: araccubugu | araccubugu2 | sagtus | palet
    /// (virgullu). "araccubugu2" = arac cubugunun IKINCI sirasi, saga yasli:
    /// gunluk akisin disinda kalan seyrek islemler birinci sirayi bogmasin.
    /// </summary>
    string Hedef = "araccubugu,sagtus,palet",
    string? Kisayol = null,
    /// <summary>Kaynak yetkisi (or. "cari") + islem. Null ise AksiyonYetkisi bakilir.</summary>
    string? KaynakKodu = null,
    Islem Islem = Islem.Gor,
    /// <summary>Aksiyon yetkisi kodu (yetki tablosunda tur = 1).</summary>
    string? AksiyonYetkisi = null,
    /// <summary>Kayit secilmeden calismaz (sag tus / liste secimi).</summary>
    bool KayitGerekir = false,
    int Sira = 0,
    /// <summary>
    /// URUN MODU SUZGECI (342/345): 0 tum kurulumlar, 1 yalniz Gentegre AI
    /// (ERP), 2 yalniz GenoTIP AI (HBYS). Saglik entegrasyonlarina ozgu
    /// aksiyonlar (SKRS senkronu) ERP kurulumunda ARAC CUBUGUNDA HIC
    /// gorunmesin diye var - pasif gosterip "neden calismiyor" sorusu
    /// urettirmek yerine listeden dusuruluyor.
    /// </summary>
    int UrunModu = 0,
    /// <summary>
    /// Dugme vurgusu: "onay" yesil · "ret" kirmizi · "bir" birincil. Bos ise
    /// notr. Kabul/ret gibi KARSIT ciftlerde renk, dugmeyi okumadan hangisinin
    /// hangisi oldugunu soyler - yanlis dugmeye basmak numuneyi reddeder.
    /// </summary>
    string? Bicim = null,
    /// <summary>Fare ipucu; bos ise `Ad` kullanilir (543).</summary>
    string? Ipucu = null);

/// <summary>Ekran basina aksiyon listesi.</summary>
public static partial class AksiyonKatalogu
{
    /// <summary>
    /// Ekran basina aksiyon listesi. Girdiler konu bazli partial dosyalarda
    /// (AksiyonKatalogu.Cari.cs, .Goz.cs, .Lab.cs ...).
    ///
    /// KURUCUDA BIRLESTIRILIYOR, statik alan zinciriyle degil: partial
    /// dosyalar arasi statik alan baslatma sirasi derleyiciye bagli oldugu
    /// icin `Ekranlar` bir parcayi null gorebilirdi.
    /// </summary>
    private static readonly Dictionary<string, IReadOnlyList<AksiyonTanimi>> Ekranlar;

    static AksiyonKatalogu()
    {
        var s = new Dictionary<string, IReadOnlyList<AksiyonTanimi>>(StringComparer.OrdinalIgnoreCase);
        EkleCari(s);
        EkleGoz(s);
        EkleDis(s);
        EkleKalite(s);
        EkleMedula(s);
        EkleAmeliyathane(s);
        EkleKlinik(s);
        EkleLab(s);
        EkleTicari(s);
        Ekranlar = s;
    }

    public static IReadOnlyList<AksiyonTanimi>? Ekran(string ad)
        => Ekranlar.TryGetValue(ad, out var liste) ? liste : null;

    public static IEnumerable<string> EkranAdlari => Ekranlar.Keys;

    /// <summary>Aksiyon kullanicinin yetkisine giriyor mu (§7: yetkisiz aksiyon HIC donmez).</summary>
    public static bool Yetkili(AksiyonTanimi aksiyon, YetkiSeti yetkiler)
    {
        if (aksiyon.KaynakKodu is { } kaynak) return yetkiler.Var(kaynak, aksiyon.Islem);
        if (aksiyon.AksiyonYetkisi is { } kod) return yetkiler.AksiyonVar(kod);
        return true;
    }

    /// <summary>
    /// STANDART KART DORTLUSU: Yeni · Düzenle · Sil · Yazdır.
    ///
    /// Bu dortlu 28 ekranda tek tek yazilmisti (26 "yeni", 24 "sil", 20 "yazdir"
    /// girdisi). Kisayol ya da hedef yuzeyi birinde degistirilince otekiler
    /// geride kaliyordu. Ayni ilke katalogun baska yerlerinde zaten uygulanmis
    /// (KartKatalogu.NumaraKarti, KaynakKatalogu.NumaraKaynagi); aksiyonlara
    /// gecmemisti.
    ///
    /// Ekranin kendine ozgu aksiyonlari dizinin arkasina eklenir:
    ///   [.. Crud("proje", "proje", "proje"), new("proje.ekstre", ...)]
    /// </summary>
    /// <param name="onEk">Aksiyon kodu oneki ("cari" -> "cari.yeni").</param>
    /// <param name="grup">Aksiyonun gorsel grubu (arac cubugunda obekleme).</param>
    /// <param name="kaynakKodu">Yetki kaynagi ("cari", "hesap"...).</param>
    /// <param name="ekleAdi">Ekleme dugmesinin adi - kart ekranlarinda "＋ Ekle".</param>
    /// <param name="silHedef">Silmenin gorunecegi yuzeyler; null = hepsi.</param>
    /// <param name="yazdir">Yazdir/CSV dugmesi eklensin mi.</param>
    /// <param name="silSira">Silme sirasi - araya aksiyon giren ekranlarda kayar.</param>
    /// <param name="sil">
    /// Silme aksiyonu uretilsin mi. <b>false</b>: kayit hic silinmez
    /// (kullanici 08.10.2026: "rollerde silme yok aktif/pasif var") - varligi
    /// gecmise bagli kayitlar kullanimdan `aktif` alani kapatilarak cikarilir.
    /// Dugmeyi gostermemek, 422 vermekten once gelir: kullanici var olmayan bir
    /// yolu denemesin. Sunucu tarafi ayrica `KartTanimi.SilmeYok` ile kapali.
    /// </param>
    private static AksiyonTanimi[] Crud(string onEk, string grup, string kaynakKodu,
        string ekleAdi = "＋ Yeni", string? silHedef = "sagtus,palet",
        bool yazdir = true, int silSira = 30, string silAdi = "🗑 Sil",
        string? silIpucu = null, bool sil = true)
    {
        AksiyonTanimi[] ucluVeSil =
        [
            new($"{onEk}.yeni", ekleAdi, grup, Kisayol: "Ctrl+N",
                KaynakKodu: kaynakKodu, Islem: Islem.Ekle, Sira: 10),
            new($"{onEk}.duzenle", "✎ Düzenle", grup, Kisayol: "Enter",
                KaynakKodu: kaynakKodu, Islem: Islem.Degistir, KayitGerekir: true, Sira: 20),
            .. (sil
                ? new AksiyonTanimi[] { silHedef is null
                    ? new($"{onEk}.sil", silAdi, grup, Kisayol: "Del",
                          KaynakKodu: kaynakKodu, Islem: Islem.Sil, KayitGerekir: true,
                          Sira: silSira, Ipucu: silIpucu)
                    : new($"{onEk}.sil", silAdi, grup, Hedef: silHedef, Kisayol: "Del",
                          KaynakKodu: kaynakKodu, Islem: Islem.Sil, KayitGerekir: true,
                          Sira: silSira, Ipucu: silIpucu) }
                : []),
        ];
        return yazdir ? [.. ucluVeSil, Yazdir()] : ucluVeSil;
    }

    /// <summary>Yazdir / CSV kaydet - salt gorunum ekranlarinda tek basina da kullanilir.</summary>
    /// <summary>
    /// Ekstre satirindan onu URETEN belgeye gider (kullanici: "başvurusuna
    /// gidebileyim"). Sira 10 - arac cubugunda Yazdır'in (90) SOLUNDA.
    /// </summary>
    private static AksiyonTanimi BasvuruAc()
        => new("basvuru.ac", "📝 Başvuru Aç", "belge", Hedef: "araccubugu,sagtus,palet",
               KaynakKodu: "belge", Islem: Islem.Gor, KayitGerekir: true, Sira: 10);

    private static AksiyonTanimi Yazdir()
        => new("genel.yazdir", "🖨️ Yazdır", "genel", Hedef: "araccubugu,palet",
               AksiyonYetkisi: "veri.disa-aktar", Sira: 90);

}
