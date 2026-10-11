using System.Text.Json.Nodes;
using System.Xml.Linq;
using Gentegre.Api.Servisler.EFatura;
using Xunit;

namespace Gentegre.Testler;

/// <summary>
/// GİDEN e-FATURA GÖVDESİ (1033, Delphi _IzibizJSONOlustur) - fatura tiplerine
/// göre izibiz JSON'u ve UBL. Veritabanı gerekmez: veri elle kurulur.
/// </summary>
public class EFaturaGovdeTestleri
{
    private static readonly EFaturaTaraf Biz = new("Demo Hastanesi A.Ş.", "4840847211", "Çankaya", "Örnek Cad. 1",
        "Çankaya", "Ankara", "", "06510", "info@demo.test", "0312 000 00 00", Mersis: "0123456789000015");
    private static readonly EFaturaTaraf Kisi = new("Ali Veli Aydın", "11111111110", "", "Adres", "Kadıköy", "İstanbul", "", "", "ali@ornek.test", "");
    private static readonly EFaturaTaraf Firma = new("Alıcı Ltd.", "1234567890", "Kozyatağı", "Adres", "Kadıköy", "İstanbul", "", "", "", "");

    private static EFaturaVerisi Veri(int tipi = 1, int senaryo = 1, short eTur = EFaturaKodlari.TurEFatura,
        EFaturaTaraf? alici = null, string para = "TRY", decimal kur = 0, int istisna = 0, decimal navlun = 0,
        string sgkTip = "", string iban = "")
    {
        var v = new EFaturaVerisi
        {
            Id = 1, Tur = 15, Tipi = tipi, Senaryo = senaryo, Durum = 3, TarafId = 5, BelgeNo = "GNY2026000000010",
            Tarih = new DateTime(2026, 10, 11, 14, 30, 0), ParaKodu = para, Kur = kur,
            Gonderici = Biz, Alici = alici ?? Firma, IstisnaKodu = istisna, Navlun = navlun,
            SgkTip = sgkTip, SgkMukellefKod = sgkTip.Length > 0 ? "M1" : "", SgkMukellefAd = sgkTip.Length > 0 ? "Mükellef" : "",
            SgkDosyaNo = sgkTip.Length > 0 ? "D1" : "", SgkDonemBas = new DateTime(2026, 9, 1), SgkDonemBit = new DateTime(2026, 9, 30),
            KamuIban = iban, BelgeKdv = 0, BelgeToplam = 0,
        };
        v.ETur = eTur; v.EBelgeNo = "GNY2026000000010"; v.Uuid = "11111111-2222-3333-4444-555555555555";
        return v;
    }

    private static EFaturaSatiri Satir(int no, decimal miktar, decimal fiyat, decimal net, int kdv, int istisna = 0,
                                       string tevKod = "", decimal tevOran = 0)
    {
        var k = Math.Round(net * kdv / 100m, 2, MidpointRounding.AwayFromZero);
        return new EFaturaSatiri
        {
            Id = no, No = no, Ad = $"Kalem {no}", Miktar = miktar, Fiyat = fiyat, Brut = Math.Round(miktar * fiyat, 2),
            Net = net, KdvOran = kdv, Kdv = k, IstisnaKodu = istisna, IstisnaAdi = istisna > 0 ? $"{istisna} - neden" : "",
            TevkifatKodu = tevKod, TevkifatAdi = tevKod.Length > 0 ? $"{tevKod} - Hizmet ({tevOran / 10}/10)" : "",
            TevkifatOran = tevOran, Tevkifat = Math.Round(k * tevOran / 100m, 2),
            Gtip = "300490000019", TeslimSarti = "FOB", TasimaSekli = 4, KapCinsi = "BX", KapNo = "1", KapAdet = 2,
        };
    }

    private static JsonObject Govde(EFaturaVerisi v) { v.Hesapla(); return IzibizGovde.Uret(v, ["not"], "<xsl/>"); }
    private static JsonObject Icerik(JsonObject g) => g["content"]!.AsObject();
    private static decimal D(JsonNode? n) => n!.GetValue<decimal>();

    [Fact]
    public void Satis_iskontolu_toplamlar_Delphi_kurali()
    {
        var v = Veri();
        v.Satirlar.Add(Satir(1, 2, 100, 170, 20));      // brüt 200, %15 iskonto
        v.Satirlar.Add(Satir(2, 1, 50, 50, 10));
        var c = Icerik(Govde(v));

        Assert.Equal("TEMELFATURA", (string?)c["profile"]);
        Assert.Equal("SATIS", (string?)c["documentTypeCode"]);
        var t = c["legalMonetaryTotal"]!;
        Assert.Equal(250m, D(t["lineExtensionAmount"]));          // brüt
        Assert.Equal(220m, D(t["taxExclusiveAmount"]));           // net
        Assert.Equal(30m, D(t["allowanceTotalAmount"]));
        Assert.Equal(220m + 34m + 5m, D(t["payableAmount"]));
        var isk = c["lines"]![0]!["allowanceCharge"]![0]!;
        Assert.Equal(0.15m, D(isk["multiplierFactorNumeric"]));  // KESİR
        Assert.Equal(2, c["taxTotal"]!["taxSubTotal"]!.AsArray().Count);
    }

