using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// JENERIK EXCEL ICERI ALMA MOTORU (548).
///
/// Mockup: Ekranlar/Ayarlar/excel_iceri_alma.html - "tek sihirbaz, cok hedef".
/// Hedef (cari / stok / hizmet) yalnizca "hangi alanlar var" sorusunu
/// degistirir; adimlar, esleme, dogrulama ve yazma kurali her hedefte aynidir.
///
/// TASARIM KARARLARI
///
///  - ALAN LISTESI KATALOGDAN. Sihirbazin "Gentegre alani" combosu
///    `KartKatalogu`daki kart alanlarindan uretilir - ayri bir sablon tanimi
///    tutulmaz. Karta alan eklendiginde iceri alma da kendiliginden bilir;
///    iki yerde iki liste olsa biri mutlaka eskirdi.
///  - YAZMA YOK, ONCE GOSTER. `Onizle` hicbir sey yazmaz: her satir icin
///    "yeni / degisecek / sorunlu" ve sebebi doner. Yazma yalniz `Uygula`da.
///  - TEK ISLEM. `Uygula` tek transaction'da calisir - ya hepsi ya hicbiri.
///    Sorunlu satirlar zaten onizlemede ayiklanir; yazma sirasinda cikan bir
///    hata (FK, kisit) dosyanin YARISI girmis bir veritabani birakmaz.
///  - BOS HUCRE SILMEZ. Guncellemede yalnizca DOLU hucreler yazilir: musteri
///    dokumunde bos kalan "Telefon" sutunu, kayitli telefonu silmemeli.
///  - IZ KALIR. Her yukleme `iceri_alma` tablosuna yazilir; yazilan her kart
///    islem_log'a yukleme numarasiyla dusurulur.
///
/// HEDEFLER: kart (cari · stok · hizmet), FIYAT LISTESI SATIRI (secilen
/// listeye, kalem kodla) ve FATURA (alis 11 / satis 15 - duz Excel satirlari
/// belge numarasina gore faturalara toplanir).
///
/// KAPSAM DISI (bugun): kasa hareketi hedefi, yuklemeyi geri alma ve YZ ile
/// satir onarimi. Mockup'ta yerleri duruyor.
/// </summary>
public static class IceriAlma
{
    // ============================================================ HEDEFLER ====

    /// <param name="Ad">Yol/istek anahtari.</param>
    /// <param name="Kart">KartKatalogu adi - alanlar ve tablo oradan (Tur = "kart").</param>
    /// <param name="Anahtarlar">Cakisma anahtari, SIRAYLA denenir (ilk dolu olan).</param>
    /// <param name="Tur">kart · fiyat-listesi · belge</param>
    /// <param name="BelgeTuru">Tur = "belge" ise belge tur kodu (11 alis, 15 satis).</param>
    /// <param name="YetkiKodu">Bos ise kartin yetki kodu kullanilir.</param>
    public sealed record Hedef(string Ad, string Baslik, string Kart,
                               string[] Anahtarlar, string Ikon,
                               string Tur = "kart", int BelgeTuru = 0,
                               string YetkiKodu = "");

    public static readonly Hedef[] Hedefler =
    {
        new("cari",   "Cari (müşteri / tedarikçi)", "cari",   ["vkno", "kod"], "🧾"),
        new("stok",   "Stok",                        "stok",   ["kod"], "📦"),
        new("hizmet", "Hizmet",                      "hizmet", ["kod", "barkod"], "🛠️"),
        // FIYAT LISTESI SATIRI: kart degil, SECILEN listenin satirlari. Hedef
        //   secilince sihirbaz hangi listeye yazilacagini sorar - ayni dosya
        //   iki farkli tarifeye yazilabilir.
        new("fiyat-listesi", "Fiyat Listesi Satırı", "", ["kalem"], "💰",
            Tur: "fiyat-listesi", YetkiKodu: "fiyat_listesi"),
        // FATURALAR: Excel'de her SATIR bir kalemdir; ayni belge numarasini
        //   tasiyan satirlar TEK faturaya toplanir (mockup: "başlık ve kalem
        //   iki sayfa" yerine tek duz sayfa - musteri dokumleri boyle geliyor).
        new("alis-faturasi",  "Alış Faturası",  "", ["belgeNo"], "📥",
            Tur: "belge", BelgeTuru: 11, YetkiKodu: "belge"),
        new("satis-faturasi", "Satış Faturası", "", ["belgeNo"], "📤",
            Tur: "belge", BelgeTuru: 15, YetkiKodu: "belge"),
    };

    /// <summary>Hedefin yetki kodu: karti varsa kartin, yoksa hedefte yazili.</summary>
    public static string YetkiKodu(Hedef hedef)
        => hedef.YetkiKodu.Length > 0 ? hedef.YetkiKodu : KartBul(hedef).YetkiKodu;

    // ---------------------------------------------------- SANAL ALAN KUMELERI ----
    // Kart olmayan hedeflerde (fiyat listesi satiri, fatura) "Gentegre alani"
    //   listesi bir kart tanimindan gelemez: yazilacak sey birden fazla
    //   tabloya dagiliyor (belge + belge_satir) ya da kalem KOD ile cozuluyor.
    //   Alanlar burada TANIMLI; `KartAlani` kaydini yeniden kullaniyoruz ki
    //   esleme/cozumleme kodu tek olsun (Kolon alani bu hedeflerde anlamsiz).
    private static KartAlani A(string ad, string baslik, string tip, bool zorunlu = false)
        => new(ad, ad, tip, Zorunlu: zorunlu, Baslik: baslik);

    private static readonly KartAlani[] FiyatListesiAlanlari =
    {
        A("stokKodu",   "Stok Kodu",   "metin"),
        A("hizmetKodu", "Hizmet Kodu", "metin"),
        // Tek "Kod" sutunu: once stokta, yoksa hizmette aranir (207 kurali).
        A("kod",        "Kod",         "metin"),
        A("fiyat",      "Fiyat",       "para", zorunlu: true),
        A("katkiTutar", "Katkı (hasta)", "para"),
        A("dovizCinsi", "Döviz",       "metin"),
        A("durum",      "Durum",       "metin"),
    };

    private static readonly KartAlani[] FaturaAlanlari =
    {
        A("belgeNo",    "Belge No",      "metin"),
        A("belgeSeri",  "Seri",          "metin"),
        A("belgeTarihi","Belge Tarihi",  "tarih", zorunlu: true),
        // CARI: uc yoldan biri yeterli - kod, vergi no ya da unvan.
        A("cariKodu",   "Cari Kodu",     "metin"),
        A("cariVkno",   "Cari Vergi/Kimlik No", "metin"),
        A("cariUnvan",  "Cari Unvan",    "metin"),
        A("aciklama",   "Belge Açıklaması", "metin"),
        // KALEM: stok ya da hizmet kodu; tek "Kod" sutunu da kabul edilir.
        A("stokKodu",   "Stok Kodu",     "metin"),
        A("hizmetKodu", "Hizmet Kodu",   "metin"),
        A("kod",        "Kalem Kodu",    "metin"),
        A("satirAciklama", "Satır Açıklaması", "metin"),
        A("adet",       "Miktar",        "ondalik", zorunlu: true),
        A("birimFiyat", "Birim Fiyat",   "para",    zorunlu: true),
        A("kdv",        "KDV (%)",       "sayi"),
        A("iskonto",    "İskonto (%)",   "ondalik"),
        A("dovizCinsi", "Döviz",         "metin"),
    };

    /// <summary>Hedefin esleme combosuna giden alanlar.</summary>
    public static IReadOnlyList<KartAlani> HedefAlanlari(Hedef hedef) => hedef.Tur switch
    {
        "fiyat-listesi" => FiyatListesiAlanlari,
        "belge" => FaturaAlanlari,
        _ => Alanlar(KartBul(hedef)).ToList(),
    };

