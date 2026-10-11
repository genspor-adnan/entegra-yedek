using System.Globalization;
using System.Text;
using System.Xml;
using System.Xml.Linq;

namespace Gentegre.Api.Servisler.EFatura;

/// <summary>
/// UBL-TR 1.2 FATURA - Delphi <c>UBLXMLUret</c> karşılığı. GİB'e GİDEN değil
/// (izibiz JSON alır, UBL'i kendisi kurar); önizleme, HTML / PDF ve "XML
/// Kaydet" için. Rakamlar <see cref="EFaturaVerisi"/>'nden - JSON ile aynı.
/// XSLT gömülü (AdditionalDocumentReference) - GİB görüntüleyicisi böyle açar.
/// </summary>
public static class UblUretici
{
    private static readonly XNamespace Inv = "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2";
    private static readonly XNamespace Cac = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2";
    private static readonly XNamespace Cbc = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2";
    private static readonly XNamespace Ext = "urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2";
    private static readonly CultureInfo C = CultureInfo.InvariantCulture;

    public static string Uret(EFaturaVerisi v, IReadOnlyList<string> notlar, string xslt)
    {
        if (v.Irsaliye) return Irsaliye(v, notlar, xslt);
        var para = v.ParaKodu;
        XElement T(string ad, decimal d) => new(Cbc + ad, new XAttribute("currencyID", para), d.ToString("0.00", C));
        XElement B(string ad, object? d) => new(Cbc + ad, d);
        var tarih = v.Tarih.ToString("yyyy-MM-dd", C);

        var kok = new XElement(Inv + "Invoice",
            new XAttribute(XNamespace.Xmlns + "cac", Cac), new XAttribute(XNamespace.Xmlns + "cbc", Cbc),
            new XAttribute(XNamespace.Xmlns + "ext", Ext),
            new XElement(Ext + "UBLExtensions", new XElement(Ext + "UBLExtension", new XElement(Ext + "ExtensionContent"))),
            B("UBLVersionID", "2.1"), B("CustomizationID", "TR1.2"), B("ProfileID", v.Profil),
            B("ID", v.EBelgeNo), B("CopyIndicator", "false"), B("UUID", v.Uuid),
            B("IssueDate", tarih), B("IssueTime", v.Tarih.ToString("HH:mm:ss", C)),
            B("InvoiceTypeCode", v.FaturaTipi),
            notlar.Select(n => B("Note", n)),
            B("DocumentCurrencyCode", para),
            v.Tipi == 25 ? B("AccountingCost", v.SgkTip) : null,
            B("LineCountNumeric", v.Satirlar.Count));

        if (v.Tipi == 25)
            kok.Add(new XElement(Cac + "InvoicePeriod",
                B("StartDate", v.SgkDonemBas?.ToString("yyyy-MM-dd", C)), B("EndDate", v.SgkDonemBit?.ToString("yyyy-MM-dd", C))));
        if (v.SiparisReferanslari.Count > 0)
            kok.Add(new XElement(Cac + "OrderReference", B("ID", v.SiparisReferanslari[0].No),
                                 B("IssueDate", v.SiparisReferanslari[0].Tarih.ToString("yyyy-MM-dd", C))));
        foreach (var r in v.IadeReferanslari.GroupBy(r => r.No).Select(g => g.First()))
            kok.Add(new XElement(Cac + "BillingReference", new XElement(Cac + "InvoiceDocumentReference",
                B("ID", r.No), B("IssueDate", r.Tarih.ToString("yyyy-MM-dd", C)),
                B("DocumentTypeCode", "IADE"), B("DocumentType", "İade Edilen Fatura"))));
        if (v.IrsaliyeNo.Length > 0)
            kok.Add(new XElement(Cac + "DespatchDocumentReference", B("ID", v.IrsaliyeNo),
                                 B("IssueDate", (v.IrsaliyeTarihi ?? v.Tarih).ToString("yyyy-MM-dd", C))));
        if (v.Tipi == 25)
            foreach (var (kod, deger) in new[] { ("MUKELLEF_KODU", v.SgkMukellefKod), ("MUKELLEF_ADI", v.SgkMukellefAd), ("DOSYA_NO", v.SgkDosyaNo) })
                kok.Add(new XElement(Cac + "AdditionalDocumentReference", B("ID", deger), B("IssueDate", tarih), B("DocumentTypeCode", kod)));
        if (v.Arsiv)
            kok.Add(new XElement(Cac + "AdditionalDocumentReference", B("ID", "1"), B("IssueDate", tarih),
                B("DocumentTypeCode", "SendingType"),
                B("DocumentType", IzibizGovde.Mailler(v.AliciAlias).Count > 0 ? "ELEKTRONIK" : "KAGIT")));
        if (xslt.Length > 0)
            kok.Add(new XElement(Cac + "AdditionalDocumentReference", B("ID", v.Uuid), B("IssueDate", tarih),
                B("DocumentType", "XSLT"),
                new XElement(Cac + "Attachment", new XElement(Cbc + "EmbeddedDocumentBinaryObject",
                    new XAttribute("characterSetCode", "UTF-8"), new XAttribute("encodingCode", "Base64"),
                    new XAttribute("filename", v.EBelgeNo + ".xslt"), new XAttribute("mimeCode", "application/xml"),
                    Convert.ToBase64String(Encoding.UTF8.GetBytes(xslt))))));

        kok.Add(new XElement(Cac + "Signature",
            new XElement(Cbc + "ID", new XAttribute("schemeID", "VKN_TCKN"), EFaturaKodlari.Rakam(v.Gonderici.Vkno)),
            new XElement(Cac + "SignatoryParty", Parti(v.Gonderici, false).Elements()),
            new XElement(Cac + "DigitalSignatureAttachment", new XElement(Cac + "ExternalReference", B("URI", "#Signature")))));

        kok.Add(new XElement(Cac + "AccountingSupplierParty", Parti(v.Gonderici, true)));
        if (v.Profil == "IHRACAT")
        {
            kok.Add(new XElement(Cac + "AccountingCustomerParty", new XElement(Cac + "Party",
                new XElement(Cac + "PartyIdentification", new XElement(Cbc + "ID", new XAttribute("schemeID", "VKN"), "1460415308")),
                new XElement(Cac + "PartyName", B("Name", "Gümrük ve Ticaret Bakanlığı Gümrükler Genel Müdürlüğü- Bilgi İşlem Dairesi Başkanlığı")),
                new XElement(Cac + "PostalAddress", B("CitySubdivisionName", "Ulus"), B("CityName", "Ankara"),
                    new XElement(Cac + "Country", B("Name", "Türkiye"))),
                new XElement(Cac + "PartyTaxScheme", new XElement(Cac + "TaxScheme", B("Name", "Ulus"))))));
            var alici = Parti(v.Alici, false);
            alici.AddFirst(new XElement(Cac + "PartyIdentification", new XElement(Cbc + "ID", new XAttribute("schemeID", "PARTYTYPE"), "EXPORT")));
            kok.Add(new XElement(Cac + "BuyerCustomerParty", alici));
        }
        else
        {
            kok.Add(new XElement(Cac + "AccountingCustomerParty", Parti(v.Alici, false, v.Arsiv ? IzibizGovde.Mailler(v.AliciAlias).FirstOrDefault() : null)));
            if (v.Profil == "KAMU")
                kok.Add(new XElement(Cac + "BuyerCustomerParty", Parti(v.Alici, false)));
        }

        if (v.Navlun > 0 || v.Sigorta > 0)
            kok.Add(new XElement(Cac + "Delivery", new XElement(Cac + "Shipment", B("ID", ""),
                T("InsuranceValueAmount", v.Sigorta), T("DeclaredForCarriageValueAmount", v.Navlun))));
        if (v.Profil == "KAMU")
            kok.Add(new XElement(Cac + "PaymentMeans", B("PaymentMeansCode", "42"),
                new XElement(Cac + "PayeeFinancialAccount", B("ID", v.KamuIban), B("CurrencyCode", para),
                    B("PaymentNote", v.Gonderici.Unvan))));
        if (v.Dovizli)
            kok.Add(new XElement(Cac + "PricingExchangeRate", B("SourceCurrencyCode", para), B("TargetCurrencyCode", "TRY"),
                B("CalculationRate", v.Kur.ToString("0.######", C)), B("Date", tarih)));

        kok.Add(VergiToplami(v.Kdv, v.VergiGruplari, T, B));
        if (v.TevkifatGruplari.Count > 0)
            kok.Add(new XElement(Cac + "WithholdingTaxTotal", T("TaxAmount", v.Tevkifat),
                v.TevkifatGruplari.Select(g => TevkifatAlt(g, T, B))));

        kok.Add(new XElement(Cac + "LegalMonetaryTotal",
            T("LineExtensionAmount", v.Brut), T("TaxExclusiveAmount", v.Net),
            T("TaxInclusiveAmount", v.Net + v.Kdv),
            v.Iskonto > 0 ? T("AllowanceTotalAmount", v.Iskonto) : null,
            T("PayableAmount", v.Odenecek)));

        foreach (var s in v.Satirlar)
        {
            var satir = new XElement(Cac + "InvoiceLine", B("ID", s.No),
                new XElement(Cbc + "InvoicedQuantity", new XAttribute("unitCode", s.BirimKodu), s.Miktar.ToString("0.######", C)),
                T("LineExtensionAmount", s.Net));
            if (v.Profil == "IHRACAT")
                satir.Add(new XElement(Cac + "Delivery",
                    new XElement(Cac + "DeliveryAddress", B("CitySubdivisionName", v.Alici.Ilce), B("CityName", v.Alici.Il),
                        new XElement(Cac + "Country", B("Name", v.Alici.Ulke))),
                    new XElement(Cac + "DeliveryTerms", new XElement(Cbc + "ID", new XAttribute("schemeID", "INCOTERMS"), s.TeslimSarti)),
                    new XElement(Cac + "Shipment", B("ID", ""),
                        new XElement(Cac + "GoodsItem", B("RequiredCustomsID", s.Gtip)),
                        new XElement(Cac + "ShipmentStage", B("TransportModeCode", s.TasimaSekli)),
                        new XElement(Cac + "TransportHandlingUnit", new XElement(Cac + "ActualPackage",
                            B("ID", s.KapNo), B("Quantity", s.KapAdet.ToString("0.##", C)), B("PackagingTypeCode", s.KapCinsi))))));
            if (s.Iskonto > 0)
                satir.Add(new XElement(Cac + "AllowanceCharge", B("ChargeIndicator", "false"),
                    B("AllowanceChargeReason", "İskonto"),
                    B("MultiplierFactorNumeric", Math.Round(s.Iskonto / s.Brut, 6).ToString("0.######", C)),
                    T("Amount", s.Iskonto), T("BaseAmount", s.Brut)));
            satir.Add(VergiToplami(s.Kdv, [new VergiGrubu(s.KdvOran, s.Net, s.Kdv, s.IstisnaKodu, s.IstisnaAdi)], T, B));
            if (s.Tevkifat > 0)
                satir.Add(new XElement(Cac + "WithholdingTaxTotal", T("TaxAmount", s.Tevkifat),
                    TevkifatAlt(new TevkifatGrubu(s.TevkifatKodu, s.TevkifatAdi, s.TevkifatOran, s.Kdv, s.Tevkifat), T, B)));
            satir.Add(new XElement(Cac + "Item", B("Name", s.Ad),
                s.StokKodu.Length > 0 ? new XElement(Cac + "SellersItemIdentification", B("ID", s.StokKodu)) : null,
                s.LotNo.Length > 0 ? new XElement(Cac + "AdditionalItemIdentification", new XElement(Cbc + "ID", new XAttribute("schemeID", "LOTNO"), s.LotNo)) : null));
            satir.Add(new XElement(Cac + "Price", new XElement(Cbc + "PriceAmount", new XAttribute("currencyID", para), s.Fiyat.ToString("0.######", C))));
            kok.Add(satir);
        }

        return Yaz(kok);
    }