    [Fact]
    public void Tevkifat_matrahi_KDV_tutari_ve_odenecekten_duser()
    {
        var v = Veri(tipi: 22);
        v.Satirlar.Add(Satir(1, 1, 1000, 1000, 20, tevKod: "602", tevOran: 90));
        var c = Icerik(Govde(v));

        Assert.Equal("TEVKIFAT", (string?)c["documentTypeCode"]);
        var w = c["withHoldingTax"]!;
        Assert.Equal(180m, D(w["taxAmount"]));
        Assert.Equal(200m, D(w["taxSubTotal"]![0]!["taxableAmount"]));   // KDV tutarı, net değil
        Assert.Equal(90, w["taxSubTotal"]![0]!["percent"]!.GetValue<int>());
        Assert.Equal("602", (string?)w["taxSubTotal"]![0]!["taxScheme"]!["typeCode"]);
        Assert.NotNull(c["lines"]![0]!["withholdingTaxTotal"]);
        Assert.Equal(1000m + 200m - 180m, D(c["legalMonetaryTotal"]!["payableAmount"]));
        Assert.Empty(v.Eksikler());
    }

    [Fact]
    public void KDV_istisna_kodu_ve_nedeni_yazilir_kodsuz_ise_eksik()
    {
        var v = Veri(tipi: 24, istisna: 0);
        v.Satirlar.Add(Satir(1, 1, 500, 500, 0));
        v.Hesapla();
        Assert.Contains(v.Eksikler(), e => e.Contains("istisna", StringComparison.OrdinalIgnoreCase));

        var v2 = Veri(tipi: 24, istisna: 325);
        v2.Satirlar.Add(Satir(1, 1, 500, 500, 0, istisna: 325));
        var c = Icerik(Govde(v2));
        Assert.Equal("ISTISNA", (string?)c["documentTypeCode"]);
        var alt = c["taxTotal"]!["taxSubTotal"]![0]!;
        Assert.Equal("325", (string?)alt["taxExemptionCode"]);
        Assert.Equal("325 - neden", (string?)alt["taxExemptionReason"]);
        Assert.Empty(v2.Eksikler());
    }

    [Fact]
    public void Ihrac_kayitli_odenecek_yalniz_net()
    {
        var v = Veri(tipi: 9, istisna: 701);
        v.Satirlar.Add(Satir(1, 1, 1000, 1000, 20, istisna: 701));
        var c = Icerik(Govde(v));
        Assert.Equal("IHRACKAYITLI", (string?)c["documentTypeCode"]);
        Assert.Equal(1000m, D(c["legalMonetaryTotal"]!["payableAmount"]));
        Assert.Equal("701", (string?)c["taxTotal"]!["taxSubTotal"]![0]!["taxExemptionCode"]);
    }

    [Fact]
    public void Ihracat_alici_gumruk_gercek_alici_buyerCustomerParty()
    {
        var v = Veri(senaryo: 3, navlun: 75);
        v.Satirlar.Add(Satir(1, 2, 100, 200, 0, istisna: 301));
        var g = Govde(v);
        var c = Icerik(g);
        Assert.Equal("IHRACAT", (string?)c["profile"]);
        Assert.Equal("ISTISNA", (string?)c["documentTypeCode"]);
        Assert.Equal("1460415308", (string?)c["customerParty"]!["identifier"]);
        Assert.Equal("EXPORT", (string?)c["buyerCustomerParty"]!["partyType"]);
        Assert.Null(g["receiverAlias"]);
        var d = c["lines"]![0]!["delivery"]!;
        Assert.Equal("FOB", (string?)d["deliveryTerms"]!["id"]);
        Assert.Equal("300490000019", (string?)d["shipment"]!["goodsItems"]![0]!["requiredCustomsID"]);
        Assert.Equal(75m, D(c["delivery"]![0]!["shipment"]!["declaredForCarriageValueAmount"]));
        Assert.Empty(v.Eksikler());
    }

    [Fact]
    public void Iade_billingReference_zorunlu()
    {
        var v = Veri(tipi: 2);
        v.Satirlar.Add(Satir(1, 1, 100, 100, 20));
        v.Hesapla();
        Assert.Contains(v.Eksikler(), e => e.Contains("İade", StringComparison.Ordinal));
        v.IadeReferanslari.Add(("GNY2026000000003", new DateTime(2026, 9, 1)));
        var c = Icerik(Govde(v));
        Assert.Equal("IADE", (string?)c["documentTypeCode"]);
        Assert.Equal("GNY2026000000003", (string?)c["billingReference"]![0]!["id"]);
        Assert.Equal("IADE", (string?)c["billingReference"]![0]!["documentTypeCode"]);
    }

