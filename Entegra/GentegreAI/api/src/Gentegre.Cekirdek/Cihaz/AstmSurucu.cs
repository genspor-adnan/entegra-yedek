namespace Gentegre.Cekirdek.Cihaz;

/// <summary>
/// ASTM E1394 SÜRÜCÜSÜ (432) — küçük analizörlerin ve otoref/tonometre
/// cihazlarının kullandığı satır tabanlı biçim.
///
/// <para>Kayıt tipi satırın İLK karakteridir: H başlık, P hasta, O istem,
/// R sonuç, C yorum, L son. Alan ayırıcı H kaydının 2. karakterinden okunur
/// (genelde <c>|</c>), bileşen ayırıcı 3. karakterden (<c>^</c>).</para>
///
/// <para><b>Çerçeve karakterleri temizlenir.</b> ASTM aktarımı her satırı
/// STX/ETX + sıra numarası + sağlama ile sarar; dosyaya düşen kayıtlarda bu
/// artıklar kalıyor ve ilk alanı bozuyordu.</para>
/// </summary>
public sealed class AstmSurucu : ICihazSurucu
{
    public string Kod => "ASTM";

    public CihazMesaji Coz(string ham)
    {
        if (string.IsNullOrWhiteSpace(ham)) return Bos("Mesaj boş.");

        var satirlar = ham.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries)
                          .Select(Temizle)
                          .Where(x => x.Length > 0)
                          .ToList();
        if (satirlar.Count == 0) return Bos("Kayıt yok.");

        var baslik = satirlar.FirstOrDefault(x => x[0] == 'H');
        if (baslik is null || baslik.Length < 3)
            return Bos("H (başlık) kaydı yok - ASTM mesajı değil.");

        // ASTM basligi: H|\^&|  -> [1] alan ayirici, sonra sirasiyla TEKRAR
        //   (\), BILESEN (^) ve KACIS (&) karakteri. Bileseni [2]'den okumak
        //   tekrar karakterini bilesen sanip test kodunu "^^^SPH" gibi ham
        //   birakiyordu.
        var alanAyirici = baslik[1];
        var bilesen = baslik.Length > 3 ? baslik[3] : '^';

        string Alan(string kayit, int no)
        {
            var p = kayit.Split(alanAyirici);
            return no < p.Length ? p[no].Trim() : "";
        }
        string Ilk(string d) => d.Split(bilesen)[0].Trim();

        string hastaNo = "", ornekNo = "", istemNo = "", kontrolNo = "";
        DateTime? zaman = CihazCevrim.Zaman(Alan(baslik, 13));
        var kalemler = new List<CihazKalemi>();

        foreach (var k in satirlar)
        {
            switch (k[0])
            {
                case 'P':
                    // P-3 uygulama hasta kimliği (P-2 cihazın kendi sırası).
                    if (hastaNo.Length == 0) hastaNo = Ilk(Alan(k, 3));
                    break;

                case 'O':
                    // O-2 örnek kimliği (barkod), O-3 cihazın örnek numarası.
                    if (ornekNo.Length == 0) ornekNo = Ilk(Alan(k, 2));
                    if (istemNo.Length == 0) istemNo = Ilk(Alan(k, 3));
                    break;

                case 'R':
                    kalemler.Add(RCoz(k, Alan, Ilk, bilesen, kalemler.Count + 1));
                    break;
            }
        }

        // ASTM'de mesaj kimliği yok: örnek numarası + ilk sonucun zamanı
        //   tekillik anahtarı olarak kullanılır (mükerrer gönderim koruması).
        if (ornekNo.Length > 0)
            kontrolNo = ornekNo + "-" +
                        (kalemler.FirstOrDefault()?.OlcumZamani ?? zaman)
                        ?.ToString("yyyyMMddHHmmss");

        if (kalemler.Count == 0)
            return new CihazMesaji("ASTM", "R", kontrolNo ?? "", ornekNo, istemNo,
                                   hastaNo, zaman, [], "Mesajda R (sonuç) kaydı yok.");

        return new CihazMesaji("ASTM", "R", kontrolNo ?? "", ornekNo, istemNo,
                               hastaNo, zaman, kalemler);
    }

    private static CihazKalemi RCoz(string k, Func<string, int, string> Alan,
                                    Func<string, string> Ilk, char bilesen, int sira)
    {
        // R-2 test kimliği: ^^^KOD (ilk üç bileşen genelde boş).
        var kimlik = Alan(k, 2).Split(bilesen);
        var kod = kimlik.LastOrDefault(x => x.Trim().Length > 0)?.Trim() ?? "";
        var deger = Alan(k, 3);

        return new CihazKalemi(
            Sira: sira,
            TestKodu: kod,
            TestAdi: kod,
            Deger: deger,
            Sayisal: CihazCevrim.Sayi(deger),
            Birim: Alan(k, 4),
            Referans: Alan(k, 5),
            // R-7 anormallik bayrağı (L/H/LL/HH/N).
            Isaret: Alan(k, 6),
            Durum: Alan(k, 8),
            OlcumZamani: CihazCevrim.Zaman(Alan(k, 12)));
    }

    /// <summary>STX/ETX/ETB, sıra numarası ve sağlama artıklarını atar.</summary>
    private static string Temizle(string satir)
    {
        var s = satir.Trim('', '', '', '\r', '\n', ' ');
        // Cerceve numarasi: satirin basindaki tek rakam (0-7).
        if (s.Length > 1 && char.IsDigit(s[0]) && !char.IsLetter(s[0]) &&
            s.Length > 1 && char.IsLetter(s[1]))
            s = s[1..];
        return s.Trim();
    }

    private static CihazMesaji Bos(string hata)
        => new("ASTM", "", "", "", "", "", null, [], hata);
}