    private static readonly XNamespace Des = "urn:oasis:names:specification:ubl:schema:xsd:DespatchAdvice-2";

    /// <summary>
    /// UBL-TR 1.2 e-İRSALİYE (DespatchAdvice) - Delphi UBLXMLUret irsaliye dalı. Önizleme /
    /// XML için; GİB'e izibiz JSON'u gider (<see cref="IzibizGovde"/>), rakamlar aynı veriden.
    /// </summary>
    private static string Irsaliye(EFaturaVerisi v, IReadOnlyList<string> notlar, string xslt)
    {
        XElement B(string ad, object? d) => new(Cbc + ad, d);
        var tarih = v.Tarih.ToString("yyyy-MM-dd", C);
        var kok = new XElement(Des + "DespatchAdvice",
            new XAttribute(XNamespace.Xmlns + "cac", Cac), new XAttribute(XNamespace.Xmlns + "cbc", Cbc),
            new XAttribute(XNamespace.Xmlns + "ext", Ext),
            new XElement(Ext + "UBLExtensions", new XElement(Ext + "UBLExtension", new XElement(Ext + "ExtensionContent"))),
            B("UBLVersionID", "2.1"), B("CustomizationID", "TR1.2.1"), B("ProfileID", v.Profil),
            B("ID", v.EBelgeNo), B("CopyIndicator", "false"), B("UUID", v.Uuid),
            B("IssueDate", tarih), B("IssueTime", v.Tarih.ToString("HH:mm:ss", C)),
            B("DespatchAdviceTypeCode", v.FaturaTipi),
            notlar.Select(n => B("Note", n)),
            B("LineCountNumeric", v.Satirlar.Count));
        foreach (var s in v.SiparisReferanslari)
            kok.Add(new XElement(Cac + "OrderReference", B("ID", s.No), B("IssueDate", s.Tarih.ToString("yyyy-MM-dd", C))));
        if (xslt.Length > 0)
            kok.Add(new XElement(Cac + "AdditionalDocumentReference", B("ID", v.Uuid), B("IssueDate", tarih),
                B("DocumentType", "XSLT"),
                new XElement(Cac + "Attachment", new XElement(Cbc + "EmbeddedDocumentBinaryObject",
                    new XAttribute("characterSetCode", "UTF-8"), new XAttribute("encodingCode", "Base64"),
                    new XAttribute("filename", v.EBelgeNo + ".xslt"), new XAttribute("mimeCode", "application/xml"),
                    Convert.ToBase64String(Encoding.UTF8.GetBytes(xslt))))));
        kok.Add(new XElement(Cac + "Signature",
            new XElement(Cbc + "ID", new XAttribute("schemeID", "VKN_TCKN"), EFaturaKodlari.Rakam(v.Gonderici.Vkno)),
            new XElement(Cac + "SignatoryParty", Parti(v.Gonderici, false).Elements()),
            new XElement(Cac + "DigitalSignatureAttachment", new XElement(Cac + "ExternalReference", B("URI", "#Signature")))));
        kok.Add(new XElement(Cac + "DespatchSupplierParty", Parti(v.Gonderici, true)));
        kok.Add(new XElement(Cac + "DeliveryCustomerParty", Parti(v.Alici, false)));

        var tasiyici = v.TasiyiciUnvan.Length > 0 || v.TasiyiciVkno.Length > 0
            ? new XElement(Cac + "CarrierParty",
                Parti(new EFaturaTaraf(v.TasiyiciUnvan, v.TasiyiciVkno, "", "", "", "", "Türkiye", "", "", ""), false).Elements())
            : null;
        var (ad, soyad) = EFaturaKodlari.AdSoyad(v.SoforAd);
        kok.Add(new XElement(Cac + "Shipment", B("ID", "1"),
            new XElement(Cac + "GoodsItem", new XElement(Cbc + "ValueAmount", new XAttribute("currencyID", v.ParaKodu), v.Net.ToString("0.00", C))),
            new XElement(Cac + "ShipmentStage",
                v.Plaka.Length > 0
                    ? new XElement(Cac + "TransportMeans", new XElement(Cac + "RoadTransport",
                        new XElement(Cbc + "LicensePlateID", new XAttribute("schemeID", "PLAKA"), v.Plaka)))
                    : null,
                v.SoforAd.Length > 0
                    ? new XElement(Cac + "DriverPerson", B("FirstName", ad), B("FamilyName", soyad), B("Title", "Şoför"),
                        v.SoforTckn.Length > 0 ? B("NationalityID", v.SoforTckn) : null)
                    : null),
            new XElement(Cac + "Delivery",
                new XElement(Cac + "DeliveryAddress", B("StreetName", v.Alici.Adres), B("CitySubdivisionName", v.Alici.Ilce),
                    B("CityName", v.Alici.Il), B("PostalZone", v.Alici.PostaKodu.Length > 0 ? v.Alici.PostaKodu : "34000"),
                    new XElement(Cac + "Country", B("Name", "Türkiye"))),
                tasiyici,
                new XElement(Cac + "Despatch", B("ActualDespatchDate", v.SevkZamani.ToString("yyyy-MM-dd", C)),
                    B("ActualDespatchTime", v.SevkZamani.ToString("HH:mm:ss", C))))));

        foreach (var s in v.Satirlar)
            kok.Add(new XElement(Cac + "DespatchLine", B("ID", s.No),
                new XElement(Cbc + "DeliveredQuantity", new XAttribute("unitCode", s.BirimKodu), s.Miktar.ToString("0.######", C)),
                new XElement(Cac + "OrderLineReference", B("LineID", s.No)),
                new XElement(Cac + "Item", B("Name", s.Ad),
                    s.StokKodu.Length > 0 ? new XElement(Cac + "SellersItemIdentification", B("ID", s.StokKodu)) : null),
                new XElement(Cac + "Shipment", B("ID", ""),
                    new XElement(Cac + "GoodsItem", new XElement(Cac + "InvoiceLine", B("ID", ""),
                        new XElement(Cbc + "InvoicedQuantity", 0),
                        new XElement(Cbc + "LineExtensionAmount", new XAttribute("currencyID", v.ParaKodu), s.Net.ToString("0.00", C)),
                        new XElement(Cac + "Item", B("Name", "")),
                        new XElement(Cac + "Price", new XElement(Cbc + "PriceAmount", new XAttribute("currencyID", v.ParaKodu),
                            s.Fiyat.ToString("0.######", C))))))));
        return Yaz(kok);
    }

