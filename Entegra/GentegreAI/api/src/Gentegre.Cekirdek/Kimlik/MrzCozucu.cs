using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Cekirdek.Kimlik;

/// <summary>
/// MRZ ÇÖZÜCÜ (1255, mockup Ekranlar/Kayıt Kabul/kimlik_mrz_okut.html) - ICAO 9303 makinece okunur bölge.
///
/// Kullanıcı 03.11.2026: "kimlikte mrz kodu ne demek? ondan hasta kimlik kaydı nasıl yapılır" → mockup →
/// 04.11.2026 "mrz'yi uygula".
///
/// SAF SINIF: girdi 2-3 satır metin (OCR tarayıcıda çözülür, görüntü sunucuya GELMEZ - KVKK), çıktı alanlar +
/// hangi kontrol hanesinin tuttuğu. Kural burada tek yerde; istemci yalnız gösterir.
///
/// Biçimler:
///   TD1 (kimlik kartı, 3 × 30): satır 1 belge kodu · düzenleyen ülke · belge no + kontrol · isteğe bağlı;
///       satır 2 doğum + kontrol · cinsiyet · son kullanma + kontrol · uyruk · isteğe bağlı (T.C. kimlik no) · bileşik;
///       satır 3 SOYAD&lt;&lt;AD.
///   TD2 (2 × 36) ve TD3 (pasaport, 2 × 44): satır 1 belge kodu · ülke · SOYAD&lt;&lt;AD; satır 2 belge no + kontrol ·
///       uyruk · doğum + kontrol · cinsiyet · son kullanma + kontrol · isteğe bağlı (+ kontrol) · bileşik.
/// Kontrol hanesi: 7-3-1 ağırlıklı mod 10; '&lt;' = 0, A..Z = 10..35.
///
/// T.C. kimlik no: TD1 satır 2 isteğe bağlı alanındaki 11 hane - NVİ algoritmasından (KimlikDogrulama) geçmezse
/// hata sayılır (hasta eşleşmesi o numarayla yapılır, yanlış okunmuş numara sessizce geçmesin).
/// Ad / soyad MRZ'de ASCII büyük harftir (Ş→S, İ→I); Türkçe'ye GERİ ÇEVİRİLMEZ (SULE Şule mi Sule mi bilinemez) -
/// gerçek yazım MERNİS'ten ya da kullanıcıdan gelir.
/// </summary>
public static class MrzCozucu
{
    public sealed record Sonuc(
        string Bicim,                 // TD1 · TD2 · TD3
        string BelgeKodu,             // I, ID, P, …
        string DuzenleyenUlke,        // ISO 3166-1 alpha-3
        string BelgeNo, bool BelgeNoTamam,
        DateOnly? DogumTarihi, bool DogumTamam,
        string Cinsiyet,              // E · K · ''
        DateOnly? SonKullanma, bool SonKullanmaTamam,
        string Uyruk,                 // ISO alpha-3
        string KimlikNo,              // doğrulanmış T.C. kimlik no ya da ''
        string Soyad, string Ad,      // MRZ ASCII büyük harf
        bool BilesikTamam,
        IReadOnlyList<string> Hatalar,
        IReadOnlyList<string> Satirlar)
    {
        public bool Gecerli => Hatalar.Count == 0;
    }

    /// <summary>Ham metni satırlara ayırır, biçimi tanır, alanları ve kontrol hanelerini çözer. Hiç tanınmazsa null.</summary>
    public static Sonuc? Coz(string? metin, DateOnly? bugun = null)
    {
        var satirlar = Satirlar(metin);
        if (satirlar.Count is < 2 or > 3) return null;
        var gun = bugun ?? DateOnly.FromDateTime(DateTime.Today);

        // Biçim: 3 satır → TD1 (30); 2 satır → P ile başlıyorsa ya da 36'dan uzunsa TD3 (44), yoksa TD2 (36).
        var enUzun = satirlar.Max(s => s.Length);
        string bicim; int uzunluk;
        if (satirlar.Count == 3) { bicim = "TD1"; uzunluk = 30; }
        else if (satirlar[0].StartsWith('P') || enUzun > 36) { bicim = "TD3"; uzunluk = 44; }
        else { bicim = "TD2"; uzunluk = 36; }
        if (enUzun > uzunluk) return null;
        // OCR satır sonundaki dolgu '<' karakterlerini düşürebilir - sağdan tamamlanır.
        var s = satirlar.Select(x => x.PadRight(uzunluk, '<')).ToList();

        return bicim == "TD1" ? Td1(s, gun) : Td2Td3(s, bicim, uzunluk, gun);
    }