    public static Hedef HedefBul(string ad)
        => Hedefler.FirstOrDefault(h => h.Ad.Equals(ad, StringComparison.OrdinalIgnoreCase))
           ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen hedef: {ad}",
                  new AlanHatasi("hedef", "Hedef tanımlı değil."));

    public static KartTanimi KartBul(Hedef hedef)
        => KartKatalogu.Bul(hedef.Kart)
           ?? throw GentegreHatasi.IsKurali($"\"{hedef.Kart}\" kartı bulunamadı.");

    /// <summary>Sihirbazin esleme combosuna giden alanlar (yazilabilir olanlar).</summary>
    public static IEnumerable<KartAlani> Alanlar(KartTanimi kart)
        => kart.Alanlar.Where(a => a.Yazilabilir && a.Ad != "id");

    // ============================================================== ESLEME ====

    /// <param name="Kolon">Excel basligi.</param>
    /// <param name="Alan">Kart alan adi - bos ise "aktarma".</param>
    /// <param name="Guven">0-100. Kayitli kuraldan gelen esleme 100.</param>
    public sealed record EslemeSatiri(string Kolon, string Alan, int Guven, string Ornek);

    /// <summary>
    /// BASLIK ESANLAMLILARI. Musteri dosyalarinda alan adlari bizim kart
    /// etiketimizle birebir gelmiyor ("VD", "ÜNVAN", "CEP"). Liste kucuk ve
    /// elle buyutulebilir olsun diye burada: yanlis esleme sessiz yanlis veri
    /// demek, bu yuzden tahminin kaynagi gorunur olmali.
    /// Anahtarlar BaslikAnahtari ile normalize edilmis hâlleridir.
    /// </summary>
    private static readonly Dictionary<string, (string Alan, int Guven)[]> Esanlamlilar =
        new(StringComparer.Ordinal)
        {
            ["ÜNVAN"] = [("unvan", 99)],
            ["UNVAN"] = [("unvan", 99)],
            ["FIRMA"] = [("unvan", 90)], ["FİRMA"] = [("unvan", 90)],
            ["FİRMA ADI"] = [("unvan", 92)], ["MÜŞTERİ ADI"] = [("unvan", 92)],
            ["CARİ ADI"] = [("unvan", 92)], ["CARİUNVAN"] = [("unvan", 90)],
            ["VKN"] = [("vkno", 98)], ["TCKN"] = [("vkno", 95)],
            ["VKN/TCKN"] = [("vkno", 98)], ["VERGİ NO"] = [("vkno", 98)],
            ["VERGİ NUMARASI"] = [("vkno", 96)], ["TC KİMLİK NO"] = [("vkno", 92)],
            // Basliklar MUSTERININ dosyasindan gelir: "TCKN"/"TC KİMLİK NO"
            //   yazan eski dosyalar calismaya devam eder, arayuzdeki yeni ad
            //   ("Kimlik No") da taninir.
            ["KİMLİK NO"] = [("vkno", 92)], ["KIMLIK NO"] = [("vkno", 92)],
            ["VD"] = [("vd", 88)], ["VERGİ DAİRESİ"] = [("vd", 98)],
            ["CARİ KOD"] = [("kod", 95)], ["CARİKOD"] = [("kod", 92)],
            ["MÜŞTERİ KODU"] = [("kod", 92)], ["STOK KODU"] = [("kod", 98)],
            ["ÜRÜN KODU"] = [("kod", 92)], ["HİZMET KODU"] = [("kod", 95)],
            ["STOK ADI"] = [("ad", 98)], ["ÜRÜN ADI"] = [("ad", 94)],
            ["HİZMET ADI"] = [("ad", 96)], ["MALZEME ADI"] = [("ad", 90)],
            ["TEL"] = [("telefon", 92)], ["TELEFON 1"] = [("telefon", 92)],
            ["CEP"] = [("cepTel", 92)], ["CEP TEL"] = [("cepTel", 94)],
            ["CEP TELEFONU"] = [("cepTel", 96)], ["GSM"] = [("cepTel", 90)],
            ["TELEFON 2"] = [("cepTel", 81)],
            ["E-POSTA"] = [("eposta", 96)], ["EMAIL"] = [("eposta", 92)],
            ["MAİL"] = [("eposta", 90)],
            ["BARKOD"] = [("barkod", 96)],
            ["BİRİM"] = [("anaBirim", 88)], ["ÖLÇÜ BİRİMİ"] = [("anaBirim", 88)],
            ["KDV"] = [("kdv", 94)], ["KDV ORANI"] = [("kdv", 96)],
            ["AÇIKLAMA"] = [("aciklama", 94)],
            ["DURUM"] = [("durum", 92)],
        };

    /// <summary>Baslik imzasi: kuralin dosyayi tanima anahtari (548).</summary>
    public static string BaslikImzasi(IEnumerable<string> basliklar)
        => string.Join('|', basliklar.Select(ExcelOkuma.BaslikAnahtari)
                                     .Where(b => b.Length > 0)
                                     .OrderBy(b => b, StringComparer.Ordinal));

    /// <summary>
    /// ESLEME ONERISI. Sirasiyla: kayitli kural > esanlamli > alan etiketi/adi
    /// birebir > icerme. Guven yuzdesi ekranda gosterilir - kullanici neye
    /// guvenip neyi elle duzeltecegini bilsin diye.
    /// </summary>
    public static List<EslemeSatiri> EslemeOner(
        IReadOnlyList<KartAlani> alanlar, ExcelOkuma.Sayfa sayfa,
        IReadOnlyDictionary<string, string>? kural)
    {
        var etiketDizini = new Dictionary<string, string>(StringComparer.Ordinal);
        foreach (var a in alanlar)
        {
            etiketDizini.TryAdd(ExcelOkuma.BaslikAnahtari(a.Etiket), a.Ad);
            etiketDizini.TryAdd(ExcelOkuma.BaslikAnahtari(a.Ad), a.Ad);
        }
        var alanKumesi = alanlar.Select(a => a.Ad).ToHashSet(StringComparer.Ordinal);

        // Bir alan IKI kolona baglanamaz: ikincisi bos kalir, kullanici secer.
        var kullanilan = new HashSet<string>(StringComparer.Ordinal);
        var sonuc = new List<EslemeSatiri>();

        foreach (var baslik in sayfa.Basliklar)
        {
            var anahtar = ExcelOkuma.BaslikAnahtari(baslik);
            var ornek = sayfa.Satirlar
                .Select(s => s.Hucreler.TryGetValue(anahtar, out var v) ? v : "")
                .FirstOrDefault(v => !string.IsNullOrWhiteSpace(v)) ?? "";

            string alan = "";
            var guven = 0;

            if (kural is not null && kural.TryGetValue(anahtar, out var kuralAlan)
                && alanKumesi.Contains(kuralAlan))
            {
                alan = kuralAlan; guven = 100;
            }
            else if (Esanlamlilar.TryGetValue(anahtar, out var oneriler)
                     && oneriler.FirstOrDefault(o => alanKumesi.Contains(o.Alan)) is { Alan: not null } o2)
            {
                alan = o2.Alan; guven = o2.Guven;
            }
            else if (etiketDizini.TryGetValue(anahtar, out var birebir))
            {
                alan = birebir; guven = 97;
            }
            else
            {
                // ICERME: "MÜŞTERİ ÜNVANI" -> "Unvan". En uzun eslesme kazanir;
                //   kisa parcalar ("AD") her seye uyup yanlis eslerdi.
                var enIyi = etiketDizini
                    .Where(e => e.Key.Length >= 3
                                && (anahtar.Contains(e.Key, StringComparison.Ordinal)
                                    || e.Key.Contains(anahtar, StringComparison.Ordinal)))
                    .OrderByDescending(e => e.Key.Length)
                    .FirstOrDefault();
                if (enIyi.Value is not null) { alan = enIyi.Value; guven = 70; }
            }

            if (alan.Length > 0 && !kullanilan.Add(alan)) { alan = ""; guven = 0; }
            sonuc.Add(new EslemeSatiri(baslik, alan, guven, ornek));
        }
        return sonuc;
    }

    // =========================================================== ONIZLEME ====

    /// <param name="Durum">yeni · degisecek · sorunlu</param>
    public sealed record OnizlemeSatiri(int SatirNo, string Durum, string Anahtar,
                                        string Ozet, string Not, long? MevcutId);

    public sealed record OnizlemeSonucu(int Toplam, int Yeni, int Degisecek, int Sorunlu,
                                        IReadOnlyList<OnizlemeSatiri> Satirlar);

    /// <summary>Cozulmus satir: yazilacak degerler + varsa hata.</summary>
    private sealed record CozulmusSatir(int SatirNo, Dictionary<string, object?> Degerler,
                                        string Anahtar, string? Hata, long? MevcutId);

    /// <summary>
    /// Sayi bicimi: "tr" (1.234,56) · "en" (1,234.56). Excel dokumlerinde ikisi
    /// de geliyor ve yanlis okumak sessizce 1000 kat sapma demek.
    /// </summary>
    private static decimal? SayiCoz(string ham, string bicim)
    {
        var s = ham.Trim();
        if (s.Length == 0) return null;
        s = s.Replace("₺", "").Replace("TL", "", StringComparison.OrdinalIgnoreCase).Trim();
        s = bicim == "en"
            ? s.Replace(",", "")                        // binlik virgul atilir
            : s.Replace(".", "").Replace(',', '.');     // tr: binlik nokta, ondalik virgul
        return decimal.TryParse(s, NumberStyles.Number, CultureInfo.InvariantCulture, out var d)
               ? d : null;
    }

    private static DateTime? TarihCoz(string ham)
    {
        var s = ham.Trim();
        if (s.Length == 0) return null;
        var tr = new CultureInfo("tr-TR");
        if (DateTime.TryParse(s, tr, DateTimeStyles.None, out var t1)) return t1;
        if (DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out var t2)) return t2;
        // Excel seri numarasi (45000 gibi) - hucre metin olarak gelmis olabilir.
        if (double.TryParse(s, NumberStyles.Number, CultureInfo.InvariantCulture, out var seri)
            && seri is > 20000 and < 60000)
            return DateTime.FromOADate(seri);
        return null;
    }

    /// <summary>Kod alani: sayi ise dogrudan, degilse AD uzerinden cozulur.</summary>
    private static async Task<object?> KodCozAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, KartAlani alan, string ham,
        Dictionary<string, Dictionary<string, string>> onbellek, CancellationToken iptal)
    {
        var s = ham.Trim();
        if (s.Length == 0) return null;
        if (long.TryParse(s, NumberStyles.Integer, CultureInfo.InvariantCulture, out var sayi))
            return sayi;

        var anahtar = ExcelOkuma.BaslikAnahtari(s);

        if (alan.SabitKodlar is not null)
        {
            var bulunan = alan.SabitKodlar.FirstOrDefault(
                k => ExcelOkuma.BaslikAnahtari(k.Value) == anahtar);
            if (bulunan.Key is not null)
                return long.TryParse(bulunan.Key, out var sk) ? sk : bulunan.Key;
            return null;
        }

        if (alan.KodListesi is not null)
        {
            if (!onbellek.TryGetValue("L:" + alan.KodListesi, out var harita))
            {
                harita = new Dictionary<string, string>(StringComparer.Ordinal);
                await using var komut = new NpgsqlCommand(
                    "select kd.deger, kd.ad from public.kod_deger kd "
                    + "  join public.kod_liste kl on kl.id = kd.liste_id "
                    + " where kl.kod = @p0", baglanti, islem);
                komut.Parameters.AddWithValue("p0", alan.KodListesi);
                await using var o = await komut.ExecuteReaderAsync(iptal);
                while (await o.ReadAsync(iptal))
                    harita[ExcelOkuma.BaslikAnahtari(o.GetString(1))] =
                        o.GetInt32(0).ToString(CultureInfo.InvariantCulture);
                onbellek["L:" + alan.KodListesi] = harita;
            }
            return harita.TryGetValue(anahtar, out var deger) && long.TryParse(deger, out var l)
                   ? l : (object?)null;
        }

        // KodTablosu (kategori, cari...): ada gore id. Tablo adi KATALOGDAN gelir.
        if (alan.KodTablosu is not null)
        {
            if (!onbellek.TryGetValue("T:" + alan.KodTablosu, out var harita))
            {
                harita = new Dictionary<string, string>(StringComparer.Ordinal);
                await using var komut = new NpgsqlCommand(
                    $"select id, ad from {alan.KodTablosu}", baglanti, islem);
                await using var o = await komut.ExecuteReaderAsync(iptal);
                while (await o.ReadAsync(iptal))
                    harita[ExcelOkuma.BaslikAnahtari(o.GetString(1))] =
                        o.GetInt32(0).ToString(CultureInfo.InvariantCulture);
                onbellek["T:" + alan.KodTablosu] = harita;
            }
            return harita.TryGetValue(anahtar, out var deger) && long.TryParse(deger, out var l)
                   ? l : (object?)null;
        }

        return s;   // serbest kod (hesap turu gibi harf kodlar)
    }

    private static async Task<List<CozulmusSatir>> SatirlariCozAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, Hedef hedef, KartTanimi? kart,
        ExcelOkuma.Sayfa sayfa, IReadOnlyDictionary<string, string> esleme, string sayiBicimi,
        CancellationToken iptal)
    {
        var hedefAlanlari = HedefAlanlari(hedef);
        var alanDizini = hedefAlanlari.ToDictionary(a => a.Ad, StringComparer.Ordinal);
        var onbellek = new Dictionary<string, Dictionary<string, string>>(StringComparer.Ordinal);

        // Esleme: EXCEL BASLIGI (normalize) -> alan adi.
        var harita = esleme
            .Where(e => e.Value.Length > 0 && alanDizini.ContainsKey(e.Value))
            .ToDictionary(e => ExcelOkuma.BaslikAnahtari(e.Key), e => e.Value, StringComparer.Ordinal);

        if (harita.Count == 0)
            throw GentegreHatasi.Dogrulama("Hiçbir kolon eşlenmedi.",
                new AlanHatasi("esleme", "En az bir kolon eşlenmeli."));

        // Zorunlu alanlardan eslenmeyen varsa dosya bastan yazilamaz - satir
        //   satir "zorunlu bos" demek yerine tek net mesaj.
        var eksikZorunlu = hedefAlanlari
            .Where(a => a.Zorunlu && !harita.Values.Contains(a.Ad, StringComparer.Ordinal))
            .Select(a => a.Etiket).ToList();
        if (eksikZorunlu.Count > 0)
            throw GentegreHatasi.Dogrulama(
                "Zorunlu alanlar eşlenmedi: " + string.Join(", ", eksikZorunlu),
                new AlanHatasi("esleme", "Zorunlu alan eksik."));

        var anahtarAlanlari = hedef.Anahtarlar.Where(alanDizini.ContainsKey).ToArray();
        var sonuc = new List<CozulmusSatir>(sayfa.Satirlar.Count);
        // Dosya ICINDE ayni anahtar iki kez: hangisi dogru belli degil - ikisi de sorunlu.
        var dosyaAnahtarlari = new Dictionary<string, int>(StringComparer.Ordinal);

        foreach (var (satirNo, hucreler) in sayfa.Satirlar)
        {
            var degerler = new Dictionary<string, object?>(StringComparer.Ordinal);
            string? hata = null;

            foreach (var (baslikAnahtari, alanAdi) in harita)
            {
                if (!hucreler.TryGetValue(baslikAnahtari, out var ham) || ham.Trim().Length == 0)
                    continue;                               // BOS HUCRE YAZILMAZ
                var alan = alanDizini[alanAdi];
                object? deger;
                switch (alan.Tip)
                {
                    case "para" or "ondalik":
                        deger = SayiCoz(ham, sayiBicimi);
                        if (deger is null) hata ??= $"{alan.Etiket}: sayı çözülemedi ({ham}).";
                        break;
                    case "sayi":
                        var s2 = SayiCoz(ham, sayiBicimi);
                        deger = s2 is null ? null : (object)(long)decimal.Truncate(s2.Value);
                        if (deger is null) hata ??= $"{alan.Etiket}: sayı çözülemedi ({ham}).";
                        break;
                    case "tarih" or "zaman":
                        deger = TarihCoz(ham);
                        if (deger is null) hata ??= $"{alan.Etiket}: tarih çözülemedi ({ham}).";
                        break;
                    case "mantik":
                        var e = ExcelOkuma.BaslikAnahtari(ham);
                        deger = (short)(e is "1" or "EVET" or "VAR" or "TRUE" or "X" ? 1 : 0);
                        break;
                    case "kod":
                        deger = await KodCozAsync(baglanti, islem, alan, ham, onbellek, iptal);
                        if (deger is null) hata ??= $"{alan.Etiket}: \"{ham}\" listede yok.";
                        break;
                    default:
                        var metin = ham.Trim();
                        if (alan.EnFazlaUzunluk is { } uzun && metin.Length > uzun)
                            hata ??= $"{alan.Etiket}: en çok {uzun} karakter ({metin.Length}).";
                        deger = metin;
                        break;
                }
                if (deger is not null) degerler[alanAdi] = deger;
            }

            foreach (var a in hedefAlanlari.Where(a => a.Zorunlu))
                if (!degerler.ContainsKey(a.Ad))
                    hata ??= $"{a.Etiket} zorunlu, satırda boş.";

            // ---- cakisma anahtari -------------------------------------------
            var anahtarAlan = anahtarAlanlari.FirstOrDefault(
                a => degerler.TryGetValue(a, out var v) && (v?.ToString() ?? "").Length > 0);
            var anahtarDeger = anahtarAlan is null ? "" : degerler[anahtarAlan]?.ToString() ?? "";
            long? mevcutId = null;

            if (kart is not null && anahtarAlan is not null && anahtarDeger.Length > 0)
            {
                var imza = anahtarAlan + "=" + anahtarDeger;
                if (dosyaAnahtarlari.TryGetValue(imza, out var ilkSatir))
                    hata ??= $"Aynı {alanDizini[anahtarAlan].Etiket} {ilkSatir}. satırda da var.";
                else
                    dosyaAnahtarlari[imza] = satirNo;

                var kolon = alanDizini[anahtarAlan].Kolon;
                var kosul = kart.SabitKosul is null ? "" : $" and {kart.SabitKosul}";
                await using var komut = new NpgsqlCommand(
                    $"select {kart.IdKolonu} from {kart.Tablo} "
                    + $" where {kolon} = @p0{kosul} limit 1", baglanti, islem);
                komut.Parameters.AddWithValue("p0", anahtarDeger);
                var bulunan = await komut.ExecuteScalarAsync(iptal);
                if (bulunan is not null and not DBNull) mevcutId = Convert.ToInt64(bulunan);
            }

            sonuc.Add(new CozulmusSatir(satirNo, degerler, anahtarDeger, hata, mevcutId));
        }
        return sonuc;
    }

    public static async Task<OnizlemeSonucu> OnizleAsync(
        VeriKaynagi veri, Hedef hedef, ExcelOkuma.Sayfa sayfa,
        IReadOnlyDictionary<string, string> esleme, string sayiBicimi,
        int? listeId, CancellationToken iptal)
    {
        if (hedef.Tur == "fiyat-listesi")
            return await FiyatOnizleAsync(veri, hedef, sayfa, esleme, sayiBicimi, listeId, iptal);
        if (hedef.Tur == "belge")
            return await FaturaOnizleAsync(veri, hedef, sayfa, esleme, sayiBicimi, iptal);

        var kart = KartBul(hedef);
        await using var baglanti = await veri.AcAsync(iptal);
        var satirlar = await SatirlariCozAsync(baglanti, null, hedef, kart, sayfa, esleme,
                                               sayiBicimi, iptal);

        // Ozet sutunu: kullanicinin satiri TANIYACAGI alan (ad/unvan).
        var ozetAlani = kart.Alan("unvan") is not null ? "unvan" : "ad";

        var gorunum = satirlar.Select(s => new OnizlemeSatiri(
            s.SatirNo,
            s.Hata is not null ? "sorunlu" : s.MevcutId is not null ? "degisecek" : "yeni",
            s.Anahtar,
            s.Degerler.TryGetValue(ozetAlani, out var o) ? o?.ToString() ?? "" : "",
            s.Hata ?? "",
            s.MevcutId)).ToList();

        return new OnizlemeSonucu(
            gorunum.Count,
            gorunum.Count(g => g.Durum == "yeni"),
            gorunum.Count(g => g.Durum == "degisecek"),
            gorunum.Count(g => g.Durum == "sorunlu"),
            gorunum);
    }

    // ============================================================= UYGULAMA ====

    public sealed record UygulamaSonucu(int YuklemeNo, int Eklenen, int Guncellenen,
                                        int Atlanan, int Toplam, string Mesaj);

    /// <summary>
    /// YAZMA. Tek transaction: ya hepsi ya hicbiri. Sorunlu satirlar yazilmaz
    /// ve "atlanan" sayilir - dosyanin tamami reddedilmez, cunku 1.200 satirlik
    /// dokumun 8 satiri yuzunden hicbir seyin girmemesi kullaniciyi dosyayi
    /// elle bolmeye zorlar. Atlananlar sonuc raporunda satir numarasiyla durur.
    /// </summary>
    public static async Task<UygulamaSonucu> UygulaAsync(
        VeriKaynagi veri, LogDeposu log, BelgeDeposu belgeDeposu, Hedef hedef,
        ExcelOkuma.Sayfa sayfa, IReadOnlyDictionary<string, string> esleme, string sayiBicimi,
        string dosyaAdi, int? listeId, int kullaniciId, int? subeId, string ip,
        CancellationToken iptal)
    {
        if (hedef.Tur == "fiyat-listesi")
            return await FiyatUygulaAsync(veri, hedef, sayfa, esleme, sayiBicimi, dosyaAdi,
                                          listeId, kullaniciId, subeId, iptal);
        if (hedef.Tur == "belge")
            return await FaturaUygulaAsync(veri, belgeDeposu, hedef, sayfa, esleme, sayiBicimi,
                                           dosyaAdi, kullaniciId, subeId, ip, iptal);

        var kart = KartBul(hedef);
        var basla = DateTime.UtcNow;

        await using var baglanti = await veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        var satirlar = await SatirlariCozAsync(baglanti, islem, hedef, kart, sayfa, esleme,
                                               sayiBicimi, iptal);

        // Yukleme kaydi ONCE acilir: yazilan kartlarin logu bu numarayi tasiyor.
        await using var yuklemeKomut = new NpgsqlCommand(
            "insert into public.iceri_alma (hedef, dosya_adi, satir_sayisi, esleme, "
            + "       kullanici_id, sube_id, durum) "
            + "values (@p0, @p1, @p2, @p3::jsonb, @p4, @p5, 1) returning id",
            baglanti, islem);
        yuklemeKomut.Parameters.AddWithValue("p0", hedef.Ad);
        yuklemeKomut.Parameters.AddWithValue("p1", dosyaAdi.Length > 200 ? dosyaAdi[..200] : dosyaAdi);
        yuklemeKomut.Parameters.AddWithValue("p2", satirlar.Count);
        yuklemeKomut.Parameters.AddWithValue("p3", JsonSerializer.Serialize(esleme));
        yuklemeKomut.Parameters.AddWithValue("p4", kullaniciId);
        yuklemeKomut.Parameters.AddWithValue("p5", (object?)subeId ?? DBNull.Value);
        var yuklemeNo = Convert.ToInt32(await yuklemeKomut.ExecuteScalarAsync(iptal));

        int eklenen = 0, guncellenen = 0, atlanan = 0;
        var alanDizini = Alanlar(kart).ToDictionary(a => a.Ad, StringComparer.Ordinal);

        foreach (var satir in satirlar)
        {
            if (satir.Hata is not null) { atlanan++; continue; }

            var degerler = new Dictionary<string, object?>(satir.Degerler, StringComparer.Ordinal);

            if (satir.MevcutId is { } mevcut)
            {
                var atamalar = new List<string>();
                var parametreler = new List<object?>();
                foreach (var (ad, deger) in degerler)
                {
                    atamalar.Add($"{alanDizini[ad].Kolon} = @p{parametreler.Count}");
                    parametreler.Add(deger);
                }
                atamalar.Add($"degistiren = @p{parametreler.Count}");
                parametreler.Add(kullaniciId);
                parametreler.Add(mevcut);

                await using var komut = new NpgsqlCommand(
                    $"update {kart.Tablo} set {string.Join(", ", atamalar)} "
                    + $" where {kart.IdKolonu} = @p{parametreler.Count - 1}", baglanti, islem);
                for (var i = 0; i < parametreler.Count; i++)
                    komut.Parameters.AddWithValue("p" + i, parametreler[i] ?? DBNull.Value);
                await komut.ExecuteNonQueryAsync(iptal);
                guncellenen++;

                await LogYazAsync(log, baglanti, islem, kart, LogIslemi.Degistir, mevcut,
                                  degerler, yuklemeNo, kullaniciId, subeId, ip, iptal);
            }
            else
            {
                foreach (var (ad, deger) in kart.YeniKayitVarsayilanlari
                                            ?? new Dictionary<string, object?>())
                    if (!degerler.ContainsKey(ad) && alanDizini.ContainsKey(ad))
                        degerler[ad] = deger;

                var kolonlar = new List<string>();
                var yerTutucular = new List<string>();
                var parametreler = new List<object?>();
                foreach (var (ad, deger) in degerler)
                {
                    if (!alanDizini.TryGetValue(ad, out var alan)) continue;
                    kolonlar.Add(alan.Kolon);
                    yerTutucular.Add("@p" + parametreler.Count);
                    parametreler.Add(deger);
                }
                // SUBE: kart yazmasindaki kuralin aynisi (KartDeposu.EkleAsync).
                //   `taraf.sube_id` NOT NULL oldugu halde cari kartinin
                //   SubeKolonu'su null - sube bilgisi orada GIZLI ALAN olarak
                //   duruyor. Iki kosuldan biri yeterli; yoksa insert
                //   "subeId bos birakilamaz" ile duser.
                if (!degerler.ContainsKey("subeId") && subeId is { } sb
                    && (kart.SubeKolonu is not null || kart.Alan("subeId") is not null))
                {
                    kolonlar.Add(kart.SubeKolonu ?? kart.Alan("subeId")!.Kolon);
                    yerTutucular.Add("@p" + parametreler.Count);
                    parametreler.Add(sb);
                }
                kolonlar.Add("ekleyen");
                yerTutucular.Add("@p" + parametreler.Count);
                parametreler.Add(kullaniciId);

                await using var komut = new NpgsqlCommand(
                    $"insert into {kart.Tablo} ({string.Join(", ", kolonlar)}) "
                    + $"values ({string.Join(", ", yerTutucular)}) returning {kart.IdKolonu}",
                    baglanti, islem);
                for (var i = 0; i < parametreler.Count; i++)
                    komut.Parameters.AddWithValue("p" + i, parametreler[i] ?? DBNull.Value);
                var yeniId = Convert.ToInt64(await komut.ExecuteScalarAsync(iptal));
                eklenen++;

                // KOD BOSSA ID YAZILIR - kart yazmasindaki kuralin aynisi
                //   (KartDeposu.EkleAsync). Kodsuz cari listede bos sutunla
                //   duruyor ve belge ekraninda aranamiyor. Tetik kod verdiyse
                //   (hasta dosya no) DOKUNULMAZ: kosul kolonun HALA bos olmasi.
                if (kart.Alan("kod") is { Zorunlu: false } kodAlan
                    && !degerler.ContainsKey("kod"))
                {
                    await using var kodKomut = new NpgsqlCommand(
                        $"update {kart.Tablo} set {kodAlan.Kolon} = @p0 "
                        + $" where {kart.IdKolonu} = @p1 "
                        + $"   and coalesce(btrim({kodAlan.Kolon}), '') = ''",
                        baglanti, islem);
                    kodKomut.Parameters.AddWithValue("p0",
                        yeniId.ToString(CultureInfo.InvariantCulture));
                    kodKomut.Parameters.AddWithValue("p1", yeniId);
                    await kodKomut.ExecuteNonQueryAsync(iptal);
                }

                await LogYazAsync(log, baglanti, islem, kart, LogIslemi.Ekle, yeniId,
                                  degerler, yuklemeNo, kullaniciId, subeId, ip, iptal);
            }
        }

        var sure = (int)(DateTime.UtcNow - basla).TotalMilliseconds;
        var mesaj = $"{eklenen:N0} eklendi · {guncellenen:N0} güncellendi"
                    + (atlanan > 0 ? $" · {atlanan:N0} atlandı" : "");

        await using (var bitir = new NpgsqlCommand(
            "update public.iceri_alma set eklenen = @p1, guncellenen = @p2, atlanan = @p3, "
            + "       durum = @p4, mesaj = @p5, sure_ms = @p6 where id = @p0",
            baglanti, islem))
        {
            bitir.Parameters.AddWithValue("p0", yuklemeNo);
            bitir.Parameters.AddWithValue("p1", eklenen);
            bitir.Parameters.AddWithValue("p2", guncellenen);
            bitir.Parameters.AddWithValue("p3", atlanan);
            bitir.Parameters.AddWithValue("p4", (short)(atlanan > 0 ? 2 : 1));
            bitir.Parameters.AddWithValue("p5", mesaj);
            bitir.Parameters.AddWithValue("p6", sure);
            await bitir.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
        return new UygulamaSonucu(yuklemeNo, eklenen, guncellenen, atlanan, satirlar.Count, mesaj);
    }


    // =================================================== FIYAT LISTESI SATIRI ====
    //
    // Kart degil, SECILEN listenin satirlari. Kalem KOD ile cozulur: musteri
    //   dokumunde id yok, kod var. Tek "Kod" sutunu geldiyse once stokta,
    //   yoksa hizmette aranir; IKISINDE de varsa satir hatalidir - belirsizlik
    //   sessizce yanlis kaleme fiyat yazdirir (207'deki kural).

    /// <summary>Kalem cozumu: (stokId, hizmetId) ya da hata metni.</summary>
    private static async Task<(int? StokId, int? HizmetId, string? Hata)> KalemCozAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        Dictionary<string, object?> degerler,
        Dictionary<string, (int? S, int? H)> onbellek, CancellationToken iptal)
    {
        string Metin(string ad)
            => degerler.TryGetValue(ad, out var v) ? v?.ToString()?.Trim() ?? "" : "";
        var stokKodu = Metin("stokKodu");
        var hizmetKodu = Metin("hizmetKodu");
        var tekKod = Metin("kod");

        if (stokKodu.Length == 0 && hizmetKodu.Length == 0 && tekKod.Length == 0)
            return (null, null, "Kalem kodu boş.");

        async Task<int?> IdAsync(string tablo, string kod)
        {
            await using var komut = new NpgsqlCommand(
                $"select id from public.{tablo} where kod = @p0 limit 1", baglanti, islem);
            komut.Parameters.AddWithValue("p0", kod);
            var v = await komut.ExecuteScalarAsync(iptal);
            return v is null or DBNull ? null : Convert.ToInt32(v);
        }

        var anahtar = $"{stokKodu}|{hizmetKodu}|{tekKod}";
        if (onbellek.TryGetValue(anahtar, out var hazir))
            return (hazir.S, hazir.H,
                    hazir.S is null && hazir.H is null ? "Kalem bulunamadı." : null);

        int? s = null, h = null;
        if (stokKodu.Length > 0) s = await IdAsync("stok", stokKodu);
        if (hizmetKodu.Length > 0) h = await IdAsync("hizmet", hizmetKodu);
        if (s is null && h is null && tekKod.Length > 0)
        {
            s = await IdAsync("stok", tekKod);
            h = await IdAsync("hizmet", tekKod);
            // IKISINDE DE VARSA satir hatalidir: sessizce birini secmek, yanlis
            //   kaleme fiyat/kalem yazmanin en sik yolu.
            if (s is not null && h is not null)
                return (null, null, $"\"{tekKod}\" hem stokta hem hizmette var - hangisi?");
        }

        onbellek[anahtar] = (s, h);
        if (s is null && h is null)
        {
            var gosterilen = tekKod.Length > 0 ? tekKod
                             : stokKodu.Length > 0 ? stokKodu : hizmetKodu;
            return (null, null, $"\"{gosterilen}\" kalemi bulunamadı.");
        }
        return (s, h, null);
    }

    /// <summary>Cozulmus fiyat satiri (onizleme ve yazma ortak kullanir).</summary>
    private sealed record FiyatSatiri(int SatirNo, Dictionary<string, object?> Degerler,
                                      int? StokId, int? HizmetId, long? MevcutId, string? Hata);

    private static async Task<List<FiyatSatiri>> FiyatSatirlariAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, Hedef hedef,
        ExcelOkuma.Sayfa sayfa, IReadOnlyDictionary<string, string> esleme,
        string sayiBicimi, int listeId, CancellationToken iptal)
    {
        var ham = await SatirlariCozAsync(baglanti, islem, hedef, null, sayfa, esleme,
                                          sayiBicimi, iptal);
        var kalemOnbellek = new Dictionary<string, (int?, int?)>(StringComparer.Ordinal);
        var dosyada = new Dictionary<string, int>(StringComparer.Ordinal);
        var sonuc = new List<FiyatSatiri>(ham.Count);

        foreach (var satir in ham)
        {
            if (satir.Hata is not null)
            {
                sonuc.Add(new FiyatSatiri(satir.SatirNo, satir.Degerler, null, null, null,
                                          satir.Hata));
                continue;
            }

            var (stokId, hizmetId, hata) = await KalemCozAsync(baglanti, islem, satir.Degerler,
                                                               kalemOnbellek, iptal);
            if (hata is not null)
            {
                sonuc.Add(new FiyatSatiri(satir.SatirNo, satir.Degerler, null, null, null, hata));
                continue;
            }

            // Ayni kalem dosyada iki kez: hangi fiyat gecerli belirsiz.
            var imza = $"{stokId}|{hizmetId}";
            if (dosyada.TryGetValue(imza, out var ilk))
            {
                sonuc.Add(new FiyatSatiri(satir.SatirNo, satir.Degerler, stokId, hizmetId, null,
                                          $"Aynı kalem {ilk}. satırda da var."));
                continue;
            }
            dosyada[imza] = satir.SatirNo;

            await using var komut = new NpgsqlCommand(
                "select id from public.fiyat_listesi_satir "
                + " where liste_id = @p0 "
                + "   and coalesce(stok_id, 0) = @p1 and coalesce(hizmet_id, 0) = @p2 limit 1",
                baglanti, islem);
            komut.Parameters.AddWithValue("p0", listeId);
            komut.Parameters.AddWithValue("p1", stokId ?? 0);
            komut.Parameters.AddWithValue("p2", hizmetId ?? 0);
            var mevcut = await komut.ExecuteScalarAsync(iptal);
            sonuc.Add(new FiyatSatiri(satir.SatirNo, satir.Degerler, stokId, hizmetId,
                                      mevcut is null or DBNull ? null : Convert.ToInt64(mevcut),
                                      null));
        }
        return sonuc;
    }

    private static int ListeIste(int? listeId)
        => listeId is > 0 ? listeId.Value
           : throw GentegreHatasi.Dogrulama("Hangi fiyat listesine yazılacağı seçilmedi.",
                 new AlanHatasi("listeId", "Fiyat listesi seçin."));

    private static async Task<OnizlemeSonucu> FiyatOnizleAsync(
        VeriKaynagi veri, Hedef hedef, ExcelOkuma.Sayfa sayfa,
        IReadOnlyDictionary<string, string> esleme, string sayiBicimi, int? listeId,
        CancellationToken iptal)
    {
        var liste = ListeIste(listeId);
        await using var baglanti = await veri.AcAsync(iptal);
        var satirlar = await FiyatSatirlariAsync(baglanti, null, hedef, sayfa, esleme,
                                                 sayiBicimi, liste, iptal);

        string Kod(FiyatSatiri x)
        {
            foreach (var ad in new[] { "kod", "stokKodu", "hizmetKodu" })
                if (x.Degerler.TryGetValue(ad, out var v) && (v?.ToString() ?? "").Length > 0)
                    return v!.ToString()!;
            return "";
        }

        var gorunum = satirlar.Select(x => new OnizlemeSatiri(
            x.SatirNo,
            x.Hata is not null ? "sorunlu" : x.MevcutId is not null ? "degisecek" : "yeni",
            Kod(x),
            x.Degerler.TryGetValue("fiyat", out var f) ? $"Fiyat {f}" : "",
            x.Hata ?? "", x.MevcutId)).ToList();

        return new OnizlemeSonucu(gorunum.Count,
            gorunum.Count(g => g.Durum == "yeni"),
            gorunum.Count(g => g.Durum == "degisecek"),
            gorunum.Count(g => g.Durum == "sorunlu"), gorunum);
    }

    private static async Task<UygulamaSonucu> FiyatUygulaAsync(
        VeriKaynagi veri, Hedef hedef, ExcelOkuma.Sayfa sayfa,
        IReadOnlyDictionary<string, string> esleme, string sayiBicimi, string dosyaAdi,
        int? listeId, int kullaniciId, int? subeId, CancellationToken iptal)
    {
        var liste = ListeIste(listeId);
        var basla = DateTime.UtcNow;

        await using var baglanti = await veri.AcAsync(iptal);
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        // Listenin KDV kurali satira kopyalanir (495): satirda ayri bir KDV
        //   sorusu yok - liste "dahil" dediyse tum satirlar dahildir.
        short listeKdvDahil;
        await using (var k = new NpgsqlCommand(
            "select kdv_dahil from public.fiyat_listesi where id = @p0", baglanti, islem))
        {
            k.Parameters.AddWithValue("p0", liste);
            var v = await k.ExecuteScalarAsync(iptal);
            if (v is null or DBNull) throw GentegreHatasi.Bulunamadi("Fiyat listesi bulunamadı.");
            listeKdvDahil = Convert.ToInt16(v);
        }

        var satirlar = await FiyatSatirlariAsync(baglanti, islem, hedef, sayfa, esleme,
                                                 sayiBicimi, liste, iptal);
        var yuklemeNo = await YuklemeAcAsync(baglanti, islem, hedef, dosyaAdi, satirlar.Count,
                                             esleme, kullaniciId, subeId, iptal);

        int eklenen = 0, guncellenen = 0, atlanan = 0;
        foreach (var x in satirlar)
        {
            if (x.Hata is not null) { atlanan++; continue; }

            var fiyat = x.Degerler.TryGetValue("fiyat", out var f) && f is decimal d ? d : 0m;
            var katki = x.Degerler.TryGetValue("katkiTutar", out var kt) && kt is decimal kd ? kd : 0m;
            var doviz = x.Degerler.TryGetValue("dovizCinsi", out var dv)
                        ? (dv?.ToString() ?? "TL").Trim().ToUpperInvariant() : "TL";
            if (doviz.Length is 0 or > 5) doviz = "TL";
            var durumMetni = x.Degerler.TryGetValue("durum", out var du)
                             ? ExcelOkuma.BaslikAnahtari(du?.ToString() ?? "") : "";
            var durum = (short)(durumMetni is "PASİF" or "PASIF" or "0" ? 0 : 1);

            if (x.MevcutId is { } mevcut)
            {
                await using var komut = new NpgsqlCommand(
                    "update public.fiyat_listesi_satir "
                    // yazim = 3 (Import) yaziyoruz ama fiyat DEGISTIYSE DB
                    //   tetigi (trg_sls_carpan_manuel) bunu 1'e (Manuel)
                    //   cevirir. Ikisi de ayni isi goruyor: "Listeyi Üret"
                    //   bu satiri EZMEZ. Tetikle yarismiyoruz.
                    + "   set fiyat = @p1, katki_tutar = @p2, doviz_cinsi = @p3, "
                    + "       kdv_dahil = @p4, durum = @p5, yazim = 3, degistiren = @p6, "
                    + "       degistirme_tarihi = now()::timestamp "
                    + " where id = @p0", baglanti, islem);
                komut.Parameters.AddWithValue("p0", mevcut);
                komut.Parameters.AddWithValue("p1", fiyat);
                komut.Parameters.AddWithValue("p2", katki);
                komut.Parameters.AddWithValue("p3", doviz);
                komut.Parameters.AddWithValue("p4", listeKdvDahil);
                komut.Parameters.AddWithValue("p5", durum);
                komut.Parameters.AddWithValue("p6", kullaniciId);
                await komut.ExecuteNonQueryAsync(iptal);
                guncellenen++;
            }
            else
            {
                await using var komut = new NpgsqlCommand(
                    "insert into public.fiyat_listesi_satir "
                    + "       (liste_id, stok_id, hizmet_id, fiyat, katki_tutar, doviz_cinsi, "
                    + "        kdv_dahil, durum, yazim, ekleyen) "
                    + "values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, 3, @p8)",
                    baglanti, islem);
                komut.Parameters.AddWithValue("p0", liste);
                komut.Parameters.AddWithValue("p1", (object?)x.StokId ?? DBNull.Value);
                komut.Parameters.AddWithValue("p2", (object?)x.HizmetId ?? DBNull.Value);
                komut.Parameters.AddWithValue("p3", fiyat);
                komut.Parameters.AddWithValue("p4", katki);
                komut.Parameters.AddWithValue("p5", doviz);
                komut.Parameters.AddWithValue("p6", listeKdvDahil);
                komut.Parameters.AddWithValue("p7", durum);
                komut.Parameters.AddWithValue("p8", kullaniciId);
                await komut.ExecuteNonQueryAsync(iptal);
                eklenen++;
            }
        }

        var mesaj = $"{eklenen:N0} satır eklendi · {guncellenen:N0} güncellendi"
                    + (atlanan > 0 ? $" · {atlanan:N0} atlandı" : "");
        await YuklemeKapatAsync(baglanti, islem, yuklemeNo, eklenen, guncellenen, atlanan,
                                mesaj, (int)(DateTime.UtcNow - basla).TotalMilliseconds, iptal);
        await islem.CommitAsync(iptal);
        return new UygulamaSonucu(yuklemeNo, eklenen, guncellenen, atlanan, satirlar.Count, mesaj);
    }

    // ------------------------------------------------- yukleme kaydi (ortak) ----
    private static async Task<int> YuklemeAcAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, Hedef hedef, string dosyaAdi,
        int satirSayisi, IReadOnlyDictionary<string, string> esleme,
        int kullaniciId, int? subeId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "insert into public.iceri_alma (hedef, dosya_adi, satir_sayisi, esleme, "
            + "       kullanici_id, sube_id, durum) "
            + "values (@p0, @p1, @p2, @p3::jsonb, @p4, @p5, 1) returning id",
            baglanti, islem);
        komut.Parameters.AddWithValue("p0", hedef.Ad);
        komut.Parameters.AddWithValue("p1", dosyaAdi.Length > 200 ? dosyaAdi[..200] : dosyaAdi);
        komut.Parameters.AddWithValue("p2", satirSayisi);
        komut.Parameters.AddWithValue("p3", JsonSerializer.Serialize(esleme));
        komut.Parameters.AddWithValue("p4", kullaniciId);
        komut.Parameters.AddWithValue("p5", (object?)subeId ?? DBNull.Value);
        return Convert.ToInt32(await komut.ExecuteScalarAsync(iptal));
    }

    private static async Task YuklemeKapatAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, int yuklemeNo,
        int eklenen, int guncellenen, int atlanan, string mesaj, int sureMs,
        CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "update public.iceri_alma set eklenen = @p1, guncellenen = @p2, atlanan = @p3, "
            + "       durum = @p4, mesaj = @p5, sure_ms = @p6 where id = @p0",
            baglanti, islem);
        komut.Parameters.AddWithValue("p0", yuklemeNo);
        komut.Parameters.AddWithValue("p1", eklenen);
        komut.Parameters.AddWithValue("p2", guncellenen);
        komut.Parameters.AddWithValue("p3", atlanan);
        komut.Parameters.AddWithValue("p4", (short)(atlanan > 0 ? 2 : 1));
        komut.Parameters.AddWithValue("p5", mesaj.Length > 400 ? mesaj[..400] : mesaj);
        komut.Parameters.AddWithValue("p6", sureMs);
        await komut.ExecuteNonQueryAsync(iptal);
    }


    // ============================================================== FATURA ====
    //
    // Musteri dokumu DUZ gelir: her Excel satiri bir KALEMDIR ve ayni fatura
    //   numarasini tasiyan satirlar TEK belgeye aittir. Mockup'taki "baslik ve
    //   kalem iki sayfa" kurgusu daha temiz ama elimizdeki dosyalar oyle degil;
    //   tek sayfayi gruplamak kullaniciyi dosyayi bolmeye zorlamiyor.
    //
    // GRUP ANAHTARI: cari + seri + belge no + tarih. Alis faturasinda numara
    //   TEDARIKCININDIR ve zorunludur (BelgeTuru.DisNumarali(11)); satista
    //   numara bizde uretilir, bu yuzden numarasiz satis dosyasinda grup
    //   anahtari cari + tarih olur - "aynı gün aynı cariye tek fatura".
    //
    // MEVCUT BELGEYE DOKUNULMAZ: ayni cari + numara zaten varsa satir SORUNLU
    //   sayilir. Faturayi guncellemek stok ve cari hareketini geri alip yeniden
    //   yazmak demek; iceri almanin isi degil, kartin isi.

    private sealed record FaturaSatiri(
        int SatirNo, Dictionary<string, object?> Degerler, int? TarafId,
        int? StokId, int? HizmetId, string Anahtar, string CariAdi, string? Hata);

    /// <summary>Cari cozumu: kod -> vergi no -> unvan sirasiyla.</summary>
    private static async Task<(int? Id, string Ad, string? Hata)> CariCozAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem,
        Dictionary<string, object?> degerler,
        Dictionary<string, (int Id, string Ad)> onbellek, CancellationToken iptal)
    {
        string Metin(string ad)
            => degerler.TryGetValue(ad, out var v) ? v?.ToString()?.Trim() ?? "" : "";
        var kod = Metin("cariKodu");
        var vkno = Metin("cariVkno");
        var unvan = Metin("cariUnvan");

        if (kod.Length == 0 && vkno.Length == 0 && unvan.Length == 0)
            return (null, "", "Cari kolonu boş (kod, vergi no ya da unvan gerekli).");

        var anahtar = $"{kod}|{vkno}|{unvan}";
        if (onbellek.TryGetValue(anahtar, out var hazir)) return (hazir.Id, hazir.Ad, null);

        async Task<(int Id, string Ad)?> AraAsync(string kolon, string deger)
        {
            await using var komut = new NpgsqlCommand(
                $"select id, unvan from public.taraf "
                + $" where {kolon} = @p0 and (musteri = 1 or tedarikci = 1 or aday = 1) "
                + " order by id limit 1", baglanti, islem);
            komut.Parameters.AddWithValue("p0", deger);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            return await o.ReadAsync(iptal) ? (o.GetInt32(0), o.GetString(1)) : null;
        }

        var bulunan = kod.Length > 0 ? await AraAsync("kod", kod) : null;
        bulunan ??= vkno.Length > 0 ? await AraAsync("vkno", vkno) : null;
        bulunan ??= unvan.Length > 0 ? await AraAsync("unvan", unvan) : null;

        if (bulunan is null)
        {
            var gosterilen = kod.Length > 0 ? kod : vkno.Length > 0 ? vkno : unvan;
            // CARI ACILMAZ: fatura iceri alirken sessizce cari kartlari
            //   uretmek, yanlis yazilmis bir unvani kalici hale getirir.
            //   Once cari dosyasi alinir, sonra fatura.
            return (null, "", $"\"{gosterilen}\" carisi bulunamadı - önce cari kartını açın.");
        }

        onbellek[anahtar] = bulunan.Value;
        return (bulunan.Value.Id, bulunan.Value.Ad, null);
    }

    private static async Task<List<FaturaSatiri>> FaturaSatirlariAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction? islem, Hedef hedef,
        ExcelOkuma.Sayfa sayfa, IReadOnlyDictionary<string, string> esleme,
        string sayiBicimi, CancellationToken iptal)
    {
        var ham = await SatirlariCozAsync(baglanti, islem, hedef, null, sayfa, esleme,
                                          sayiBicimi, iptal);
        var cariOnbellek = new Dictionary<string, (int, string)>(StringComparer.Ordinal);
        var kalemOnbellek = new Dictionary<string, (int?, int?)>(StringComparer.Ordinal);
        var belgeVar = new Dictionary<string, long>(StringComparer.Ordinal);
        var sonuc = new List<FaturaSatiri>(ham.Count);
        var disNumarali = hedef.BelgeTuru == 11;

        foreach (var satir in ham)
        {
            if (satir.Hata is not null)
            {
                sonuc.Add(new FaturaSatiri(satir.SatirNo, satir.Degerler, null, null, null,
                                           "", "", satir.Hata));
                continue;
            }

            var (tarafId, cariAdi, cariHata) = await CariCozAsync(baglanti, islem,
                                                                  satir.Degerler,
                                                                  cariOnbellek, iptal);
            if (cariHata is not null)
            {
                sonuc.Add(new FaturaSatiri(satir.SatirNo, satir.Degerler, null, null, null,
                                           "", "", cariHata));
                continue;
            }

            var (stokId, hizmetId, kalemHata) = await KalemCozAsync(baglanti, islem,
                                                                    satir.Degerler,
                                                                    kalemOnbellek, iptal);
            if (kalemHata is not null)
            {
                sonuc.Add(new FaturaSatiri(satir.SatirNo, satir.Degerler, tarafId, null, null,
                                           "", cariAdi, kalemHata));
                continue;
            }

            string Metin(string ad)
                => satir.Degerler.TryGetValue(ad, out var v) ? v?.ToString()?.Trim() ?? "" : "";
            var belgeNo = Metin("belgeNo");
            var seri = Metin("belgeSeri");
            var tarih = satir.Degerler.TryGetValue("belgeTarihi", out var t) && t is DateTime dt
                        ? dt : (DateTime?)null;

            if (tarih is null)
            {
                sonuc.Add(new FaturaSatiri(satir.SatirNo, satir.Degerler, tarafId, stokId,
                                           hizmetId, "", cariAdi, "Belge tarihi çözülemedi."));
                continue;
            }
            if (disNumarali && belgeNo.Length == 0)
            {
                sonuc.Add(new FaturaSatiri(satir.SatirNo, satir.Degerler, tarafId, stokId,
                                           hizmetId, "", cariAdi,
                                           "Alış faturasında tedarikçi belge numarası zorunlu."));
                continue;
            }

            var anahtar = $"{tarafId}|{seri}|{belgeNo}|{tarih:yyyyMMdd}";

            // AYNI CARI + NUMARA ZATEN KAYITLI MI: mukerrer fatura, stok ve
            //   cari bakiyesini iki kez oynatir.
            if (belgeNo.Length > 0)
            {
                if (!belgeVar.TryGetValue($"{tarafId}|{belgeNo}", out var mevcutId))
                {
                    await using var komut = new NpgsqlCommand(
                        "select id from public.belge "
                        + " where tur = @p0 and taraf_id = @p1 and belge_no = @p2 limit 1",
                        baglanti, islem);
                    komut.Parameters.AddWithValue("p0", (short)hedef.BelgeTuru);
                    komut.Parameters.AddWithValue("p1", tarafId ?? 0);
                    komut.Parameters.AddWithValue("p2", belgeNo);
                    var v = await komut.ExecuteScalarAsync(iptal);
                    mevcutId = v is null or DBNull ? 0 : Convert.ToInt64(v);
                    belgeVar[$"{tarafId}|{belgeNo}"] = mevcutId;
                }
                if (mevcutId > 0)
                {
                    sonuc.Add(new FaturaSatiri(satir.SatirNo, satir.Degerler, tarafId, stokId,
                                               hizmetId, anahtar, cariAdi,
                                               $"\"{belgeNo}\" numaralı belge bu caride zaten kayıtlı (#{mevcutId})."));
                    continue;
                }
            }

            sonuc.Add(new FaturaSatiri(satir.SatirNo, satir.Degerler, tarafId, stokId, hizmetId,
                                       anahtar, cariAdi, null));
        }
        return sonuc;
    }

    private static async Task<OnizlemeSonucu> FaturaOnizleAsync(
        VeriKaynagi veri, Hedef hedef, ExcelOkuma.Sayfa sayfa,
        IReadOnlyDictionary<string, string> esleme, string sayiBicimi, CancellationToken iptal)
    {
        await using var baglanti = await veri.AcAsync(iptal);
        var satirlar = await FaturaSatirlariAsync(baglanti, null, hedef, sayfa, esleme,
                                                  sayiBicimi, iptal);

        // Bir faturanin ILK satiri "yeni belge", sonrakiler "kalem eklenecek":
        //   kullanici kac BELGE olusacagini gormeli - 400 satir 12 fatura olabilir.
        var gorulen = new HashSet<string>(StringComparer.Ordinal);
        var gorunum = new List<OnizlemeSatiri>(satirlar.Count);
        foreach (var x in satirlar)
        {
            var ilkMi = x.Hata is null && gorulen.Add(x.Anahtar);
            var belgeNo = x.Degerler.TryGetValue("belgeNo", out var b) ? b?.ToString() ?? "" : "";
            var adet = x.Degerler.TryGetValue("adet", out var a) ? a?.ToString() ?? "" : "";
            gorunum.Add(new OnizlemeSatiri(
                x.SatirNo,
                x.Hata is not null ? "sorunlu" : ilkMi ? "yeni" : "degisecek",
                belgeNo,
                $"{x.CariAdi}{(adet.Length > 0 ? $" · {adet} adet" : "")}",
                x.Hata ?? (ilkMi ? "Yeni fatura açılacak" : "Bu faturanın kalemi"),
                null));
        }

        return new OnizlemeSonucu(gorunum.Count,
            gorunum.Count(g => g.Durum == "yeni"),
            gorunum.Count(g => g.Durum == "degisecek"),
            gorunum.Count(g => g.Durum == "sorunlu"), gorunum);
    }

    private static async Task<UygulamaSonucu> FaturaUygulaAsync(
        VeriKaynagi veri, BelgeDeposu belgeDeposu, Hedef hedef, ExcelOkuma.Sayfa sayfa,
        IReadOnlyDictionary<string, string> esleme, string sayiBicimi, string dosyaAdi,
        int kullaniciId, int? subeId, string ip, CancellationToken iptal)
    {
        var basla = DateTime.UtcNow;

        List<FaturaSatiri> satirlar;
        int yuklemeNo;
        await using (var baglanti = await veri.AcAsync(iptal))
        {
            satirlar = await FaturaSatirlariAsync(baglanti, null, hedef, sayfa, esleme,
                                                  sayiBicimi, iptal);
            yuklemeNo = await YuklemeAcAsync(baglanti, null, hedef, dosyaAdi, satirlar.Count,
                                             esleme, kullaniciId, subeId, iptal);
        }

        // HER FATURA KENDI ISLEMI: belge yazma stok hareketi, cari bacagi ve
        //   numara uretimi yapiyor ve kendi transaction'ini aciyor. 300 faturayi
        //   tek transaction'da tutmak hem kilit suresini hem geri alma riskini
        //   buyutur - burada atom birimi FATURADIR, dosya degil.
        var gruplar = satirlar.Where(x => x.Hata is null)
                              .GroupBy(x => x.Anahtar, StringComparer.Ordinal).ToList();
        var atlanan = satirlar.Count(x => x.Hata is not null);
        var yazma = new YazmaBaglami(kullaniciId, subeId, ip);

        int belgeSayisi = 0, kalemSayisi = 0;
        var hatalar = new List<string>();

        foreach (var grup in gruplar)
        {
            var ilk = grup.First();
            string Metin(FaturaSatiri x, string ad)
                => x.Degerler.TryGetValue(ad, out var v) ? v?.ToString()?.Trim() ?? "" : "";
            decimal Sayi(FaturaSatiri x, string ad)
                => x.Degerler.TryGetValue(ad, out var v) && v is decimal d ? d
                   : x.Degerler.TryGetValue(ad, out var v2) && v2 is long l ? l : 0m;

            var doviz = Metin(ilk, "dovizCinsi").ToUpperInvariant();
            if (doviz.Length is 0 or > 5) doviz = "TL";

            var belge = new Dictionary<string, object?>(StringComparer.Ordinal)
            {
                ["tur"] = (long)hedef.BelgeTuru,
                ["belgeTarihi"] = ilk.Degerler["belgeTarihi"],
                ["tarafId"] = (long)(ilk.TarafId ?? 0),
                ["belgeNo"] = Metin(ilk, "belgeNo"),
                ["belgeSeri"] = Metin(ilk, "belgeSeri"),
                ["aciklama"] = Metin(ilk, "aciklama"),
                ["belgeDovizi"] = doviz,
            };

            var belgeSatirlari = new List<Dictionary<string, JsonElement>>();
            foreach (var x in grup)
            {
                var govde = new Dictionary<string, object?>
                {
                    ["tur"] = x.StokId is not null ? 1 : 2,
                    ["stokId"] = x.StokId,
                    ["hizmetId"] = x.HizmetId,
                    ["adet"] = Sayi(x, "adet"),
                    ["birimFiyat"] = Sayi(x, "birimFiyat"),
                    ["kdv"] = (int)Sayi(x, "kdv"),
                    ["iskonto"] = Sayi(x, "iskonto"),
                    ["aciklama"] = Metin(x, "satirAciklama"),
                    ["dovizCinsi"] = doviz,
                };
                belgeSatirlari.Add(JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(
                    JsonSerializer.Serialize(govde))!);
            }

            try
            {
                // STOK KONTROLU KAPALI: gecmis faturalar iceri alinirken stok
                //   bakiyesi henuz olusmamis oluyor; "yetersiz stok" dosyanin
                //   yarisini reddederdi. Hareket yine yazilir, bakiye dogru
                //   yerine oturur.
                await belgeDeposu.KaydetAsync(belge, belgeSatirlari,
                    new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
                    yazma, iptal);
                belgeSayisi++;
                kalemSayisi += grup.Count();
            }
            catch (GentegreHatasi h)
            {
                // Bir fatura duserse otekiler devam eder; sebebi satir
                //   numarasiyla raporlanir.
                atlanan += grup.Count();
                if (hatalar.Count < 5)
                    hatalar.Add($"{ilk.SatirNo}. satır: {h.Message}");
            }
        }

        var mesaj = $"{belgeSayisi:N0} fatura · {kalemSayisi:N0} kalem yazıldı"
                    + (atlanan > 0 ? $" · {atlanan:N0} satır atlandı" : "")
                    + (hatalar.Count > 0 ? " — " + string.Join(" | ", hatalar) : "");

        await using (var baglanti = await veri.AcAsync(iptal))
            await YuklemeKapatAsync(baglanti, null, yuklemeNo, belgeSayisi, 0, atlanan, mesaj,
                                    (int)(DateTime.UtcNow - basla).TotalMilliseconds, iptal);

        return new UygulamaSonucu(yuklemeNo, belgeSayisi, 0, atlanan, satirlar.Count, mesaj);
    }

    /// <summary>Yazilan kartin islem_log satiri - yukleme numarasiyla isaretli.</summary>
    private static Task LogYazAsync(
        LogDeposu log, NpgsqlConnection baglanti, NpgsqlTransaction islem, KartTanimi kart,
        short islemTuru, long kayitId, Dictionary<string, object?> degerler,
        int yuklemeNo, int kullaniciId, int? subeId, string ip, CancellationToken iptal)
    {
        var bilgi = degerler.ToDictionary(
            d => d.Key,
            d => d.Value?.ToString() ?? "",
            StringComparer.Ordinal);
        bilgi["iceriAlma"] = "#" + yuklemeNo.ToString(CultureInfo.InvariantCulture);

        return log.YazAsync(baglanti, islem, islemTuru, kart.LogTabloId, kayitId,
            kullaniciId, subeId, ip, bilgi,
            tarafId: kart.Ad == "cari" ? (int)kayitId : null,
            stokId: kart.Ad == "stok" ? (int)kayitId : null,
            iptal: iptal);
    }
}
