using System.Text;

namespace Gentegre.Cekirdek.Cihaz;

/// <summary>Gelen ORU^R01'den çıkarılan rapor — iş kuralı yok, düz veri.</summary>
public sealed record GelenOru
{
    public bool Gecerli { get; init; }
    public string Hata { get; init; } = "";

    public string KontrolNo { get; init; } = "";
    public string Surum { get; init; } = "";
    public string GonderenUygulama { get; init; } = "";
    public string GonderenTesis { get; init; } = "";
    public DateTime? MesajZamani { get; init; }

    public string AccessionNo { get; init; } = "";
    /// <summary>ORC-21 ya da OBR-15'teki SKRS kodu — raporu kim gönderdi.</summary>
    public string GonderenSkrs { get; init; } = "";
    public string HastaTckn { get; init; } = "";
    public string HastaDosyaNo { get; init; } = "";
    public string HastaAdi { get; init; } = "";

    public DateTime? OnayZamani { get; init; }
    public string RadyologTckn { get; init; } = "";
    public string RadyologAdi { get; init; } = "";

    public string RaporTeknik { get; init; } = "";
    public string RaporKarsilastirma { get; init; } = "";
    public string RaporBulgular { get; init; } = "";
    public string RaporSonuc { get; init; } = "";
    /// <summary>Parçalanamayan gövde (kurum profili düz metin) — olduğu gibi.</summary>
    public string RaporDuzMetin { get; init; } = "";

    public short IstemNedeniPuan { get; init; }
    public short CekimKalitePuan { get; init; }
    public string KontrastObx17 { get; init; } = "";
    /// <summary>OBX-11 = C ise bu bir düzeltme (ek rapor).</summary>
    public bool Duzeltme { get; init; }

    /// <summary>Rapor gövdesi hiç yoksa yazılacak bir şey yok demektir.</summary>
    public bool GovdeVar =>
        RaporBulgular.Length > 0 || RaporSonuc.Length > 0
        || RaporTeknik.Length > 0 || RaporKarsilastirma.Length > 0
        || RaporDuzMetin.Length > 0;
}

/// <summary>
/// GELEN ORU^R01 ÇÖZÜMLEYİCİSİ (817) — <see cref="OruUretici"/>'nin aynası.
///
/// <para><b>Ayırıcılar MSH'den okunur</b> (432'deki kural): sabit
/// <c>|^~\&amp;</c> varsaymak, başka ayırıcı kullanan ilk sistemde her alanı
/// yanlış yere düşürür.</para>
///
/// <para><b>İki gövde biçimi de anlaşılır.</b> Bakanlık dört parça base64
/// gönderiyor (<c>gövde^3~gövde^4</c>), kurum HBYS'leri düz TX satırları.
/// Birini desteklemek ötekini "boş rapor" yapardı - ikisi de okunur, parça
/// numarası varsa ona, yoksa başlığa bakılır.</para>
///
/// <para><b>Çözümleyici yazmaz, karar vermez:</b> hangi isteğe ait olduğu ve
/// ne yazılacağı servis katmanının işi. Burada yalnız metin çözümlenir -
/// böylece mesaj biçimi veritabanısız sınanabiliyor.</para>
/// </summary>
public static class OruCozumleyici
{
    public static GelenOru Coz(string ham)
    {
        if (string.IsNullOrWhiteSpace(ham))
            return new GelenOru { Hata = "Mesaj boş." };

        // MLLP zarfı gelmiş olabilir - ayıklanır.
        var metin = ham.Trim('\v', '', '\r', '\n', ' ');
        var satirlar = metin.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries);
        if (satirlar.Length == 0 || !satirlar[0].StartsWith("MSH", StringComparison.Ordinal))
            return new GelenOru { Hata = "MSH segmenti yok - HL7 v2 mesajı değil." };

        var msh = satirlar[0];
        if (msh.Length < 8) return new GelenOru { Hata = "MSH segmenti eksik." };

