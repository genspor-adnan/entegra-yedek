using System.Globalization;
using System.Text;
using System.Text.Json.Nodes;

namespace Gentegre.Api.Servisler.EFatura;

/// <summary>
/// izibiz GÖNDERİM GÖVDESİ - Delphi <c>TEBelgeOlusturucu._IzibizJSONOlustur</c>
/// birebir. GİB'e GİDEN BUDUR (izibiz JSON-native; UBL yalnız önizleme / XML
/// çıktısı için üretilir). Anahtar adları ve biçimleri izibiz şematronunda
/// doğrulanmış hâlleriyle (Delphi'deki yorumlar):
///   - assignNumber STRING ("false"), percent TAM SAYI, multiplierFactorNumeric KESİR,
///   - tevkifat matrahı KDV TUTARI, satırda withholdingTaxTotal / başlıkta withHoldingTax,
///   - despatchDocumentReference DİZİ, billingReference iade için zorunlu,
///   - XSLT her belgeye gömülür (xsltName=DEFAULT "imza bilgisi bulunamadı" verir).
/// </summary>
public static class IzibizGovde
{
    private static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

    public static JsonObject Uret(EFaturaVerisi v, IReadOnlyList<string> notlar, string xslt)
    {
        var tarih = v.Tarih.ToString("yyyy-MM-dd", Inv);
        var content = new JsonObject
        {
            ["profile"] = v.Profil,
            ["documentTypeCode"] = v.FaturaTipi,
            ["documentNo"] = v.EBelgeNo,
            ["uuid"] = v.Uuid,
            ["issueDate"] = tarih,
            ["issueTime"] = v.Tarih.ToString("HH:mm:ss", Inv),
            ["notes"] = new JsonArray(notlar.Select(n => (JsonNode?)n).ToArray()),
            ["currencyCode"] = v.ParaKodu,
        };

        // DÖVİZ: kur TRY'ye (Delphi PricingExchangeRate).
        if (v.Dovizli)
            content["pricingExchangeRate"] = new JsonObject
            {
                ["sourceCurrencyCode"] = v.ParaKodu, ["targetCurrencyCode"] = "TRY",
                ["calculationRate"] = v.Kur, ["date"] = tarih,
            };

        // NAVLUN / SİGORTA (ihracat başlığı).
        if (v.Navlun > 0 || v.Sigorta > 0)
            content["delivery"] = new JsonArray(new JsonObject
            {
                ["shipment"] = new JsonObject
                {
                    ["insuranceValueAmount"] = Y(v.Sigorta),
                    ["declaredForCarriageValueAmount"] = Y(v.Navlun),
                },
            });

        // SGK (Tipi 25).
        if (v.Tipi == 25)
        {
            content["accountingCost"] = v.SgkTip;
            content["invoicePeriod"] = new JsonObject
            {
                ["startDate"] = v.SgkDonemBas?.ToString("yyyy-MM-dd", Inv),
                ["endDate"] = v.SgkDonemBit?.ToString("yyyy-MM-dd", Inv),
            };
        }

        var ekRef = new JsonArray();
        if (v.Tipi == 25)
        {
            ekRef.Add(EkRef("MUKELLEF_KODU", v.SgkMukellefKod, tarih));
            ekRef.Add(EkRef("MUKELLEF_ADI", v.SgkMukellefAd, tarih));
            ekRef.Add(EkRef("DOSYA_NO", v.SgkDosyaNo, tarih));
        }

        // SİPARİŞ / İRSALİYE REFERANSI (Delphi KaynakBelgeReferanslariDoldur).
        if (v.SiparisReferanslari.Count > 0)
        {
            content["orderReference"] = new JsonObject
            { ["id"] = v.SiparisReferanslari[0].No, ["issueDate"] = v.SiparisReferanslari[0].Tarih.ToString("yyyy-MM-dd", Inv) };
            foreach (var s in v.SiparisReferanslari.Skip(1))
                ekRef.Add(new JsonObject
                {
                    ["id"] = s.No, ["issueDate"] = s.Tarih.ToString("yyyy-MM-dd", Inv),
                    ["documentTypeCode"] = "SIPARIS", ["documentType"] = "SIPARIS",
                });
        }
        if (v.IrsaliyeNo.Length > 0)
            content["despatchDocumentReference"] = new JsonArray(new JsonObject
            {
                ["id"] = v.IrsaliyeNo,
                ["issueDate"] = (v.IrsaliyeTarihi ?? v.Tarih).ToString("yyyy-MM-dd", Inv),
            });

        // İADE: iade edilen faturanın referansı (şematron 10003).
        if (v.Tipi == 2 && v.IadeReferanslari.Count > 0)
            content["billingReference"] = new JsonArray(v.IadeReferanslari
                .GroupBy(r => r.No).Select(g => g.First())
                .Select(r => (JsonNode?)new JsonObject
                {
                    ["id"] = r.No, ["issueDate"] = r.Tarih.ToString("yyyy-MM-dd", Inv),
                    ["documentTypeCode"] = "IADE", ["documentType"] = "İade Edilen Fatura",
                }).ToArray());

        // e-ARŞİV GÖNDERİM ŞEKLİ: alıcı e-postası varsa ELEKTRONIK, yoksa KAGIT.
        var mailler = Mailler(v.AliciAlias);
        if (v.Arsiv)
            ekRef.Add(new JsonObject
            {
                ["documentTypeCode"] = "SendingType",
                ["documentType"] = mailler.Count > 0 ? "ELEKTRONIK" : "KAGIT",
                ["id"] = "1", ["issueDate"] = tarih,
            });

        // XSLT GÖMÜLÜ (her belge türünde).
        ekRef.Add(new JsonObject
        {
            ["id"] = v.Uuid, ["documentType"] = "XSLT", ["issueDate"] = tarih,
            ["attachment"] = new JsonObject
            {
                ["characterSetCode"] = "UTF-8", ["encodingCode"] = "Base64",
                ["filename"] = $"{v.EBelgeNo}.xslt", ["mimeCode"] = "application/xml",
                ["content"] = Convert.ToBase64String(Encoding.UTF8.GetBytes(xslt)),
            },
        });
        content["additionalReferences"] = ekRef;

        // SATICI
        content["supplierParty"] = Taraf(v.Gonderici, arsivIletisim: false, kimlikler: true);

        // ALICI. İhracatta asıl alıcı buyerCustomerParty'ye, customerParty Gümrük.
        if (v.Profil == "IHRACAT")
        {
            content["customerParty"] = new JsonObject
            {
                ["name"] = "Gümrük ve Ticaret Bakanlığı Gümrükler Genel Müdürlüğü- Bilgi İşlem Dairesi Başkanlığı",
                ["identifier"] = "1460415308", ["schemeId"] = "VKN", ["taxOffice"] = "ULUS",
                ["address"] = new JsonObject { ["city"] = "ANKARA", ["country"] = "TÜRKİYE" },
            };
            var alici = Taraf(v.Alici, false, false);
            alici["schemeId"] = "PARTYTYPE";
            alici["partyType"] = "EXPORT";
            alici["taxRegisterNo"] = EFaturaKodlari.Rakam(v.Alici.Vkno);
            content["buyerCustomerParty"] = alici;
        }
        else
        {
            var alici = Taraf(v.Alici, arsivIletisim: v.Arsiv, kimlikler: false);
            if (v.Arsiv && mailler.Count > 0)
                ((JsonObject)alici["address"]!)["email"] = mailler[0];
            content["customerParty"] = alici;
        }

        // KAMU: ödeme IBAN'ı (paymentCode 46 = hesaba havale).
        if (v.Profil == "KAMU")
        {
            content["buyerCustomerParty"] = Taraf(v.Alici, false, false);
            content["paymentMeans"] = new JsonArray(new JsonObject
            {
                ["paymentCode"] = "46",
                ["payeeFinancialAccount"] = new JsonObject
                {
                    ["id"] = v.KamuIban, ["currencyCode"] = v.ParaKodu,
                    ["paymentNote"] = v.Gonderici.Unvan,
                    ["financialInstitutionBranch"] = new JsonObject
                    {
                        ["name"] = v.KamuSube,
                        ["financialInstitution"] = new JsonObject { ["id"] = v.KamuBanka },
                    },
                },
            });
        }

        // VERGİ / TOPLAM
        content["taxTotal"] = VergiToplami(v.Kdv, v.VergiGruplari);
        if (v.TevkifatGruplari.Count > 0)
            content["withHoldingTax"] = new JsonObject
            {
                ["taxAmount"] = Y(v.Tevkifat),
                ["taxSubTotal"] = new JsonArray(v.TevkifatGruplari.Select(g => (JsonNode?)TevkifatAlt(g)).ToArray()),
            };

        var toplam = new JsonObject
        {
            ["lineExtensionAmount"] = Y(v.Brut),
            ["taxExclusiveAmount"] = Y(v.Net),
            ["taxInclusiveAmount"] = Y(v.Net + v.Kdv),
            ["payableAmount"] = Y(v.Odenecek),
        };
        if (v.Iskonto > 0) toplam["allowanceTotalAmount"] = Y(v.Iskonto);
        content["legalMonetaryTotal"] = toplam;

        content["lines"] = new JsonArray(v.Satirlar.Select(s => (JsonNode?)Satir(v, s)).ToArray());

        var kok = new JsonObject
        {
            ["documentAction"] = "SEND",
            ["assignNumber"] = v.EBelgeNo.Length > 0 ? "false" : "true",
            ["seriePrefix"] = v.EBelgeNo.Length >= 3 ? v.EBelgeNo[..3] : "",
        };
        if (v.Profil != "IHRACAT" && !v.Arsiv && v.AliciAlias.Length > 0) kok["receiverAlias"] = v.AliciAlias;
        if (v.GondericiAlias.Length > 0) kok["senderAlias"] = v.GondericiAlias;
        if (v.Arsiv && mailler.Count > 0)
        {
            kok["mailFlag"] = true;
            kok["mailAdress"] = new JsonArray(mailler.Select(m => (JsonNode?)m).ToArray());
        }
        kok["content"] = content;
        return kok;
    }