    private static string Yaz(XElement kok)
    {
        var ayar = new XmlWriterSettings { Indent = true, Encoding = new UTF8Encoding(false), OmitXmlDeclaration = false };
        var sb = new StringBuilder();
        using (var w = XmlWriter.Create(new Utf8StringWriter(sb), ayar)) new XDocument(kok).Save(w);
        return sb.ToString();
    }

    private static XElement VergiToplami(decimal toplam, IEnumerable<VergiGrubu> gruplar,
                                         Func<string, decimal, XElement> T, Func<string, object?, XElement> B)
        => new(Cac + "TaxTotal", T("TaxAmount", toplam),
            gruplar.Select(g => new XElement(Cac + "TaxSubtotal",
                T("TaxableAmount", g.Matrah), T("TaxAmount", g.Vergi), B("CalculationSequenceNumeric", 1),
                B("Percent", g.Oran),
                new XElement(Cac + "TaxCategory",
                    g.IstisnaKodu > 0 ? B("TaxExemptionReasonCode", g.IstisnaKodu) : null,
                    g.IstisnaKodu > 0 ? B("TaxExemptionReason", g.IstisnaAdi) : null,
                    new XElement(Cac + "TaxScheme", B("Name", "KDV"), B("TaxTypeCode", "0015"))))));