        var alanAyirici = msh[3];
        var kodlama = msh[4..].Split(alanAyirici)[0];
        var bilesen = kodlama.Length > 0 ? kodlama[0] : '^';
        var tekrar = kodlama.Length > 1 ? kodlama[1] : '~';

        string Alan(string segment, int no)
        {
            var p = segment.Split(alanAyirici);
            // MSH'de 1. alan ayırıcının KENDİSİ: MSH-3 dizinin 2. ögesi.
            var i = segment.StartsWith("MSH", StringComparison.Ordinal) ? no - 1 : no;
            return i >= 0 && i < p.Length ? p[i] : "";
        }
        string Parca(string deger, int sira)
        {
            var b = deger.Split(bilesen);
            return sira < b.Length ? b[sira].Trim() : "";
        }
        string Segment(string ad)
            => satirlar.FirstOrDefault(x => x.StartsWith(ad, StringComparison.Ordinal)) ?? "";

        var mesajTipi = Alan(msh, 9).Replace(bilesen, '^');
        if (!mesajTipi.StartsWith("ORU", StringComparison.OrdinalIgnoreCase))
            return new GelenOru
            {
                KontrolNo = Alan(msh, 10),
                Hata = $"Beklenen ORU^R01, gelen '{mesajTipi}'.",
            };

        var pid = Segment("PID");
        var orc = Segment("ORC");
        var obr = Segment("OBR");
        if (obr.Length == 0)
            return new GelenOru
            {
                KontrolNo = Alan(msh, 10),
                Hata = "OBR segmenti yok - hangi tetkike ait olduğu bilinemiyor.",
            };

        // ACCESSION İKİ YERDE: OBR-18 birincil, yoksa ORC-2 / OBR-3 / OBR-2.
        //   Kılavuz ikisinin de aynı olmasını istiyor ama gönderenlerin bir
        //   kısmı yalnız birini dolduruyor.
        var accession = Ilk(
            Kacissiz(Alan(obr, 18)),
            Parca(Kacissiz(Alan(orc, 2)), 0),
            Parca(Kacissiz(Alan(obr, 3)), 0),
            Parca(Kacissiz(Alan(obr, 2)), 0));

        // SKRS: ORC-21 (kurum kodu) ya da OBR-15'teki `12345&&SKRS` biçimi.
        var skrs = Parca(Kacissiz(Alan(orc, 21)), 0);
        if (skrs.Length == 0)
        {
            var kaynak = Alan(obr, 15);
            var ilkParca = Parca(kaynak, 0);
            if (ilkParca.Contains('&'))
            {
                var alt = ilkParca.Split('&')[0].Trim();
                if (alt.Length > 0 && !alt.Equals("Radiology", StringComparison.OrdinalIgnoreCase))
                    skrs = alt;
            }
        }

        var obxler = satirlar.Where(x => x.StartsWith("OBX", StringComparison.Ordinal)).ToList();
        var govde = GovdeCoz(obxler, alanAyirici, bilesen, tekrar, Alan, Parca);

