namespace Gentegre.Cekirdek.Cihaz;

/// <summary>
/// HL7 v2 SÜRÜCÜSÜ (432) — sonuç mesajı (ORU^R01 / OUL^R22) çözümleyici.
///
/// <para><b>Ayırıcılar MSH'den okunur, sabit varsayılmaz.</b> Standart
/// <c>|^~\&amp;</c> ama cihazlar başka karakter kullanabiliyor; sabit kabul
/// etmek o cihazlarda her alanı yanlış yere düşürürdü.</para>
///
/// <para><b>Segment sırası değil ADI okunur.</b> Cihazlar NTE, SPM, TQ1 gibi
/// segmentleri araya serpiştiriyor; "üçüncü satır OBR'dir" varsayımı ilk
/// farklı cihazda kırılır.</para>
///
/// <para>Kapsam sonuç MESAJIDIR: OBX kalemleri + OBR/SPM'den örnek ve istem
/// numarası, PID'den hasta numarası. Sipariş (ORM) ve çalışma listesi
/// gönderimi Faz 2 (Lab v1) işidir.</para>
/// </summary>
public sealed class Hl7Surucu : ICihazSurucu
{
    public string Kod => "HL7V2";

    public CihazMesaji Coz(string ham)
    {
        if (string.IsNullOrWhiteSpace(ham))
            return Bos("Mesaj boş.");

        // MLLP zarfı (0x0B … 0x1C 0x0D) gelmiş olabilir - ayıklanır.
        var metin = ham.Trim('\v', '', '\r', '\n', ' ');
        var satirlar = metin.Split(['\r', '\n'], StringSplitOptions.RemoveEmptyEntries);
        if (satirlar.Length == 0 || !satirlar[0].StartsWith("MSH", StringComparison.Ordinal))
            return Bos("MSH segmenti yok - HL7 v2 mesajı değil.");

        var msh = satirlar[0];
        if (msh.Length < 8) return Bos("MSH segmenti eksik.");

        // MSH-1 alan ayırıcı, MSH-2 kodlama karakterleri (bileşen ~ tekrar
        //   \ kaçış & alt bileşen).
        var alanAyirici = msh[3];
        var kodlama = msh[4..].Split(alanAyirici)[0];
        var bilesen = kodlama.Length > 0 ? kodlama[0] : '^';
        var tekrar = kodlama.Length > 1 ? kodlama[1] : '~';

        string Alan(string segment, int no)
        {
            var p = segment.Split(alanAyirici);
            // MSH'de alan numaralandırması kaymalıdır: MSH-1 ayırıcının
            //   kendisi, dolayısıyla MSH-3 dizinin 2. ögesidir.
            var i = segment.StartsWith("MSH", StringComparison.Ordinal) ? no - 1 : no;
            return i >= 0 && i < p.Length ? p[i] : "";
        }

        string Ilk(string deger)
        {
            var b = deger.Split(bilesen);
            return b.Length > 0 ? b[0].Trim() : deger.Trim();
        }

        var mesajTipi = Alan(msh, 9).Replace(bilesen, '^');
        var kontrolNo = Alan(msh, 10);
        var mesajZamani = CihazCevrim.Zaman(Alan(msh, 7));

        string hastaNo = "", ornekNo = "", istemNo = "";
        var kalemler = new List<CihazKalemi>();

        foreach (var s in satirlar)
        {
            if (s.Length < 3) continue;
            var ad = s[..3];

            switch (ad)
            {
                case "PID":
                    // PID-3 hasta kimlik listesi; ilk bileşen numaradır.
                    hastaNo = Ilk(Alan(s, 3).Split(tekrar)[0]);
                    break;

                case "OBR":
                    // OBR-2 yerleştirici (bizim istem no), OBR-3 dolduran
                    //   (cihazın örnek no). İkisi de boşsa OBR-4 kod kalır.
                    if (istemNo.Length == 0) istemNo = Ilk(Alan(s, 2));
                    if (ornekNo.Length == 0) ornekNo = Ilk(Alan(s, 3));
                    break;

                case "SPM":
                    // SPM-2 örnek kimliği: modern cihazlar burayı kullanıyor.
                    if (ornekNo.Length == 0) ornekNo = Ilk(Alan(s, 2));
                    break;

                case "OBX":
                    kalemler.Add(ObxCoz(s, Alan, Ilk, bilesen, kalemler.Count + 1));
                    break;
            }
        }

        if (kalemler.Count == 0)
            return new CihazMesaji("HL7V2", mesajTipi, kontrolNo, ornekNo, istemNo,
                                   hastaNo, mesajZamani, [], "Mesajda OBX (sonuç) yok.");

        return new CihazMesaji("HL7V2", mesajTipi, kontrolNo, ornekNo, istemNo,
                               hastaNo, mesajZamani, kalemler);
    }

    private static CihazKalemi ObxCoz(string s, Func<string, int, string> Alan,
                                      Func<string, string> Ilk, char bilesen, int sira)
    {
        // OBX-3 test kimliği: kod^ad^kodlama sistemi.
        var kimlik = Alan(s, 3).Split(bilesen);
        var kod = kimlik.Length > 0 ? kimlik[0].Trim() : "";
        var ad = kimlik.Length > 1 ? kimlik[1].Trim() : "";
        var deger = Alan(s, 5).Trim();

        return new CihazKalemi(
            Sira: sira,
            TestKodu: kod,
            TestAdi: ad.Length > 0 ? ad : kod,
            Deger: deger,
            Sayisal: CihazCevrim.Sayi(deger),
            Birim: Ilk(Alan(s, 6)),
            Referans: Alan(s, 7).Trim(),
            Isaret: Alan(s, 8).Trim(),
            Durum: Alan(s, 11).Trim(),
            OlcumZamani: CihazCevrim.Zaman(Alan(s, 14)));
    }

    private static CihazMesaji Bos(string hata)
        => new("HL7V2", "", "", "", "", "", null, [], hata);
}
