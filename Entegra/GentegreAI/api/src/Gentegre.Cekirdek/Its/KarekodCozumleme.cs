namespace Gentegre.Cekirdek.Its;

/// <summary>
/// İLAÇ KAREKODU (GS1 DataMatrix) ÇÖZÜMLEME — İTS v1.
///
/// Türkiye'de ilaç kutusundaki kare kod GS1 biçimindedir ve dört veri taşır:
///
///   (01) GTIN / barkod   14 hane, SABİT uzunluk
///   (21) Seri numarası   değişken, en fazla 20
///   (17) Son kullanma    YYMMDD, SABİT 6 hane
///   (10) Parti (lot)     değişken, en fazla 20
///
/// <para><b>Değişken uzunluklu alanlar ayırıcı ister.</b> GS1'de bu ayırıcı
/// FNC1 karakteridir ve klavye emülasyonlu okuyucular onu <c>GS</c> (0x1D)
/// olarak gönderir. Bazı okuyucular hiç göndermez ya da yerine <c>|</c> veya
/// <c>&lt;GS&gt;</c> yazar — üçü de kabul edilir. Ayırıcı yoksa alanın nerede
/// bittiği ancak BİR SONRAKİ AI'ya bakarak bulunur; bunu yapmayan bir
/// çözümleyici seri numarasının içine son kullanma tarihini de katar ve
/// bildirim İTS tarafından reddedilir.</para>
///
/// <para><b>Alan sırası sabit değildir.</b> Üretici (01)(17)(10)(21) da
/// yazabilir; bu yüzden sıraya değil AI'ya bakılır.</para>
/// </summary>
public static class KarekodCozumleme
{
    /// <summary>Çözümlenmiş karekod. <c>Gecerli</c> false ise <c>Hata</c> doludur.</summary>
    public sealed record Karekod(string Gtin, string SeriNo, string PartiNo,
                                 DateOnly? SonKullanma, bool Gecerli, string Hata)
    {
        /// <summary>Boş / okunamayan kod.</summary>
        public static Karekod Hatali(string sebep) => new("", "", "", null, false, sebep);
    }

    /// <summary>
    /// GS1 FNC1 ayırıcısı: klavye emülasyonlu okuyucular 0x1D gönderir.
    /// Kaynak dosyada görünmez bir karakter bırakmamak için koddan üretilir -
    /// görünmez karakter kopyala-yapıştırda sessizce kaybolur.
    /// </summary>
    private const char AYIRICI = (char)0x1D;

    /// <summary>Ayiricinin metin olarak yazilmis halleri (okuyucuya gore).</summary>
    private static readonly string[] Ayiricilar = ["<GS>", "|"];

    /// <summary>Değişken uzunluklu alanlar - ayırıcı ya da sonraki AI ile biter.</summary>
    private static readonly string[] DegiskenAi = ["21", "10"];

    /// <summary>Sabit uzunluklu alanlar ve uzunlukları.</summary>
    private static readonly Dictionary<string, int> SabitAi = new()
    {
        ["01"] = 14,   // GTIN
        ["17"] = 6,    // SKT (YYMMDD)
        ["11"] = 6,    // üretim tarihi (okunur, kullanılmaz)
        ["15"] = 6,    // tavsiye edilen son kullanma
    };

    /// <summary>
    /// Karekod metnini çözümler.
    ///
    /// Okuyucular kodun başına parantezli gösterim ("(01)08699...") ya da
    /// baştaki bir FNC1 koyabiliyor; ikisi de temizlenir. Parantezli biçim
    /// ayrıca değişken alanları kendiliğinden sınırlar.
    /// </summary>
    public static Karekod Coz(string? kod)
    {
        var metin = (kod ?? "").Trim();
        if (metin.Length == 0) return Karekod.Hatali("Karekod boş.");

        // Parantezli gösterim: "(01)0869...(21)ABC(17)271231(10)L1"
        if (metin.Contains('(')) metin = ParantezliDuzlestir(metin);

        foreach (var a in Ayiricilar) metin = metin.Replace(a, AYIRICI.ToString());
        metin = metin.TrimStart(AYIRICI);

        string gtin = "", seri = "", parti = "";
        DateOnly? skt = null;
        var i = 0;

        while (i < metin.Length)
        {
            if (metin[i] == AYIRICI) { i++; continue; }
            if (i + 2 > metin.Length) return Karekod.Hatali("Karekod eksik bitiyor.");

            var ai = metin.Substring(i, 2);
            i += 2;

            if (SabitAi.TryGetValue(ai, out var uzunluk))
            {
                if (i + uzunluk > metin.Length)
                    return Karekod.Hatali($"({ai}) alanı eksik.");
                var deger = metin.Substring(i, uzunluk);
                i += uzunluk;

                if (ai == "01") gtin = deger;
                else if (ai == "17")
                {
                    var t = TarihCoz(deger);
                    if (t is null) return Karekod.Hatali("Son kullanma tarihi geçersiz.");
                    skt = t;
                }
                continue;
            }

            if (!DegiskenAi.Contains(ai))
                return Karekod.Hatali($"Bilinmeyen alan tanımlayıcı: ({ai}).");

            // DEGISKEN ALAN: ayirici varsa oraya kadar; yoksa BIR SONRAKI AI'ya
            //   kadar. Ikincisini yapmayan cozumleyici, ayirici gondermeyen
            //   okuyucuda seri numarasinin icine SKT'yi de katar.
            var son = SonrakiSinir(metin, i);
            var icerik = metin[i..son];
            i = son;

            if (ai == "21") seri = icerik;
            else parti = icerik;
        }

        if (gtin.Length != 14 || !gtin.All(char.IsDigit))
            return Karekod.Hatali("GTIN (01) bulunamadı ya da 14 haneli değil.");

        return new Karekod(gtin, seri, parti, skt, true, "");
    }