        return new GelenOru
        {
            Gecerli = true,
            KontrolNo = Alan(msh, 10),
            Surum = Alan(msh, 12),
            GonderenUygulama = Kacissiz(Alan(msh, 3)),
            GonderenTesis = Kacissiz(Alan(msh, 4)),
            MesajZamani = Zaman(Alan(msh, 7)),

            AccessionNo = accession,
            GonderenSkrs = skrs,
            HastaTckn = Parca(Kacissiz(Alan(pid, 4)), 0),
            HastaDosyaNo = Parca(Kacissiz(Alan(pid, 3)), 0),
            // ÖNCE BİLEŞENE AYIR, SONRA KAÇIŞI AÇ: tersi sırada adın içindeki
            //   kaçışlı `\S\` gerçek ayırıcıya dönüşüp ad bölünüyordu.
            HastaAdi = string.Join(' ', new[] { Parca(Alan(pid, 5), 0), Parca(Alan(pid, 5), 1) }
                                        .Select(Kacissiz)
                                        .Where(x => x.Length > 0)).Trim(),

            // OBR-7 ORU'da RAPOR ONAY zamanıdır (kılavuzun sık yapılan
            //   hatalar listesinde); yoksa mesaj zamanına düşülür.
            OnayZamani = Zaman(Alan(obr, 7)) ?? Zaman(Alan(msh, 7)),
            RadyologTckn = govde.RadyologTckn,
            RadyologAdi = govde.RadyologAdi,

            RaporTeknik = govde.Teknik,
            RaporKarsilastirma = govde.Karsilastirma,
            RaporBulgular = govde.Bulgular,
            RaporSonuc = govde.Sonuc,
            RaporDuzMetin = govde.DuzMetin,
            IstemNedeniPuan = govde.NedenPuan,
            CekimKalitePuan = govde.KalitePuan,
            KontrastObx17 = govde.Kontrast,
            Duzeltme = govde.Duzeltme,
        };
    }

    private sealed record Govde(string Teknik, string Karsilastirma, string Bulgular,
                                string Sonuc, string DuzMetin, string RadyologTckn,
                                string RadyologAdi, short NedenPuan, short KalitePuan,
                                string Kontrast, bool Duzeltme);

    private static Govde GovdeCoz(List<string> obxler, char alanAyirici, char bilesen,
                                  char tekrar, Func<string, int, string> Alan,
                                  Func<string, int, string> Parca)
    {
        var parcalar = new Dictionary<int, string>();
        var duz = new List<string>();
        string radyologTckn = "", radyologAdi = "", kontrast = "";
        short nedenPuan = 0, kalitePuan = 0;
        var duzeltme = false;

        foreach (var obx in obxler)
        {
            var tanim = Alan(obx, 3);
            var deger = Alan(obx, 5);

            if (Alan(obx, 11).Trim().Equals("C", StringComparison.OrdinalIgnoreCase))
                duzeltme = true;

            // OBX-16: raporu onaylayan radyolog. Her satırda tekrar ediyor,
            //   ilk dolu olan alınır.
            var kisi = Alan(obx, 16);
            if (kisi.Length > 0 && radyologTckn.Length == 0)
            {
                var ilk = kisi.Split(tekrar)[0];
                radyologTckn = Parca(ilk, 0);
                radyologAdi = string.Join(' ',
                    new[] { Parca(ilk, 2), Parca(ilk, 1) }.Where(x => x.Length > 0)).Trim();
            }

            var puanlar = Alan(obx, 13);
            if (puanlar.Contains(bilesen) && nedenPuan == 0)
            {
                short.TryParse(Parca(puanlar, 0), out nedenPuan);
                short.TryParse(Parca(puanlar, 1), out kalitePuan);
            }

            if (kontrast.Length == 0 && Alan(obx, 17).Length > 0) kontrast = Alan(obx, 17);

            // BASE64 GÖVDE: tanım alanı `TXT^BASE64` / `HTML^BASE64`.
            if (tanim.Contains("BASE64", StringComparison.OrdinalIgnoreCase))
            {
                foreach (var p in deger.Split(tekrar, StringSplitOptions.RemoveEmptyEntries))
                {
                    var son = p.LastIndexOf(bilesen);
                    var metin = son > 0 ? p[..son] : p;
                    var no = son > 0 && int.TryParse(p[(son + 1)..].Trim(), out var n) ? n : 0;
                    var cozulen = Base64Coz(metin);
                    if (cozulen.Length == 0) continue;
                    // NUMARASIZ PARÇA DÜZ METNE: uydurup 3'e (Bulgular)
                    //   yazmak, raporun yanlış bölümüne düşürmek olurdu.
                    if (no is >= 1 and <= 4)
                        parcalar[no] = parcalar.TryGetValue(no, out var v)
                                     ? v + "\n" + cozulen : cozulen;
                    else duz.Add(cozulen);
                }
                continue;
            }

            // DÜZ TX: satır satır gelir, sırası korunur.
            var satir = Kacissiz(deger);
            if (satir.Length > 0) duz.Add(satir);
        }

        var duzMetin = string.Join("\n", duz).Trim();

        // BAŞLIKLI DÜZ METİN: kendi ürettiğimiz kurum profili "Bulgular:" gibi
        //   başlıklarla gidiyor - geri geldiğinde parçalara ayrılabilsin.
        if (parcalar.Count == 0 && duzMetin.Length > 0)
        {
            var ayrilan = BasliktanParcala(duzMetin);
            if (ayrilan.Count > 0)
            {
                foreach (var (no, metin) in ayrilan) parcalar[no] = metin;
                duzMetin = "";
            }
        }

        return new Govde(
            parcalar.GetValueOrDefault(1, ""), parcalar.GetValueOrDefault(2, ""),
            parcalar.GetValueOrDefault(3, ""), parcalar.GetValueOrDefault(4, ""),
            duzMetin, radyologTckn, radyologAdi, nedenPuan, kalitePuan, kontrast, duzeltme);
    }

    /// <summary>"Bulgular:" gibi başlıkları parça numarasına çevirir.</summary>
    private static Dictionary<int, string> BasliktanParcala(string metin)
    {
        var sonuc = new Dictionary<int, string>();
        var aktif = 0;
        var tampon = new StringBuilder();

        void Bosalt()
        {
            if (aktif > 0 && tampon.Length > 0)
                sonuc[aktif] = tampon.ToString().Trim();
            tampon.Clear();
        }

        foreach (var satir in metin.Split('\n'))
        {
            var kirpik = satir.Trim();
            var no = BaslikNo(kirpik);
            if (no > 0) { Bosalt(); aktif = no; continue; }
            if (aktif > 0) tampon.AppendLine(kirpik);
        }
        Bosalt();
        return sonuc;
    }

    private static int BaslikNo(string satir)
    {
        if (!satir.EndsWith(':')) return 0;
        var b = satir[..^1].Trim().ToLower(System.Globalization.CultureInfo.GetCultureInfo("tr-TR"));
        return b switch
        {
            "teknik" => 1,
            "karşılaştırma" or "karsilastirma" => 2,
            "bulgular" => 3,
            "sonuç ve öneriler" or "sonuc ve oneriler" or "sonuç" or "sonuc" => 4,
            _ => 0,
        };
    }

    private static string Base64Coz(string deger)
    {
        var temiz = deger.Trim();
        if (temiz.Length == 0) return "";
        try { return Encoding.UTF8.GetString(Convert.FromBase64String(temiz)).Trim(); }
        // BASE64 DEĞİLSE METNİN KENDİSİ: kimi sistem `TXT^BASE64` yazıp düz
        //   metin gönderiyor. Mesajı çöpe atmaktansa okunanı almak yeğdir.
        catch (FormatException) { return Kacissiz(temiz); }
    }

    private static DateTime? Zaman(string deger)
    {
        var d = new string(deger.Where(char.IsDigit).ToArray());
        if (d.Length < 8) return null;
        var bicim = d.Length >= 14 ? "yyyyMMddHHmmss" : d.Length >= 12 ? "yyyyMMddHHmm" : "yyyyMMdd";
        return DateTime.TryParseExact(d[..bicim.Length], bicim, null,
                   System.Globalization.DateTimeStyles.None, out var t) ? t : null;
    }

    private static string Ilk(params string[] adaylar)
        => adaylar.FirstOrDefault(x => !string.IsNullOrWhiteSpace(x))?.Trim() ?? "";

    /// <summary>HL7 kaçışını geri çevirir (üreticinin tersi).</summary>
    internal static string Kacissiz(string? deger)
    {
        if (string.IsNullOrEmpty(deger)) return "";
        return deger
            .Replace(@"\F\", "|").Replace(@"\S\", "^")
            .Replace(@"\R\", "~").Replace(@"\T\", "&")
            .Replace(@"\X0D0A\", "\n").Replace(@"\X0D\", "\n").Replace(@"\X0A\", "\n")
            // Ters bölü EN SON: önce açılsaydı öteki kaçışları bozardı.
            .Replace(@"\E\", @"\");
    }
}
