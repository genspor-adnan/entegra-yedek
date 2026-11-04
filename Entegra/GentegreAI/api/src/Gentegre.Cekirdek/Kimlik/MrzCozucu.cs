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
        // OCR ONARIMI (gerçek kart denemesi 04.11.2026): dolgu '<' koşuları C/L/K olarak, '0' 'O', '6' 'E' okunuyordu;
        //   koşular uzayıp satır 33-35 karaktere çıkıyordu. Önce koşu / uzunluk, sonra alan türüne göre karakter.
        var s = satirlar.Select(x => UzunlukOnar(DolguOnar(x), uzunluk)).ToList();
        if (s.Any(x => x.Length != uzunluk)) return null;
        s = bicim == "TD1" ? Td1Onar(s) : Td2Td3Onar(s, uzunluk);

        return bicim == "TD1" ? Td1(s, gun) : Td2Td3(s, bicim, uzunluk, gun);
    }

    // ------------------------------------------------------------ OCR onarımı --
    // Tesseract'ın genel İngilizce modeli OCR-B'nin '<' işaretini bilmez: dolgu koşuları "CLCC", "LLLLK" gibi okunur.
    // Üç ve daha uzun [<CLK] koşusu dolgudur: ad / numara alanında sesli harfsiz böyle bir dizi gerçekçi değil,
    // sayısal alanda zaten olamaz. Yazılı / cihazdan gelen geçerli MRZ'de zararsız (koşular zaten '<').
    private static string DolguOnar(string satir)
        => System.Text.RegularExpressions.Regex.Replace(satir, "[<CLK]{3,}", m => new string('<', m.Value.Length));

    /// <summary>Uzunsa en uzun '&lt;' koşusundan kısaltır (OCR koşuyu uzatır), kısaysa sağdan '&lt;' ile tamamlar.</summary>
    private static string UzunlukOnar(string satir, int hedef)
    {
        while (satir.Length > hedef)
        {
            var enUzun = System.Text.RegularExpressions.Regex.Matches(satir, "<+").MaxBy(m => m.Length);
            if (enUzun is null || enUzun.Length < 2) break;
            satir = satir.Remove(enUzun.Index, 1);
        }
        return satir.PadRight(hedef, '<');
    }

    private static char Rakam(char c) => c switch
    {
        'O' or 'Q' or 'D' => '0', 'I' or 'L' => '1', 'Z' => '2', 'S' => '5', 'G' or 'E' => '6', 'B' => '8', 'A' => '4', 'T' => '7',
        _ => c,
    };

    private static char Harf(char c) => c switch
    {
        '0' => 'O', '1' => 'I', '2' => 'Z', '5' => 'S', '6' => 'G', '8' => 'B', '4' => 'A', '7' => 'T',
        _ => c,
    };

    private static string Rakamlar(string s) => new(s.Select(c => c == '<' ? c : Rakam(c)).ToArray());
    private static string Harfler(string s) => new(s.Select(c => c == '<' ? c : Harf(c)).ToArray());

    /// <summary>
    /// Alfasayısal belge no. T.C. kimlik kartı serisi sabit yapıdadır (harf · 2 rakam · harf · 5 rakam, "A12B34567") -
    /// konuma göre kesin çevrim. Diğer ülkelerde kontrol hanesi karar verir: en az değişiklikle, yalnız O/0 · I/1 ·
    /// S/5 · B/8 ikilileri (geniş küme tek haneli kontrolü yanlış adaya da uydurabilirdi).
    /// </summary>
    private static string BelgeNoOnar(string alan, char kontrol, string ulke)
    {
        if (ulke == "TUR" && alan.Length == 9 && !alan.Contains('<'))
        {
            var d = alan.ToCharArray();
            for (var i = 0; i < 9; i++) d[i] = i is 0 or 3 ? Harf(d[i]) : Rakam(d[i]);
            return new string(d);
        }
        if (!char.IsAsciiDigit(kontrol) || Kontrol(alan, kontrol)) return alan;
        var konumlar = alan.Select((c, i) => (c, i)).Where(x => x.c is 'O' or '0' or 'I' or '1' or 'S' or '5' or 'B' or '8')
                           .Select(x => x.i).Take(8).ToList();
        foreach (var maske in Enumerable.Range(1, (1 << konumlar.Count) - 1).OrderBy(m => System.Numerics.BitOperations.PopCount((uint)m)))
        {
            var d = alan.ToCharArray();
            for (var k = 0; k < konumlar.Count; k++)
                if ((maske & (1 << k)) != 0) { var c = d[konumlar[k]]; d[konumlar[k]] = char.IsAsciiDigit(c) ? Harf(c) : Rakam(c); }
            var aday = new string(d);
            if (Kontrol(aday, kontrol)) return aday;
        }
        return alan;
    }

    /// <summary>İsteğe bağlı alan: ağırlıkla rakamsa (T.C. kimlik no) harf benzerleri rakama çevrilir.</summary>
    private static string IstegeBagliOnar(string alan)
    {
        var dolu = alan.Trim('<');
        if (dolu.Length < 9) return alan;
        return dolu.Count(char.IsAsciiDigit) * 100 / dolu.Length >= 60 ? Rakamlar(alan) : alan;
    }

    private static List<string> Td1Onar(List<string> s)
    {
        var l1 = s[0].ToCharArray(); var l2 = s[1].ToCharArray();
        // Satır 1: belge kodu + ülke harf; belge no kontrol haneli; isteğe bağlı alan.
        for (var i = 0; i < 5; i++) l1[i] = Harf(l1[i]);
        var belgeNo = BelgeNoOnar(s[0][5..14], Rakam(s[0][14]), Ulke(new string(l1, 2, 3)));
        belgeNo.CopyTo(0, l1, 5, 9);
        if (l1[14] != '<') l1[14] = Rakam(l1[14]);
        IstegeBagliOnar(s[0][15..30]).CopyTo(0, l1, 15, 15);
        // Satır 2: doğum + kontrol, cinsiyet, SKT + kontrol rakam; uyruk harf; isteğe bağlı; bileşik rakam.
        for (var i = 0; i < 7; i++) l2[i] = Rakam(l2[i]);
        for (var i = 8; i < 15; i++) l2[i] = Rakam(l2[i]);
        for (var i = 15; i < 18; i++) l2[i] = Harf(l2[i]);
        IstegeBagliOnar(s[1][18..29]).CopyTo(0, l2, 18, 11);
        l2[29] = Rakam(l2[29]);
        return [new string(l1), new string(l2), Harfler(s[2])];
    }

    private static List<string> Td2Td3Onar(List<string> s, int uzunluk)
    {
        var l2 = s[1].ToCharArray();
        for (var i = 10; i < 13; i++) l2[i] = Harf(l2[i]);
        var belgeNo = BelgeNoOnar(s[1][..9], Rakam(s[1][9]), Ulke(new string(l2, 10, 3)));
        belgeNo.CopyTo(0, l2, 0, 9);
        l2[9] = Rakam(l2[9]);
        for (var i = 13; i < 20; i++) l2[i] = Rakam(l2[i]);
        for (var i = 21; i < 28; i++) l2[i] = Rakam(l2[i]);
        if (uzunluk == 44) { if (l2[42] != '<') l2[42] = Rakam(l2[42]); l2[43] = Rakam(l2[43]); }
        else l2[35] = Rakam(l2[35]);
        // Satır 1: belge kodu + ülke + adlar hep harf.
        return [Harfler(s[0]), new string(l2)];
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
