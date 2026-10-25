using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İCMALDEN TASLAK SATINALMA TALEBİ - Kritik Stok İcmali (`/api/stok-icmal/kritik/talep`) ve Üretim İcmali
/// (`/api/uretim-icmal/talep`) aynı yazıcıyı kullanır (önceden iki kopyaydı). Talep TASLAK açılır (durum 0):
/// onaya insan gönderir. Depo kullanıcının şubelerinde olmalı; aynı şubede açık talebi (durum 0/1/2/4) olan
/// kalem ATLANIR (aynı malı iki kez istememek). Satır fiyatı son alış fiyatı (iade olmayan kesin alış
/// belgesi); başlık + her satır islem_log'a yazılır.
/// </summary>
internal static class TaslakTalep
{
    /// <summary>islem_log.tablo_id — satinalma_talep / satır (KartKatalogu.Satinalma ile aynı).</summary>
    internal const int LogTalep = 1241;
    internal const int LogTalepSatir = 1242;

    /// <summary>Talep satırı. <paramref name="Not"/> satır açıklamasının başına; <paramref name="LogBilgi"/>
    ///   satır logunun gövdesi (boşsa stok + miktar).</summary>
    internal sealed record Kalem(int StokId, decimal Miktar, string Not = "", object? LogBilgi = null);

    /// <summary>Talebin kaynağı ve metinleri. Hesap notu: "[açıklama · ]{Icmal}'nden N kalem{NotEki} ({MiktarNotu})."</summary>
    internal sealed record Tanim(short Kaynak, short KaynakTur, long? KaynakId, int? DepartmanId,
        string GerekceOnEki, string Icmal, string MiktarNotu, string NotEki, string LogKaynak, object? LogEk = null);

    internal sealed record Sonuc(long Id, string TalepNo, int Kalem, List<int> Atlananlar);

    /// <summary>Son alış: tedarikçi, tarih, birim fiyat (iade olmayan, kesin alış belgesi).</summary>
    internal static async Task<Dictionary<int, (string Tedarikci, DateTime Tarih, decimal Fiyat)>> SonAlisAsync(
        NpgsqlConnection b, NpgsqlTransaction? tx, IEnumerable<int> idler, CancellationToken iptal)
    {
        var dizi = idler.Distinct().ToArray();
        if (dizi.Length == 0) return new();
        var l = await b.ListeAsync("""
            select x.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(160), ''), sa.belge_tarihi, sa.fiyat
              from unnest(@p0::int[]) as x(id)
              join lateral (
                    select b.taraf_id, b.belge_tarihi, round(bs.tutar / bs.miktar, 4) as fiyat
                      from public.belge_satir bs join public.belge b on b.id = bs.belge_id
                     where bs.stok_id = x.id and bs.miktar > 0 and bs.tutar > 0 and b.durum = 0
                       and b.tur in (10, 11, 12, 109) and coalesce(b.tipi, 0) <> 2
                     order by b.belge_tarihi desc, b.id desc limit 1) sa on true
              left join public.taraf t on t.id = sa.taraf_id
            """, tx, [dizi], o => (id: o.GetInt32(0), ted: o.GetString(1), tarih: o.GetDateTime(2), fiyat: o.GetDecimal(3)), iptal);
        return l.ToDictionary(x => x.id, x => (x.ted, x.tarih, x.fiyat));
    }

    /// <summary>İstekteki satırları süzer (stok &gt; 0, miktar &gt; 0, aynı stok bir kez - sonuncusu) ve sınırı denetler.</summary>
    internal static List<T> Suz<T>(IEnumerable<T>? satirlar, Func<T, int> stok, Func<T, decimal> miktar)
    {
        var l = (satirlar ?? []).Where(x => stok(x) > 0 && miktar(x) > 0).GroupBy(stok).Select(g => g.Last()).ToList();
        if (l.Count == 0) throw GentegreHatasi.Dogrulama("Talep edilecek kalem seçilmedi.");
        if (l.Count > 500) throw GentegreHatasi.Dogrulama("Tek talepte en çok 500 kalem.");
        return l;
    }

    /// <summary>Depo kullanıcının şubelerinde mi; talebin şubesi (depo şubesi, yoksa çalışılan şube).</summary>
    internal static async Task<(int SubeId, string DepoAd)> DepoAsync(NpgsqlConnection b, NpgsqlTransaction tx,
        IstekBaglami baglam, int depoId, CancellationToken iptal)
    {
        var depo = await b.TekAsync("select d.id, coalesce(d.ad, ''), d.sube_id from public.depo d where d.id = @p0",
            tx, [depoId], o => new { ad = o.GetString(1), sube = o.IsDBNull(2) ? (int?)null : o.GetInt32(2) }, iptal);
        if (depo is null || depo.sube is { } ds && !baglam.Subeler.Any(s => s.Id == ds))
            throw GentegreHatasi.Bulunamadi("Depo bulunamadı.");
        var subeId = depo.sube ?? baglam.SubeId ?? throw GentegreHatasi.IsKurali("Çalışılan şube seçilmeli.");
        return (subeId, depo.ad);
    }

