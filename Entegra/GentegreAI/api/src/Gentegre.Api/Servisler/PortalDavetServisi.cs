using System.Security.Cryptography;
using System.Text;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Bildirim;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;

namespace Gentegre.Api.Servisler;

/// <summary>
/// PORTAL DAVETİ ÜRETİMİ (822) — tek yer.
///
/// <para>İki yol buraya çıkıyor: <b>"Portal Daveti Gönder"</b> (hesabı olmayan
/// kişiye bağlantı) ve <b>"Portal Erişimi"</b> (hesap açıldıktan sonra kişiye
/// haber). İkisi de aynı jetonu, aynı süreyi, aynı şablonu kullanır - iki ayrı
/// yerde üretilseydi biri düzeltilip öteki eski kalırdı.</para>
///
/// <para><b>Jeton depoda DÜZ DURMAZ:</b> saklanan SHA-256 özeti. Bağlantının
/// kendisi yalnız gönderilen mesajda olur; uç yanıtında bile dönmez.</para>
/// </summary>
public sealed class PortalDavetServisi(VeriKaynagi veri, BildirimDeposu bildirim)
{
    private readonly VeriKaynagi _veri = veri;
    private readonly BildirimDeposu _bildirim = bildirim;

    public sealed record DavetSonucu(long DavetId, short Kanal, string MaskeliAlici,
                                     int GecerlilikSaat, long? BildirimId, string Mesaj);