    private static JsonObject Satir(EFaturaVerisi v, EFaturaSatiri s)
    {
        var o = new JsonObject
        {
            ["id"] = s.No,
            ["quantity"] = s.Miktar,
            ["unitCode"] = s.BirimKodu,
            ["lineExtensionAmount"] = Y(s.Net),
            ["itemName"] = s.Ad,
            ["itemPrice"] = s.Fiyat,
        };
        if (s.StokKodu.Length > 0) o["sellerIdentificationId"] = s.StokKodu;
        if (s.LotNo.Length > 0)
            o["additionalItemProperties"] = new JsonArray(new JsonObject { ["name"] = "LOTNO", ["value"] = s.LotNo });
        if (s.Iskonto > 0)
            o["allowanceCharge"] = new JsonArray(new JsonObject
            {
                ["chargeIndicator"] = false,
                ["reason"] = "Iskonto",
                ["multiplierFactorNumeric"] = Math.Round(s.Iskonto / s.Brut, 6),
                ["amount"] = Y(s.Iskonto),
                ["baseAmount"] = Y(s.Brut),
            });

        o["taxTotal"] = VergiToplami(s.Kdv, [new VergiGrubu(s.KdvOran, s.Net, s.Kdv, s.IstisnaKodu, s.IstisnaAdi)]);
        if (s.Tevkifat > 0)
            o["withholdingTaxTotal"] = new JsonObject
            {
                ["taxAmount"] = Y(s.Tevkifat),
                ["taxSubTotal"] = new JsonArray(TevkifatAlt(new TevkifatGrubu(s.TevkifatKodu, s.TevkifatAdi,
                                                                               s.TevkifatOran, s.Kdv, s.Tevkifat))),
            };

        // İHRACAT satır teslimatı (Delphi IhracatSatirDeliveryOlustur).
        if (v.Profil == "IHRACAT")
            o["delivery"] = new JsonObject
            {
                ["deliveryAddress"] = new JsonObject
                {
                    ["country"] = v.Alici.Ulke.Length > 0 ? v.Alici.Ulke : "TR",
                    ["city"] = v.Alici.Il, ["subCity"] = v.Alici.Ilce, ["streetName"] = v.Alici.Adres,
                },
                ["deliveryTerms"] = new JsonObject { ["schemeID"] = "INCOTERMS", ["id"] = s.TeslimSarti },
                ["shipment"] = new JsonObject
                {
                    ["freeOnBoardValueAmount"] = Y(0m),
                    ["goodsItems"] = new JsonArray(new JsonObject { ["requiredCustomsID"] = s.Gtip }),
                    ["shipmentStages"] = new JsonArray(new JsonObject { ["transportModeCode"] = s.TasimaSekli }),
                    ["transportHandlingUnits"] = new JsonArray(new JsonObject
                    {
                        ["actualPackage"] = new JsonObject
                        {
                            ["id"] = s.KapNo, ["quantity"] = s.KapAdet, ["packagingTypeCode"] = s.KapCinsi,
                        },
                    }),
                },
            };
        return o;
    }

