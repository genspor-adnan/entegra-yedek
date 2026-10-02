using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// ÇAĞRI MERKEZİ (839) — SQL tarafındaki üç kural doğrudan veritabanında
/// sınanır (ekran bunları hesaplamaz, görünüm/fonksiyon hesaplar):
///
///  1. ARAYAN TANIMA: <c>fn_cagri_arayan_bul</c> numarayı rakama indirger ve
///     son 10 haneyle eşler - "+90 532 417 88 21", "05324178821" ve
///     "532 417 88 21" aynı kişiyi bulmalı; tanınmayan numara boş dönmeli.
///  2. SLA: <c>v_cagri.sla_icinde</c> kuyruğun eşiğine göre 1/0; cevapsız çağrı 0.
///  3. KAMPANYA ADIMI: <c>v_cagri_kampanya_kisi.aranacak</c> - bekleyen kişi
///     hemen aranır; mesaj gönderilmiş kişi ancak bekleme süresi dolunca;
///     ulaşılamayan kişi deneme hakkı ve ara süresi varsa yeniden.
///
/// Her test kendi transaction'ında çalışır ve geri alınır.
/// </summary>
public sealed class CagriTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    private static async Task<int> SubeAsync(NpgsqlConnection b, NpgsqlTransaction t)
        => await b.TekDegerAsync<int>("select id from public.sube order by id limit 1", t, [], CancellationToken.None);

    private static async Task<int> TarafAsync(NpgsqlConnection b, NpgsqlTransaction t, string cep, int sube)
        => await b.TekDegerAsync<int>("""
            insert into public.taraf (unvan, grup, durum, hasta, cep_tel, sube_id)
            values ('TEST ÇAĞRI ARAYAN', 101, 1, 1, @p0, @p1) returning id
            """, t, [cep, sube], CancellationToken.None);

    [VtFact]
    public async Task Arayan_numara_bicimden_bagimsiz_bulunur()
    {
        if (!_olgu.Baglandi(nameof(Arayan_numara_bicimden_bagimsiz_bulunur))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = await SubeAsync(b, t);
        var tarafId = await TarafAsync(b, t, "0532 417 88 21", sube);

        foreach (var tel in new[] { "+90 532 417 88 21", "05324178821", "532 417 88 21", "905324178821" })
        {
            var bulunan = await b.ListeAsync("select taraf_id from public.fn_cagri_arayan_bul(@p0)", t, [tel],
                o => o.GetInt32(0), CancellationToken.None);
            Assert.Contains(tarafId, bulunan);
        }
        var bos = await b.ListeAsync("select taraf_id from public.fn_cagri_arayan_bul(@p0)", t, ["0000 000 00 00"],
            o => o.GetInt32(0), CancellationToken.None);
        Assert.DoesNotContain(tarafId, bos);
        var hic = await b.TekDegerAsync<long>("select count(*) from public.fn_cagri_arayan_bul('')", t, [], CancellationToken.None);
        Assert.Equal(0, hic);
    }

    [VtFact]
    public async Task Sla_kuyruk_esigine_gore_hesaplanir()
    {
        if (!_olgu.Baglandi(nameof(Sla_kuyruk_esigine_gore_hesaplanir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = await SubeAsync(b, t);
        var kuyruk = await b.TekDegerAsync<int>("insert into public.cagri_kuyruk (ad, sla_sn, sube_id) values ('TEST SLA', 20, @p0) returning id", t, [sube], CancellationToken.None);
        var hizli = await b.TekDegerAsync<int>("""
            insert into public.cagri (kanal, yon, arayan_no, kuyruk_id, baslama, cevap, bekleme_sn, durum, sube_id)
            values (1, 1, '05000000001', @p0, now() - interval '5 minutes', now() - interval '4 minutes', 12, 5, @p1) returning id
            """, t, [kuyruk, sube], CancellationToken.None);
        var yavas = await b.TekDegerAsync<int>("""
            insert into public.cagri (kanal, yon, arayan_no, kuyruk_id, baslama, cevap, bekleme_sn, durum, sube_id)
            values (1, 1, '05000000002', @p0, now() - interval '5 minutes', now() - interval '4 minutes', 45, 5, @p1) returning id
            """, t, [kuyruk, sube], CancellationToken.None);
        var kacan = await b.TekDegerAsync<int>("""
            insert into public.cagri (kanal, yon, arayan_no, kuyruk_id, baslama, bekleme_sn, durum, sube_id)
            values (1, 1, '05000000003', @p0, now() - interval '5 minutes', 60, 6, @p1) returning id
            """, t, [kuyruk, sube], CancellationToken.None);

        Assert.Equal(1, await b.TekDegerAsync<int>("select sla_icinde from public.v_cagri where id = @p0", t, [hizli], CancellationToken.None));
        Assert.Equal(0, await b.TekDegerAsync<int>("select sla_icinde from public.v_cagri where id = @p0", t, [yavas], CancellationToken.None));
        Assert.Equal(0, await b.TekDegerAsync<int>("select sla_icinde from public.v_cagri where id = @p0", t, [kacan], CancellationToken.None));
        Assert.Equal("Kaçan", await b.TekDegerAsync<string>("select durum_adi from public.v_cagri where id = @p0", t, [kacan], CancellationToken.None));
        // Kuyruk görünümü bugünkü kaçanı sayar.
        Assert.Equal(1L, await b.TekDegerAsync<long>("select kacan_bugun from public.v_cagri_kuyruk where id = @p0", t, [kuyruk], CancellationToken.None));
    }

    [VtFact]
    public async Task Kampanya_kisisi_aranacak_kurali()
    {
        if (!_olgu.Baglandi(nameof(Kampanya_kisisi_aranacak_kurali))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();
        var sube = await SubeAsync(b, t);
        var kampanya = await b.TekDegerAsync<int>("""
            insert into public.cagri_kampanya (ad, tur, kaynak, ikinci_adim_dk, deneme, deneme_ara_dk, durum, sube_id)
            values ('TEST KAMPANYA', 5, 'serbest', 120, 3, 60, 1, @p0) returning id
            """, t, [sube], CancellationToken.None);
        async Task<int> Kisi(short durum, short deneme, string sonDeneme) => await b.TekDegerAsync<int>($"""
            insert into public.cagri_kampanya_kisi (kampanya_id, ad, telefon, durum, deneme, son_deneme, sube_id)
            values (@p0, 'K', '05000000000', @p1, @p2, {sonDeneme}, @p3) returning id
            """, t, [kampanya, durum, deneme, sube], CancellationToken.None);
        async Task<int> Aranacak(int id) => await b.TekDegerAsync<int>("select aranacak from public.v_cagri_kampanya_kisi where id = @p0", t, [id], CancellationToken.None);

        Assert.Equal(1, await Aranacak(await Kisi(1, 0, "null")));                                  // bekliyor → hemen
        Assert.Equal(0, await Aranacak(await Kisi(2, 1, "now() - interval '30 minutes'")));         // mesaj yeni gitti → bekle
        Assert.Equal(1, await Aranacak(await Kisi(2, 1, "now() - interval '3 hours'")));            // 120 dk doldu → ara
        Assert.Equal(1, await Aranacak(await Kisi(3, 1, "now() - interval '2 hours'")));            // ulaşılamadı, hak var, ara süresi doldu
        Assert.Equal(0, await Aranacak(await Kisi(3, 1, "now() - interval '10 minutes'")));         // ara süresi dolmadı
        Assert.Equal(0, await Aranacak(await Kisi(3, 3, "now() - interval '2 days'")));             // deneme hakkı bitti
        Assert.Equal(0, await Aranacak(await Kisi(5, 1, "now() - interval '2 days'")));             // onayladı → bitti
        Assert.Equal(5L, await b.TekDegerAsync<long>("select basarili + bekleyen from public.v_cagri_kampanya where id = @p0", t, [kampanya], CancellationToken.None));
    }
}
