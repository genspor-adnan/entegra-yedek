using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// İSKONTONUN İKİ KURALI (783) — tasarım konuşmasından çıktı:
///
///  1. **Kendi talebini onaylayamaz.** İskonto talebi bir imzadır ("ben
///     istedim, şu kişi uygun buldu"); isteyenle onaylayan aynı kişi olunca
///     kayıt belge olmaktan çıkar.
///  2. **Eşik üstü iskonto onaysız yazılamaz.** 661'den beri
///     `basvuru.iskonto` yetkisinin değeri bir TAVANDI ve tavanı yeten
///     kullanıcı talebi hiç açmadan indirimi uyguluyordu: tavanı %100 olan
///     rol ("İskonto Onaylayanlar", 663) sınırsız indirimi tek başına,
///     kayıtsız yapabiliyordu. Artık kurumun eşiği üstündeki her iskonto
///     onaylı talepten gelmek zorunda (`iskonto_kilit = 1`).
///
/// İkisi de VERİTABANINDA: ekran kuralı yalnız kullanıcıyı boşa uğraştırmamak
/// için biliyor; API'den ya da başka bir yoldan gelen yazım da aynı duvara
/// çarpmalı.
/// </summary>
public sealed class IskontoKurallariTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>Gerçek bir başvuru satırı (tur 19 · tipi 30).</summary>
    private static async Task<(int BelgeId, int SatirId)> BasvuruSatiriAsync(
        NpgsqlConnection b, NpgsqlTransaction t)
    {
        var satirlar = await b.ListeAsync(
            "select s.id, s.belge_id from public.belge_satir s "
            + "  join public.belge bl on bl.id = s.belge_id "
            + " where bl.tur = 19 and bl.tipi = 30 order by s.id desc limit 1",
            t, [], o => (Id: o.GetInt32(0), BelgeId: o.GetInt32(1)), CancellationToken.None);
        Assert.Single(satirlar);
        return (satirlar[0].BelgeId, satirlar[0].Id);
    }

    private static Task<decimal> EsikAsync(NpgsqlConnection b, NpgsqlTransaction t)
        => b.TekDegerAsync<decimal>(
            "select coalesce(nullif(deger, '')::numeric, 0) from public.referans "
            + " where anahtar = 'basvuru.iskonto_onay_esik'", t, [], CancellationToken.None);

    [Fact]
    public async Task Esik_ustu_iskonto_ONAYSIZ_yazilamaz()
    {
        if (!_olgu.Baglandi(nameof(Esik_ustu_iskonto_ONAYSIZ_yazilamaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var esik = await EsikAsync(b, t);
        Assert.True(esik > 0, "Eşik ayarı (basvuru.iskonto_onay_esik) tanımlı olmalı.");
        var (_, satirId) = await BasvuruSatiriAsync(b, t);

        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "update public.belge_satir set iskonto = @p1 where id = @p0",
            t, [satirId, esik + 5m], CancellationToken.None));
        Assert.Equal("GK422", h.SqlState);          // API mesajı aynen gösterir
        Assert.Contains("onay ister", h.MessageText);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Esik_altinda_iskonto_serbest()
    {
        if (!_olgu.Baglandi(nameof(Esik_altinda_iskonto_serbest))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kural bir TAVAN değil bir EŞİKTİR: günlük küçük indirim (kuruş
        //   yuvarlama, personel indirimi) onay kuyruğuna düşmemeli.
        var esik = await EsikAsync(b, t);
        var (_, satirId) = await BasvuruSatiriAsync(b, t);

        await b.CalistirAsync("update public.belge_satir set iskonto = @p1 where id = @p0",
            t, [satirId, Math.Max(esik - 1m, 0.5m)], CancellationToken.None);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task ONAYDAN_gelen_satir_esikten_muaf()
    {
        if (!_olgu.Baglandi(nameof(ONAYDAN_gelen_satir_esikten_muaf))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // `fn_iskonto_talep_karar` onaylanan satırı kilitle yazar; kilit
        //   "bu satır zincirden geçti" demektir - eşik ona uygulanmaz, yoksa
        //   onaylanan iskonto kaydedilemezdi.
        var esik = await EsikAsync(b, t);
        var (_, satirId) = await BasvuruSatiriAsync(b, t);

        await b.CalistirAsync(
            "update public.belge_satir set iskonto = @p1, iskonto_kilit = 1 where id = @p0",
            t, [satirId, esik + 20m], CancellationToken.None);

        var yazilan = await b.TekDegerAsync<decimal>(
            "select iskonto from public.belge_satir where id = @p0",
            t, [satirId], CancellationToken.None);
        Assert.Equal(esik + 20m, yazilan);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task ERP_belgesinde_kural_islemez()
    {
        if (!_olgu.Baglandi(nameof(ERP_belgesinde_kural_islemez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // ERP satış/alış belgesinde iskonto ticari pazarlıktır; onay zinciri
        //   yoktur, eşik de yoktur.
        var satirlar = await b.ListeAsync(
            "select s.id from public.belge_satir s join public.belge bl on bl.id = s.belge_id "
            + " where not (bl.tur = 19 and bl.tipi = 30) order by s.id desc limit 1",
            t, [], o => o.GetInt32(0), CancellationToken.None);
        if (satirlar.Count == 0) return;            // ERP satırı yoksa denenecek şey yok

        await b.CalistirAsync("update public.belge_satir set iskonto = 40 where id = @p0",
            t, [satirlar[0]], CancellationToken.None);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Kendi_talebini_onaylayamaz()
    {
        if (!_olgu.Baglandi(nameof(Kendi_talebini_onaylayamaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (belgeId, _) = await BasvuruSatiriAsync(b, t);
        var talepId = await b.TekDegerAsync<int>(
            "insert into public.iskonto_talep (belge_id, oran, gerekce, durum, isteyen_id, sube_id) "
            + "values (@p0, 20, 'test', 0, 4242, 0) returning id",
            t, [belgeId], CancellationToken.None);

        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "select public.fn_iskonto_talep_karar(@p0, 1::smallint, 20, 'kendi', 4242)",
            t, [talepId], CancellationToken.None));
        Assert.Equal("GK422", h.SqlState);
        Assert.Contains("Kendi iskonto talebinizi", h.MessageText);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task Kendi_talebini_REDDEDEMEZ_de()
    {
        if (!_olgu.Baglandi(nameof(Kendi_talebini_REDDEDEMEZ_de))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Kendi talebini reddetmek zararsız görünür ama zinciri kendi
        //   üstünden kaldırmanın yolu olurdu (talebi kapatıp yeniden,
        //   daha düşük oranla uygulamak).
        var (belgeId, _) = await BasvuruSatiriAsync(b, t);
        var talepId = await b.TekDegerAsync<int>(
            "insert into public.iskonto_talep (belge_id, oran, gerekce, durum, isteyen_id, sube_id) "
            + "values (@p0, 20, 'test', 0, 4242, 0) returning id",
            t, [belgeId], CancellationToken.None);

        var h = await Assert.ThrowsAsync<PostgresException>(() => b.CalistirAsync(
            "select public.fn_iskonto_talep_karar(@p0, 2::smallint, 0, 'kendi ret', 4242)",
            t, [talepId], CancellationToken.None));
        Assert.Equal("GK422", h.SqlState);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task BASKASI_onaylayabilir()
    {
        if (!_olgu.Baglandi(nameof(BASKASI_onaylayabilir))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var (belgeId, satirId) = await BasvuruSatiriAsync(b, t);
        var talepId = await b.TekDegerAsync<int>(
            "insert into public.iskonto_talep (belge_id, oran, gerekce, durum, isteyen_id, sube_id) "
            + "values (@p0, 20, 'test', 0, 4242, 0) returning id",
            t, [belgeId], CancellationToken.None);
        await b.CalistirAsync(
            "insert into public.iskonto_talep_satir (talep_id, belge_satir_id, oran) "
            + "values (@p0, @p1, 20)", t, [talepId, satirId], CancellationToken.None);

        await b.CalistirAsync(
            "select public.fn_iskonto_talep_karar(@p0, 1::smallint, 20, 'uygun', 777)",
            t, [talepId], CancellationToken.None);

        var satir = await b.ListeAsync(
            "select iskonto, iskonto_kilit from public.belge_satir where id = @p0",
            t, [satirId], OkuyucuGenisletmeleri.Sozluk, CancellationToken.None);
        Assert.Equal(20m, Convert.ToDecimal(satir[0]["iskonto"]));
        // Kilit hem "onaylandı" hem "eşikten muaf" demektir.
        Assert.Equal(1, Convert.ToInt32(satir[0]["iskonto_kilit"]));

        await t.RollbackAsync();
    }
}