    private static JsonObject VergiToplami(decimal toplam, IEnumerable<VergiGrubu> gruplar) => new()
    {
        ["taxAmount"] = Y(toplam),
        ["taxSubTotal"] = new JsonArray(gruplar.Select(g =>
        {
            var o = new JsonObject
            {
                ["calculationSequenceNumeric"] = 1,
                ["taxableAmount"] = Y(g.Matrah),
                ["percent"] = g.Oran,
                ["taxAmount"] = Y(g.Vergi),
                ["taxScheme"] = new JsonObject { ["name"] = "KDV", ["typeCode"] = "0015" },
            };
            if (g.IstisnaKodu > 0)
            {
                o["taxExemptionCode"] = g.IstisnaKodu.ToString(Inv);
                o["taxExemptionReason"] = g.IstisnaAdi;
            }
            return (JsonNode?)o;
        }).ToArray()),
    };

    private static JsonObject TevkifatAlt(TevkifatGrubu g) => new()
    {
        ["taxableAmount"] = Y(g.Kdv),
        ["taxAmount"] = Y(g.Tevkifat),
        ["calculationSequenceNumeric"] = 1,
        ["percent"] = (int)Math.Round(g.Oran),
        ["taxScheme"] = new JsonObject { ["name"] = g.Ad, ["typeCode"] = g.Kod },
    };