    // ---------------------------------------------------------------- TD1 --
    private static Sonuc Td1(List<string> s, DateOnly gun)
    {
        var hatalar = new List<string>();
        var l1 = s[0]; var l2 = s[1]; var l3 = s[2];

        var belgeKodu = Temiz(l1[..2]);
        var ulke = Ulke(l1[2..5]);
        // Belge no: 9 hane + kontrol. Kontrol yerinde '<' ise numara isteğe bağlı alanda sürer, ardından kontrol hanesi.
        var belgeNo = Temiz(l1[5..14]);
        char belgeKontrol = l1[14];
        if (belgeKontrol == '<')
        {
            var ek = l1[15..30];
            var kes = ek.IndexOf('<'); if (kes < 0) kes = ek.Length;
            if (kes >= 1) { belgeNo += ek[..(kes - 1)]; belgeKontrol = ek[kes - 1]; }
        }
        var belgeTamam = Kontrol(belgeNo, belgeKontrol);
        if (!belgeTamam) hatalar.Add("Belge no kontrol hanesi tutmuyor.");

        var (dogum, dogumBicimTamam) = Tarih(l2[..6], gun, dogum: true);
        var dogumTamam = dogumBicimTamam && Kontrol(l2[..6], l2[6]);
        if (!dogumTamam) hatalar.Add("Doğum tarihi kontrol hanesi tutmuyor.");
        var cinsiyet = Cinsiyet(l2[7]);
        var (skt, sktBicimTamam) = Tarih(l2[8..14], gun, dogum: false);
        var sktTamam = sktBicimTamam && Kontrol(l2[8..14], l2[14]);
        if (!sktTamam) hatalar.Add("Son kullanma tarihi kontrol hanesi tutmuyor.");
        var uyruk = Ulke(l2[15..18]);

        // Bileşik kontrol: satır 1 [5..29] + satır 2 [0..6] + [8..14] + [18..28].
        var bilesikTamam = Kontrol(l1[5..30] + l2[..7] + l2[8..15] + l2[18..29], l2[29]);
        if (!bilesikTamam) hatalar.Add("Bileşik kontrol hanesi tutmuyor - satırlar eksik ya da yanlış okunmuş.");

        // T.C. kimlik no: satır 2 isteğe bağlı alan (11 hane); yoksa satır 1 isteğe bağlı alanda aranır.
        var kimlikNo = TcBul(Temiz(l2[18..29]), hatalar) ?? TcBul(Temiz(l1[15..30]), hatalar) ?? "";

        var (soyad, ad) = Adlar(l3);
        return new Sonuc("TD1", belgeKodu, ulke, belgeNo, belgeTamam, dogum, dogumTamam, cinsiyet, skt, sktTamam,
                         uyruk, kimlikNo, soyad, ad, bilesikTamam, hatalar, s);
    }

    // ----------------------------------------------------------- TD2 / TD3 --
    private static Sonuc Td2Td3(List<string> s, string bicim, int uzunluk, DateOnly gun)
    {
        var hatalar = new List<string>();
        var l1 = s[0]; var l2 = s[1];
        var belgeKodu = Temiz(l1[..2]);
        var ulke = Ulke(l1[2..5]);
        var (soyad, ad) = Adlar(l1[5..]);

        var belgeNo = Temiz(l2[..9]);
        var belgeTamam = Kontrol(l2[..9], l2[9]);
        if (!belgeTamam) hatalar.Add("Belge no kontrol hanesi tutmuyor.");
        var uyruk = Ulke(l2[10..13]);
        var (dogum, dogumBicimTamam) = Tarih(l2[13..19], gun, dogum: true);
        var dogumTamam = dogumBicimTamam && Kontrol(l2[13..19], l2[19]);
        if (!dogumTamam) hatalar.Add("Doğum tarihi kontrol hanesi tutmuyor.");
        var cinsiyet = Cinsiyet(l2[20]);
        var (skt, sktBicimTamam) = Tarih(l2[21..27], gun, dogum: false);
        var sktTamam = sktBicimTamam && Kontrol(l2[21..27], l2[27]);
        if (!sktTamam) hatalar.Add("Son kullanma tarihi kontrol hanesi tutmuyor.");

        bool bilesikTamam;
        if (uzunluk == 44)
        {
            // TD3: isteğe bağlı alan [28..41] + kontrol [42] (alan boşsa '<' de geçerli); bileşik [43] = [0..9]+[13..19]+[21..42].
            var opt = l2[28..42];
            if (!(opt.Trim('<').Length == 0 && l2[42] == '<') && !Kontrol(opt, l2[42]))
                hatalar.Add("İsteğe bağlı alan kontrol hanesi tutmuyor.");
            bilesikTamam = Kontrol(l2[..10] + l2[13..20] + l2[21..43], l2[43]);
        }
        else
            // TD2: isteğe bağlı [28..34], bileşik [35] = [0..9]+[13..19]+[21..34].
            bilesikTamam = Kontrol(l2[..10] + l2[13..20] + l2[21..35], l2[35]);
        if (!bilesikTamam) hatalar.Add("Bileşik kontrol hanesi tutmuyor - satırlar eksik ya da yanlış okunmuş.");

        return new Sonuc(bicim, belgeKodu, ulke, belgeNo, belgeTamam, dogum, dogumTamam, cinsiyet, skt, sktTamam,
                         uyruk, "", soyad, ad, bilesikTamam, hatalar, s);
    }

