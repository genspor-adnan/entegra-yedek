using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// STERİLİZASYON (868) — SQL tarafındaki üç kural doğrudan veritabanında sınanır
/// (ekran bunları hesaplamaz, fonksiyon / görünüm hesaplar):
///
///  1. PAKET KULLANILABİLİRLİK: <c>fn_steril_paket_kullanilabilir</c> - steril ve SKT içinde 1;
///     karantina 2 (implant kitinde 0); kullanılmış / iptal / süresi dolmuş / bloke 0.
///  2. BOWIE-DICK BUGÜN: <c>fn_steril_bd_bugun</c> - cihazda bugün geçmiş BD varsa 1.
///  3. GERİ ÇAĞIRMA KAPSAMI: <c>fn_steril_geri_cagirma_dongular</c> - son negatif biyolojikten
///     (hariç) tetik döngüye (dahil) kadar aynı cihazın sonuçlanmış döngüleri.
///
/// Her test kendi transaction'ında çalışır ve geri alınır.
/// </summary>
public sealed class SterilTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<int> CihazAsync(NpgsqlConnection b, NpgsqlTransaction t)
        => await b.TekDegerAsync<int>("insert into public.steril_cihaz (ad, tur, sinif, sube_id) values ('TEST OTOKLAV', 1, 1, 1) returning id", t, [], CancellationToken.None);

    private static async Task<int> DonguAsync(NpgsqlConnection b, NpgsqlTransaction t, int cihaz, int sayac, string baslama, short durum)
        => await b.TekDegerAsync<int>($"insert into public.steril_dongu (cihaz_id, sayac_no, baslama, bitis, durum, sube_id) values (@p0, @p1, {baslama}, {baslama} + interval '30 minutes', @p2, 1) returning id",
            t, [cihaz, sayac, durum], CancellationToken.None);

    private static async Task<int> BirimAsync(NpgsqlConnection b, NpgsqlTransaction t, string barkod, int? setId)
        => await b.TekDegerAsync<int>("insert into public.steril_birim (barkod, tur, set_id, ad, durum, sube_id) values (@p0, 1, @p1, 'TEST SET', 7, 1) returning id", t, [barkod, setId], CancellationToken.None);

    private static async Task<int> PaketAsync(NpgsqlConnection b, NpgsqlTransaction t, string barkod, int birim, int dongu, short durum, string skt)
        => await b.TekDegerAsync<int>($"insert into public.steril_paket (barkod, birim_id, dongu_id, durum, skt, sube_id) values (@p0, @p1, @p2, @p3, {skt}, 1) returning id", t, [barkod, birim, dongu, durum], CancellationToken.None);

    private static async Task IndikatorAsync(NpgsqlConnection b, NpgsqlTransaction t, int dongu, short tur, short sonuc)
        => await b.CalistirAsync("insert into public.steril_dongu_indikator (dongu_id, tur, sonuc, okuma_zamani) values (@p0, @p1, @p2, now())", t, [dongu, tur, sonuc], CancellationToken.None);

    [Fact]
    public async Task Paket_kullanilabilirlik_kurali()
    {
        if (!_olgu.Baglandi(nameof(Paket_kullanilabilirlik_kurali))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var cihaz = await CihazAsync(b, t);
        var dongu = await DonguAsync(b, t, cihaz, 1, "now() - interval '1 day'", 4);
        var implantSet = await b.TekDegerAsync<int>("insert into public.steril_set (kod, ad, implant) values ('T-IMP', 'TEST İMPLANT', 1) returning id", t, [], CancellationToken.None);
        var b1 = await BirimAsync(b, t, "T-01", null); var b2 = await BirimAsync(b, t, "T-02", implantSet);
        async Task<short> K(int id) => await b.TekDegerAsync<short>("select public.fn_steril_paket_kullanilabilir(@p0)", t, [id], CancellationToken.None);

        Assert.Equal(1, await K(await PaketAsync(b, t, "TP-1", b1, dongu, 3, "current_date + 30")));   // steril, SKT içinde
        Assert.Equal(0, await K(await PaketAsync(b, t, "TP-2", b1, dongu, 3, "current_date - 1")));    // steril ama süresi dolmuş
        Assert.Equal(1, await K(await PaketAsync(b, t, "TP-3", b1, dongu, 3, "null")));                // olay bazlı (SKT yok)
        Assert.Equal(2, await K(await PaketAsync(b, t, "TP-4", b1, dongu, 2, "null")));                // karantina → uyarılı
        Assert.Equal(0, await K(await PaketAsync(b, t, "TP-5", b2, dongu, 2, "null")));                // karantina + implant kiti → yasak
        Assert.Equal(0, await K(await PaketAsync(b, t, "TP-6", b1, dongu, 4, "current_date + 30")));   // kullanılmış
        Assert.Equal(0, await K(await PaketAsync(b, t, "TP-7", b1, dongu, 7, "current_date + 30")));   // bloke (geri çağırma)
        Assert.Equal(0, await K(await PaketAsync(b, t, "TP-8", b1, dongu, 1, "null")));                // henüz sterilde
    }

    [Fact]
    public async Task Bowie_dick_bugun_kurali()
    {
        if (!_olgu.Baglandi(nameof(Bowie_dick_bugun_kurali))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var cihaz = await CihazAsync(b, t);
        async Task<short> Bd() => await b.TekDegerAsync<short>("select public.fn_steril_bd_bugun(@p0)", t, [cihaz], CancellationToken.None);
        Assert.Equal(0, await Bd());
        var dun = await DonguAsync(b, t, cihaz, 1, "now() - interval '1 day'", 8);
        await IndikatorAsync(b, t, dun, 1, 1);
        Assert.Equal(0, await Bd());                                     // dünkü test bugünü kurtarmaz
        var bugun = await DonguAsync(b, t, cihaz, 2, "now() - interval '1 hour'", 8);
        await IndikatorAsync(b, t, bugun, 1, 2);
        Assert.Equal(0, await Bd());                                     // bugün KALDI
        await IndikatorAsync(b, t, bugun, 1, 1);
        Assert.Equal(1, await Bd());                                     // bugün geçti
    }

    [Fact]
    public async Task Geri_cagirma_kapsami_son_negatif_biyolojikten_sonrasi()
    {
        if (!_olgu.Baglandi(nameof(Geri_cagirma_kapsami_son_negatif_biyolojikten_sonrasi))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var cihaz = await CihazAsync(b, t); var digerCihaz = await CihazAsync(b, t);
        var d1 = await DonguAsync(b, t, cihaz, 1, "now() - interval '10 days'", 4);   // eski, negatif biyolojik öncesi
        var d2 = await DonguAsync(b, t, cihaz, 2, "now() - interval '8 days'", 4);    // son NEGATİF biyolojik
        await IndikatorAsync(b, t, d2, 6, 1);
        var d3 = await DonguAsync(b, t, cihaz, 3, "now() - interval '6 days'", 4);    // kapsamda
        var d4 = await DonguAsync(b, t, cihaz, 4, "now() - interval '5 days'", 7);    // iptal → kapsam dışı
        var d5 = await DonguAsync(b, t, cihaz, 5, "now() - interval '3 days'", 5);    // karantina → kapsamda
        var d6 = await DonguAsync(b, t, cihaz, 6, "now() - interval '1 day'", 4);     // tetik (pozitif)
        await IndikatorAsync(b, t, d6, 6, 2);
        var d7 = await DonguAsync(b, t, cihaz, 7, "now() - interval '1 hour'", 4);    // tetikten sonra → kapsam dışı
        var dx = await DonguAsync(b, t, digerCihaz, 1, "now() - interval '2 days'", 4); // başka cihaz
        var kapsam = await b.ListeAsync("select dongu_id from public.fn_steril_geri_cagirma_dongular(@p0, @p1)", t, [cihaz, d6], o => o.GetInt32(0), CancellationToken.None);
        Assert.Equal(new[] { d3, d5, d6 }.OrderBy(x => x), kapsam.OrderBy(x => x));
        Assert.DoesNotContain(d1, kapsam); Assert.DoesNotContain(d2, kapsam); Assert.DoesNotContain(d4, kapsam); Assert.DoesNotContain(d7, kapsam); Assert.DoesNotContain(dx, kapsam);
        // Hiç negatif biyolojik yoksa cihazın tetik dahil tüm sonuçlanmış döngüleri.
        var hepsi = await b.ListeAsync("select dongu_id from public.fn_steril_geri_cagirma_dongular(@p0, @p1)", t, [digerCihaz, dx], o => o.GetInt32(0), CancellationToken.None);
        Assert.Equal([dx], hepsi);
    }
}
