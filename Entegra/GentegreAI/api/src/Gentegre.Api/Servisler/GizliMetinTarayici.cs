using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// DÜZ METİN SIRLARI ŞİFRELER (kod inceleme 30.10.2026 K28): açılışta ve saatte bir, önek taşımayan
/// (eski / Delphi aktarımından gelen / elle SQL ile girilmiş) entegrasyon şifrelerini ve santral anahtarlarını
/// <see cref="GizliMetin"/> ile şifreler. Okuyucular düz metni de kabul ettiği için bu iş gecikse de hiçbir
/// gönderim durmaz; yalnız düz metnin DB'de kalma süresi kısalır.
///
/// Güncelleme değer koşulludur (`and sifre = @eski`): arada kullanıcı yeni şifre girdiyse ezilmez.
/// Aktarım salt-okur tetiği (fn_aktarim_salt_okunur) bu işlemde açılır - satırın kendisi değişmiyor,
/// yalnız saklama biçimi.
/// </summary>
public sealed class GizliMetinTarayici(IServiceProvider servisler, ILogger<GizliMetinTarayici> gunluk) : BackgroundService
{
    private static readonly (string Tablo, string Id, string Kolon)[] Kolonlar =
    [
        ("public.entegrasyon_hesap", "id", "sifre"),
        ("public.cagri_santral", "sube_id", "gizli"),
        ("public.cagri_santral", "sube_id", "whatsapp_token"),
    ];

    protected override async Task ExecuteAsync(CancellationToken iptal)
    {
        while (!iptal.IsCancellationRequested)
        {
            try { await TaraAsync(servisler, gunluk, iptal); }
            catch (OperationCanceledException) when (iptal.IsCancellationRequested) { break; }
            catch (Exception h) { gunluk.LogError(h, "Gizli metin taraması başarısız."); }
            await Task.Delay(TimeSpan.FromHours(1), iptal).ContinueWith(_ => { }, CancellationToken.None);
        }
    }

    /// <summary>Tek tur; şifrelenen satır sayısını döner (test ve elle çağrı için açık).</summary>
    public static async Task<int> TaraAsync(IServiceProvider servisler, ILogger gunluk, CancellationToken iptal)
    {
        await using var kapsam = servisler.CreateAsyncScope();
        var veri = kapsam.ServiceProvider.GetRequiredService<VeriKaynagi>();
        await using var b = await veri.AcAsync(iptal);
        var toplam = 0;
        foreach (var (tablo, id, kolon) in Kolonlar)
        {
            if (await b.TekDegerAsync<string>("select to_regclass(@p0)::text", null, [tablo], iptal) is null) continue;
            var satirlar = await b.ListeAsync($"""
                select {id}, {kolon} from {tablo}
                 where coalesce({kolon}, '') <> '' and {kolon} not like 'enc1:%'
                """, null, null, o => (Id: o.GetInt32(0), Deger: o.GetString(1)), iptal);
            if (satirlar.Count == 0) continue;

            await using var islem = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("select set_config('gentegre.aktarim', '1', true)", islem, null, iptal);
            foreach (var s in satirlar)
                toplam += await b.CalistirAsync(
                    $"update {tablo} set {kolon} = @p1 where {id} = @p0 and {kolon} = @p2",
                    islem, [s.Id, GizliMetin.Sifrele(s.Deger), s.Deger], iptal);
            await islem.CommitAsync(iptal);
        }
        // JSON İÇİ SIRLAR: entegrasyon ayarlar.client_secret (ASMED / sigorta OAuth).
        var jsonlar = await b.ListeAsync("""
            select id, ayarlar ->> 'client_secret' from public.entegrasyon_hesap
             where coalesce(ayarlar ->> 'client_secret', '') <> '' and ayarlar ->> 'client_secret' not like 'enc1:%'
            """, null, null, o => (Id: o.GetInt32(0), Deger: o.GetString(1)), iptal);
        foreach (var s in jsonlar)
            toplam += await b.CalistirAsync("""
                update public.entegrasyon_hesap set ayarlar = jsonb_set(ayarlar, '{client_secret}', to_jsonb(@p1::text))
                 where id = @p0 and ayarlar ->> 'client_secret' = @p2
                """, null, [s.Id, GizliMetin.Sifrele(s.Deger), s.Deger], iptal);
        if (toplam > 0) gunluk.LogInformation("Gizli metin: {Adet} düz metin sır şifrelendi.", toplam);
        return toplam;
    }
}
