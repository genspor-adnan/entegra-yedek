using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// HEKİMİN HASTANIN e-NABIZ KAYITLARINA ERİŞİMİ (878 — KTS maddesi H6 / D15).
///
/// <para>Akış kılavuzdan (SBYS Entegrasyon Kılavuzu, 05.04.2017):
/// <c>DoktorEHRErisimi</c> çağrılır, dönen <c>AccessKey</c> paylaşım
/// adresinin sonuna eklenir, adres TARAYICIDA açılır. Hekim orada e-Devlet
/// ile girer; hasta verisini gizlemişse aynı ekran SMS onayı ister.</para>
///
/// <para><b>Anahtar kaydedilmez.</b> <c>AccessKey</c> geçici bir erişim
/// kimlik bilgisidir; veritabanına yazmak, veritabanını okuyan herkese o
/// hastanın kayıtlarına açılan bir kapı bırakmaktı. Kayda yalnız ilk 8
/// karakteri girer - Bakanlık tarafındaki kayıtla eşleştirmeye yeter.</para>
///
/// <para><b>Her deneme kayda geçer</b> (başarısız olan da): "hangi hekim,
/// hangi hastanın kayıtlarına, ne zaman erişmek istedi" sorusunun cevabı
/// kurumda durmalı - denetimden önce KVKK gereği.</para>
/// </summary>
public sealed class EnabizErisimServisi
{
    private readonly VeriKaynagi _veri;
    private readonly EnabizPortalIstemcisi _portal;
    private readonly ILogger<EnabizErisimServisi> _gunluk;

    public EnabizErisimServisi(VeriKaynagi veri, EnabizPortalIstemcisi portal,
                               ILogger<EnabizErisimServisi> gunluk)
    {
        _veri = veri;
        _portal = portal;
        _gunluk = gunluk;
    }

    public const string Metot = "DoktorEHRErisimi";

    public sealed record Sonuc(long KayitId, bool Basarili, string Adres, string ServisMesaji);

