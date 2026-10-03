using System.Globalization;
using Gentegre.Api.Servisler;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri.Depolar;
using Microsoft.AspNetCore.Authorization;

namespace Gentegre.Api.AraKatman;

/// <summary>
/// OTURUM KAPISI (denetim 28.09.2026 #4): kimlik dogrulamasindan SONRA, her
/// kimlikli istekte hesabin guncel durumuna bakar.
///
/// <para><b>Zorunlu parola degisimi sunucuda uygulanir.</b> Onceden
/// <c>parola_degismeli</c> yalniz React'te bir yonlendirmeydi: varsayilan
/// parolayla (kart id'si) alinan token dogrudan API'ye verildiginde rolun
/// butun yetkileri calisiyordu. Bayrak surdukce yalniz
/// <see cref="SinirliOturum.ParolaDegismeli"/> ile isaretli uclar (profil,
/// parola degistirme) calisir. Kontrol istek basina DB'den okunur: bayrak
/// token alindiktan sonra acilsa da, yenileme ya da sube degistirme ile yeni
/// token alinsa da kapi ayni karari verir.</para>
///
/// <para><b>Pasif hesap</b> gecerli token'la da iceri giremez (401).</para>
///
/// <para>Anonim uclar (giris, yenile, ilk parola...) kapiya girmez.</para>
/// </summary>
public sealed class OturumKapisi
{
    private readonly RequestDelegate _sonraki;
    public OturumKapisi(RequestDelegate sonraki) => _sonraki = sonraki;

    public async Task InvokeAsync(HttpContext ctx, KullaniciDeposu kullanicilar)
    {
        var uc = ctx.GetEndpoint();
        var kimlikli = ctx.User.Identity?.IsAuthenticated == true;
        var anonim = uc?.Metadata.GetMetadata<IAllowAnonymous>() is not null;

        if (uc is not null && kimlikli && !anonim
            && int.TryParse(ctx.User.FindFirst(Talep.KullaniciId)?.Value, NumberStyles.Integer,
                            CultureInfo.InvariantCulture, out var kullaniciId))
        {
            var durum = await kullanicilar.OturumDurumuAsync(kullaniciId, ctx.RequestAborted);
            if (durum is null || !durum.Aktif)
                throw GentegreHatasi.Yetkisiz();
            // ROL ATANMAMIS (kullanici): rolu oturum acikken "Rol Atanmamis"a
            //   cekilen kisi bir sonraki istekte duser - token suresini beklemez.
            if (durum.RolAtanmamis)
                throw GentegreHatasi.Yetkisiz(Servisler.KimlikServisi.RolYokMesaji);

            if (durum.ParolaDegismeli && !ctx.SinirliOturumaAcikMi(SinirliOturum.ParolaDegismeli))
                throw new GentegreHatasi(HataKodu.ParolaDegismeli,
                    "Devam etmek icin once parolanizi degistirin.");
        }

        await _sonraki(ctx);
    }
}