    /// <summary>
    /// Davet üretir ve kuyruğa bırakır. <paramref name="zorunlu"/> false ise
    /// (Portal Erişimi akışı) iletişim bilgisi yoksa <c>null</c> döner -
    /// hesap açılmış olur, yalnız haber gönderilemez.
    /// </summary>
    public async Task<DavetSonucu?> UretVeGonderAsync(
        int tarafId, short? kanalSecim, string? aliciSecim, IstekBaglami baglam,
        bool zorunlu, CancellationToken iptal, short portalTuru = 0)
    {
        await using var b = await _veri.AcAsync(iptal);

        var taban = (await AyarDeposu.MetinAsync(b, null, "portal.taban_url", "", iptal))
                    .Trim().TrimEnd('/');
        if (taban.Length == 0)
        {
            if (!zorunlu) return null;
            throw GentegreHatasi.IsKurali(
                "Portal adresi tanımlı değil (ayar: portal.taban_url). "
                + "Davet bağlantısı bu adresle kurulur.");
        }

        var saat = int.TryParse(
            await AyarDeposu.MetinAsync(b, null, "portal.davet_saat", "48", iptal),
            out var s) ? s : 48;

        var kisi = await b.TekAsync("""
            select t.id, coalesce(t.unvan, '') as unvan, coalesce(t.vkno, '') as tckn,
                   coalesce(t.cep_tel, '') as cep, coalesce(t.eposta, '') as eposta,
                   k.id as "hesapVar",
                   case when coalesce(k.parola_hash, '') = '' then 1 else 0 end as "parolasiz"
              from public.taraf t
              left join public.taraf_kullanici k on k.id = t.id
             where t.id = @p0
            """, null, [tarafId], OkuyucuGenisletmeleri.Sozluk, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Kişi bulunamadı.");

        // KİMLİK KANITI OLMADAN DAVET OLMAZ: doğrulama TCKN'nin son 4 hanesini
        //   soruyor. TCKN yoksa bağlantıyı eline geçiren herkes hesabı açardı.
        var tckn = ((string)(kisi["tckn"] ?? "")).Trim();
        if (tckn.Length < 4)
        {
            if (!zorunlu) return null;
            throw GentegreHatasi.IsKurali(
                "Kartta TCKN yok - davet doğrulaması TCKN'nin son 4 hanesini soruyor. "
                + "Önce kimlik bilgisini girin.");
        }

        // PAROLASI OLAN HESABA DAVET GİTMEZ: davet hesabı açar ya da parolasını
        //   belirletir; var olan parolayı değiştirmek "parola sıfırlama"dır ve
        //   ayrı bir karardır.
        if (kisi["hesapVar"] is not null && Convert.ToInt32(kisi["parolasiz"] ?? 0) == 0)
        {
            if (!zorunlu) return null;
            throw GentegreHatasi.IsKurali(
                "Bu kişinin parolası zaten tanımlı. Parola sorunu varsa Kullanıcılar "
                + "ekranından sıfırlanır.");
        }

        // KANAL SEÇİLMEDİYSE: cep varsa SMS, yoksa e-posta. Portal Erişimi
        //   akışında kullanıcıya ikinci bir soru sorulmasın.
        var cep = ((string)(kisi["cep"] ?? "")).Trim();
        var eposta = ((string)(kisi["eposta"] ?? "")).Trim();
        var kanal = kanalSecim == 2 ? BildirimKanali.Eposta
                  : kanalSecim == 1 ? BildirimKanali.Sms
                  : cep.Length > 0 ? BildirimKanali.Sms : BildirimKanali.Eposta;

        var alici = (aliciSecim ?? "").Trim();
        if (alici.Length == 0) alici = kanal == BildirimKanali.Sms ? cep : eposta;
        if (alici.Length == 0)
        {
            if (!zorunlu) return null;
            throw GentegreHatasi.IsKurali(kanal == BildirimKanali.Sms
                ? "Kişinin cep telefonu yok - kartına yazın ya da numarayı girin."
                : "Kişinin e-posta adresi yok.");
        }

        var (jeton, ozet) = JetonUret();
        var davetId = await b.TekDegerAsync<long>("""
            insert into public.portal_davet
                   (taraf_id, kanal, alici, jeton_ozet, durum, gecerlilik, sube_id, ekleyen)
            values (@p0, @p1, @p2, @p3, 1,
                    (now() + make_interval(hours => @p4))::timestamp, @p5, @p6)
            returning id
            """, null,
            [tarafId, (short)kanal, alici, ozet, saat, baglam.SubeId, baglam.KullaniciId],
            iptal);

        var kurum = baglam.Subeler.FirstOrDefault(x => x.Id == baglam.SubeId)?.Ad ?? "Portal";
        // PORTAL ADI ŞABLONA DEĞİŞKEN GİDER (823): aynı metin hastaya "hasta
        //   portalı", hekime "hekim portalı" der. Üç ayrı şablon tutmak,
        //   kurumun imzasını değiştirmek istediğinde altı yerde düzeltme
        //   demekti. Tür verilmediyse hesabın rolünden okunur.
        var tur = portalTuru > 0 ? portalTuru : await b.TekDegerAsync<short>(
            "select coalesce(r.portal_turu, 0) from public.taraf_kullanici k "
            + "left join public.rol r on r.id = k.rol_id where k.id = @p0",
            null, [tarafId], iptal);
        var portalAdi = tur switch
        {
            1 => "hekim portalı",
            2 => "kurum portalı",
            _ => "hasta portalı",
        };
        var bildirimId = await _bildirim.KuyrugaEkleAsync(new BildirimIstegi(
            kanal == BildirimKanali.Sms ? "portal.davet" : "portal.davet.eposta",
            kanal, alici,
            new Dictionary<string, string>
            {
                ["kurum"] = kurum,
                ["portal"] = portalAdi,
                ["baglanti"] = $"{taban}/davet/{jeton}",
                ["saat"] = saat.ToString(),
                ["kisi"] = (string)(kisi["unvan"] ?? ""),
            },
            TarafId: tarafId, KaynakTur: 41, KaynakId: (int)davetId),
            baglam.KullaniciId, baglam.SubeId, iptal);

        await b.CalistirAsync(
            "update public.portal_davet set gonderim_id = @p1 where id = @p0",
            null, [davetId, bildirimId], iptal);

        var maskeli = Maskele(alici);
        return new DavetSonucu(davetId, (short)kanal, maskeli, saat, bildirimId,
            $"Davet {(kanal == BildirimKanali.Sms ? "SMS" : "e-posta")} ile gönderildi "
            + $"({maskeli}). Bağlantı {saat} saat geçerli.");
    }

    /// <summary>
    /// 32 baytlık rastgele jeton + SHA-256 özeti. base64url: SMS'te kırpılan
    /// ya da kaçışlanan bir bağlantı çalışmaz.
    /// </summary>
    public static (string Jeton, string Ozet) JetonUret()
    {
        var ham = RandomNumberGenerator.GetBytes(32);
        var jeton = Convert.ToBase64String(ham)
            .Replace('+', '-').Replace('/', '_').TrimEnd('=');
        return (jeton, Ozet(jeton));
    }

    public static string Ozet(string jeton)
        => Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(jeton))).ToLowerInvariant();

    /// <summary>Günlük ve yanıt için maskeli alıcı: 0533***4110 · a***@x.com</summary>
    public static string Maskele(string alici)
    {
        if (alici.Contains('@'))
        {
            var p = alici.Split('@');
            return $"{(p[0].Length > 1 ? p[0][..1] : p[0])}***@{p[^1]}";
        }
        return alici.Length > 8 ? $"{alici[..4]}***{alici[^4..]}" : "***";
    }
}