    /// <summary>
    /// Değişken alanın nerede bittiği: ayırıcı ya da tanınan bir sonraki AI.
    ///
    /// AI araması İKİ HANE İLERİ gider; seri numarasının içinde "17" geçmesi
    /// olağandır, bu yüzden yalnız ARDINDAN GEÇERLİ BİR ALAN GELEN aday
    /// sınır sayılır (ör. "17" + 6 hane).
    /// </summary>
    private static int SonrakiSinir(string metin, int bas)
    {
        var ayirici = metin.IndexOf(AYIRICI, bas);
        if (ayirici >= 0) return ayirici;

        for (var j = bas + 1; j + 2 <= metin.Length; j++)
        {
            var aday = metin.Substring(j, 2);
            if (SabitAi.TryGetValue(aday, out var uz))
            {
                // Sabit alan tam sigiyor mu: sigmiyorsa bu bir AI degil,
                //   seri numarasinin icindeki iki hanedir.
                if (j + 2 + uz <= metin.Length
                    && metin.Skip(j + 2).Take(uz).All(char.IsDigit))
                    return j;
            }
            else if (DegiskenAi.Contains(aday) && j + 2 < metin.Length)
            {
                return j;
            }
        }
        return metin.Length;
    }

    /// <summary>
    /// YYMMDD → tarih. Gün 00 ise ayın SON GÜNÜ (GS1 kuralı: "ay sonu").
    ///
    /// Yüzyıl GS1 kuralıyla: 51-99 → 1900'ler, 00-50 → 2000'ler. İlaçta
    /// pratikte hep 2000'ler ama kuralı bozmak 2051'de sessizce yanlış tarih
    /// üretirdi.
    /// </summary>
    private static DateOnly? TarihCoz(string yymmdd)
    {
        if (yymmdd.Length != 6 || !yymmdd.All(char.IsDigit)) return null;
        var yy = int.Parse(yymmdd[..2]);
        var ay = int.Parse(yymmdd.Substring(2, 2));
        var gun = int.Parse(yymmdd.Substring(4, 2));
        if (ay is < 1 or > 12) return null;

        var yil = yy <= 50 ? 2000 + yy : 1900 + yy;
        if (gun == 0) gun = DateTime.DaysInMonth(yil, ay);
        if (gun > DateTime.DaysInMonth(yil, ay)) return null;
        return new DateOnly(yil, ay, gun);
    }

    /// <summary>"(01)086...(21)ABC" → düz metin (alanlar ayırıcıyla).</summary>
    private static string ParantezliDuzlestir(string metin)
    {
        var sonuc = new System.Text.StringBuilder();
        var i = 0;
        while (i < metin.Length)
        {
            if (metin[i] == '(')
            {
                var kapanis = metin.IndexOf(')', i);
                if (kapanis < 0) break;
                if (sonuc.Length > 0) sonuc.Append(AYIRICI);
                sonuc.Append(metin[(i + 1)..kapanis]);
                i = kapanis + 1;
                continue;
            }
            sonuc.Append(metin[i]);
            i++;
        }
        return sonuc.ToString();
    }

    /// <summary>GTIN'den barkod: İTS GTIN'i 14 hane, ilaç katalogu 13 (EAN-13).</summary>
    public static string GtinBarkod(string gtin)
        => gtin.Length == 14 && gtin[0] == '0' ? gtin[1..] : gtin;
}
