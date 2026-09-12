using System.Reflection;
using System.Xml.Linq;
using Gentegre.Api.Servisler;
using Gentegre.Veri;

namespace Gentegre.Testler;

/// <summary>
/// USS gövdesi (`SYSMessage`) doğru kuruluyor mu - 602/605.
///
/// Bu paket GERÇEK bir dış servise gidiyor ve şeması deneyerek çıkarıldı
/// (dokuman/09_ENABIZ_USS_SEMASI.md); sessizce bozulursa hata ancak Sağlık
/// Bakanlığı'nın reddettiği gönderimde görülür. Test, üretilen XML'in
/// kılavuzdaki üç kuralını sabitler: değerler `value` özniteliğinde, veri
/// setleri hiyerarşik, SKRS alanları kodlu.
/// </summary>
public class EnabizXmlTestleri : IClassFixture<VeritabaniOlgusu>
{
    private readonly VeritabaniOlgusu _olgu;
    public EnabizXmlTestleri(VeritabaniOlgusu olgu) => _olgu = olgu;

    private const string Etiket = "TEST-ENABIZ-XML";

    private static async Task<string> XmlUretAsync(VeriKaynagi veri, long paketId)
    {
        var servis = (EnabizGonderimi)Activator.CreateInstance(
            typeof(EnabizGonderimi),
            veri,
            new SahteFabrika(),
            Microsoft.Extensions.Logging.Abstractions.NullLogger<EnabizGonderimi>.Instance,
            // 625: gonderim, 101 gidince ISLEM paketini uretiyor - govde
            //   testinde uretim yolu calismaz ama kurucu bagimliligi gercek.
            new Gentegre.Api.Servisler.EnabizPaketUretici(veri,
                Microsoft.Extensions.Logging.Abstractions
                         .NullLogger<Gentegre.Api.Servisler.EnabizPaketUretici>.Instance))!;
        var yontem = typeof(EnabizGonderimi).GetMethod("XmlUretAsync",
            BindingFlags.NonPublic | BindingFlags.Instance)!;
        var gorev = (Task<string>)yontem.Invoke(servis, [paketId, CancellationToken.None])!;
        return await gorev;
    }

    private sealed class SahteFabrika : IHttpClientFactory
    {
        public HttpClient CreateClient(string name) => new();
    }

