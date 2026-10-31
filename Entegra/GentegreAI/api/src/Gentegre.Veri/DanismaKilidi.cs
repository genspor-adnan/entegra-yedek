using Npgsql;

namespace Gentegre.Veri;

/// <summary>
/// DANIŞMA KİLİDİ (kod inceleme 30.10.2026 K37): aynı kuyruğu zamanlı iş ile ekrandaki "Bekleyenleri gönder"
/// aynı anda işliyordu - satırlar kilitsiz seçildiği için aynı Medula çağrısı / e-Nabız mesajı / cihaz mesajı iki
/// kez gidiyordu. Kuyruk işleyicisi başlarken oturum düzeyinde <c>pg_try_advisory_lock</c> alır; alamazsa
/// "başkası işliyor" diye döner. Kilit bağlantıya bağlıdır: bu nesne bağlantıdan ÖNCE dispose edilmeli
/// (<c>await using</c> sırası bunu sağlar) ve kilit açılışta mutlaka bırakılır - havuza dönen bağlantıda
/// kilit kalmasın.
/// </summary>
public sealed class DanismaKilidi : IAsyncDisposable
{
    private readonly NpgsqlConnection _baglanti;
    private readonly string _ad;
    private DanismaKilidi(NpgsqlConnection baglanti, string ad) { _baglanti = baglanti; _ad = ad; }

    /// <summary>Kilidi dener; alınamazsa null (başka oturum işliyor).</summary>
    public static async Task<DanismaKilidi?> DeneAsync(NpgsqlConnection baglanti, string ad, CancellationToken iptal = default)
    {
        var alindi = await baglanti.TekDegerAsync<bool>(
            "select pg_try_advisory_lock(hashtext(@p0))", null, [ad], iptal);
        return alindi ? new DanismaKilidi(baglanti, ad) : null;
    }

    public async ValueTask DisposeAsync()
    {
        try
        {
            await _baglanti.CalistirAsync("select pg_advisory_unlock(hashtext(@p0))", null, [_ad], CancellationToken.None);
        }
        catch { /* bağlantı zaten kopmuşsa kilit sunucuda düşmüştür */ }
    }
}
