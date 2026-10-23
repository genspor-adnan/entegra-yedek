using System.Text.Json;
using Gentegre.Api.Servisler;
using Gentegre.Api.Uclar;

namespace Gentegre.Testler;

/// <summary>
/// GARANTİ BBVA yanıt çözümü (1157) - Banka/api.json'daki GERÇEK yanıt örneğiyle: gösterge alanı
/// <c>txnCreditDebitIndicator</c> (A giriş / B çıkış), zenginleştirme <c>{enrichmentCode, enrichmentValue}</c>.
/// Örnek sunucunun ürettiği veri de aynı çeviriciden geçer - iki taraf ayrışırsa test yakalar. Veritabanı gerekmez.
/// </summary>
public sealed class GarantiCeviriciTestleri
{
    // Banka/api.json 200 örneği, 1. hareket (DURU LTD, alacak) - birebir.
    private const string GelenOrnek = """
        {"customerNum":45245447,"customerName":"DURU LTD ","VKN":1194136989,"TCKN":null,
         "productId":"9d5de526-e32c-5cc7-81ce-545b93ade759","unitNum":295,"accountNum":6291296,"currencyCode":"TL",
         "IBAN":"TR620006200029500006291296","activityDate":"2020-12-25","valueDate":"2020-12-28",
         "txnCreditDebitIndicator":"A","amount":1250.67,"balanceAfterTransaction":9836180.2,"explanation":"00000",
         "transactionId":"WPDT","clasificationCode":"NDTS","corrVKN":"1518410029","corrTCKN":null,"corrCustomerNum":45271413,
         "transactionReferenceId":"2020-12-25T16:13:36.688516","transactionInstanceId":"2020-12-25T16:13:36.862988",
         "enrichmentInformation":[
           {"enrichmentCode":"CORRACNT","enrichmentValue":{"moduleName":"CORRACNT","productType":"Account","corrAccountNum":"6287369","corrUnitNum":"295","corrIBAN":"TR700006200029500006287369"}},
           {"enrichmentCode":"MUS","enrichmentValue":{"moduleName":"MUS","nameSurnameText":"DURU LTD ","corrNameSurnameText":"DURU LTD "}},
           {"enrichmentCode":"HES","enrichmentValue":{"moduleName":"HES","accountMainType":"M","accSubType":"S","accType":"A","productCode":"VDSTDUI","subProductCode":""}},
           {"enrichmentCode":"DTS","enrichmentValue":{"moduleName":"DTS","firmOriginalText":"","relatedInvText1":"FAT2026000000123"}},
           {"enrichmentCode":"DEK","enrichmentValue":{"moduleName":"DEK","detailText":""}}]}
        """;

    // api.json 7. hareket: giden EFT - karşı ad / IBAN yalnız EFT zenginleştirmesinde (MUS yok).
    private const string GidenEft = """
        {"activityDate":"2020-12-25","valueDate":"2020-12-25","txnCreditDebitIndicator":"B","amount":560.7,
         "balanceAfterTransaction":9835061.14,"explanation":"Para Transferi ELMP-EFT                             - 0140008",
         "transactionId":"ELMP","clasificationCode":"NTHE","corrVKN":null,"corrTCKN":null,
         "transactionReferenceId":"2020-12-25T14:15:14.008745","transactionInstanceId":"2020-12-25T14:15:14.440521",
         "enrichmentInformation":[
           {"enrichmentCode":"THE","enrichmentValue":{"moduleName":"THE","firmOriginalText1":"202012061215036","txnId":"","ustrId":""}},
           {"enrichmentCode":"EFT","enrichmentValue":{"moduleName":"EFT","corrBankNum":"46","msgType":"KRED",
             "senderIBANEFT":"TR620006200029500006291296","receiverIBANEFT":"TR470004600036888000060447",
             "senderName":"DURU LTD","receiverName":" HAN LTD ","remark":"TRANSFER ELMP-EFT","senderVKN":"1194136989"}},
           {"enrichmentCode":"DEK","enrichmentValue":{"moduleName":"DEK","detailText":""}}]}
        """;

    private static BankaHareketSatiri Coz(string json)
    {
        using var j = JsonDocument.Parse(json);
        return GarantiCevirici.Satir(j.RootElement);
    }

    [Fact]
    public void Gelen_hareket_arti_isaretli_ve_zenginlestirme_cozulur()
    {
        var h = Coz(GelenOrnek);
        Assert.Equal(1250.67m, h.Tutar);
        Assert.Equal(9836180.2m, h.Bakiye);
        Assert.Equal("TR700006200029500006287369", h.KarsiIban);
        Assert.Equal("DURU LTD", h.KarsiAd);
        Assert.Equal("1518410029", h.KarsiVkn);
        Assert.Equal("FAT2026000000123", h.Fatura);
        Assert.Equal("NDTS", h.Sinif);
        Assert.Equal("TL", h.Doviz);
        Assert.Equal(new DateTime(2020, 12, 28), h.Valor);
        // Gün hassasiyetli tarih + oluşturma anından saat.
        Assert.Equal(new DateTime(2020, 12, 25, 16, 13, 36, 862), h.Tarih.AddTicks(-(h.Tarih.Ticks % TimeSpan.TicksPerMillisecond)));
        Assert.Equal("2020-12-25T16:13:36.688516|2020-12-25T16:13:36.862988", h.IslemNo);
    }