    [Fact]
    public async Task SYSMessage_govdesi_kilavuz_kurallarina_uyar()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        var turId = await veri.TekDegerAsync<int>(
            "select id from public.enabiz_paket_turu where uss_paket_kodu = '101'");
        var paketId = await veri.TekDegerAsync<long>("""
            insert into public.enabiz_paket
                   (paket_no, paket_turu_id, kaynak_tur, kaynak_id, durum,
                    olay_tarihi, sube_id, ekleyen)
            values (@p0, @p1, 1, 999999, 0, timestamp '2026-09-05 16:37:23',
                    (select min(id) from public.sube), 0)
            returning id
            """, [Etiket, turId]);
        try
        {
            await veri.CalistirAsync("""
                insert into public.enabiz_paket_alan
                       (paket_id, uss_alan, deger, skrs_kod, skrs_sistem, skrs_surum, sira)
                values (@p0, 'HASTA_KIMLIK_BILGILERI/AD', 'E2E', '', '', '1', 1),
                       (@p0, 'HASTA_KIMLIK_BILGILERI/CINSIYET', 'Erkek', 'E',
                        '784d0f4f-0603-4425-937f-1a3941fc3a1f', '1', 2),
                       (@p0, 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES',
                        'TEST MAH', '', '', '1', 3),
                       (@p0, 'HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES_ILCE',
                        'CANKAYA', '', '', '1', 4)
                """, [paketId]);

            var xml = await XmlUretAsync(veri, paketId);
            var kok = XElement.Parse(xml);

            Assert.Equal("SYSMessage", kok.Name.LocalName);
            // Basligin zorunlu parcalari.
            Assert.Equal("101", kok.Element("messageType")!.Attribute("code")!.Value);
            Assert.Equal("202609051637",
                kok.Element("documentGenerationTime")!.Attribute("value")!.Value);
            Assert.NotNull(kok.Element("author")!.Element("healthcareProvider"));
            Assert.NotNull(kok.Element("firmaKodu"));

            var kayit = kok.Element("recordData")!;
            var kimlik = kayit.Element("HASTA_KIMLIK_BILGILERI")!;

            // 1) DEGER `value` OZNITELIGINDE - eleman metninde degil.
            var ad = kimlik.Element("AD")!;
            Assert.Equal("E2E", ad.Attribute("value")!.Value);
            Assert.Equal("", ad.Value);

            // 2) SKRS ALANI KODLU: version + codeSystemGuid + code + value.
            var cinsiyet = kimlik.Element("CINSIYET")!;
            Assert.Equal("E", cinsiyet.Attribute("code")!.Value);
            Assert.Equal("784d0f4f-0603-4425-937f-1a3941fc3a1f",
                         cinsiyet.Attribute("codeSystemGuid")!.Value);
            Assert.Equal("Erkek", cinsiyet.Attribute("value")!.Value);
            // Duz alanda kod oznitelikleri BULUNMAZ.
            Assert.Null(ad.Attribute("codeSystemGuid"));

            // 3) HIYERARSI: ara dugum BIR KEZ acilir, iki alan ayni adresin
            //    altinda toplanir.
            var adres = kimlik.Elements("ADRES_BILGISI").ToList();
            Assert.Single(adres);
            Assert.Equal(2, adres[0].Elements().Count());
            Assert.Equal("TEST MAH", adres[0].Element("ACIK_ADRES")!.Attribute("value")!.Value);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [paketId]);
        }
    }

    [Fact]
    public async Task Silme_paketi_govdesini_TAKIP_NUMARASINDAN_uretir()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        var turId = await veri.TekDegerAsync<int>(
            "select id from public.enabiz_paket_turu where uss_paket_kodu = '301'");
        var paketId = await veri.TekDegerAsync<long>("""
            insert into public.enabiz_paket
                   (paket_no, paket_turu_id, kaynak_tur, kaynak_id, durum,
                    olay_tarihi, sys_takip_no, sube_id, ekleyen)
            values (@p0, @p1, 1, 999999, 0, now(), 'TAKIP-12345',
                    (select min(id) from public.sube), 0)
            returning id
            """, [Etiket + "-SIL", turId]);
        try
        {
            // 301'in govdesi ALAN TABLOSUNDAN gelmez: paketin kendi takip
            //   numarasindan uretilir (605).
            var kok = XElement.Parse(await XmlUretAsync(veri, paketId));
            Assert.Equal("301", kok.Element("messageType")!.Attribute("code")!.Value);
            var takip = kok.Element("recordData")!
                           .Element("HASTA_TAKIP_BILGISI")!.Element("SYSTakipNo")!;
            Assert.Equal("TAKIP-12345", takip.Attribute("value")!.Value);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [paketId]);
        }
    }

    [Fact]
    public async Task Uretici_USS_alan_adlari_ve_yollarini_yazar()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        // GERCEK bir basvurudan uretilen alanlar USS adlarinda mi (605/606)?
        //   Eski yer tutucu adlar ("HastaKimlikNo", "TesisKodu") kalirsa
        //   gonderim sessizce reddedilirdi - USS o adlari tanimiyor.
        // EN ESKI basvuru: `max(id)` baska testlerin gecici kayitlarini
        //   secip yaris uretiyordu (o test satirini silince paket uretilemez
        //   ve UretAsync null doner). En eski kayit kalicidir.
        var belgeId = await veri.TekDegerAsync<int>(
            "select min(b.id) from public.belge b " +
            " join public.belge_basvuru bb on bb.id = b.id " +
            " where b.tur = 19 and bb.bolum_id is not null");
        if (belgeId <= 0) return;

        var uretici = new Gentegre.Api.Servisler.EnabizPaketUretici(veri,
            Microsoft.Extensions.Logging.Abstractions
                     .NullLogger<Gentegre.Api.Servisler.EnabizPaketUretici>.Instance);
        var sonuc = await uretici.UretAsync("HASTA_KABUL", belgeId, 0, CancellationToken.None);
        Assert.NotNull(sonuc);
        try
        {
            var adlar = await veri.ListeAsync(
                "select uss_alan from public.enabiz_paket_alan where paket_id = @p0",
                [sonuc!.PaketId], o => o.GetString(0));

            Assert.NotEmpty(adlar);
            // Hepsi YOL tasir: veri seti / alan.
            Assert.All(adlar, a => Assert.Contains('/', a));
            Assert.Contains("HASTA_KIMLIK_BILGILERI/HASTA_KIMLIK_NUMARASI", adlar);
            Assert.Contains("HASTA_BASVURU_BILGILERI/KABUL_ZAMANI", adlar);
            // Eski yer tutucu adlardan HICBIRI kalmamali.
            Assert.DoesNotContain("HastaKimlikNo", adlar);
            Assert.DoesNotContain("TesisKodu", adlar);

            // KABUL_ZAMANI USS bicimi: yyyyMMddHHmm (12 hane, tire/T yok).
            var zaman = await veri.TekDegerAsync<string>(
                "select deger from public.enabiz_paket_alan " +
                " where paket_id = @p0 and uss_alan like '%KABUL_ZAMANI'",
                [sonuc.PaketId]);
            Assert.Matches(@"^\d{12}$", zaman);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [sonuc!.PaketId]);
        }
    }

    [Fact]
    public async Task SKRS_kodlu_alanlar_kod_ve_sistem_tasir()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        // 607 ile kod eslemeleri yuklendi. Cinsiyet YEREL kod uzayimizla
        //   birebir ortusen tek liste (1 Erkek / 2 Kadin) - o yuzden ucu ucuna
        //   dogrulanabilir: eslemesiz alan bos gider, eslesen alan kod TASIR.
        var eslemeVar = await veri.TekDegerAsync<int>(
            "select count(*) from public.enabiz_kod_esleme " +
            " where esleme_turu = 'CINSIYET' and yerel_kod = '1' and aktif = 1");
        Assert.True(eslemeVar > 0, "607 kod eslemeleri yuklenmemis.");

        var belgeId = await veri.TekDegerAsync<int>("""
            select min(b.id) from public.belge b
              join public.belge_basvuru bb on bb.id = b.id
              join public.taraf_hasta th on th.id = b.taraf_id
             where b.tur = 19 and th.cinsiyet = 1
            """);
        if (belgeId <= 0) return;

        var uretici = new Gentegre.Api.Servisler.EnabizPaketUretici(veri,
            Microsoft.Extensions.Logging.Abstractions
                     .NullLogger<Gentegre.Api.Servisler.EnabizPaketUretici>.Instance);
        var sonuc = await uretici.UretAsync("HASTA_KABUL", belgeId, 0, CancellationToken.None);
        Assert.NotNull(sonuc);
        try
        {
            var c = await veri.TekAsync("""
                select deger, skrs_kod, skrs_sistem from public.enabiz_paket_alan
                 where paket_id = @p0 and uss_alan like '%CINSIYET'
                """, [sonuc!.PaketId],
                o => new { Deger = o.GetString(0), Kod = o.GetString(1), Sistem = o.GetString(2) });

            Assert.NotNull(c);
            Assert.Equal("1", c!.Kod);
            Assert.Equal("ERKEK", c.Deger);
            // codeSystemGuid USS semasindaki cinsiyet listesi olmali.
            Assert.Equal("784d0f4f-0603-4425-937f-1a3941fc3a1f", c.Sistem);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [sonuc!.PaketId]);
        }
    }

    [Fact]
    public async Task Gonderilmis_101_icin_301_SILME_paketi_uretilir()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        // Kullanicinin asil istegi: "101 gonderip iptal etmek". USS'de iptalin
        //   karsiligi 301 paketidir ve govdesi 101'in dondurdugu SYSTakipNo'yu
        //   tasir. Burada gonderim TAKLIT edilir (dis servise gidilmez): paket
        //   durum 3 + takip numarasi yazilir, sonra silme paketi uretilir.
        var belgeId = await veri.TekDegerAsync<int>("""
            select min(b.id) from public.belge b
              join public.belge_basvuru bb on bb.id = b.id
             where b.tur = 19 and bb.bolum_id is not null
            """);
        if (belgeId <= 0) return;

        var uretici = new Gentegre.Api.Servisler.EnabizPaketUretici(veri,
            Microsoft.Extensions.Logging.Abstractions
                     .NullLogger<Gentegre.Api.Servisler.EnabizPaketUretici>.Instance);

        var kabul = await uretici.UretAsync("HASTA_KABUL", belgeId, 0, CancellationToken.None);
        Assert.NotNull(kabul);
        long? silmeId = null;
        try
        {
            // Gonderim TAKLIDI: paket gonderildi isaretlenir ve takip numarasi
            //   BASVURUYA yazilir (608) - yururlukteki yer orasidir, sonraki
            //   paketler (103/106/301) onu oradan okur. Pakettekini de
            //   birakiyoruz: o, "bu gonderim hangi numarayi dondurdu" izi.
            await veri.CalistirAsync("""
                update public.enabiz_paket
                   set durum = 3, sys_takip_no = 'TAKIP-TEST-9001'
                 where id = @p0
                """, [kabul!.PaketId]);
            await veri.CalistirAsync("""
                update public.belge_basvuru set sys_takip_no = 'TAKIP-TEST-9001'
                 where id = @p0
                """, [belgeId]);

            var silme = await uretici.UretAsync("HASTA_KABUL_SIL", belgeId, 0,
                                                CancellationToken.None);
            Assert.NotNull(silme);
            silmeId = silme!.PaketId;

            // Silme paketi 101'in TAKIP NUMARASINI bulmus olmali.
            var deger = await veri.TekDegerAsync<string>("""
                select deger from public.enabiz_paket_alan
                 where paket_id = @p0 and uss_alan = 'HASTA_TAKIP_BILGISI/SYSTakipNo'
                """, [silme.PaketId]);
            Assert.Equal("TAKIP-TEST-9001", deger);

            // Eksik alan YOK: paket kuyruga girebilmeli (durum 0 degil).
            Assert.Empty(silme.Eksikler);
        }
        finally
        {
            await veri.CalistirAsync(
                "update public.belge_basvuru set sys_takip_no = '' where id = @p0",
                [belgeId]);
            if (silmeId is { } sid)
                await veri.CalistirAsync(
                    "delete from public.enabiz_paket where id = @p0", [sid]);
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [kabul!.PaketId]);
        }
    }

    [Fact]
    public async Task Hasta_tipi_KARTTAN_turetilir_liste_basindan_degil()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        // GERCEK VAKA (basvuru 1092): HASTA_TIPI sorgusu eslemeyi kosulsuz
        //   `limit 1` ile cekiyordu ve ERKEK hastaya "15-49 KADIN HASTALAR"
        //   yaziyordu - hem YANLIS LISTE hem rastgele deger.
        //
        // Dogrusu 609/610 ile netlesti: USS'nin istedigi liste SKRS'nin
        //   klinik "HASTA TIPI"si degil GP_HASTA_TIPI - VATANDAS_KAYIT /
        //   YABANCI_KAYIT / VATANSIZ / YENIDOGAN / KIMLIKSIZ. Bu hasta
        //   kartindan KESIN turetilir, o yuzden artik dolu gider ve
        //   `taraf_hasta.hasta_tipi` neyse ONU tasir.
        var belgeId = await veri.TekDegerAsync<int>("""
            select min(b.id) from public.belge b
              join public.belge_basvuru bb on bb.id = b.id
             where b.tur = 19 and bb.bolum_id is not null
            """);
        if (belgeId <= 0) return;

        var uretici = new Gentegre.Api.Servisler.EnabizPaketUretici(veri,
            Microsoft.Extensions.Logging.Abstractions
                     .NullLogger<Gentegre.Api.Servisler.EnabizPaketUretici>.Instance);
        var sonuc = await uretici.UretAsync("HASTA_KABUL", belgeId, 0, CancellationToken.None);
        Assert.NotNull(sonuc);
        try
        {
            var tip = await veri.TekAsync("""
                select a.deger, a.skrs_kod, a.skrs_sistem,
                       coalesce((select th.hasta_tipi::text from public.taraf_hasta th
                                  join public.belge b on b.taraf_id = th.id
                                 where b.id = @p1), '')
                  from public.enabiz_paket_alan a
                 where a.paket_id = @p0 and a.uss_alan like '%HASTA_TIPI'
                """, [sonuc!.PaketId, belgeId],
                o => new { Deger = o.GetString(0), Kod = o.GetString(1),
                           Sistem = o.GetString(2), Kart = o.GetString(3) });
            Assert.NotNull(tip);

            // Kod KARTTAKI degerin ta kendisi - liste basindan secilmis
            //   rastgele bir kod degil.
            Assert.Equal(tip!.Kart, tip.Kod);

            // ... ve GP_HASTA_TIPI listesinden, klinik "HASTA TIPI"nden degil.
            Assert.Equal("4f4fd85e-6f52-4c38-a302-6d5e3d6dc1c4", tip.Sistem);
            Assert.NotEqual("", tip.Deger);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [sonuc!.PaketId]);
        }
    }

    [Fact]
    public async Task Yeni_kayitta_SYSTakipNo_alani_BOS_ama_VAR_olur()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        // GERCEK VAKA (paket 132, canli USS): alan hic yazilmayinca USS
        //   "E1004 SYSTakipNo bos olamaz" dondu. Kilavuz: "Yeni kayit icin
        //   BOS, kayit guncelleme icin ... SYS Takip Numarasi" - yani alan
        //   ZORUNLU DEGIL ama EKSIK de olamaz. Bos alanlar normalde govdeye
        //   yazilmaz; SYSTakipNo bunun istisnasidir.
        var belgeId = await veri.TekDegerAsync<int>("""
            select min(b.id) from public.belge b
              join public.belge_basvuru bb on bb.id = b.id
             where b.tur = 19 and bb.bolum_id is not null
            """);
        if (belgeId <= 0) return;

        var uretici = new Gentegre.Api.Servisler.EnabizPaketUretici(veri,
            Microsoft.Extensions.Logging.Abstractions
                     .NullLogger<Gentegre.Api.Servisler.EnabizPaketUretici>.Instance);
        var sonuc = await uretici.UretAsync("HASTA_KABUL", belgeId, 0, CancellationToken.None);
        Assert.NotNull(sonuc);
        try
        {
            var xml = await XmlUretAsync(veri, sonuc!.PaketId);
            var kok = XElement.Parse(xml);
            var takip = kok.Element("recordData")!
                           .Element("HASTA_BASVURU_BILGILERI")!
                           .Element("SYSTakipNo");

            Assert.NotNull(takip);                       // alan VAR
            Assert.Equal("", takip!.Attribute("value")!.Value);  // degeri BOS

            // KODSUZ OLAN alanlar da yazilir - ama SKRS KODLU olanlar
            //   yazilmaz (asagidaki test). MHRS randevu numarasi duz bir
            //   alan: degeri bos, kendisi govdede.
            var mhrs = kok.Element("recordData")!
                          .Element("HASTA_BASVURU_BILGILERI")!
                          .Element("MHRS_RANDEVU_NUMARASI");
            Assert.NotNull(mhrs);
            Assert.Equal("", mhrs!.Attribute("value")!.Value);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [sonuc!.PaketId]);
        }
    }

    [Theory]
    [InlineData("E1004", "SYSTakipNo bos olamaz", false)]   // is hatasi
    [InlineData("S0000", "Islem Basari ile Sonuclandi.", true)]
    public void Sonuc_kodu_HTTP_200_icinde_basariyi_belirler(
        string kod, string mesaj, bool basariBekleniyor)
    {
        // USS is hatasini da HTTP 200 ile doner. Yalniz HTTP koduna bakmak,
        //   USS'ye HIC KAYDEDILMEMIS paketi "gonderildi" isaretliyordu
        //   (gercek vaka, paket 132). Olcu SONUC KODUDUR.
        var govde = $"""
            <SYSMessage><recordData><KayitCevabi>
              <sonucKodu value="{kod}" />
              <sonucMesaji value="{mesaj}" />
            </KayitCevabi></recordData></SYSMessage>
            """;
        var yontem = typeof(Gentegre.Api.Servisler.EnabizGonderimi).GetMethod(
            "SonucCoz", BindingFlags.NonPublic | BindingFlags.Static)!;
        var (cKod, cMesaj) = ((string, string))yontem.Invoke(null, [govde])!;

        Assert.Equal(kod, cKod);
        Assert.Equal(mesaj, cMesaj);
        Assert.Equal(basariBekleniyor, !cKod.StartsWith('E'));
    }

    [Fact]
    public void XML_bildirimiyle_baslayan_cevap_AYRISTIRILIR()
    {
        // GERCEK USS CEVABI (paket 156, canli). Govde `<?xml …?>` ile baslar;
        //   onu sarmalayicinin icine koyup ayristirmak XmlException atiyordu,
        //   hata catch'e dusup BOS sonuc donduruyor ve USS'nin REDDETTIGI
        //   paket "gonderildi" isaretleniyordu. Iki kez ayni sekilde kacti
        //   (E1004, sonra E0009) - bu yuzden testi gercek govdeyle yaziyorum.
        const string cevap = """
            <?xml version="1.0" encoding="utf-8" ?>
            <SYSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <messageType code="1" value="SYS Cevabı" version="1" />
                <recordData>
                <KayitCevabi>
                    <sonucKodu value="E0009"/>
                    <sonucMesaji value="Kurum kodu hatalı!"/>
                </KayitCevabi>
                </recordData>
            </SYSMessage>
            """;
        var yontem = typeof(Gentegre.Api.Servisler.EnabizGonderimi).GetMethod(
            "SonucCoz", BindingFlags.NonPublic | BindingFlags.Static)!;
        var (kod, mesaj) = ((string, string))yontem.Invoke(null, [cevap])!;

        Assert.Equal("E0009", kod);
        Assert.Equal("Kurum kodu hatalı!", mesaj);
        Assert.StartsWith("E", kod);   // yani BASARISIZ sayilmali
    }

    [Fact]
    public void Basarili_cevaptan_SYSTakipNo_okunur()
    {
        const string cevap = """
            <?xml version="1.0" encoding="utf-8" ?>
            <SYSMessage>
                <recordData><KayitCevabi>
                    <sonucKodu value="S0000"/>
                    <sonucMesaji value="İşlem Başarı ile Sonuçlandı."/>
                    <SYSTakipNo value="20260912-ABC123"/>
                </KayitCevabi></recordData>
            </SYSMessage>
            """;
        var kimlik = typeof(Gentegre.Api.Servisler.EnabizGonderimi).GetMethod(
            "UssKimlikCoz", BindingFlags.NonPublic | BindingFlags.Static)!;
        Assert.Equal("20260912-ABC123", (string)kimlik.Invoke(null, [cevap])!);
    }

    [Fact]
    public async Task SKRS_kodu_degisince_YENI_paket_uretilir()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        // GERCEK VAKA (paket 156): kurum kodu 11111111 -> 500154 duzeltildi ama
        //   alanin GORUNEN degeri ("e-Nabız / USS") degismedi. Parmak izi
        //   yalniz ad+deger'den hesaplandigi icin icerik "ayni" sayildi ve
        //   "ayni icerik -> ayni paket" korumasi REDDEDILMIS eski paketi
        //   dondurdu; duzeltme hic gonderilemedi. Kod da parmak izine girmeli.
        var belgeId = await veri.TekDegerAsync<int>("""
            select min(b.id) from public.belge b
              join public.belge_basvuru bb on bb.id = b.id
             where b.tur = 19 and bb.bolum_id is not null
            """);
        if (belgeId <= 0) return;

        var uretici = new Gentegre.Api.Servisler.EnabizPaketUretici(veri,
            Microsoft.Extensions.Logging.Abstractions
                     .NullLogger<Gentegre.Api.Servisler.EnabizPaketUretici>.Instance);

        var eskiKod = await veri.TekDegerAsync<string>(
            "select coalesce(kurum_kodu,'') from public.entegrasyon_hesap where kod='ENABIZ'");
        var ilk = await uretici.UretAsync("HASTA_KABUL", belgeId, 0, CancellationToken.None);
        Assert.NotNull(ilk);
        long? ikinciId = null;
        try
        {
            // Yalniz KODU degistir - gorunen ad ayni kalsin.
            await veri.CalistirAsync(
                "update public.entegrasyon_hesap set kurum_kodu = '999999' where kod='ENABIZ'");
            var ikinci = await uretici.UretAsync("HASTA_KABUL", belgeId, 0, CancellationToken.None);
            Assert.NotNull(ikinci);
            ikinciId = ikinci!.PaketId;

            Assert.NotEqual(ilk!.PaketId, ikinci.PaketId);
        }
        finally
        {
            await veri.CalistirAsync(
                "update public.entegrasyon_hesap set kurum_kodu = @p0 where kod='ENABIZ'",
                [eskiKod]);
            if (ikinciId is { } iid)
                await veri.CalistirAsync(
                    "delete from public.enabiz_paket where id = @p0", [iid]);
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [ilk!.PaketId]);
        }
    }

    [Fact]
    public async Task Kodu_olmayan_SKRS_alani_HIC_YAZILMAZ()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        // USS'nin kurali canli denemeyle netlesti: SKRS kod sistemine bagli
        //   eleman ya GECERLI KODLA gelir ya da HIC GELMEZ.
        //     · kodsuz/guid'siz  -> "E1011 ADRES_KODU_SEVIYESI xml elemani
        //       icin belirtilen Guid degeri gecerli degil"
        //     · guid var kod bos -> "E1008 Code '' ve value '' degerleriyle
        //       Guid '...' Kod Sisteminde bir tanimlama bulunmuyor"
        //     · eleman hic yok   -> KABUL
        //   Onceki beklenti "duz eleman olarak yazilsin" idi; gercek servis
        //   yanlis oldugunu gosterdi.
        var belgeId = await veri.TekDegerAsync<int>("""
            select min(b.id) from public.belge b
              join public.belge_basvuru bb on bb.id = b.id
             where b.tur = 19 and bb.bolum_id is not null
            """);
        if (belgeId <= 0) return;

        var uretici = new Gentegre.Api.Servisler.EnabizPaketUretici(veri,
            Microsoft.Extensions.Logging.Abstractions
                     .NullLogger<Gentegre.Api.Servisler.EnabizPaketUretici>.Instance);
        var sonuc = await uretici.UretAsync("HASTA_KABUL", belgeId, 0, CancellationToken.None);
        Assert.NotNull(sonuc);
        try
        {
            var kok = XElement.Parse(await XmlUretAsync(veri, sonuc!.PaketId));
            var kimlik = kok.Element("recordData")!.Element("HASTA_KIMLIK_BILGILERI")!;

            var basvuru = kok.Element("recordData")!
                             .Element("HASTA_BASVURU_BILGILERI")!;

            // Kodu olmayan SKRS alani: eleman HIC YOK. TRIAJ kodlu bir
            //   alandir ve ayakta basvuruda triaj verilmez.
            Assert.Null(basvuru.Element("TRIAJ"));

            // Kodu OLAN alan kodlu gider (cinsiyet).
            var cinsiyet = kimlik.Element("CINSIYET")!;
            Assert.NotNull(cinsiyet.Attribute("codeSystemGuid"));
            Assert.NotEqual("", cinsiyet.Attribute("code")!.Value);

            // Kod sistemine bagli OLMAYAN bos alan yazilmaya devam eder.
            Assert.NotNull(basvuru.Element("MHRS_RANDEVU_NUMARASI"));
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [sonuc!.PaketId]);
        }
    }

    [Fact]
    public async Task Islem_paketinde_HER_KALEM_AYRI_grup_olur()
    {
        if (!_olgu.Baglandi(nameof(EnabizXmlTestleri))) return;
        var veri = _olgu.Gerekli();

        // 102'de ISLEM_BILGISI TEKRARLI bir gruptur - her belge kalemi biri.
        //   Govde yazicisi ara dugumleri ADINA gore birlestiriyordu (ayni
        //   veri setinin alanlari dagilmasin diye); tekrarli grupta bu,
        //   butun kalemleri TEK grubun icine yigardi ve USS tek islem
        //   gorurdu. Yol parcasindaki `[n]` indeksi ayirt edicidir ve
        //   XML'e YAZILMAZ.
        var belgeId = await veri.TekDegerAsync<int>("""
            select min(b.id) from public.belge b
              join public.belge_basvuru bb on bb.id = b.id
             where (select count(*) from public.belge_satir s
                     where s.belge_id = b.id) >= 2
            """);
        if (belgeId <= 0) return;

        var uretici = new Gentegre.Api.Servisler.EnabizPaketUretici(veri,
            Microsoft.Extensions.Logging.Abstractions
                     .NullLogger<Gentegre.Api.Servisler.EnabizPaketUretici>.Instance);
        var sonuc = await uretici.UretAsync("HASTA_ISLEM", belgeId, 0, CancellationToken.None);
        Assert.NotNull(sonuc);
        try
        {
            var kok = XElement.Parse(await XmlUretAsync(veri, sonuc!.PaketId));
            var islemler = kok.Element("recordData")!
                              .Element("HASTA_ISLEM_BILGILERI")!
                              .Elements("ISLEM_BILGISI").ToList();

            // Kalem sayisi kadar grup - hepsi tek grupta toplanmis DEGIL.
            var kalem = await veri.TekDegerAsync<int>(
                "select count(*) from public.belge_satir where belge_id = @p0", [belgeId]);
            Assert.Equal(kalem, islemler.Count);

            // Her grup KENDI referans numarasini tasir: kalemler karismamis.
            var referanslar = islemler
                .Select(i => i.Element("ISLEM_REFERANS_NUMARASI")?.Attribute("value")?.Value)
                .Where(v => !string.IsNullOrEmpty(v))
                .Distinct().Count();
            Assert.Equal(kalem, referanslar);

            // Gruplama isareti govdede KALMAZ - USS semasinda boyle bir
            //   oznitelik yok, kalirsa paket reddedilirdi.
            Assert.DoesNotContain("__ix", kok.ToString(), StringComparison.Ordinal);
        }
        finally
        {
            await veri.CalistirAsync(
                "delete from public.enabiz_paket where id = @p0", [sonuc!.PaketId]);
        }
    }
}
