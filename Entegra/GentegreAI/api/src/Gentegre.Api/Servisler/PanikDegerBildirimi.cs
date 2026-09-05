using Gentegre.Cekirdek.Bildirim;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// PANİK DEĞER BİLDİRİMİ (Faz 0 · 399) — lab istemi kaydedilince, işareti
/// "Panik" (3) olan testler için isteyen hekime bildirim kuyruğa konur.
///
/// TETİK NEDEN <c>isaret</c> ALANINDAN: panik eşiklerinin kataloğu (referans
/// aralıkları, TAT, oto-onay) Faz 2'nin işi. Faz 0'da eşiği hesaplamaya
/// kalkmak, sonradan gelecek katalogla çakışan ikinci bir kural yazmak olurdu.
/// Bugün sonucu giren/onaylayan kişi satırı "Panik" işaretliyor; bildirim onu
/// izliyor. Faz 2'de eşik kataloğu geldiğinde işareti kural motoru koyar,
/// BURASI DEĞİŞMEZ.
///
/// TEKRAR GÖNDERMEZ: aynı test satırı için kuyrukta/gönderilmiş bir bildirim
/// varsa yenisi konmaz — istem her kaydedildiğinde hekime aynı panik mesajı
/// gitse, üçüncüsünden sonra kimse okumaz.
///
/// ÖNCELİK 1 ve şablonun saat penceresi yok: panik değer gece de gider.
/// </summary>
public sealed class PanikDegerBildirimi
{
    private readonly VeriKaynagi _veri;
    private readonly BildirimDeposu _bildirim;
    private readonly ILogger<PanikDegerBildirimi> _gunluk;

    public PanikDegerBildirimi(VeriKaynagi veri, BildirimDeposu bildirim,
                               ILogger<PanikDegerBildirimi> gunluk)
    {
        _veri = veri;
        _bildirim = bildirim;
        _gunluk = gunluk;
    }

    /// <summary>Bildirim kaynağı: 5 = lab testi (kuyruk `kaynak_tur`).</summary>
    private const short KaynakLabTesti = 5;

    /// <summary>Panik işareti (lab_istem_test.isaret): 0 normal · 1 düşük · 2 yüksek · 3 panik.</summary>
    private const short PanikIsareti = 3;

    public async Task TazeleAsync(long istemId, int kullaniciId, CancellationToken iptal)
    {
        if (await AyarAsync("lab.panik_bildirim_acik", "1", iptal) == "0") return;

        var panikler = await _veri.ListeAsync("""
            select t.id, coalesce(t.ad, t.kod) as test, coalesce(t.sonuc, '') as sonuc,
                   coalesce(t.birim, '')       as birim,
                   coalesce(h.unvan, '')       as hasta,
                   coalesce(b.belge_no, '')    as protokol,
                   coalesce(p.cep_tel, '')     as hekim_tel,
                   coalesce(p.unvan, '')       as hekim,
                   coalesce(i.sube_id, 0)      as sube_id
              from public.lab_istem_test t
              join public.lab_istem i on i.id = t.istem_id
              left join public.taraf h on h.id = i.taraf_id
              left join public.taraf p on p.id = i.personel_id
              left join public.belge b on b.id = i.belge_id
             where t.istem_id = @p0
               and t.isaret = @p1
               and coalesce(t.sonuc, '') <> ''
               -- Ayni test icin ZATEN bildirim varsa (iptal edilmemis) atla.
               and not exists (
                     select 1 from public.bildirim n
                      where n.kaynak_tur = @p2 and n.kaynak_id = t.id and n.durum <> 5)
            """, new object?[] { (int)istemId, PanikIsareti, KaynakLabTesti },
            o => new
            {
                TestId = o.GetInt32(0), Test = o.GetString(1), Sonuc = o.GetString(2),
                Birim = o.GetString(3), Hasta = o.GetString(4), Protokol = o.GetString(5),
                HekimTel = o.GetString(6), Hekim = o.GetString(7), SubeId = o.GetInt32(8),
            }, iptal);

        if (panikler.Count == 0) return;

        // NÖBET NUMARASI: isteyen hekimin telefonu yoksa (ya da her panikte
        //   ikinci bir hat isteniyorsa) buraya da gider. Boş bırakılabilir.
        var ekNumara = Rakamlar(await AyarAsync("lab.panik_ek_numara", "", iptal));

        foreach (var p in panikler)
        {
            var alicilar = new List<string>();
            var hekimTel = Rakamlar(p.HekimTel);
            if (hekimTel.Length >= 10) alicilar.Add(hekimTel);
            if (ekNumara.Length >= 10 && !alicilar.Contains(ekNumara)) alicilar.Add(ekNumara);

            if (alicilar.Count == 0)
            {
                // Sessiz kalmaz: panik değerin haber verilememesi kayda geçer.
                _gunluk.LogWarning(
                    "Lab istem {Istem}: PANİK değer ({Test} = {Sonuc}) bildirilemedi - "
                    + "isteyen hekimin telefonu yok ve lab.panik_ek_numara boş.",
                    istemId, p.Test, p.Sonuc);
                continue;
            }

            var degerler = new Dictionary<string, string>
            {
                ["hasta_ad"] = p.Hasta,
                ["protokol"] = p.Protokol,
                ["test"] = p.Test,
                ["sonuc"] = string.IsNullOrWhiteSpace(p.Birim) ? p.Sonuc : $"{p.Sonuc} {p.Birim}",
            };

            foreach (var alici in alicilar)
                await _bildirim.KuyrugaEkleAsync(new BildirimIstegi(
                        SablonKodu: "panik.deger",
                        Kanal: null,
                        Alici: alici,
                        Degiskenler: degerler,
                        KaynakTur: KaynakLabTesti,
                        KaynakId: p.TestId,
                        Oncelik: 1,           // kuyrukta en önde
                        Planlanan: null),     // hemen
                    kullaniciId, p.SubeId > 0 ? p.SubeId : null, iptal);
        }
    }

    private async Task<string> AyarAsync(string anahtar, string varsayilan, CancellationToken iptal)
        => await _veri.TekDegerAsync<string>(
               "select deger from public.referans where anahtar = @p0",
               new object?[] { anahtar }, iptal) is { Length: > 0 } d ? d : varsayilan;

    private static string Rakamlar(string metin)
    {
        var s = new string(metin.Where(char.IsDigit).ToArray());
        if (s.StartsWith("90", StringComparison.Ordinal) && s.Length > 10) s = s[2..];
        return s.TrimStart('0');
    }
}
