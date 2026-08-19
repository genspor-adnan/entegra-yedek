namespace Gentegre.Veri.Depolar;

/// <summary>hata_log ve giris_denemesi yazimi. Yazma hatasi istegi BOZMAZ.</summary>
public sealed class GunlukDeposu
{
    private readonly VeriKaynagi _veri;
    public GunlukDeposu(VeriKaynagi veri) => _veri = veri;

    public async Task HataYazAsync(string izlemeNo, string kod, int httpDurum, string yol,
        string yontem, string mesaj, string ayrinti, string yigin, int? kullaniciId,
        int? subeId, string ip, string? istekJson, CancellationToken iptal = default)
    {
        try
        {
            await _veri.CalistirAsync("""
                insert into public.hata_log
                    (izleme_no, kod, http_durum, yol, yontem, mesaj, ayrinti, yigin,
                     kullanici_id, sube_id, ip, istek)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11::jsonb)
                on conflict (izleme_no) do nothing
                """,
                new object?[]
                {
                    izlemeNo, kod, (short)httpDurum, Kirp(yol, 200), Kirp(yontem, 10),
                    Kirp(mesaj, 500), ayrinti, yigin, kullaniciId, subeId, Kirp(ip, 45), istekJson
                }, iptal);
        }
        catch
        {
            // Gunluk yazamamak istegi bozmaz - hata yaniti yine de doner.
        }
    }

    public async Task GirisDenemesiAsync(string kod, int? kullaniciId, string ip, string istemci,
        bool basarili, string sebep, CancellationToken iptal = default)
    {
        try
        {
            await _veri.CalistirAsync("""
                insert into public.giris_denemesi (kod, kullanici_id, ip, istemci, basarili, sebep)
                values (@p0, @p1, @p2, @p3, @p4, @p5)
                """,
                new object?[]
                {
                    Kirp(kod, 30), kullaniciId, Kirp(ip, 45), Kirp(istemci, 200),
                    (short)(basarili ? 1 : 0), Kirp(sebep, 40)
                }, iptal);
        }
        catch
        {
            // yoksay
        }
    }

    private static string Kirp(string? m, int uzunluk)
        => string.IsNullOrEmpty(m) ? "" : (m.Length <= uzunluk ? m : m[..uzunluk]);
}