    [Fact]
    public void EArsiv_tckn_ad_soyad_ve_eposta()
    {
        var v = Veri(eTur: EFaturaKodlari.TurEArsiv, alici: Kisi);
        v.AliciAlias = "ali@ornek.test";
        v.Satirlar.Add(Satir(1, 1, 100, 100, 10));
        var g = Govde(v);
        var c = Icerik(g);
        Assert.Equal("EARSIVFATURA", (string?)c["profile"]);
        Assert.Equal("TCKN", (string?)c["customerParty"]!["schemeId"]);
        Assert.Equal("Ali Veli", (string?)c["customerParty"]!["firstName"]);
        Assert.Equal("Aydın", (string?)c["customerParty"]!["lastName"]);
        Assert.True(g["mailFlag"]!.GetValue<bool>());
        Assert.Equal("ELEKTRONIK", (string?)c["additionalReferences"]![0]!["documentType"]);
    }

    [Fact]
    public void Dovizli_pricingExchangeRate()
    {
        var v = Veri(para: "EUR", kur: 36.5m);
        v.Satirlar.Add(Satir(1, 1, 100, 100, 20));
        var c = Icerik(Govde(v));
        Assert.Equal("EUR", (string?)c["currencyCode"]);
        Assert.Equal(36.5m, D(c["pricingExchangeRate"]!["calculationRate"]));
        var bos = Veri(para: "USD", kur: 0);
        bos.Satirlar.Add(Satir(1, 1, 100, 100, 20));
        bos.Hesapla();
        Assert.Contains(bos.Eksikler(), e => e.Contains("kur", StringComparison.OrdinalIgnoreCase));
    }

    [Fact]
    public void SGK_ve_Kamu_alanlari()
    {
        var s = Veri(tipi: 25, sgkTip: "SAGLIK_HAS");
        s.Satirlar.Add(Satir(1, 1, 100, 100, 10));
        var c = Icerik(Govde(s));
        Assert.Equal("SGK", (string?)c["documentTypeCode"]);
        Assert.Equal("SAGLIK_HAS", (string?)c["accountingCost"]);
        Assert.Equal("2026-09-01", (string?)c["invoicePeriod"]!["startDate"]);
        Assert.Contains(c["additionalReferences"]!.AsArray(), r => (string?)r!["documentTypeCode"] == "DOSYA_NO");

        var k = Veri(senaryo: 7, iban: "TR300006200047600006295332");
        k.Satirlar.Add(Satir(1, 1, 100, 100, 20));
        var ck = Icerik(Govde(k));
        Assert.Equal("KAMU", (string?)ck["profile"]);
        Assert.Equal("46", (string?)ck["paymentMeans"]![0]!["paymentCode"]);
        Assert.Empty(k.Eksikler());
        Assert.False(EFaturaVerisi.IbanGecerli("TR300006200047600006295333"));
    }

    [Fact]
    public void UBL_ayni_rakamlari_tasir()
    {
        var v = Veri(tipi: 22);
        v.Satirlar.Add(Satir(1, 1, 1000, 1000, 20, tevKod: "602", tevOran: 90));
        v.Hesapla();
        var x = XDocument.Parse(UblUretici.Uret(v, ["not"], "<xsl/>"));
        XNamespace cbc = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2";
        Assert.Equal("TEVKIFAT", x.Descendants(cbc + "InvoiceTypeCode").Single().Value);
        Assert.Equal("1020.00", x.Descendants(cbc + "PayableAmount").Single().Value);
        Assert.Equal("GNY2026000000010", x.Root!.Element(cbc + "ID")!.Value);
    }

    [Fact]
    public void Menu_kurallari_Delphi_ile_ayni()
    {
        Assert.Null(EFaturaKodlari.Engel("ebelge.hazirla", 15, 3, 0));
        Assert.NotNull(EFaturaKodlari.Engel("ebelge.gonder", 15, 3, 0));      // hazırlanmadan gönderilmez
        Assert.Null(EFaturaKodlari.Engel("ebelge.gonder", 15, 3, 11));
        Assert.NotNull(EFaturaKodlari.Engel("ebelge.sifirla", 15, 3, 2));     // gönderilmiş geri alınmaz
        Assert.Null(EFaturaKodlari.Engel("ebelge.seri", 15, 3, 0));           // Delphi: ikinci seriyle hazırla
        Assert.NotNull(EFaturaKodlari.Engel("ebelge.pdf", 15, 3, 0));
        Assert.NotNull(EFaturaKodlari.Engel("ebelge.hazirla", 16, 3, 0));     // fiş e-Fatura değil
        Assert.Equal("BinİkiYüzElliTL ElliKr", TutarYazi.Yaz(1250.50m, "TRY"));
    }
}
