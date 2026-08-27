using System.Globalization;
using System.Text.Json;
using System.Xml.Linq;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// GELEN e-FATURAYI ALIS FATURASINA AKTAR (187).
///
/// Kutu tek basina bir gorunum; belge muhasebeye ancak ALIS FATURASI olarak
/// islenince girer - cari borcu, stok girisi ve ekstre oradan dogar. Kullanici:
/// "gelen kutusu onaydan sonra ana listeye gecsin, borc/alacak ekstrede
/// gorunsun".
///
/// TEK KAYIT YOLU: UBL cozulur ve normal <see cref="BelgeDeposu.KaydetAsync"/>
/// akisina verilir. Ayri bir "gelen fatura yazici" yazmak numara/stok/cari
/// hareket/muhasebe kurallarini ikinci kez uygulamak olurdu.
///
/// STOK ESLESTIRME: satirlar stok karti aranarak baglanir (stok kodu, sonra
/// barkod). Bulunamayan satir SERBEST kalir (stok_id null) - gonderenin kodunu
/// bizim kartimiza uydurmaya calismak yanlis stoga hareket yazar. Satici urun
/// kodu izleme_kodu'na yazilir, sonradan eslestirilebilsin.
/// </summary>
public sealed class GelenBelgeAktar(VeriKaynagi veri, BelgeDeposu belgeler, EBelgeGelen gelen)
{
    public sealed record Sonuc(int BelgeId, string BelgeNo, int SatirSayisi,
                               int EslesenStok, string Mesaj);

    private static readonly XNamespace Cbc =
        "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2";
    private static readonly XNamespace Cac =
        "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2";

    public async Task<Sonuc> AktarAsync(long eBelgeId, YazmaBaglami baglam,
                                        CancellationToken iptal = default)
    {
        await using var baglanti = await veri.AcAsync(iptal);

        // 1) Kayit + daha once aktarilmis mi.
        int? mevcutBelge = null;
        string gondericiVkno = "", gondericiUnvan = "", belgeNo = "";
        short belgeTuru = 1;
        await using (var oku = new NpgsqlCommand("""
            select belge_id, coalesce(gonderici_vkno, ''), coalesce(gonderici_unvan, ''),
                   coalesce(belge_no, ''), belge_turu
              from public.e_belge where id = @p0 and yon = 2
            """, baglanti))
        {
            oku.Parameters.AddWithValue("p0", eBelgeId);
            await using var o = await oku.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) throw GentegreHatasi.Bulunamadi();
            mevcutBelge = o.IsDBNull(0) ? null : o.GetInt32(0);
            gondericiVkno = o.GetString(1); gondericiUnvan = o.GetString(2);
            belgeNo = o.GetString(3); belgeTuru = o.GetInt16(4);
        }

        if (mevcutBelge is { } eski)
            throw GentegreHatasi.IsKurali(
                $"Bu belge zaten alış faturasına aktarılmış (belge #{eski}).");

        // 2) UBL - yoksa entegratorden indirilir.
        var ubl = await gelen.IcerikIndirAsync(eBelgeId, baglam.SubeId, baglam.KullaniciId, iptal);
        var kok = XDocument.Parse(ubl).Root
                  ?? throw GentegreHatasi.IsKurali("Belge içeriği okunamadı.");

        // 3) Cari: VKN ile eslesen taraf; yoksa TEDARIKCI olarak acilir.
        var tarafId = await TarafBulVeyaAcAsync(baglanti, gondericiVkno, gondericiUnvan,
                                                kok, baglam, iptal);

        // 4) Baslik + satirlar.
        var doviz = (kok.Element(Cbc + "DocumentCurrencyCode")?.Value ?? "TRY").Trim();
        if (doviz.Equals("TRY", StringComparison.OrdinalIgnoreCase)) doviz = "TL";

        var tarih = Tarih(kok.Element(Cbc + "IssueDate")?.Value)
                    ?? DateTime.Today;

