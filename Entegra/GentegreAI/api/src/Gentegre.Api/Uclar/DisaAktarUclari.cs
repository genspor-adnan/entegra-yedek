using System.Globalization;
using System.Text.Json;
using ClosedXML.Excel;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇIKTI MENÜSÜ "Gönder › Excel" ucu (kullanıcı 10.10.2026, İskonto İcmali'nde
/// test). Tarayıcının kendi başına yapamadığı tek iş: gerçek <c>.xlsx</c>
/// (ClosedXML). Belgeyi ekran zaten çizmiştir - sunucu yeni veri OKUMAZ,
/// yalnız istemcinin gönderdiği A4 bloklarını biçimlendirir; bu yüzden ekran
/// yetkisi değil oturum yeter (veri ekrana gelmişse yetki zaten verilmiştir).
///
/// <para><b>Rapor düzeni</b> (kullanıcı: "excel çıktısı iyi olmamış"): antet,
/// birleştirilmiş başlık, bilgi satırları, kenarlıklı ve başlığı renkli
/// tablo, sağda toplamlar, sarılı not; tutar sayı, tarih tarih hücresi;
/// kolon genişliği yalnız tablolardan; A4 sayfa düzeni.</para>
/// </summary>
public static class DisaAktarUclari
{
    public sealed record ExcelOzetSatiri(string? Ad, JsonElement Deger, bool Kalin);
    public sealed record ExcelKutu(string Baslik, string Deger, string Alt, string Renk);

    /// <summary>A4 bloğu (istemci: ciktiDonustur.excelBloklari).</summary>
    public sealed record ExcelBlok(string Tur, string? Metin, string[]? Satirlar, string[]? Sag, string[]? Hucreler,
                                   string[]? Basliklar, JsonElement[][]? TabloSatirlari, int[]? Kalin, bool[]? SagYasli,
                                   ExcelOzetSatiri[]? OzetSatirlari, ExcelKutu[]? Kutular = null, string? Logo = null);

    public sealed record ExcelIstegi(string? DosyaAdi, string? SayfaAdi, JsonElement[]? Bloklar);

    private static readonly XLColor BaslikZemin = XLColor.FromHtml("#DCE6F1");
    private static readonly XLColor ToplamZemin = XLColor.FromHtml("#F2F2F2");
    private static readonly XLColor Lacivert = XLColor.FromHtml("#1C4374");
    private static readonly CultureInfo Tr = CultureInfo.GetCultureInfo("tr-TR");

    public static void DisaAktarUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/disa-aktar").WithTags("Dışa Aktar").RequireAuthorization();

        grup.MapPost("/excel", async (ExcelIstegi istek, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            await cozucu.CozAsync(ctx, iptal);
            var bloklar = (istek.Bloklar ?? []).Select(BlokOku).ToList();
            if (bloklar.Count == 0) throw GentegreHatasi.IsKurali("Aktarılacak belge yok.");
            if (bloklar.Sum(b => b.TabloSatirlari?.Length ?? 0) > 50_000)
                throw GentegreHatasi.IsKurali("En çok 50.000 satır aktarılabilir.");

            using var kitap = new XLWorkbook();
            var ad = new string((istek.SayfaAdi ?? "İcmal").Where(c => !"[]:*?/\\".Contains(c)).ToArray()).Trim();
            var sayfa = kitap.Worksheets.Add(ad.Length == 0 ? "İcmal" : ad[..Math.Min(31, ad.Length)]);
            sayfa.Style.Font.FontName = "Calibri";
            sayfa.Style.Font.FontSize = 10;
            Yerlestir(sayfa, bloklar);

            using var akis = new MemoryStream();
            kitap.SaveAs(akis);
            var dosya = DosyaAdi(istek.DosyaAdi, "icmal") + ".xlsx";
            return Results.File(akis.ToArray(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", dosya);
        });
    }

    /// <summary>İstemci camelCase + karışık şekilli bloğu okur.</summary>
    private static ExcelBlok BlokOku(JsonElement j)
    {
        string? S(string ad) => j.TryGetProperty(ad, out var d) && d.ValueKind == JsonValueKind.String ? d.GetString() : null;
        string[]? Dizi(string ad) => j.TryGetProperty(ad, out var d) && d.ValueKind == JsonValueKind.Array
            ? d.EnumerateArray().Select(x => x.ValueKind == JsonValueKind.String ? x.GetString() ?? "" : x.ToString()).ToArray() : null;
        var tur = S("tur") ?? "";
        JsonElement[][]? tablo = null; ExcelOzetSatiri[]? ozet = null; int[]? kalin = null; bool[]? sag = null;
        if (tur == "tablo" && j.TryGetProperty("satirlar", out var ts) && ts.ValueKind == JsonValueKind.Array)
            tablo = ts.EnumerateArray().Select(r => r.ValueKind == JsonValueKind.Array ? r.EnumerateArray().ToArray() : []).ToArray();
        if (tur == "ozet" && j.TryGetProperty("satirlar", out var os) && os.ValueKind == JsonValueKind.Array)
            ozet = os.EnumerateArray().Select(r => new ExcelOzetSatiri(
                r.TryGetProperty("ad", out var a) ? a.GetString() : "",
                r.TryGetProperty("deger", out var d) ? d.Clone() : default,
                r.TryGetProperty("kalin", out var k) && k.ValueKind == JsonValueKind.True)).ToArray();
        if (j.TryGetProperty("kalin", out var kl) && kl.ValueKind == JsonValueKind.Array)
            kalin = kl.EnumerateArray().Where(x => x.ValueKind == JsonValueKind.Number).Select(x => x.GetInt32()).ToArray();
        if (j.TryGetProperty("sag", out var sg) && sg.ValueKind == JsonValueKind.Array && tur == "tablo")
            sag = sg.EnumerateArray().Select(x => x.ValueKind == JsonValueKind.True).ToArray();
        ExcelKutu[]? kutular = null;
        if (tur == "kutular" && j.TryGetProperty("kutular", out var ku) && ku.ValueKind == JsonValueKind.Array)
            kutular = ku.EnumerateArray().Select(k =>
            {
                string A(string ad) => k.TryGetProperty(ad, out var d) && d.ValueKind == JsonValueKind.String ? d.GetString() ?? "" : "";
                return new ExcelKutu(A("baslik"), A("deger"), A("alt"), A("renk"));
            }).ToArray();
        return new ExcelBlok(tur, S("metin"), tur == "kurum" ? Dizi("satirlar") : null, tur == "kurum" ? Dizi("sag") : null,
                             Dizi("hucreler"), Dizi("basliklar"), tablo, kalin, sag, ozet, kutular, S("logo"));
    }

    private static void Yerlestir(IXLWorksheet sayfa, List<ExcelBlok> bloklar)
    {
        // Kolon sayısı: en geniş tablo (en az 4) - başlık / not bu genişlikte birleşir.
        var n = Math.Max(8, bloklar.Where(b => b.Tur == "tablo")
            .Select(b => Math.Max(b.Basliklar?.Length ?? 0, b.TabloSatirlari?.Max(r => r.Length) ?? 0)).DefaultIfEmpty(0).Max());
        var genislik = new double[n + 1];
        var r = 1;

        IXLRange Birlesik(int satir, int bas, int bit) { var a = sayfa.Range(satir, bas, satir, bit); if (bit > bas) a.Merge(); return a; }

        foreach (var b in bloklar)
        {
            switch (b.Tur)
            {
                case "kurum":
                {
                    // ANTET (kullanıcı 10.10.2026): solda logo; logonun sağında alt alta
                    //   kurum adı / adres / telefon; en sağda düzenleme tarihi ve düzenleyen.
                    var sol = b.Satirlar ?? []; var sag = b.Sag ?? [];
                    var satir = Math.Max(3, Math.Max(sol.Length, sag.Length));
                    var logo = LogoOku(b.Logo);
                    var metinBas = logo is null ? 1 : 2;
                    var orta = Math.Max(metinBas + 1, n - 2);
                    for (var i = 0; i < satir; i++) sayfa.Row(r + i).Height = 16;
                    if (logo is not null)
                    {
                        using var akis = new MemoryStream(logo);
                        var resim = sayfa.AddPicture(akis).MoveTo(sayfa.Cell(r, 1), 2, 2);
                        // 3 satır (48 px) yüksekliğe sığdır, oranı koru.
                        var olcek = 44.0 / Math.Max(1, resim.OriginalHeight);
                        resim.Scale(olcek);
                    }
                    for (var i = 0; i < sol.Length; i++)
                    {
                        var a = Birlesik(r + i, metinBas, orta);
                        a.Value = sol[i];
                        a.Style.Font.Bold = i == 0; a.Style.Font.FontSize = i == 0 ? 12 : 9;
                        a.Style.Alignment.Vertical = XLAlignmentVerticalValues.Center;
                        if (i > 0) a.Style.Font.FontColor = XLColor.FromHtml("#555555");
                    }
                    for (var i = 0; i < sag.Length; i++)
                    {
                        var a = Birlesik(r + i, orta + 1, n);
                        a.Value = sag[i];
                        a.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                        a.Style.Alignment.Vertical = XLAlignmentVerticalValues.Center;
                        a.Style.Font.FontSize = 9; a.Style.Font.FontColor = XLColor.FromHtml("#555555");
                    }
                    r += satir;
                    sayfa.Range(r - 1, 1, r - 1, n).Style.Border.BottomBorder = XLBorderStyleValues.Medium;
                    sayfa.Range(r - 1, 1, r - 1, n).Style.Border.BottomBorderColor = Lacivert;
                    r++;
                    break;
                }
                case "baslik":
                {
                    var a = Birlesik(r, 1, n);
                    a.Value = b.Metin ?? "";
                    a.Style.Font.Bold = true; a.Style.Font.FontSize = 14; a.Style.Font.FontColor = Lacivert;
                    a.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                    sayfa.Row(r).Height = 22;
                    r += 2;
                    break;
                }
                case "altbaslik":
                {
                    var a = Birlesik(r, 1, n);
                    a.Value = b.Metin ?? ""; a.Style.Font.Bold = true; a.Style.Font.FontColor = Lacivert;
                    r++;
                    break;
                }
                case "bilgi":
                {
                    // İki sütunlu bilgi kutusu: her hücre yarım genişlikte, çevresi çerçeveli.
                    var h = b.Hucreler ?? [];
                    var yarim = Math.Max(1, n / 2);
                    var bas = r;
                    for (var i = 0; i < h.Length; i++)
                    {
                        var satir = r + i / 2; var sol = i % 2 == 0;
                        var a = Birlesik(satir, sol ? 1 : yarim + 1, sol ? yarim : n);
                        BilgiYaz(a.FirstCell(), h[i]);
                    }
                    r += (h.Length + 1) / 2;
                    if (h.Length > 0)
                    {
                        var kutu = sayfa.Range(bas, 1, r - 1, n);
                        kutu.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
                        kutu.Style.Border.OutsideBorderColor = XLColor.FromHtml("#BBBBBB");
                        kutu.Style.Fill.BackgroundColor = XLColor.FromHtml("#FAFBFD");
                    }
                    r++;
                    break;
                }
                case "tablo":
                {
                    var bas = b.Basliklar ?? [];
                    var satirlar = b.TabloSatirlari ?? [];
                    var kolon = Math.Max(bas.Length, satirlar.Select(x => x.Length).DefaultIfEmpty(0).Max());
                    if (kolon == 0) break;
                    var ilk = r;
                    if (bas.Length > 0)
                    {
                        for (var c = 0; c < bas.Length; c++)
                        {
                            var h = sayfa.Cell(r, c + 1);
                            h.Value = bas[c];
                            h.Style.Font.Bold = true; h.Style.Fill.BackgroundColor = BaslikZemin;
                            h.Style.Alignment.WrapText = true; h.Style.Alignment.Vertical = XLAlignmentVerticalValues.Center;
                            if (b.SagYasli is { } sy && c < sy.Length && sy[c]) h.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                            Olc(genislik, c + 1, bas[c].Length);
                        }
                        r++;
                    }
                    var kalin = (b.Kalin ?? []).ToHashSet();
                    for (var i = 0; i < satirlar.Length; i++, r++)
                    {
                        for (var c = 0; c < satirlar[i].Length; c++)
                        {
                            var h = sayfa.Cell(r, c + 1);
                            var uz = HucreYaz(h, satirlar[i][c]);
                            if (b.SagYasli is { } sy && c < sy.Length && sy[c]) h.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                            Olc(genislik, c + 1, uz);
                        }
                        if (kalin.Contains(i))
                        {
                            var tr = sayfa.Range(r, 1, r, kolon);
                            tr.Style.Font.Bold = true; tr.Style.Fill.BackgroundColor = ToplamZemin;
                        }
                    }
                    var alan = sayfa.Range(ilk, 1, r - 1, kolon);
                    alan.Style.Border.InsideBorder = XLBorderStyleValues.Thin;
                    alan.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
                    alan.Style.Border.InsideBorderColor = XLColor.FromHtml("#C8CED6");
                    alan.Style.Border.OutsideBorderColor = XLColor.FromHtml("#9AA7B4");
                    r++;
                    break;
                }
                case "kutular":
                {
                    // EKRANIN ÖZET KUTULARI: her kutu 2 kolon genişliğinde kart -
                    //   üstte gri etiket, ortada büyük renkli değer, altta açıklama.
                    var kutular = b.Kutular ?? [];
                    var satirda = Math.Max(2, n / 2);
                    for (var i = 0; i < kutular.Length; i++)
                    {
                        var k = kutular[i];
                        var ust = r + i / satirda * 4;          // 3 satır kart + 1 boşluk
                        var bas = i % satirda * 2 + 1; var bit = bas + 1;
                        var et = Birlesik(ust, bas, bit);
                        et.Value = k.Baslik.ToUpper(Tr);
                        et.Style.Font.FontSize = 8; et.Style.Font.FontColor = XLColor.FromHtml("#6B7A8B");
                        var dg = Birlesik(ust + 1, bas, bit);
                        HucreYaz(dg.FirstCell(), JsonDocument.Parse(JsonSerializer.Serialize(k.Deger)).RootElement);
                        dg.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Left;
                        dg.Style.Font.Bold = true; dg.Style.Font.FontSize = 13;
                        dg.Style.Font.FontColor = XLColor.FromHtml(k.Renk switch
                        {
                            "mor" => "#6A3FB5", "iyi" => "#2E7D46", "uy" => "#B7791F", "teh" => "#B3261E", _ => "#14315A",
                        });
                        var al = Birlesik(ust + 2, bas, bit);
                        al.Value = k.Alt;
                        al.Style.Font.FontSize = 8; al.Style.Font.FontColor = XLColor.FromHtml("#6B7A8B");
                        al.Style.Alignment.WrapText = true; al.Style.Alignment.Vertical = XLAlignmentVerticalValues.Top;
                        sayfa.Row(ust + 1).Height = 20;
                        sayfa.Row(ust + 2).Height = Math.Max(sayfa.Row(ust + 2).Height, k.Alt.Length > 30 ? 24 : 13);
                        var kart = sayfa.Range(ust, bas, ust + 2, bit);
                        kart.Style.Fill.BackgroundColor = XLColor.FromHtml("#F7F9FC");
                        kart.Style.Border.OutsideBorder = XLBorderStyleValues.Thin;
                        kart.Style.Border.OutsideBorderColor = XLColor.FromHtml("#D5DCE4");
                    }
                    r += (kutular.Length + satirda - 1) / satirda * 4;
                    break;
                }
                case "ozet":
                {
                    // Toplamlar sağda: etiket son iki kolonun solunda birleşik, tutar son kolonda.
                    foreach (var o in b.OzetSatirlari ?? [])
                    {
                        var etiketBas = Math.Max(1, n - 3);
                        var et = Birlesik(r, etiketBas, n - 1);
                        et.Value = o.Ad ?? "";
                        et.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                        var d = sayfa.Cell(r, n);
                        HucreYaz(d, o.Deger);
                        d.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Right;
                        if (o.Kalin)
                        {
                            var tum = sayfa.Range(r, etiketBas, r, n);
                            tum.Style.Font.Bold = true; tum.Style.Font.FontColor = XLColor.FromHtml("#B3261E");
                            tum.Style.Border.TopBorder = XLBorderStyleValues.Thin;
                        }
                        r++;
                    }
                    r++;
                    break;
                }
                case "not":
                {
                    var a = Birlesik(r, 1, n);
                    a.Value = b.Metin ?? "";
                    a.Style.Alignment.WrapText = true; a.Style.Alignment.Vertical = XLAlignmentVerticalValues.Top;
                    a.Style.Font.FontColor = XLColor.FromHtml("#555555"); a.Style.Font.FontSize = 9;
                    // Birleşik hücrede Excel satır yüksekliğini kendisi büyütmez - kabaca hesapla.
                    var toplamGen = Enumerable.Range(1, n).Sum(c => Math.Max(10, Math.Min(45, genislik[c] + 2)));
                    sayfa.Row(r).Height = Math.Max(15, 12.5 * Math.Ceiling((b.Metin?.Length ?? 0) / Math.Max(20, toplamGen * 1.1)));
                    r += 2;
                    break;
                }
            }
        }

        for (var c = 1; c <= n; c++)
            sayfa.Column(c).Width = Math.Max(10, Math.Min(45, genislik[c] + 2));

        var ayar = sayfa.PageSetup;
        ayar.PaperSize = XLPaperSize.A4Paper;
        ayar.PageOrientation = n > 7 ? XLPageOrientation.Landscape : XLPageOrientation.Portrait;
        ayar.FitToPages(1, 0);
        ayar.Margins.Left = ayar.Margins.Right = 0.4;
        ayar.Margins.Top = ayar.Margins.Bottom = 0.5;
        ayar.CenterHorizontally = true;
        sayfa.ShowGridLines = false;
    }

    /// <summary>"data:image/png;base64,..." logosunu çözer; bozuk / 2 MB üstü logo atlanır (antet logosuz basılır).</summary>
    private static byte[]? LogoOku(string? dataUrl)
    {
        if (string.IsNullOrEmpty(dataUrl) || !dataUrl.StartsWith("data:image/", StringComparison.Ordinal)) return null;
        var virgul = dataUrl.IndexOf(',');
        if (virgul < 0 || dataUrl.Length - virgul > 2_800_000) return null;
        try { return Convert.FromBase64String(dataUrl[(virgul + 1)..]); } catch (FormatException) { return null; }
    }

    private static void Olc(double[] genislik, int c, int uzunluk)
    {
        if (c < genislik.Length) genislik[c] = Math.Max(genislik[c], uzunluk);
    }

    /// <summary>"Etiket: değer" bilgisini yazar; etiket normal, değer kalın değil (A4'teki gibi).</summary>
    private static void BilgiYaz(IXLCell h, string metin)
    {
        h.Value = metin;
        h.Style.Alignment.Vertical = XLAlignmentVerticalValues.Center;
    }

    /// <summary>TR sayı: "1.234,56" / "-12,50 ₺" / "2026". Baştaki sıfırlı kod (0012) sayı değildir.</summary>
    private static readonly System.Text.RegularExpressions.Regex TrSayi =
        new(@"^(-?(?:\d{1,3}(?:\.\d{3})+|\d+))(?:,(\d+))?(\s*₺)?$");

    /// <summary>
    /// Hücre değeri: TR sayı metni → sayı (ekrandaki ondalık sayısıyla; ₺ varsa
    /// para biçimi), "gg.aa.yyyy" → tarih, gerisi metin. Görünen uzunluğu döner.
    /// </summary>
    private static int HucreYaz(IXLCell h, JsonElement d)
    {
        var s = d.ValueKind switch
        {
            JsonValueKind.String => d.GetString() ?? "",
            JsonValueKind.Number => d.GetRawText(),
            _ => "",
        };
        s = s.Replace(' ', ' ').Trim();
        var m = TrSayi.Match(s);
        if (m.Success && !System.Text.RegularExpressions.Regex.IsMatch(m.Groups[1].Value, @"^-?0\d"))
        {
            var ondalik = m.Groups[2].Success ? m.Groups[2].Value.Length : 0;
            var v = decimal.Parse(m.Groups[1].Value.Replace(".", "") + (ondalik > 0 ? "." + m.Groups[2].Value : ""),
                                  CultureInfo.InvariantCulture);
            h.Value = v;
            var bicim = ondalik > 0 ? "#,##0." + new string('0', ondalik) : "#,##0";
            h.Style.NumberFormat.Format = m.Groups[3].Success ? bicim + " \"₺\"" : bicim;
            return s.Length;
        }
        if (s.Length == 10 && DateTime.TryParseExact(s, "dd.MM.yyyy", Tr, DateTimeStyles.None, out var t))
        {
            h.Value = t; h.Style.NumberFormat.Format = "dd.mm.yyyy";
            return 10;
        }
        h.Value = s;
        return s.Length;
    }

    /// <summary>Dosya adından Windows'ta yasak karakterleri atar.</summary>
    private static string DosyaAdi(string? ad, string varsayilan)
    {
        var temiz = new string((ad ?? "").Where(c => !"/\\:*?\"<>|".Contains(c)).ToArray()).Trim();
        return temiz.Length == 0 ? varsayilan : temiz;
    }
}