    /// <summary>Taslak talebi yazar (çağıran işlemi commit eder). Hepsi açık talepliyse 422.</summary>
    internal static async Task<Sonuc> AcAsync(NpgsqlConnection b, NpgsqlTransaction tx, LogDeposu log, IstekBaglami baglam,
        int subeId, string depoAd, int depoId, IReadOnlyList<Kalem> kalemler, Tanim t, string? aciklama, CancellationToken iptal)
    {
        var acik = (await b.ListeAsync("""
            select distinct ts.stok_id from public.satinalma_talep_satir ts join public.satinalma_talep t on t.id = ts.talep_id
             where t.durum in (0, 1, 2, 4) and t.sube_id = @p0 and ts.stok_id = any(@p1::int[])
            """, tx, [subeId, kalemler.Select(x => x.StokId).ToArray()], o => o.GetInt32(0), iptal)).ToHashSet();
        var yazilacak = kalemler.Where(x => !acik.Contains(x.StokId)).ToList();
        if (yazilacak.Count == 0)
            throw GentegreHatasi.IsKurali("Seçilen kalemlerin hepsinin açık satınalma talebi var.");

        var bilgi = (await b.ListeAsync("""
            select s.id, coalesce(nullif(s.ad, ''), s.kod, ''),
                   coalesce((select kd.ad from public.kod_deger kd join public.kod_liste kl on kl.id = kd.liste_id
                              where kl.kod = 'stok.ana_birim' and kd.deger = s.ana_birim and kd.dil = 0), '')
              from public.stok s where s.id = any(@p0::int[])
            """, tx, [yazilacak.Select(x => x.StokId).ToArray()], o => (id: o.GetInt32(0), ad: o.GetString(1), birim: o.GetString(2)), iptal))
            .ToDictionary(x => x.id);
        var sonAlis = await SonAlisAsync(b, tx, yazilacak.Select(x => x.StokId), iptal);
        decimal Fiyat(int id) => sonAlis.TryGetValue(id, out var sa) ? sa.Fiyat : 0;
        var tahmini = Math.Round(yazilacak.Sum(x => x.Miktar * Fiyat(x.StokId)), 2);
        var ek = (aciklama ?? "").Trim();

        var talepId = await b.TekDegerAsync<long>("""
            insert into public.satinalma_talep
                (sube_id, tarih, kaynak, kaynak_tur, kaynak_id, isteyen_id, departman_id, oncelik, gerekce, hesap_notu,
                 tahmini_tutar, durum, ekleyen)
            values (@p0, current_date, @p1, @p2, @p3, null, @p4, 2, @p5, @p6, @p7, 0, @p8)
            returning id
            """, tx,
            [subeId, t.Kaynak, t.KaynakTur, t.KaynakId, t.DepartmanId, t.GerekceOnEki + " · " + depoAd,
             (ek.Length > 0 ? ek + " · " : "") + t.Icmal + "'nden " + yazilacak.Count + " kalem" + t.NotEki + " (" + t.MiktarNotu + ").",
             tahmini, baglam.KullaniciId], iptal);

        short sira = 0;
        foreach (var x in yazilacak)
        {
            var bi = bilgi.TryGetValue(x.StokId, out var z) ? z : (id: x.StokId, ad: "", birim: "");
            var not = string.Join(" · ", new[] { x.Not, Fiyat(x.StokId) == 0 ? "son alış fiyatı yok" : "" }.Where(s => s.Length > 0));
            var satirId = await b.TekDegerAsync<long>("""
                insert into public.satinalma_talep_satir (talep_id, sira, stok_id, ad, miktar, birim, son_alis_fiyat, tahmini_tutar, aciklama, ekleyen)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9) returning id
                """, tx,
                [talepId, ++sira, x.StokId, bi.ad, x.Miktar, bi.birim, Fiyat(x.StokId),
                 Math.Round(x.Miktar * Fiyat(x.StokId), 2), not, baglam.KullaniciId], iptal);
            await log.YazAsync(b, tx, LogIslemi.Ekle, LogTalepSatir, satirId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                x.LogBilgi ?? new { x.StokId, x.Miktar }, LogTalep, talepId, stokId: x.StokId, iptal: iptal);
        }
        await log.YazAsync(b, tx, LogIslemi.Ekle, LogTalep, talepId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
            new { kaynak = t.LogKaynak, DepoId = depoId, kalem = yazilacak.Count, tahmini, ek = t.LogEk }, iptal: iptal);

        var talepNo = await b.TekDegerAsync<string>("select coalesce(talep_no, '') from public.satinalma_talep where id = @p0",
            tx, [talepId], iptal);
        return new Sonuc(talepId, talepNo ?? "", yazilacak.Count,
            kalemler.Where(x => acik.Contains(x.StokId)).Select(x => x.StokId).ToList());
    }
}