        // BASLIK ham .NET degerleriyle kurulur (JsonElement DEGIL): BelgeDeposu
        //   basligi dogrudan parametreye baglar, uc katmani JSON'u zaten burada
        //   cozer. JsonElement verilince "IConvertible" cevrim hatasi aliniyordu.
        var belge = new Dictionary<string, object?>
        {
            ["tur"]          = 11,                              // Alis Faturasi
            ["tipi"]         = 1,
            ["tarafId"]      = tarafId,
            ["belgeTarihi"]  = tarih,
            // Gelen faturanin numarasi SATICININ numarasidir; kendi seri/sayacimiz
            //   tuketilmez (alis belgesinde numara zaten alfanumerik gelir).
            ["belgeNo"]      = belgeNo.Length > 20 ? belgeNo[..20] : belgeNo,
            ["belgeDovizi"]  = doviz.Length > 5 ? doviz[..5] : doviz,
            ["aciklama"]     = $"e-Fatura kutusundan aktarıldı ({belgeNo})",
        };

        var satirlar = new List<Dictionary<string, JsonElement>>();
        var eslesen = 0;

        foreach (var satir in kok.Elements(Cac + "InvoiceLine"))
        {
            var miktar = Sayi(satir.Element(Cbc + "InvoicedQuantity")?.Value);
            var tutar  = Sayi(satir.Element(Cbc + "LineExtensionAmount")?.Value);
            var fiyat  = Sayi(satir.Element(Cac + "Price")?.Element(Cbc + "PriceAmount")?.Value);
            if (fiyat == 0 && miktar != 0) fiyat = tutar / miktar;

            var kdv = (short)Sayi(satir.Element(Cac + "TaxTotal")
                                      ?.Element(Cac + "TaxSubtotal")
                                      ?.Element(Cbc + "Percent")?.Value);

            var urun = satir.Element(Cac + "Item");
            var ad = urun?.Element(Cbc + "Name")?.Value?.Trim() ?? "";
            var kod = UrunKodu(urun);

            var (stokId, esles) = await StokBulAsync(baglanti, kod, iptal);
            if (esles) eslesen++;

            satirlar.Add(new Dictionary<string, JsonElement>
            {
                ["tur"]         = Deger(1),
                ["stokId"]      = stokId is { } sid ? Deger(sid) : Deger((object?)null),
                ["aciklama"]    = Deger(ad),
                ["miktar"]      = Deger(miktar),
                ["adet"]        = Deger(miktar),
                ["birimFiyat"]  = Deger(fiyat),
                ["kdv"]         = Deger(kdv),
                ["dovizCinsi"]  = Deger(doviz),
                // Saticinin urun kodu KAYBOLMASIN: sonradan stok eslestirmesi
                //   yapilabilsin diye izleme koduna yazilir (Delphi ile ayni yer).
                ["izlemeKodu"]  = Deger(kod.Length > 40 ? kod[..40] : kod),
            });
        }

        if (satirlar.Count == 0)
            throw GentegreHatasi.IsKurali("Belgede kalem bulunamadı; aktarılamaz.");

        // 5) NORMAL belge kaydi: numara, stok, cari hareket, muhasebe hep ayni yoldan.
        //    Stok kontrolu KAPALI: alis girisi stok azaltmaz, gelen belgeyi
        //    stok yetersizligi yuzunden reddetmek anlamsiz olurdu.
        var (belgeId, uyarilar) = await belgeler.KaydetAsync(
            belge,
            satirlar,
            new BelgeSecenekleri { Taslak = false, StokKontrolu = false },
            baglam, iptal);