    // ------------------------------------------------------------ yardımcı --
    /// <summary>Metni MRZ satırlarına indirger: büyük harf, boşluksuz, OCR'ın benzer işaretleri '&lt;'e çevrilir; 20'den kısa satır atılır.</summary>
    public static List<string> Satirlar(string? metin)
    {
        var sonuc = new List<string>();
        foreach (var ham in (metin ?? "").Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries))
        {
            var sb = new System.Text.StringBuilder(ham.Length);
            foreach (var c in ham.ToUpperInvariant())
            {
                if (c is ' ' or '\t') continue;
                sb.Append(c switch { '«' or '‹' or '〈' or '《' or '≪' => '<', 'İ' => 'I', 'Ş' => 'S', 'Ğ' => 'G', 'Ü' => 'U',
                                      'Ö' => 'O', 'Ç' => 'C', _ => c });
            }
            var satir = sb.ToString();
            if (satir.Length >= 20 && satir.All(c => c is '<' || char.IsAsciiDigit(c) || char.IsAsciiLetterUpper(c)))
                sonuc.Add(satir);
        }
        return sonuc;
    }

    /// <summary>ICAO 9303 kontrol hanesi: 7-3-1 ağırlıklı toplam mod 10.</summary>
    public static int KontrolHanesi(string alan)
    {
        int[] agirlik = [7, 3, 1];
        var toplam = 0;
        for (var i = 0; i < alan.Length; i++) toplam += Deger(alan[i]) * agirlik[i % 3];
        return toplam % 10;
    }

    private static bool Kontrol(string alan, char hane)
        => char.IsAsciiDigit(hane) && KontrolHanesi(alan) == hane - '0';

    private static int Deger(char c) => c switch
    {
        '<' => 0,
        >= '0' and <= '9' => c - '0',
        >= 'A' and <= 'Z' => c - 'A' + 10,
        _ => 0,
    };

    private static string Temiz(string s) => s.Trim('<');

    /// <summary>Düzenleyen ülke / uyruk: 'D&lt;&lt;' Almanya'nın MRZ kısaltmasıdır.</summary>
    private static string Ulke(string s)
    {
        var u = s.Trim('<');
        return u == "D" ? "DEU" : u;
    }

    private static string Cinsiyet(char c) => c switch { 'M' => "E", 'F' => "K", _ => "" };

    /// <summary>YYAAGG → tarih. Doğumda yüzyıl: bugünün yılından büyükse 19xx; son kullanmada hep 20xx.</summary>
    private static (DateOnly? Tarih, bool Tamam) Tarih(string yyaagg, DateOnly gun, bool dogum)
    {
        if (yyaagg.Length != 6 || !yyaagg.All(char.IsAsciiDigit)) return (null, false);
        var yy = int.Parse(yyaagg[..2]); var aa = int.Parse(yyaagg[2..4]); var gg = int.Parse(yyaagg[4..6]);
        var yil = dogum ? (2000 + yy > gun.Year ? 1900 + yy : 2000 + yy) : 2000 + yy;
        if (aa is < 1 or > 12 || gg < 1 || gg > DateTime.DaysInMonth(yil, aa)) return (null, false);
        return (new DateOnly(yil, aa, gg), true);
    }

    private static (string Soyad, string Ad) Adlar(string alan)
    {
        var parcalar = alan.Split("<<", 2);
        var soyad = parcalar[0].Replace('<', ' ').Trim();
        var ad = parcalar.Length > 1 ? parcalar[1].Replace('<', ' ').Trim() : "";
        while (ad.Contains("  ")) ad = ad.Replace("  ", " ");
        while (soyad.Contains("  ")) soyad = soyad.Replace("  ", " ");
        return (soyad, ad);
    }

    /// <summary>11 haneli sayı varsa T.C. algoritmasından geçirir; geçmezse hata yazar ve null döner.</summary>
    private static string? TcBul(string alan, List<string> hatalar)
    {
        var rakamlar = new string(alan.Where(char.IsAsciiDigit).ToArray());
        if (rakamlar.Length != 11 || alan.Trim('<').Length != 11) return null;
        if (KimlikDogrulama.TcknGecerli(rakamlar)) return rakamlar;
        hatalar.Add("T.C. kimlik no algoritması tutmuyor - numara yanlış okunmuş olabilir.");
        return null;
    }

    /// <summary>
    /// ISO alpha-3 → Türkçe ülke adı (ön ek) - uyruk kod listesi (SKRS hasta.uyruk) ad ile eşlenir, kod listesinde
    /// ISO kodu yok. Listede olmayan ülke için kod aynen gösterilir, kullanıcı seçer.
    /// </summary>
    public static string? UlkeAdi(string iso3) => UlkeAdlari.TryGetValue(iso3, out var ad) ? ad : null;

    private static readonly Dictionary<string, string> UlkeAdlari = new(StringComparer.OrdinalIgnoreCase)
    {
        ["TUR"] = "Türkiye", ["DEU"] = "Almanya Federal", ["SYR"] = "Suriye", ["IRQ"] = "Irak", ["IRN"] = "İran",
        ["AFG"] = "Afganistan", ["AZE"] = "Azerbaycan", ["GEO"] = "Gürcistan", ["ARM"] = "Ermenistan", ["RUS"] = "Rusya Federasyonu",
        ["UKR"] = "Ukrayna", ["BLR"] = "Belarus", ["MDA"] = "Moldova", ["KAZ"] = "Kazakistan", ["UZB"] = "Özbekistan",
        ["TKM"] = "Türkmenistan", ["KGZ"] = "Kırgızistan", ["TJK"] = "Tacikistan", ["USA"] = "Amerika Birleşik", ["CAN"] = "Kanada",
        ["GBR"] = "Birleşik Krallık", ["FRA"] = "Fransa", ["NLD"] = "Hollanda", ["BEL"] = "Belçika", ["AUT"] = "Avusturya",
        ["CHE"] = "İsviçre", ["ITA"] = "İtalya", ["ESP"] = "İspanya", ["PRT"] = "Portekiz", ["GRC"] = "Yunanistan",
        ["BGR"] = "Bulgaristan", ["ROU"] = "Romanya", ["SRB"] = "Sırbistan", ["BIH"] = "Bosna", ["MKD"] = "Makedonya",
        ["ALB"] = "Arnavutluk", ["MNE"] = "Karadağ", ["XKX"] = "Kosova", ["RKS"] = "Kosova", ["HRV"] = "Hırvatistan", ["SVN"] = "Slovenya",
        ["HUN"] = "Macaristan", ["CZE"] = "Çek", ["SVK"] = "Slovakya", ["POL"] = "Polonya", ["LTU"] = "Litvanya",
        ["LVA"] = "Letonya", ["EST"] = "Estonya", ["FIN"] = "Finlandiya", ["SWE"] = "İsveç", ["NOR"] = "Norveç",
        ["DNK"] = "Danimarka", ["IRL"] = "İrlanda", ["ISL"] = "İzlanda", ["LUX"] = "Lüksemburg", ["MLT"] = "Malta",
        ["CYP"] = "Kıbrıs", ["ISR"] = "İsrail", ["PSE"] = "Filistin", ["LBN"] = "Lübnan", ["JOR"] = "Ürdün",
        ["SAU"] = "Suudi Arabistan", ["ARE"] = "Birleşik Arap", ["QAT"] = "Katar", ["KWT"] = "Kuveyt", ["BHR"] = "Bahreyn",
        ["OMN"] = "Umman", ["YEM"] = "Yemen", ["EGY"] = "Mısır", ["LBY"] = "Libya", ["TUN"] = "Tunus",
        ["DZA"] = "Cezayir", ["MAR"] = "Fas", ["SDN"] = "Sudan", ["SOM"] = "Somali", ["ETH"] = "Etiyopya",
        ["NGA"] = "Nijerya", ["KEN"] = "Kenya", ["ZAF"] = "Güney Afrika", ["PAK"] = "Pakistan", ["IND"] = "Hindistan",
        ["BGD"] = "Bangladeş", ["CHN"] = "Çin Halk", ["JPN"] = "Japonya", ["KOR"] = "Kore Cumhuriyeti", ["IDN"] = "Endonezya",
        ["MYS"] = "Malezya", ["AUS"] = "Avustralya", ["NZL"] = "Yeni Zelanda", ["BRA"] = "Brezilya", ["ARG"] = "Arjantin",
        ["MEX"] = "Meksika", ["XXA"] = "Vatansız", ["XXB"] = "Mülteci", ["XXC"] = "Mülteci",
    };
}
