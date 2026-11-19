using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÖDEME SÖZÜ / PLANI DEĞERLENDİRMESİ (kullanıcı 19.11.2026: "borç bir kısmı veya tamamı ödendiğinde söz kaydı nasıl
/// azalacak/kalkacak?" → "yap"). Söz kaydı DEĞİŞMEZ; durum her okumada sözün verildiği andan SONRAKİ tahsilatlardan
/// hesaplanır - ödeme silinir / iade edilirse sonuç kendiliğinden düzelir.
///
///  * SÖZ: ödenen = söz sonrası tahsilat; kalan = tutar - ödenen. Ödenen ≥ tutar ya da borç kapandı → "tutuldu";
///    vade geçti ve kalan > 0 → "tutulmadi"; yoksa "bekliyor".
///  * PLAN: tutar taksit sayısına eşit bölünür (kuruş farkı son taksitte), ilk taksit tarihinden ayda bir. Ödenen
///    taksitlere sırayla sayılır. Toplam ödendi ya da borç kapandı → "tutuldu"; bugüne kadar vadesi gelen taksitlerden
///    karşılanmayan varsa → "tutulmadi" (geciken taksit sayısıyla); yoksa "bekliyor".
/// </summary>
public static class HastaBorcSozDegerlendirme
{
    public sealed record Sonuc(string Durum, decimal Odenen, decimal Kalan, int OdenenTaksit, int GecikenTaksit,
                               DateTime? SonrakiVade, decimal? SonrakiTutar);

    /// <summary>Söz sonrası tahsilat (yerel, iade eksi) - hasta + an.</summary>
    public sealed record Odeme(int HastaId, DateTime Zaman, decimal Tutar);

    /// <summary>Hastaların <paramref name="bas"/> sonrası başvuru tahsilatları (borç takibinin tahsil kuralıyla).</summary>
    public static Task<List<Odeme>> OdemelerAsync(NpgsqlConnection b, int[] hastalar, DateTime bas, CancellationToken iptal)
        => hastalar.Length == 0 ? Task.FromResult(new List<Odeme>()) : b.ListeAsync("""
            select coalesce(bb.hasta_id, be.taraf_id), ki.islem_tarihi,
                   case when kt.yon > 0 then ki.yerel_tutar else -ki.yerel_tutar end
              from public.kasa_islem ki
              join public.kasa_islem_turu kt on kt.kod = ki.tur
              join public.belge be on be.id = ki.belge_id and be.tipi = 30 and be.tur = 19
              join public.belge_basvuru bb on bb.id = be.id
             where ki.durum <> 9 and ki.islem_tarihi >= @p0
               and coalesce(bb.hasta_id, be.taraf_id) = any(@p1)
            """, null, [bas, hastalar], o => new Odeme(o.GetInt32(0), o.GetDateTime(1), o.GetDecimal(2)), iptal);

    public static Sonuc Degerlendir(short tur, decimal? tutar, DateTime? vade, short? taksitSayisi, DateTime sozZamani,
                                    decimal borc, IEnumerable<Odeme> odemeler, DateTime bugun)
    {
        var toplam = Math.Max(0m, tutar ?? 0m);
        var odenen = Math.Max(0m, odemeler.Where(o => o.Zaman >= sozZamani).Sum(o => o.Tutar));
        var kalan = Math.Max(0m, toplam - odenen);
        var borcKapandi = borc <= 0.005m;

        if (tur != 3)   // SÖZ
        {
            var durum = borcKapandi || kalan <= 0.005m ? "tutuldu"
                      : vade is { } v && v.Date < bugun.Date ? "tutulmadi" : "bekliyor";
            return new Sonuc(durum, odenen, kalan, 0, 0, durum == "tutuldu" ? null : vade, durum == "tutuldu" ? null : kalan);
        }

        // PLAN: taksitler ve sırayla karşılanma
        var n = Math.Max(1, (int)(taksitSayisi ?? 1));
        var pay = Math.Floor(toplam / n * 100m) / 100m;
        var ilk = (vade ?? bugun).Date;
        var taksitler = Enumerable.Range(0, n)
            .Select(i => (Tarih: ilk.AddMonths(i), Tutar: i == n - 1 ? toplam - pay * (n - 1) : pay)).ToList();
        int odenenTaksit = 0, geciken = 0;
        var birikim = 0m;
        (DateTime Tarih, decimal Tutar)? sonraki = null;
        foreach (var t in taksitler)
        {
            birikim += t.Tutar;
            if (odenen >= birikim - 0.005m) { odenenTaksit++; continue; }
            if (t.Tarih < bugun.Date) geciken++;
            sonraki ??= (t.Tarih, Math.Min(t.Tutar, birikim - odenen));
        }
        var planDurum = borcKapandi || odenenTaksit == n ? "tutuldu" : geciken > 0 ? "tutulmadi" : "bekliyor";
        return new Sonuc(planDurum, odenen, kalan, odenenTaksit, geciken,
                         planDurum == "tutuldu" ? null : sonraki?.Tarih, planDurum == "tutuldu" ? null : sonraki?.Tutar);
    }
}
