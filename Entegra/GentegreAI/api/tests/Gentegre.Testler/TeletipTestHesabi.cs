using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Testler;

/// <summary>
/// TELERADYOLOJİ TEST HESABI (1324: eski teletip.* yolu kalktı - gönderim yalnız hesaptan). Kurum geneli tek test satırı:
/// işlem içinde (geri alınır) ya da kalıcı (çağıran <see cref="SilAsync"/> ile siler). İşlem içinde başka TELERADYOLOJI
/// satırları geçici adla gizlenir; kalıcıda gizlenmez (test DB'sinde gerçek hesap yok).
/// </summary>
internal static class TeletipTestHesabi
{
    private const string Isaret = "TT test hesabı (1324)";
    private static readonly CancellationToken Iptal = CancellationToken.None;

    public static async Task<int> AyarlaAsync(NpgsqlConnection b, NpgsqlTransaction? t, bool aktif, string hl7 = "127.0.0.1:6661", string firma = "GENTEGRE")
    {
        if (t is not null)
            await b.CalistirAsync("update public.entegrasyon_hesap set kod = 'TELERADYOLOJI_X' where kod = 'TELERADYOLOJI' and coalesce(aciklama, '') <> @p0",
                t, [Isaret], Iptal);
        var id = await b.TekDegerAsync<int?>(
            "update public.entegrasyon_hesap set aktif = @p1, url = @p2, uygulama_kodu = @p3 where kod = 'TELERADYOLOJI' and aciklama = @p0 returning id",
            t, [Isaret, (short)(aktif ? 1 : 0), hl7, firma], Iptal);
        return id ?? await b.TekDegerAsync<int>("""
            insert into public.entegrasyon_hesap (kod, ad, sube_id, test_mi, aktif, uygulama_kodu, url, ayarlar, aciklama)
            values ('TELERADYOLOJI', 'TT TeleRadyoloji', null, 0, @p1, @p3, @p2, '{}'::jsonb, @p0) returning id
            """, t, [Isaret, (short)(aktif ? 1 : 0), hl7, firma], Iptal);
    }

    public static Task SilAsync(NpgsqlConnection b) =>
        b.CalistirAsync("delete from public.entegrasyon_hesap where kod = 'TELERADYOLOJI' and aciklama = @p0", null, [Isaret], Iptal);
}