    [Fact]
    public void Giden_eft_eksi_isaretli_karsi_taraf_eft_kalemenden()
    {
        var h = Coz(GidenEft);
        Assert.Equal(-560.7m, h.Tutar);
        Assert.Equal("HAN LTD", h.KarsiAd);
        Assert.Equal("TR470004600036888000060447", h.KarsiIban);
        Assert.Equal("", h.KarsiVkn);
    }

    [Fact]
    public void Semadaki_eski_gosterge_adi_ve_duz_zenginlestirme_de_okunur()
    {
        var h = Coz("""
            {"activityDate":"2026-10-23","txtnCreditDebitIndicator":"D","amount":"100,5","explanation":"x",
             "transactionReferenceId":"R1","enrichmentInformation":{"moduleName":"CORRACNT","corrIBAN":"TR33 0006 1005 1978 6457 8413 26"}}
            """);
        Assert.Equal(-1005m, h.Tutar);   // InvariantCulture: virgül binlik ayracı - banka nokta gönderir
        Assert.Equal("TR330006100519786457841326", h.KarsiIban);
        Assert.Equal("R1", h.IslemNo);
        Assert.Null(h.Bakiye);
    }

    [Fact]
    public void Ayni_referans_iki_harekette_tekil_numara_olusturma_aniyla_ayrilir()
    {
        var a = Coz("""{"activityDate":"2020-12-25","txnCreditDebitIndicator":"B","amount":0.92,"transactionReferenceId":"2020-12-25T14:19:39.629065","transactionInstanceId":"2020-12-25T14:19:40.56661"}""");
        var b = Coz("""{"activityDate":"2020-12-25","txnCreditDebitIndicator":"B","amount":92.14,"transactionReferenceId":"2020-12-25T14:19:39.629065","transactionInstanceId":"2020-12-25T14:19:40.450429"}""");
        Assert.NotEqual(a.IslemNo, b.IslemNo);
        Assert.True(a.IslemNo.Length <= 80 && b.IslemNo.Length <= 80);
    }

    [Fact]
    public void Ornek_sunucu_verisi_ceviriciden_tutarli_gecer()
    {
        var o = new GarantiOrnekVerisi.Taraflar("Aloe Plant Ltd", "0550459827", "TR330006100519786457841326", "GNY2026000000010",
                                                "Tedarikçi AŞ", "1234567890", "Kuveyt TL", "TR680020500009549234600002");
        var bas = new DateTime(2026, 10, 21); var bit = new DateTime(2026, 10, 23, 23, 59, 59);
        var govde = new System.Text.Json.Nodes.JsonObject
        {
            ["result"] = new System.Text.Json.Nodes.JsonObject { ["returnCode"] = 200 },
            ["transactions"] = new System.Text.Json.Nodes.JsonArray(
                GarantiOrnekVerisi.Uret("TR620006200029500006291296", "295", "6291296", bas, bit, o)
                    .Select(x => (System.Text.Json.Nodes.JsonNode)x).ToArray()),
        };
        using var j = JsonDocument.Parse(govde.ToJsonString());
        var liste = GarantiCevirici.Liste(j.RootElement);

        Assert.Equal(3 * 7, liste.Count);
        Assert.Equal(liste.Count, liste.Select(x => x.IslemNo).Distinct().Count());
        Assert.All(liste, x => Assert.Equal("TL", x.Doviz));
        Assert.All(liste, x => Assert.True(x.Tarih >= bas && x.Tarih <= bit));

        var fast = liste.First(x => x.Aciklama.StartsWith("FAST GELEN"));
        Assert.Equal(4800m, fast.Tutar);
        Assert.Equal("TR330006100519786457841326", fast.KarsiIban);
        Assert.Equal("Aloe Plant Ltd", fast.KarsiAd);
        Assert.Equal("0550459827", fast.KarsiVkn);

        var fatura = liste.First(x => x.Aciklama.StartsWith("HAVALE GELEN FATURA"));
        Assert.Contains("GNY2026000000010", fatura.Aciklama);
        Assert.Equal("GNY2026000000010", fatura.Fatura);
        Assert.Equal("", fatura.KarsiIban);   // öneri fatura kuralına düşsün diye IBAN'sız

        var virman = liste.First(x => x.Aciklama == "HESAPLAR ARASI VIRMAN");
        Assert.Equal(-20000m, virman.Tutar);
        Assert.Equal("TR680020500009549234600002", virman.KarsiIban);

        var pos = liste.First(x => x.Aciklama.StartsWith("POS GUN SONU"));
        Assert.Equal(984m, pos.Tutar);
        Assert.Contains("UYE ISYERI 41203388", pos.Aciklama);   // DEK detayı açıklamaya eklenir

        // Yürüyen bakiye: her satırın bakiyesi önceki + tutar.
        var sirali = liste.OrderBy(x => x.Tarih).ToList();
        for (var i = 1; i < sirali.Count; i++)
            Assert.Equal(sirali[i - 1].Bakiye + sirali[i].Tutar, sirali[i].Bakiye);
    }

    [Fact]
    public void Ornek_sunucu_araligi_92_gunle_sinirlar_ve_ters_aralikta_bos_doner()
    {
        var o = new GarantiOrnekVerisi.Taraflar("M", "", "", "", "T", "", "", "");
        Assert.Empty(GarantiOrnekVerisi.Uret("TR1", "1", "1", new DateTime(2026, 10, 23), new DateTime(2026, 10, 22), o));
        var uzun = GarantiOrnekVerisi.Uret("TR1", "1", "1", new DateTime(2026, 1, 1), new DateTime(2026, 10, 23), o);
        Assert.Equal(93 * 7, uzun.Count);
    }
}
