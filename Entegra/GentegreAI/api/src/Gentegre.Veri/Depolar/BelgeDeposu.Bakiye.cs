using System.Globalization;
using System.Text.Json;
using Gentegre.Cekirdek.Katalog;
using Gentegre.Cekirdek.Sozlesme;
using Npgsql;
using static Gentegre.Veri.JsonDeger;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// STOK BAKİYE DENETİMİ (12.11.2026; kullanıcı: "Giriş belgesi ile stoğu arttırıyorum, çıkış belgesi ile hepsini çıkış
/// yapıyorum, sonra giriş belgesini silebiliyorum. Stok eksiye düşüyor.. Genel bir çalışma yap").
///
/// Eskiden denetim yalnız YAZARKEN, satır satır ve "bakiye eksi mi" diye yapılıyordu (DepoyaYazAsync): belge silinince
/// (stok geri alınır) hiç denetim yoktu; zaten eksi olan stoğa GİRİŞ yapmak bile "engelle" modunda reddediliyordu.
///
/// Şimdi TEK KURAL, her belge işleminde (kaydet / düzenle / sil): işlemden önce belgenin değdiği stok × depo ve
/// stok × depo × lot bakiyelerinin anlık görüntüsü alınır, işlemden sonra yeniden okunur. Bir bakiye eksiye düştüyse
/// VE işlemden önceki hâlinden kötüleştiyse:
///   - belgenin GİRİŞ TARAFINDAKİ depoda (giriş belgesi, iade girişi, transferin varış deposu) bu, tüketilmiş malın
///     geri alınmasıdır - ayardan bağımsız HER ZAMAN engellenir (kullanıcı kararı: "Her zaman engelle");
///   - ÇIKIŞ TARAFINDAKİ depoda yeni bir çıkıştır - `stok.negatif_davranis` (0 serbest / 1 uyar / 2 engelle) uygulanır.
/// Kötüleşmeyen eksi bakiye (önceden eksiydi, işlem değiştirmedi ya da iyileştirdi) sessizdir. Tekrar kullanılan
/// (yeniden_kullanilir) stok denetlenmez (141).
/// </summary>
public sealed partial class BelgeDeposu
{
    private sealed class BakiyeAnligi
    {
        public HashSet<int> Stoklar { get; } = [];
        public HashSet<int> Depolar { get; } = [];
        /// <summary>Bu belgenin GİRİŞ tarafındaki depolar (eski ve yeni hâli) - burada düşüş geriye dönüktür.</summary>
        public HashSet<int> GirisDepolari { get; } = [];
        public Dictionary<(int Stok, int Depo), decimal> Depo { get; set; } = [];
        public Dictionary<(int Stok, int Depo, int Lot), decimal> Lot { get; set; } = [];
    }

