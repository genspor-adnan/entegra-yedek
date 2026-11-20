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
                    izlemeNo, kod, (short)httpDurum, Gentegre.Cekirdek.MetinAraci.Kes(yol, 200), Gentegre.Cekirdek.MetinAraci.Kes(yontem, 10),
                    Gentegre.Cekirdek.MetinAraci.Kes(mesaj, 500), ayrinti, yigin, kullaniciId, subeId, Gentegre.Cekirdek.MetinAraci.Kes(ip, 45), istekJson
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
                    Gentegre.Cekirdek.MetinAraci.Kes(kod, 120), kullaniciId, Gentegre.Cekirdek.MetinAraci.Kes(ip, 45), Gentegre.Cekirdek.MetinAraci.Kes(istemci, 200),
                    (short)(basarili ? 1 : 0), Gentegre.Cekirdek.MetinAraci.Kes(sebep, 40)
                }, iptal);
        }
        catch
        {
            // yoksay
        }
    }

}