    private static JsonObject Taraf(EFaturaTaraf t, bool arsivIletisim, bool kimlikler)
    {
        var vkn = EFaturaKodlari.Rakam(t.Vkno);
        var sema = EFaturaKodlari.KimlikSemasi(vkn);
        var o = new JsonObject { ["schemeId"] = sema, ["identifier"] = vkn };
        if (sema == "TCKN")
        {
            var (ad, soyad) = EFaturaKodlari.AdSoyad(t.Unvan);
            o["firstName"] = ad;
            o["lastName"] = soyad;
        }
        else o["name"] = t.Unvan;
        o["taxOffice"] = t.VergiDairesi;
        var adres = new JsonObject
        {
            ["country"] = t.Ulke.Length > 0 ? t.Ulke : "TR",
            ["city"] = t.Il, ["subCity"] = t.Ilce, ["streetName"] = t.Adres,
        };
        if (t.PostaKodu.Length > 0) adres["postalCode"] = t.PostaKodu;
        if (kimlikler || arsivIletisim)
        {
            if (t.Eposta.Length > 0) adres["email"] = t.Eposta;
            if (t.Telefon.Length > 0) adres["telephone"] = t.Telefon;
        }
        if (kimlikler && t.Web.Length > 0) adres["webSite"] = t.Web;
        o["address"] = adres;
        if (kimlikler)
        {
            var k = new JsonArray();
            if (t.Mersis.Length > 0) k.Add(new JsonObject { ["scheme"] = "MERSISNO", ["value"] = t.Mersis });
            if (t.TicaretSicil.Length > 0) k.Add(new JsonObject { ["scheme"] = "TICARETSICILNO", ["value"] = t.TicaretSicil });
            if (k.Count > 0) o["identifications"] = k;
        }
        return o;
    }

    private static JsonObject EkRef(string kod, string deger, string tarih) => new()
    {
        ["id"] = deger, ["issueDate"] = tarih, ["documentTypeCode"] = kod, ["documentType"] = kod,
    };

    /// <summary>e-Arşiv alıcı e-postaları: ; , satır sonu ile ayrılmış (Delphi).</summary>
    public static List<string> Mailler(string metin) => (metin ?? "")
        .Split([';', ',', '\r', '\n'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
        .Where(m => m.Contains('@')).Distinct().ToList();

    /// <summary>Para alanı: 2 ondalık.</summary>
    private static decimal Y(decimal d) => Math.Round(d, 2, MidpointRounding.AwayFromZero);
}
