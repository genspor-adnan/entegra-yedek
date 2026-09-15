using System.Globalization;
using System.Text;
using Gentegre.Cekirdek.Sozlesme;

namespace Gentegre.Cekirdek.Katalog;

public sealed partial class SorguUretici
{
    /// <summary>Özet sorgusunun ürettiği kolon adları (istemci yanıtı okusun diye).</summary>
    public sealed record OzetPlani(SorguParcasi Sorgu, IReadOnlyList<string> Boyutlar,
                                   IReadOnlyList<OzetOlcu> Olculer);

    /// <summary>
    /// ÖZET / İSTATİSTİK (686): `Gruplar()`'ın genelleştirilmişi - kaynağın
    /// sabit grup kolonu yerine tanımdan gelen 1-3 boyut, sum/count yerine
    /// beyaz listedeki ölçü fonksiyonları.
    ///
    /// WHERE liste sorgusuyla AYNI (şube, kapsam, sabit koşul, süzgeç). Boyut
    /// ve ölçü SQL'i OlcuKatalogu şablonlarından; istekten metin gelmez.
    /// Satır tavanı 5.000: çapraz tabloda 60 sütun × 80 satır bile bunun çok
    /// altında; daha fazlası istatistik değil listedir.
    /// </summary>
    public OzetPlani Ozet(DokumTanimi tanim, Kosul? filtre, int? subeId,
                          IReadOnlyList<int>? kapsamTarafIdleri)
    {
        _par.Clear();
        var istek = new ListeIstegi { Filtre = filtre };

        var boyutAdlari = new List<string>();
        var boyutSqlleri = new List<string>();
        var tumBoyutlar = new List<string>(tanim.Boyut?.Satir ?? []);
        if (!string.IsNullOrEmpty(tanim.Boyut?.Sutun)) tumBoyutlar.Add(tanim.Boyut!.Sutun!);

        var secim = new StringBuilder("select ");
        foreach (var b in tumBoyutlar)
        {
            var (alan, kesme) = OlcuKatalogu.BoyutCoz(b);
            var kolon = _kaynak.Kolon(alan)
                ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen alan: {alan}");
            var ad = kesme.Length == 0 ? alan : $"{alan}_{kesme}";
            boyutAdlari.Add(ad);
            boyutSqlleri.Add(OlcuKatalogu.BoyutSql(kolon, kesme));
            secim.Append(boyutSqlleri[^1]).Append(" as \"").Append(ad).Append("\", ");
        }

        var olculer = new List<OzetOlcu>();
        foreach (var o in tanim.Olcu ?? [])
        {
            var fn = OlcuKatalogu.Fn(o.Fn) ?? throw GentegreHatasi.Dogrulama($"Bilinmeyen ölçü: {o.Fn}");
            var alanKolon = string.IsNullOrEmpty(o.Alan) ? null : _kaynak.Kolon(o.Alan!);
            var bolenKolon = string.IsNullOrEmpty(o.Bolen) ? null : _kaynak.Kolon(o.Bolen!);
            var sql = fn.Sablon
                .Replace("{x}", alanKolon?.Sql ?? "1")
                .Replace("{y}", bolenKolon?.Sql ?? "1");
            var ad = alanKolon is null ? o.Fn : $"{alanKolon.Ad}_{o.Fn}";
            var baslik = string.IsNullOrWhiteSpace(o.Baslik)
                ? fn.BaslikEki.Replace("{b}", alanKolon?.Baslik ?? "").Replace("{y}", bolenKolon?.Baslik ?? "")
                : o.Baslik;
            olculer.Add(new OzetOlcu(ad, baslik, o.Fn, fn.Bicim));
            secim.Append(sql).Append(" as \"").Append(ad).Append("\", ");
        }
        secim.Length -= 2;

        var sqlMetni = new StringBuilder()
            .Append(secim)
            .Append(" from ").Append(_kaynak.Kaynak)
            .Append(Nerede(istek, subeId, kapsamTarafIdleri));

        if (boyutSqlleri.Count > 0)
        {
            sqlMetni.Append(" group by ").Append(string.Join(", ",
                Enumerable.Range(1, boyutSqlleri.Count).Select(i => i.ToString(CultureInfo.InvariantCulture))));
            // GİZLİLİK EŞİĞİ: küçük hücre hiç dönmez (istemcide "<n" yazılır).
            if (tanim.Esik > 0) sqlMetni.Append(" having count(*) >= ").Append(Ekle(tanim.Esik));
            sqlMetni.Append(" order by ").Append(string.Join(", ",
                Enumerable.Range(1, boyutSqlleri.Count).Select(i => i.ToString(CultureInfo.InvariantCulture))));
        }
        sqlMetni.Append(" limit ").Append(Ekle(5000));

        return new OzetPlani(new SorguParcasi(sqlMetni.ToString(), _par.ToArray()), boyutAdlari, olculer);
    }
}
