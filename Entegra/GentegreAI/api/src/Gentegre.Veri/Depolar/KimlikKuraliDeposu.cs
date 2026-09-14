using System.Collections.Concurrent;
using Gentegre.Cekirdek.Katalog;

namespace Gentegre.Veri.Depolar;

/// <summary>
/// KİMLİK NO BİÇİMİ (679) — kurum profilindeki ayarın okuyucusu.
///
/// Kural HER İSTEKTE gerekir (kart yazımı ve kart meta'sı) ama saatte bir bile
/// değişmez: her istekte bir sorgu daha atmak, ayarın kendisinden pahalı olurdu.
/// Bu yüzden şube başına KISA ÖMÜRLÜ önbellek (60 sn) - yönetici ayarı
/// değiştirince en geç bir dakika içinde her yerde geçerli olur, uygulamayı
/// yeniden başlatmak gerekmez.
///
/// "otomatik" değeri DB'de çözülür (fn_kimlik_kurali): sunucu ile istemcinin
/// aynı cevabı alması şart, yoksa ekranın kabul edip sunucunun reddettiği bir
/// numara ortaya çıkardı.
/// </summary>
public sealed class KimlikKuraliDeposu
{
    private static readonly TimeSpan Omur = TimeSpan.FromSeconds(60);
    private static readonly ConcurrentDictionary<int, (KimlikKurali Kural, DateTime Bitis)> Kova
        = new();

    private readonly VeriKaynagi _veri;

    public KimlikKuraliDeposu(VeriKaynagi veri) => _veri = veri;

    public async Task<KimlikKurali> KuralAsync(int subeId = 0,
                                               CancellationToken iptal = default)
    {
        if (Kova.TryGetValue(subeId, out var kayit) && kayit.Bitis > DateTime.UtcNow)
            return kayit.Kural;

        KimlikKurali kural;
        try
        {
            await using var baglanti = await _veri.AcAsync(iptal);
            await using var komut = baglanti.Komut(
                "select bicim, desen, aciklama from public.fn_kimlik_kurali(@p0)",
                null, subeId);
            await using var o = await komut.ExecuteReaderAsync(iptal);
            kural = await o.ReadAsync(iptal)
                ? new KimlikKurali(o.GetString(0), o.GetString(1), o.GetString(2))
                : KimlikKurali.Varsayilan;
        }
        catch
        {
            // Ayar okunamadi (betik uygulanmamis eski veritabani): kontrol
            //   ACIK kalir - sessizce kapanmasi kotudur.
            kural = KimlikKurali.Varsayilan;
        }

        Kova[subeId] = (kural, DateTime.UtcNow.Add(Omur));
        return kural;
    }

    /// <summary>Ayar yazildiginda onbellegi dusur - bir dakika beklemeden gecerli olsun.</summary>
    public static void Unut() => Kova.Clear();
}
