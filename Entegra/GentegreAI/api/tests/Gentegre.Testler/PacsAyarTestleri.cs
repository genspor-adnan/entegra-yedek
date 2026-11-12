using Gentegre.Api.Servisler;
using Gentegre.Veri;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;

namespace Gentegre.Testler;

/// <summary>
/// PACS AYARI ENTEGRASYON EKRANINDAN (1316): satır alanlarının ayara çevrimi (boş alan dosyadan, dinleyiciler daima
/// dosyadan), şube önceliği (şube satırı → kurum geneli → dosya), şubeyi taşıyan görüntüleyici jetonu.
/// </summary>
public sealed class PacsAyarTestleri(VeritabaniOlgusu olgu) : IClassFixture<VeritabaniOlgusu>
{
    private static DicomAyarlari Dosya() => new()
    {
        Aktif = false, Sunucu = "10.0.0.1", Port = 104, SunucuAe = "DOSYA_PACS", BizimAe = "DOSYA_BIZ", WadoUrl = "http://dosya/wado",
        GoruntuleyiciUrl = "http://dosya:3001", JetonDakika = 240, ZamanAsimiSn = 20, MwlPort = 4242, MwlAe = "MWL", MwlKarakterSeti = "ISO_IR 148",
    };

    [Fact]
    public void Satir_ayara_cevrilir_bos_alan_dosyadan()
    {
        var a = DicomAyarDeposu.Coz(Dosya(), "GENTEGRE", "SERVERAE", "http://pacs:1000/WADO/SERVERAE",
            """{"sunucu":"192.168.1.20","port":11112,"zamanAsimiSn":"30","goruntuleyiciUrl":"http://ohif","jetonDakika":60,"urun":"ClearCanvas ImageServer"}""");
        Assert.True(a.Aktif);
        Assert.Equal("192.168.1.20", a.Sunucu); Assert.Equal(11112, a.Port); Assert.Equal(30, a.ZamanAsimiSn);
        Assert.Equal("SERVERAE", a.SunucuAe); Assert.Equal("GENTEGRE", a.BizimAe);
        Assert.Equal("http://pacs:1000/WADO/SERVERAE", a.WadoUrl); Assert.Equal("http://ohif", a.GoruntuleyiciUrl); Assert.Equal(60, a.JetonDakika);
        Assert.Equal(4242, a.MwlPort); Assert.Equal("MWL", a.MwlAe);                    // dinleyici dosyadan

        var bos = DicomAyarDeposu.Coz(Dosya(), "", " ", "", "{}");
        Assert.Equal("10.0.0.1", bos.Sunucu); Assert.Equal("DOSYA_PACS", bos.SunucuAe); Assert.Equal("DOSYA_BIZ", bos.BizimAe);
        Assert.Equal("http://dosya/wado", bos.WadoUrl); Assert.Equal(104, bos.Port);
        // Görüntüleyici bilerek boş bırakılabilir ("Görüntüle" kapalı).
        Assert.Equal("", DicomAyarDeposu.Coz(Dosya(), "", "", "", """{"goruntuleyiciUrl":""}""").GoruntuleyiciUrl);
    }

    [Fact]
    public void Jeton_subeyi_tasir_ve_degistirilemez()
    {
        var depo = new DicomAyarDeposu(Options.Create(Dosya()), null!, NullLogger<DicomAyarDeposu>.Instance);
        var dicom = new DicomKaynagi(depo, Options.Create(new GuvenlikAyarlari { ImzaAnahtari = "test-anahtari-0123456789-0123456789" }), null!);
        string jeton;
        using (DicomAyarDeposu.SubeIcin(3)) jeton = dicom.JetonUret("1.2.3", 10);
        Assert.Null(DicomAyarDeposu.Kapsam);                                             // kapsam geri alındı
        Assert.True(dicom.JetonGecerli("1.2.3", jeton, out var sube));
        Assert.Equal(3, sube);
        Assert.False(dicom.JetonGecerli("1.2.4", jeton));                                // başka çalışma
        var p = jeton.Split('.');
        Assert.False(dicom.JetonGecerli("1.2.3", $"{p[0]}.7.{p[2]}"));                   // şube değiştirilemez
        string kurum;
        using (DicomAyarDeposu.SubeIcin(null)) kurum = dicom.JetonUret("1.2.3", 10);
        Assert.True(dicom.JetonGecerli("1.2.3", kurum, out var yok));
        Assert.Null(yok);
    }

    [VtFact]
    public async Task Sube_satiri_kurum_genelini_ezer_satir_yoksa_dosya()
    {
        if (!olgu.Baglandi(nameof(Sube_satiri_kurum_genelini_ezer_satir_yoksa_dosya))) return;
        var veri = olgu.Gerekli();
        // Testin dışındaki PACS satırları (varsa) geçici pasife alınır, sonunda geri açılır.
        var digerleri = await veri.ListeAsync("select id from public.entegrasyon_hesap where kod = 'PACS' and aktif = 1", null,
                                               o => o.GetInt32(0), default);
        var sube = await veri.TekDegerAsync<int>("select id from public.sube where aktif = 1 order by id limit 1");
        var eklenen = new List<int>();
        try
        {
            foreach (var d in digerleri) await veri.CalistirAsync("update public.entegrasyon_hesap set aktif = 0 where id = @p0", [d]);
            var depo = new DicomAyarDeposu(Options.Create(Dosya()), veri, NullLogger<DicomAyarDeposu>.Instance);
            Assert.Equal("DOSYA_PACS", depo.Gecerli(sube).SunucuAe);                  // satır yok → dosya
            Assert.False(depo.EkrandanMi(sube));

            async Task<int> Ekle(int? s, string ae) => await veri.TekDegerAsync<int>("""
                insert into public.entegrasyon_hesap (kod, ad, sube_id, test_mi, aktif, kullanici_adi, uygulama_kodu, url, ayarlar)
                values ('PACS', 'TT PACS', @p0, 0, 1, 'GENTEGRE', @p1, 'http://x/wado', '{"sunucu":"10.9.9.9","port":104}'::jsonb) returning id
                """, [s, ae]);
            eklenen.Add(await Ekle(null, "GENEL_PACS"));
            await depo.YenileAsync();
            Assert.Equal("GENEL_PACS", depo.Gecerli(sube).SunucuAe);                  // kurum geneli
            Assert.True(depo.EkrandanMi(sube));
            eklenen.Add(await Ekle(sube, "SUBE_PACS"));
            await depo.YenileAsync();
            Assert.Equal("SUBE_PACS", depo.Gecerli(sube).SunucuAe);                   // şube satırı ezer
            Assert.Equal("GENEL_PACS", depo.Gecerli(null).SunucuAe);
            using (DicomAyarDeposu.SubeIcin(sube)) Assert.Equal("SUBE_PACS", depo.Gecerli().SunucuAe);
        }
        finally
        {
            foreach (var id in eklenen) await veri.CalistirAsync("delete from public.entegrasyon_hesap where id = @p0", [id]);
            foreach (var d in digerleri) await veri.CalistirAsync("update public.entegrasyon_hesap set aktif = 1 where id = @p0", [d]);
        }
    }
}