        // 6) Bag: kutu satiri artik belgeye isaret eder (tekrar aktarim engellenir).
        await using (var bag = new NpgsqlCommand("""
            update public.e_belge set belge_id = @p1, taraf_id = coalesce(taraf_id, @p2),
                   degistiren = @p3, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, baglanti))
        {
            bag.Parameters.AddWithValue("p0", eBelgeId);
            bag.Parameters.AddWithValue("p1", belgeId);
            bag.Parameters.AddWithValue("p2", tarafId);
            bag.Parameters.AddWithValue("p3", baglam.KullaniciId);
            await bag.ExecuteNonQueryAsync(iptal);
        }

        var mesaj = $"Alış faturası oluşturuldu ({satirlar.Count} kalem, " +
                    $"{eslesen} kalem stok kartıyla eşleşti).";
        if (uyarilar.Count > 0) mesaj += " " + string.Join(" • ", uyarilar);

        return new Sonuc(belgeId, belgeNo, satirlar.Count, eslesen, mesaj);
    }

    // --------------------------------------------------------------- cari ----
    private static async Task<int> TarafBulVeyaAcAsync(NpgsqlConnection baglanti,
        string vkno, string unvan, XElement kok, YazmaBaglami baglam, CancellationToken iptal)
    {
        var temiz = new string((vkno ?? "").Where(char.IsDigit).ToArray());

        if (temiz.Length > 0)
        {
            await using var ara = baglanti.Komut(
                "select id from public.taraf where regexp_replace(coalesce(vkno,''), '\\D', '', 'g') = @p0 order by id limit 1", null,
                temiz);
            if (await ara.ExecuteScalarAsync(iptal) is int bulunan) return bulunan;
        }

        // Yeni TEDARIKCI karti: unvan/VKN/vergi dairesi/adres UBL'deki gonderen
        //   bloguna gore doldurulur; kullanici sonra duzeltir.
        var taraf = kok.Element(Cac + "AccountingSupplierParty")?.Element(Cac + "Party");
        var ad = unvan.Length > 0
                 ? unvan
                 : taraf?.Element(Cac + "PartyName")?.Element(Cbc + "Name")?.Value?.Trim() ?? "";
        if (ad.Length == 0) ad = temiz.Length > 0 ? temiz : "Bilinmeyen tedarikçi";

        // ADRES taraf tablosunda DEGIL (taraf_adres) - kart acilirken adres
        //   yazilmaz; kullanici gerekirse kartta ekler. Burada amac faturayi
        //   bir cariye baglamak, tedarikci kartini eksiksiz doldurmak degil.
        await using var ekle = baglanti.Komut("""
            insert into public.taraf (unvan, vkno, vd, tedarikci, durum, sube_id, ekleyen)
            values (left(@p0, 120), left(@p1, 20), left(@p2, 60), 1, 1, @p3, @p4)
            returning id
            """, null,
            ad, temiz);
        ekle.Parameters.AddWithValue("p2",
            taraf?.Element(Cac + "PartyTaxScheme")?.Element(Cac + "TaxScheme")
                 ?.Element(Cbc + "Name")?.Value?.Trim() ?? "");
        ekle.Parameters.AddWithValue("p3", (object?)baglam.SubeId ?? DBNull.Value);
        ekle.Parameters.AddWithValue("p4", baglam.KullaniciId);

        return (int)(await ekle.ExecuteScalarAsync(iptal))!;
    }

    // --------------------------------------------------------------- stok ----
    /// <summary>Stok KODU ile eslestirme. Ad benzerligiyle eslestirme YOK -
    /// yanlis stoga hareket yazmak, hic yazmamaktan kotudur.</summary>
    private static async Task<(int? Id, bool Eslesti)> StokBulAsync(NpgsqlConnection baglanti,
        string kod, CancellationToken iptal)
    {
        if (string.IsNullOrWhiteSpace(kod)) return (null, false);

        await using var komut = baglanti.Komut("""
            select id from public.stok
             where upper(btrim(kod)) = upper(btrim(@p0))
             order by id limit 1
            """, null,
            kod);
        return await komut.ExecuteScalarAsync(iptal) is int id ? (id, true) : (null, false);
    }

    /// <summary>Satici / alici / GTIP / uretici kodu - UBL'de dort ayri yerde olabilir.</summary>
    private static string UrunKodu(XElement? urun)
    {
        if (urun is null) return "";
        foreach (var ad in new[] { "SellersItemIdentification", "BuyersItemIdentification",
                                   "StandardItemIdentification", "ManufacturersItemIdentification" })
        {
            var k = urun.Element(Cac + ad)?.Element(Cbc + "ID")?.Value?.Trim();
            if (!string.IsNullOrWhiteSpace(k)) return k;
        }
        return "";
    }

    // ------------------------------------------------------------ yardimci ----
    private static JsonElement Deger(object? v) => JsonSerializer.SerializeToElement(v);

    private static decimal Sayi(string? m)
        => decimal.TryParse((m ?? "").Trim(), NumberStyles.Any,
                            CultureInfo.InvariantCulture, out var d) ? d : 0m;

    private static DateTime? Tarih(string? m)
        => DateTime.TryParse((m ?? "").Trim(), CultureInfo.InvariantCulture,
                             DateTimeStyles.None, out var t) ? t : null;
}