    private static XElement TevkifatAlt(TevkifatGrubu g, Func<string, decimal, XElement> T, Func<string, object?, XElement> B)
        => new(Cac + "TaxSubtotal", T("TaxableAmount", g.Kdv), T("TaxAmount", g.Tevkifat),
            B("Percent", (int)Math.Round(g.Oran)),
            new XElement(Cac + "TaxCategory", new XElement(Cac + "TaxScheme", B("Name", g.Ad), B("TaxTypeCode", g.Kod))));

    private static XElement Parti(EFaturaTaraf t, bool kimlikler, string? eposta = null)
    {
        var vkn = EFaturaKodlari.Rakam(t.Vkno);
        var sema = EFaturaKodlari.KimlikSemasi(vkn);
        var p = new XElement(Cac + "Party");
        if (t.Web.Length > 0) p.Add(new XElement(Cbc + "WebsiteURI", t.Web));
        p.Add(new XElement(Cac + "PartyIdentification", new XElement(Cbc + "ID", new XAttribute("schemeID", sema), vkn)));
        if (kimlikler && t.Mersis.Length > 0)
            p.Add(new XElement(Cac + "PartyIdentification", new XElement(Cbc + "ID", new XAttribute("schemeID", "MERSISNO"), t.Mersis)));
        if (kimlikler && t.TicaretSicil.Length > 0)
            p.Add(new XElement(Cac + "PartyIdentification", new XElement(Cbc + "ID", new XAttribute("schemeID", "TICARETSICILNO"), t.TicaretSicil)));
        if (sema == "VKN") p.Add(new XElement(Cac + "PartyName", new XElement(Cbc + "Name", t.Unvan)));
        p.Add(new XElement(Cac + "PostalAddress",
            new XElement(Cbc + "StreetName", t.Adres), new XElement(Cbc + "CitySubdivisionName", t.Ilce),
            new XElement(Cbc + "CityName", t.Il),
            t.PostaKodu.Length > 0 ? new XElement(Cbc + "PostalZone", t.PostaKodu) : null,
            new XElement(Cac + "Country", new XElement(Cbc + "Name", t.Ulke.Length > 0 ? t.Ulke : "Türkiye"))));
        p.Add(new XElement(Cac + "PartyTaxScheme", new XElement(Cac + "TaxScheme", new XElement(Cbc + "Name", t.VergiDairesi))));
        var mail = eposta ?? (kimlikler ? t.Eposta : "");
        if (mail.Length > 0 || t.Telefon.Length > 0)
            p.Add(new XElement(Cac + "Contact",
                t.Telefon.Length > 0 ? new XElement(Cbc + "Telephone", t.Telefon) : null,
                mail.Length > 0 ? new XElement(Cbc + "ElectronicMail", mail) : null));
        if (sema == "TCKN")
        {
            var (ad, soyad) = EFaturaKodlari.AdSoyad(t.Unvan);
            p.Add(new XElement(Cac + "Person", new XElement(Cbc + "FirstName", ad), new XElement(Cbc + "FamilyName", soyad)));
        }
        return p;
    }

    private sealed class Utf8StringWriter(StringBuilder sb) : StringWriter(sb, CultureInfo.InvariantCulture)
    {
        public override Encoding Encoding => new UTF8Encoding(false);
    }
}