    /// <summary>
    /// Erişim anahtarı ister ve açılacak adresi döner.
    ///
    /// <para>Kimlik numaraları ZORUNLU: servis hastayı ve hekimi TC kimlik
    /// numarasıyla tanır. Numarasız çağrı yapmak, servise kesin reddedilecek
    /// bir istek göndermek olurdu - hata ekranda anlaşılır olsun.</para>
    /// </summary>
    public async Task<Sonuc> AnahtarAlAsync(int hastaId, int hekimId, int? muayeneId, int? belgeId,
                                            int subeId, int kullaniciId, string ip,
                                            CancellationToken iptal)
    {
        await using var baglanti = await _veri.AcAsync(iptal);

        var kimlikler = await baglanti.TekAsync("""
            select coalesce((select vkno from public.taraf where id = @p0), ''),
                   coalesce((select vkno from public.taraf where id = @p1), '')
            """, null, [hastaId, hekimId],
            o => new { Hasta = o.GetString(0), Hekim = o.GetString(1) }, iptal)
            ?? throw GentegreHatasi.Bulunamadi("Hasta ya da hekim bulunamadı.");

        if (kimlikler.Hasta.Trim().Length == 0)
            throw GentegreHatasi.IsKurali(
                "Hastanın kimlik numarası kayıtlı değil; e-Nabız kayıtlarına erişilemez.");
        if (kimlikler.Hekim.Trim().Length == 0)
            throw GentegreHatasi.IsKurali(
                "Hekimin kimlik numarası kayıtlı değil; e-Nabız erişimi hekim kimliğiyle açılır.");

        var hesap = await EnabizPortalIstemcisi.HesapAlAsync(baglanti, iptal)
            ?? throw GentegreHatasi.IsKurali(
                "e-Nabız Portal hesabı tanımlı değil ya da pasif "
                + "(Genel Ayarlar › Entegrasyon Hesapları › \"e-Nabız Portal\").");

        // KAYIT ÖNCE AÇILIR (sonuç 0 = istendi): servis çağrısı patlasa bile
        //   "erişmek istedi" izi kalsın. Erişim izinin kendisi, erişimin
        //   sonucundan daha önemlidir.
        var kayitId = await baglanti.TekDegerAsync<long>("""
            insert into public.enabiz_erisim
                   (sube_id, hasta_id, hekim_id, hasta_kimlik, hekim_kimlik,
                    muayene_id, belge_id, sonuc, ip, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, 0, @p7, @p8)
            returning id
            """, null, [subeId, hastaId, hekimId, kimlikler.Hasta, kimlikler.Hekim,
                        muayeneId, belgeId, EnabizPortalIstemcisi.Kirp(ip, 45), kullaniciId], iptal);

        short sonuc; string mesaj = ""; string adres = "";
        try
        {
            var (httpTamam, httpKod, zarf) = await _portal.CagirAsync(hesap, Metot, new[]
            {
                ("KURUM_KODU", hesap.KurumKodu),
                ("HEKIM_KIMLIK_NUMARASI", kimlikler.Hekim),
                ("HASTA_KIMLIK_NUMARASI", kimlikler.Hasta),
            }, iptal);

            if (!httpTamam)
            {
                sonuc = 3;
                mesaj = $"HTTP {httpKod}: {EnabizPortalIstemcisi.Kirp(zarf, 200)}";
            }
            else if (EnabizPortalIstemcisi.Fault(zarf) is string fault)
            {
                sonuc = 3; mesaj = EnabizPortalIstemcisi.Kirp(fault, 400);
            }
            else
            {
                var basari = EnabizPortalIstemcisi.Eleman(zarf, "IslemBasarisi");
                var anahtar = EnabizPortalIstemcisi.Eleman(zarf, "AccessKey") ?? "";
                mesaj = EnabizPortalIstemcisi.Kirp(
                    EnabizPortalIstemcisi.Eleman(zarf, "ServisMesaji") ?? "", 400);

                // İKİ KOŞUL BİRDEN: servis "başarılı" deyip anahtarı boş
                //   gönderirse ekran boş bir adres açardı; hekim "e-Nabız
                //   çalışmıyor" derdi, sebebi görünmezdi.
                if (bool.TryParse(basari, out var b) && b && anahtar.Trim().Length > 0)
                {
                    sonuc = 1;
                    adres = await PaylasimAdresiAsync(baglanti, iptal) + Uri.EscapeDataString(anahtar.Trim());
                }
                else
                {
                    sonuc = 2;
                    if (mesaj.Length == 0)
                        mesaj = anahtar.Trim().Length == 0
                            ? "Servis erişim anahtarı döndürmedi."
                            : "Servis isteği reddetti.";
                }

                await baglanti.CalistirAsync(
                    "update public.enabiz_erisim set anahtar_onek = @p1 where id = @p0",
                    null, [kayitId, EnabizPortalIstemcisi.Kirp(anahtar.Trim(), 8)], iptal);
            }
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz erisim anahtari alinamadi (hasta {Hasta})", hastaId);
            sonuc = 3; mesaj = EnabizPortalIstemcisi.Kirp(h.Message, 400);
        }

        await baglanti.CalistirAsync("""
            update public.enabiz_erisim set sonuc = @p1, servis_mesaji = @p2 where id = @p0
            """, null, [kayitId, sonuc, mesaj], iptal);

        return new Sonuc(kayitId, sonuc == 1, adres, mesaj);
    }

    private static async Task<string> PaylasimAdresiAsync(NpgsqlConnection b, CancellationToken iptal)
        => await b.TekDegerAsync<string>("""
            select coalesce(nullif(deger, ''),
                            'https://www.enabiz.gov.tr/nabizpaylasim/HastaBilgisiKontrol.aspx?keyH=')
              from public.referans where anahtar = 'enabiz.paylasim_adresi'
            """, null, [], iptal)
           ?? "https://www.enabiz.gov.tr/nabizpaylasim/HastaBilgisiKontrol.aspx?keyH=";
}