    /// <summary>
    /// İşlemden ÖNCE: belgenin (varsa) kayıtlı satırları + istekte gelen yeni hâli (belge / satırlar) hangi stok ve
    /// depolara değiyorsa onların bakiyeleri. Yeni belgede belgeId = 0.
    /// </summary>
    private static async Task<BakiyeAnligi> BakiyeAnligiAlAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem,
        int belgeId, IDictionary<string, object?>? belge, List<Dictionary<string, JsonElement>>? satirlar,
        CancellationToken iptal)
    {
        var a = new BakiyeAnligi();
        int? tur = null, tipi = null;
        if (belgeId > 0)
        {
            await using (var k = baglanti.Komut("""
                select b.tur, coalesce(b.tipi, 0), b.giris_depo_id, b.cikis_depo_id
                  from public.belge b where b.id = @p0
                """, islem, belgeId))
            await using (var o = await k.ExecuteReaderAsync(iptal))
                if (await o.ReadAsync(iptal))
                {
                    tur = o.GetInt32(0); tipi = o.GetInt32(1);
                    DepoEkle(a, tur.Value, tipi.Value, o.IsDBNull(2) ? null : o.GetInt32(2), o.IsDBNull(3) ? null : o.GetInt32(3));
                }
            if (tur is int t0)
            {
                await using var k = baglanti.Komut("""
                    select s.stok_id, s.giris_depo_id, s.cikis_depo_id
                      from public.belge_satir s
                     where s.belge_id = @p0 and s.stok_id is not null
                    """, islem, belgeId);
                await using var o = await k.ExecuteReaderAsync(iptal);
                while (await o.ReadAsync(iptal))
                {
                    a.Stoklar.Add(o.GetInt32(0));
                    DepoEkle(a, t0, tipi!.Value, o.IsDBNull(1) ? null : o.GetInt32(1), o.IsDBNull(2) ? null : o.GetInt32(2));
                }
            }
        }
        if (belge is not null)
        {
            var yTur = SayiNull(belge, "tur") ?? tur ?? 0;
            var yTipi = SayiNull(belge, "tipi") ?? tipi ?? 0;
            DepoEkle(a, yTur, yTipi, SayiNull(belge, "girisDepoId"), SayiNull(belge, "cikisDepoId"));
            foreach (var s in satirlar ?? [])
            {
                if (JsonSayiNull(s, "stokId") is int st) a.Stoklar.Add(st);
                DepoEkle(a, yTur, yTipi, JsonSayiNull(s, "girisDepoId"), JsonSayiNull(s, "cikisDepoId"));
            }
        }
        (a.Depo, a.Lot) = await BakiyeOkuAsync(baglanti, islem, a, iptal);
        return a;

        static void DepoEkle(BakiyeAnligi a, int tur, int tipi, int? giris, int? cikis)
        {
            if (giris is int g) a.Depolar.Add(g);
            if (cikis is int c) a.Depolar.Add(c);
            // Giriş tarafı: transferin varış deposu; transfer dışı GİRİŞ yönlü belgenin (iade girişi dahil) deposu.
            if (BelgeTuru.TransferMi(tur)) { if (giris is int tg) a.GirisDepolari.Add(tg); }
            else if (!BelgeTuru.CikisMi(tur, tipi))
            {
                if (giris is int gg) a.GirisDepolari.Add(gg);
                else if (cikis is int cc) a.GirisDepolari.Add(cc);   // satırda yalnız tek depo dolu olabilir
            }
        }
    }

    private static async Task<(Dictionary<(int, int), decimal>, Dictionary<(int, int, int), decimal>)> BakiyeOkuAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem, BakiyeAnligi a, CancellationToken iptal)
    {
        var depo = new Dictionary<(int, int), decimal>();
        var lot = new Dictionary<(int, int, int), decimal>();
        if (a.Stoklar.Count == 0 || a.Depolar.Count == 0) return (depo, lot);
        var stoklar = a.Stoklar.ToArray(); var depolar = a.Depolar.ToArray();
        await using (var k = baglanti.Komut(
            "select stok_id, depo_id, coalesce(kalan, 0) from public.stok_durum where stok_id = any(@p0) and depo_id = any(@p1)",
            islem, stoklar, depolar))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) depo[(o.GetInt32(0), o.GetInt32(1))] = o.GetDecimal(2);
        await using (var k = baglanti.Komut(
            "select stok_id, depo_id, seri_lot_id, coalesce(kalan, 0) from public.stok_lot_durum where stok_id = any(@p0) and depo_id = any(@p1)",
            islem, stoklar, depolar))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) lot[(o.GetInt32(0), o.GetInt32(1), o.GetInt32(2))] = o.GetDecimal(3);
        return (depo, lot);
    }

    /// <summary>
    /// İşlemden SONRA: bakiyeler yeniden okunur, kötüleşen eksiler sınıflanır. Geriye dönük düşüş (giriş tarafı) her
    /// zaman engel; çıkış tarafı `stokKontrolu` açıksa ayara göre (aktarım / içeri alma ayarı atlar).
    /// </summary>
    private static async Task BakiyeDenetleAsync(NpgsqlConnection baglanti, NpgsqlTransaction islem, BakiyeAnligi once,
        bool stokKontrolu, List<string> uyarilar, CancellationToken iptal)
    {
        if (once.Stoklar.Count == 0 || once.Depolar.Count == 0) return;
        var (depoSonra, lotSonra) = await BakiyeOkuAsync(baglanti, islem, once, iptal);

        // Tekrar kullanılan stok (kiralık / demirbaş) denetlenmez - aynı ekipman defalarca çıkıp girer (141).
        var muaf = new HashSet<int>();
        await using (var k = baglanti.Komut(
            "select id from public.stok where id = any(@p0) and coalesce(yeniden_kullanilir, 0) = 1", islem, once.Stoklar.ToArray()))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) muaf.Add(o.GetInt32(0));

        var dusenler = new List<(int Stok, int Depo, int? Lot, decimal Once, decimal Sonra, bool GeriyeDonuk)>();
        foreach (var ((s, d), sonra) in depoSonra)
        {
            var onceDeger = once.Depo.GetValueOrDefault((s, d));
            if (sonra < 0 && sonra < onceDeger && !muaf.Contains(s))
                dusenler.Add((s, d, null, onceDeger, sonra, once.GirisDepolari.Contains(d)));
        }
        foreach (var ((s, d, l), sonra) in lotSonra)
        {
            var onceDeger = once.Lot.GetValueOrDefault((s, d, l));
            // Depo düzeyinde zaten yakalanan stok × depo için lot satırı ayrıca yazılmaz (aynı nedenin iki mesajı).
            if (sonra < 0 && sonra < onceDeger && !muaf.Contains(s) && !dusenler.Any(x => x.Stok == s && x.Depo == d))
                dusenler.Add((s, d, l, onceDeger, sonra, once.GirisDepolari.Contains(d)));
        }
        if (dusenler.Count == 0) return;

        var geriye = dusenler.Where(x => x.GeriyeDonuk).ToList();
        var cikis = dusenler.Where(x => !x.GeriyeDonuk).ToList();
        var davranis = stokKontrolu && cikis.Count > 0
            ? await AyarDeposu.SayiAsync(baglanti, islem, "stok.negatif_davranis", iptal) : 0;
        if (geriye.Count == 0 && davranis == 0) return;

        var adlar = await AdlarAsync(baglanti, islem, dusenler, iptal);
        string Satir((int Stok, int Depo, int? Lot, decimal Once, decimal Sonra, bool GeriyeDonuk) x) =>
            $"{adlar.Stok.GetValueOrDefault(x.Stok, "#" + x.Stok)} · {adlar.Depo.GetValueOrDefault(x.Depo, "#" + x.Depo)}"
            + (x.Lot is int l ? $" · lot {adlar.Lot.GetValueOrDefault(l, "#" + l)}" : "")
            + $": {Sayi(x.Once)} → {Sayi(x.Sonra)}";

        if (geriye.Count > 0)
            throw GentegreHatasi.IsKurali(
                "Bu işlem stoğu eksiye düşürür - bu girişten çıkış yapılmış: " + string.Join("; ", geriye.Take(5).Select(Satir))
                + (geriye.Count > 5 ? $" (+{geriye.Count - 5})" : "")
                + ". Önce o çıkışları silin ya da düzeltin.");
        if (davranis >= 2)
            throw GentegreHatasi.IsKurali(
                "Stok bakiyesi yetersiz: " + string.Join("; ", cikis.Take(5).Select(Satir))
                + ". Önce giriş yapılmalı (Genel Ayarlar > Stok: negatif stok engelli).");
        foreach (var x in cikis) uyarilar.Add("Stok bakiyesi eksiye düştü: " + Satir(x));

        static string Sayi(decimal d) => d.ToString("0.####", CultureInfo.GetCultureInfo("tr-TR"));
    }

    private static async Task<(Dictionary<int, string> Stok, Dictionary<int, string> Depo, Dictionary<int, string> Lot)> AdlarAsync(
        NpgsqlConnection baglanti, NpgsqlTransaction islem,
        List<(int Stok, int Depo, int? Lot, decimal Once, decimal Sonra, bool GeriyeDonuk)> x, CancellationToken iptal)
    {
        var stok = new Dictionary<int, string>(); var depo = new Dictionary<int, string>(); var lot = new Dictionary<int, string>();
        await using (var k = baglanti.Komut(
            "select id, btrim(coalesce(kod, '') || ' ' || coalesce(ad, '')) from public.stok where id = any(@p0)", islem,
            x.Select(y => y.Stok).Distinct().ToArray()))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) stok[o.GetInt32(0)] = o.GetString(1);
        await using (var k = baglanti.Komut(
            "select id, coalesce(ad, '') from public.depo where id = any(@p0)", islem, x.Select(y => y.Depo).Distinct().ToArray()))
        await using (var o = await k.ExecuteReaderAsync(iptal))
            while (await o.ReadAsync(iptal)) depo[o.GetInt32(0)] = o.GetString(1);
        var lotlar = x.Where(y => y.Lot is not null).Select(y => y.Lot!.Value).Distinct().ToArray();
        if (lotlar.Length > 0)
        {
            await using var k = baglanti.Komut(
                "select id, coalesce(nullif(lot_no, ''), seri_no, '') from public.stok_seri_lot where id = any(@p0)", islem, lotlar);
            await using var o = await k.ExecuteReaderAsync(iptal);
            while (await o.ReadAsync(iptal)) lot[o.GetInt32(0)] = o.GetString(1);
        }
        return (stok, depo, lot);
    }
}
