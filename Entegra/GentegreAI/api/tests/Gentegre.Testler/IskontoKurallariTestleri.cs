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
        // EN ESKI satir (en yeni degil): baska testler kendi basvuru satirini
        //   acip siliyor, "en yeni satir" iki kosu arasinda yok olabiliyordu -
        //   update sifir satira dokunuyor, test "iskonto yazilmadi" diye
        //   kiriliyordu (gercek bir hata degil, yaris). Eski satirlar duragan.
        var satirlar = await b.ListeAsync(
            "select s.id, s.belge_id from public.belge_satir s "
            + "  join public.belge bl on bl.id = s.belge_id "
            + " where bl.tur = 19 and bl.tipi = 30 order by s.id limit 1",
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

/// <summary>
/// ZİNCİRDE TEK İMZA (784) — kullanıcı: *"1'i yaz"* ("aynı kişi ardışık
/// basamakları imzalayamaz").
///
/// 783 kendi TALEBİNİ onaylamayı kapattı; açık kalan taraf başkasının
/// talebinde üç imzayı tek elde toplamaktı: basamaklar role düşüyor (754:
/// birim · mali · üst) ve üç rolü birden taşıyan kişi - "İskonto
/// Onaylayanlar" rolü tam da öyleydi - zinciri tek başına yürütebiliyordu.
/// İki imza aynı elden çıkınca ikincisi denetim değil tekrardır.
///
/// Kural OMURGANIN TAMAMINDA: satınalma · izin · avans · iskonto · doküman.
/// </summary>
public sealed class OnayTekImzaTestleri(VeritabaniOlgusu olgu)
    : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu = olgu;

    /// <summary>İki basamaklı bir deneme zinciri açar.</summary>
    private static async Task<long> ZincirAsync(NpgsqlConnection b, NpgsqlTransaction t)
    {
        var onayId = await b.TekDegerAsync<long>(
            "insert into public.onay (akis_id, kaynak_tur, kaynak_id, durum, ekleyen, sube_id) "
            + "select k.id, 1256, 999999, 0, 1, 0 from public.onay_akis k "
            + " where k.kod = 'belge.iskonto' returning id",
            t, [], CancellationToken.None);
        await b.CalistirAsync(
            "insert into public.onay_adim (onay_id, sira, ad, sahip_turu, rol, durum) "
            + "values (@p0, 1, 'Birim', 1, 1, 0), (@p0, 2, 'Mali', 1, 4, 0)",
            t, [onayId], CancellationToken.None);
        return onayId;
    }

    private static Task<int> ImzalaAsync(NpgsqlConnection b, NpgsqlTransaction t,
        long onayId, short sira, int kullanici, short durum = 1)
        => b.CalistirAsync(
            "update public.onay_adim set durum = @p3, karar_veren_id = @p2 "
            + " where onay_id = @p0 and sira = @p1",
            t, [onayId, sira, kullanici, durum], CancellationToken.None);

    [Fact]
    public async Task Ayni_kisi_IKINCI_basamagi_imzalayamaz()
    {
        if (!_olgu.Baglandi(nameof(Ayni_kisi_IKINCI_basamagi_imzalayamaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var onayId = await ZincirAsync(b, t);
        await ImzalaAsync(b, t, onayId, 1, 555);

        var h = await Assert.ThrowsAsync<PostgresException>(
            () => ImzalaAsync(b, t, onayId, 2, 555));
        Assert.Equal("GK422", h.SqlState);
        Assert.Contains("daha önce imza attınız", h.MessageText);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task BASKASI_ikinci_basamagi_imzalar()
    {
        if (!_olgu.Baglandi(nameof(BASKASI_ikinci_basamagi_imzalar))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        var onayId = await ZincirAsync(b, t);
        await ImzalaAsync(b, t, onayId, 1, 555);
        await ImzalaAsync(b, t, onayId, 2, 777);

        var imzalar = await b.ListeAsync(
            "select sira, karar_veren_id from public.onay_adim where onay_id = @p0 "
            + " and durum = 1 order by sira", t, [onayId],
            o => (Sira: o.GetInt16(0), Kisi: o.GetInt32(1)), CancellationToken.None);
        Assert.Equal(2, imzalar.Count);
        Assert.NotEqual(imzalar[0].Kisi, imzalar[1].Kisi);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task RET_de_imzadir_ayni_kisi_tekrar_karar_veremez()
    {
        if (!_olgu.Baglandi(nameof(RET_de_imzadir_ayni_kisi_tekrar_karar_veremez))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // Ret de bir karardır: reddeden kişi ikinci basamağı onaylayarak
        //   kendi kararını dolanamaz.
        var onayId = await ZincirAsync(b, t);
        await ImzalaAsync(b, t, onayId, 1, 555, durum: 2);

        var h = await Assert.ThrowsAsync<PostgresException>(
            () => ImzalaAsync(b, t, onayId, 2, 555));
        Assert.Equal("GK422", h.SqlState);

        await t.RollbackAsync();
    }

    [Fact]
    public async Task BILGI_ISTEME_imza_sayilmaz()
    {
        if (!_olgu.Baglandi(nameof(BILGI_ISTEME_imza_sayilmaz))) return;
        await using var b = await _olgu.Gerekli().AcAsync();
        await using var t = await b.BeginTransactionAsync();

        // "Bilgi istendi" (3) soru sorar, karar vermez: aynı kişi soruyu
        //   sorup sonra kendi basamağını imzalayabilmeli.
        var onayId = await ZincirAsync(b, t);
        await ImzalaAsync(b, t, onayId, 1, 555, durum: 3);
        await ImzalaAsync(b, t, onayId, 1, 555);

        var durum = await b.TekDegerAsync<short>(
            "select durum from public.onay_adim where onay_id = @p0 and sira = 1",
            t, [onayId], CancellationToken.None);
        Assert.Equal((short)1, durum);

        await t.RollbackAsync();
    }
}
