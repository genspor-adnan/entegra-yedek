using System.Diagnostics;
using System.Text;
using System.Xml.Linq;
using Gentegre.Veri;

namespace Gentegre.Api.Servisler;

/// <summary>
/// e-NABIZ GÖNDERİMİ (415, Faz 1) — kuyruktan alıp USS'ye götüren kat.
///
/// <para><b>Kapı kapalıyken SAHTE BAŞARI YOK.</b> USS hesabı tanımlı değilse
/// ya da servis adresi boşsa işçi paketleri kuyrukta bırakır ve bunu söyler.
/// "Gönderildi" işaretlemek kurumu "e-Nabıza gitti" sanmaya iterdi; bildirim
/// yükümlülüğü yerine getirilmemişken getirilmiş görünmek, hiç göndermemekten
/// daha kötüdür.</para>
///
/// <para><b>XML şeması geçicidir.</b> USS kılavuzunun gerçek şeması elimizde
/// yok (KTS tescili bekliyor); paket alanları ad-değer olarak sarılıyor.
/// Şema geldiğinde DEĞİŞECEK tek yer burasıdır - alan çözümleme, doğrulama ve
/// kuyruk bundan bağımsız çalışıyor.</para>
///
/// <para>Hata sınıfı ayrımı gerçek: servis hatası (zaman aşımı, 5xx) otomatik
/// tekrarlanır, veri hatası tekrarlanmaz - aynı veriyi beş kez göndermek aynı
/// cevabı beş kez almaktır.</para>
/// </summary>
public sealed class EnabizGonderimi
{
    private readonly VeriKaynagi _veri;
    private readonly IHttpClientFactory _http;
    private readonly ILogger<EnabizGonderimi> _gunluk;
    private readonly EnabizPaketUretici _uretici;

    public EnabizGonderimi(VeriKaynagi veri, IHttpClientFactory http,
                           ILogger<EnabizGonderimi> gunluk,
                           EnabizPaketUretici uretici)
    {
        _veri = veri;
        _http = http;
        _gunluk = gunluk;
        _uretici = uretici;
    }

    public sealed record Sonuc(int Alinan, int Gonderilen, int Hatali, string Aciklama);

    private sealed record Hesap(string Url, string Kullanici, string Sifre, short Ortam);

    /// <summary>
    /// Kuyruktan bir parti alır ve gönderir.
    ///
    /// <paramref name="paketId"/> verilirse yalnız o paket denenir (ekrandaki
    /// "Şimdi Gönder"). Kuyruktan alma atomiktir (`for update skip locked`):
    /// iki işçi aynı paketi almaz.
    /// </summary>
    public async Task<Sonuc> CalistirAsync(int adet, long? paketId, int? kullaniciId,
                                           CancellationToken iptal)
    {
        var hesap = await HesapAlAsync(iptal);
        if (hesap is null)
            return new Sonuc(0, 0, 0,
                "USS hesabı tanımlı değil (entegrasyon: ENABIZ) - paketler kuyrukta bekliyor.");

        var paketler = paketId is null
            ? await _veri.ListeAsync(
                "select * from public.fn_enabiz_siradakiler(@p0)", [adet], OkuPaket, iptal)
            : await _veri.ListeAsync("""
                update public.enabiz_paket
                   set durum = 2, deneme = deneme + 1, son_deneme = now()
                 where id = @p0 and durum in (0, 1, 4)
                returning id, paket_no, durum
                """, [paketId], OkuPaket, iptal);

        if (paketler.Count == 0)
            return new Sonuc(0, 0, 0, paketId is null
                ? "Kuyrukta gönderilecek paket yok."
                : "Paket gönderilebilir durumda değil (eksik alan düzeltilmemiş olabilir).");

        int gonderilen = 0, hatali = 0;
        foreach (var p in paketler)
        {
            var xml = await XmlUretAsync(p.Id, iptal);
            var (basarili, httpKod, kod, mesaj, yanit, sure) =
                await GonderAsync(hesap, xml, iptal);

            // GUNLUK SONUCU DUSUREMEZ (620).
            //
            // Gunluk satiri ONCE yaziliyordu ve yazilamayinca butun istek
            //   400 ile dusuyordu: paket "2 - gonderiliyor"da asili kaliyor,
            //   takip numarasi kaydedilmiyordu. Oysa PAKET USS'YE GITMISTI -
            //   gercek vaka, paket 364: USS kaydi olusturdu, biz `uss_kod`
            //   kolonuna sigmayan takip numarasi yuzunden (`22001 string data
            //   right truncated`) sonucu yazamadik. Ikinci deneme ayni
            //   hastayi IKINCI KEZ kaydederdi.
            //
            // Sira tersine cevrildi: once paketin sonucu islenir, gunluk
            //   sonra ve HATASI YUTULARAK yazilir. Gunluk bir izdir; izi
            //   tutamamak, olmus bir gonderimi olmamis saymak icin sebep
            //   degildir.
            async Task GunlugeYazAsync()
            {
                try
                {
                    await _veri.CalistirAsync("""
                        insert into public.enabiz_gonderim
                               (paket_id, ortam, http_kod, sonuc, uss_kod, uss_mesaj,
                                yanit_ham, sure_ms, kullanici_id)
                        values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
                        """,
                        [p.Id, hesap.Ortam, (short)httpKod, (short)(basarili ? 1 : 2),
                         kod, mesaj, yanit, sure, kullaniciId], iptal);
                }
                catch (Exception h)
                {
                    _gunluk.LogError(h, "e-Nabiz gonderim gunlugu yazilamadi (paket {Id})",
                                     p.Id);
                }
            }

            if (basarili)
            {
                gonderilen++;
                await BasariIsleAsync(p, kod, xml, kullaniciId, iptal);
                await GunlugeYazAsync();
            }
            else
            {
                hatali++;
                await HataIsleAsync(p, kod, mesaj, xml, httpKod, iptal);
                await GunlugeYazAsync();
            }
        }

        _gunluk.LogInformation("e-Nabiz gonderimi: {Alinan} alindi, {Gonderilen} gitti, "
                             + "{Hatali} hata.", paketler.Count, gonderilen, hatali);
        return new Sonuc(paketler.Count, gonderilen, hatali,
            $"{paketler.Count} paket denendi: {gonderilen} gönderildi, {hatali} hata.");
    }

    private sealed record PaketOzet(long Id, string PaketNo, short Durum);

    private static PaketOzet OkuPaket(Npgsql.NpgsqlDataReader o)
        => new(o.GetInt64(o.GetOrdinal("id")),
               o.GetString(o.GetOrdinal("paket_no")),
               o.GetInt16(o.GetOrdinal("durum")));

    /// <summary>
    /// USS hesabı: yoksa null. Test ortamında test_url kullanılır.
    ///
    /// Adres BOŞSA hesap yok sayılır: yarım yapılandırılmış bir hesapla
    /// gönderim denemek, her pakete "bağlanılamadı" hatası yazıp kuyruğu
    /// hatalarla doldururdu.
    /// </summary>
    private async Task<Hesap?> HesapAlAsync(CancellationToken iptal)
    {
        var h = await _veri.TekAsync("""
            select coalesce(nullif(case when e.test_mi = 1 then e.test_url else e.url end, ''),
                            '') as adres,
                   coalesce(e.kullanici_adi, ''), coalesce(e.sifre, ''),
                   case when e.test_mi = 1 then 1 else 2 end as ortam
              from public.entegrasyon_hesap e
             where e.kod = 'ENABIZ' and e.aktif = 1
             limit 1
            """, null,
            o => new Hesap(o.GetString(0), o.GetString(1), o.GetString(2), (short)o.GetInt32(3)),
            iptal);

        return h is null || h.Url.Length == 0 ? null : h;
    }

    /// <summary>SKRS kod sistemi kimlikleri - USS kilavuzundan sabit.</summary>
    private const string MesajTipiSistemi = "0a9ba485-e7e0-4abb-9c86-0a14fd364bb8";
    private const string KurumSistemi = "c3eade04-4f91-5dab-e043-14031b0ac9f9";

    /// <summary>
    /// Paketten USS `SYSMessage` govdesi uretir (602/605).
    ///
    /// SEMA: dokuman/09_ENABIZ_USS_SEMASI.md (rehber.enabiz.gov.tr'den cikarildi).
    ///
    ///   &lt;SYSMessage&gt;
    ///     &lt;messageGuid value="..." /&gt;
    ///     &lt;messageType version="1" codeSystemGuid="..." code="101" value="..." /&gt;
    ///     &lt;documentGenerationTime value="yyyyMMddHHmm" /&gt;
    ///     &lt;author&gt;&lt;healthcareProvider ... code="{kurum}" /&gt;&lt;/author&gt;
    ///     &lt;firmaKodu value="{KTS firma kodu}" /&gt;
    ///     &lt;recordData&gt; ... &lt;/recordData&gt;
    ///   &lt;/SYSMessage&gt;
    ///
    /// IKI KURAL, USS'nin her yerinde gecerli:
    ///  · Degerler ELEMAN METNINDE DEGIL `value` OZNITELIGINDE durur.
    ///  · Tarihler `yyyyMMddHHmm`.
    ///
    /// HIYERARSI: `uss_alan` "/" ile ayrilmis YOL tasir (605) -
    /// "HASTA_KIMLIK_BILGILERI/ADRES_BILGISI/ACIK_ADRES". Yol parcalanir,
    /// ara dugumler bir kez acilir; ayni veri setine dusen alanlar ayni
    /// dugumun altinda toplanir.
    ///
    /// SKRS: `skrs_sistem` doluysa alan kodlanmis yazilir
    /// (version/codeSystemGuid/code + value), bossa duz deger.
    /// </summary>
    private async Task<string> XmlUretAsync(long paketId, CancellationToken iptal)
    {
        var baslik = await _veri.TekAsync("""
            select t.uss_paket_kodu, t.ad, p.sys_takip_no,
                   to_char(coalesce(p.olay_tarihi, now()), 'YYYYMMDDHH24MI'),
                   -- KOLON ESLEMESI (602 duzeltme): `kurum_kodu` TESIS kodudur
                   --   (author/healthcareProvider/@code), `uygulama_kodu` ise
                   --   KTS UYGULAMA KODU - XML'de `firmaKodu` alanina gider.
                   --   Ikisi bastan ters baglanmisti: kuruma 11111111 yer
                   --   tutucusu gidiyordu ve USS "E0009 Kurum kodu hatalı!"
                   --   donuyordu.
                   coalesce(h.kurum_kodu, ''), coalesce(h.uygulama_kodu, ''),
                   coalesce(h.ad, '')
              from public.enabiz_paket p
              join public.enabiz_paket_turu t on t.id = p.paket_turu_id
              left join public.entegrasyon_hesap h
                     on h.kod = 'ENABIZ' and h.aktif = 1
             where p.id = @p0
            """, [paketId],
            o => new
            {
                Kod = o.GetString(0), Ad = o.GetString(1), Takip = o.GetString(2),
                Zaman = o.IsDBNull(3) ? "" : o.GetString(3),
                KurumKodu = o.GetString(4), FirmaKodu = o.GetString(5),
                KurumAdi = o.GetString(6),
            }, iptal);
        if (baslik is null) return "";

        var alanlar = await _veri.ListeAsync("""
            select uss_alan, deger, skrs_kod, skrs_sistem, skrs_surum
              from public.enabiz_paket_alan
             -- BOS ALANLAR DA YAZILIR (602). USS govdeyi XSD ile dogruluyor:
             --   semadaki her eleman BULUNMAK ZORUNDA, degeri bos olsa bile.
             --   "Bos olani atla" kurali su hatayi uretiyordu:
             --     E1014 "Xml dokumaninda eksik elemanlar var: UYRUK,
             --            ANNE_KIMLIK_NUMARASI, ... HASTA_TIPI"
             --   (gercek vaka, paket 194). Yani USS icin "bos gonderildi" ile
             --   "hic gonderilmedi" AYNI SEY DEGIL - ilki gecerli, ikincisi
             --   sema ihlali. Uretici hangi alanlari cikardiysa hepsi gider.
             where paket_id = @p0
             order by sira
            """, [paketId],
            o => (Yol: o.GetString(0), Deger: o.GetString(1),
                  Kod: o.GetString(2), Sistem: o.GetString(3), Surum: o.GetString(4)),
            iptal);

        var kayit = new XElement("recordData");
        foreach (var a in alanlar)
        {
            // Yolun son parcasi ALAN, oncekiler VERI SETI / GRUP dugumleri.
            var parcalar = a.Yol.Split('/', StringSplitOptions.RemoveEmptyEntries);
            if (parcalar.Length == 0) continue;

            var dugum = kayit;
            for (var i = 0; i < parcalar.Length - 1; i++)
            {
                // Ara dugum BIR KEZ acilir: ayni veri setinin alanlari
                //   birbirinin altinda toplansin, her alan icin yeni bir
                //   HASTA_KIMLIK_BILGILERI dogmasin.
                //
                // TEKRARLI GRUPLAR ISTISNA (623): 102 paketinde her kalem bir
                //   `ISLEM_BILGISI`dir ve hepsi ayni ada sahiptir. Ad
                //   esitligiyle birlestirmek butun kalemleri TEK grubun
                //   icine yigardi - USS de tek islem gormus olurdu. Yol
                //   parcasi `ISLEM_BILGISI[3]` gibi indeks tasiyorsa indeks
                //   AYIRT EDICIDIR: ayni indeks ayni gruba, farkli indeks
                //   yeni gruba gider. Indeks XML'e YAZILMAZ, yalnizca
                //   uretim sirasinda kimliktir.
                var ad = parcalar[i];
                var indeks = "";
                var koseli = ad.IndexOf('[');
                if (koseli > 0 && ad.EndsWith(']'))
                {
                    indeks = ad[(koseli + 1)..^1];
                    ad = ad[..koseli];
                }

                XElement? alt;
                if (indeks.Length > 0)
                {
                    // Ayni indeksi tasiyan kardes aranir; isaret gecici bir
                    //   oznitelikte durur ve govde tamamlaninca silinir.
                    alt = dugum.Elements(ad).FirstOrDefault(
                        e => (string?)e.Attribute("__ix") == indeks);
                    if (alt is null)
                    {
                        alt = new XElement(ad, new XAttribute("__ix", indeks));
                        dugum.Add(alt);
                    }
                }
                else
                {
                    alt = dugum.Element(ad);
                    if (alt is null) { alt = new XElement(ad); dugum.Add(alt); }
                }
                dugum = alt;
            }

            // KODU OLMAYAN KODLU ALAN HIC YAZILMAZ (611).
            //
            // USS'nin kurali canli denemeyle netlesti: SKRS kod sistemine
            //   bagli bir eleman ya GECERLI BIR KODLA gelir ya da HIC
            //   GELMEZ. Arasi yok -
            //     · kodsuz/guid'siz yazarsak  -> "E1011 ADRES_KODU_SEVIYESI
            //       xml elemani icin belirtilen Guid degeri gecerli degil",
            //     · guid'i yazip kodu bos birakirsak -> "E1008 Code '' ve
            //       value '' degerleriyle Guid '...' Kod Sisteminde bir
            //       tanimlama bulunmuyor",
            //     · elemani hic yazmazsak -> KABUL (ayni paket bir sonraki
            //       alana gecti).
            //
            // Onceki davranis "duz eleman olarak yaz" idi; sema ihlali
            //   sayilmasin diye. Yanlismis: eksik kod, eksik ELEMAN olarak
            //   bildirilmeli. Zorunlu bir alan boyle dusuyorsa USS zaten
            //   adiyla soyler ve eslemeyi kurmak gerekir - sessizce gecmez.
            if (a.Sistem.Length > 0 && a.Kod.Length == 0) continue;

            var eleman = new XElement(parcalar[^1]);
            if (a.Sistem.Length > 0)
            {
                eleman.Add(new XAttribute("version", a.Surum.Length > 0 ? a.Surum : "1"));
                eleman.Add(new XAttribute("codeSystemGuid", a.Sistem));
                eleman.Add(new XAttribute("code", a.Kod));
            }
            eleman.Add(new XAttribute("value", a.Deger));
            dugum.Add(eleman);
        }

        // Gecici gruplama isaretleri govdede kalmaz.
        foreach (var oz in kayit.Descendants().Attributes("__ix").ToList())
            oz.Remove();

        // 301 SILME: govde tek alandir ve paketin KENDI takip numarasindan
        //   uretilir - alan tablosuna yazmaya gerek yok (605).
        if (baslik.Kod == "301" && !kayit.HasElements && baslik.Takip.Length > 0)
            kayit.Add(new XElement("HASTA_TAKIP_BILGISI",
                new XElement("SYSTakipNo", new XAttribute("value", baslik.Takip))));

        var kok = new XElement("SYSMessage",
            new XElement("messageGuid", new XAttribute("value", Guid.NewGuid().ToString())),
            new XElement("messageType",
                new XAttribute("version", "1"),
                new XAttribute("codeSystemGuid", MesajTipiSistemi),
                new XAttribute("code", baslik.Kod),
                new XAttribute("value", baslik.Ad)),
            new XElement("documentGenerationTime", new XAttribute("value", baslik.Zaman)),
            new XElement("author",
                new XElement("healthcareProvider",
                    new XAttribute("version", "1"),
                    new XAttribute("codeSystemGuid", KurumSistemi),
                    new XAttribute("code", baslik.KurumKodu),
                    new XAttribute("value", baslik.KurumAdi))),
            new XElement("firmaKodu", new XAttribute("value", baslik.FirmaKodu)),
            kayit);

        // BILDIRIM DEGIL BELGE: XML bildirimi olmadan doner - govde `input`
        //   icine METIN olarak gomulecek (SoapZarfla), oraya ikinci bir
        //   <?xml?> satiri girmesi ayristiriciyi bozar.
        return kok.ToString(SaveOptions.DisableFormatting);
    }

    /// <summary>USS servisinin TEK SOAP eylemi (WSDL: BasicHttpBinding_ISYSWS).</summary>
    private const string SoapEylemi =
        "https://sys.sagliknet.saglik.gov.tr/SYS/ISYSWS/SYSSendMessage";

    private const string WsseAd =
        "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd";
    private const string WsuAd =
        "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd";
    private const string SifreTipi =
        "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText";

    /// <summary>
    /// Paket XML'ini SOAP 1.1 zarfina sarar - USS kilavuzundaki ornek istekle
    /// birebir (dokuman/09_ENABIZ_USS_SEMASI.md).
    ///
    /// IKI NOKTA DENEYEREK DOGRULANDI:
    ///  1. KIMLIK WS-SECURITY ILE: HTTP Basic auth basligi sunucuda YOK
    ///     SAYILIYOR - sahte kimlikle ve hic kimliksiz istek ayni faultu
    ///     dondurdu ("Kullanici adi veya sifre tanimli degil!"). Kullanici/sifre
    ///     `wsse:UsernameToken` icinde gider.
    ///  2. `input` METIN (xs:string) ALIR - ham XML DEGIL. Kilavuzun ornek
    ///     istegi `SYSMessage`i ic ice gosteriyor ama SERVIS oyle kabul
    ///     etmiyor; ham eleman gonderilince WCF soyle diyor:
    ///       "End element 'input' ... expected. Found element ..."
    ///     `?xsd=xsd0` da ayni seyi soyluyor (`input` type="xs:string").
    ///     Bu yuzden paket XML'i KACISLANIR: XElement'in metin icerigi olarak
    ///     verilir, XDocument kacislamayi kendisi yapar.
    ///  3. `SYSSendMessage` AD ALANI istegin govdesinde
    ///     'https://sys.sagliknet.saglik.gov.tr/SYS/' olmali - asagida.
    /// </summary>
    private static string SoapZarfla(string paketXml, Hesap hesap)
    {
        XNamespace s = "http://schemas.xmlsoap.org/soap/envelope/";
        XNamespace wsse = WsseAd;
        XNamespace wsu = WsuAd;
        // SUNUCUNUN BEKLEDIGI AD ALANI (602) - deneyerek dogrulandi. WCF
        //   deserializer'i acikca soyledi:
        //     "Expected ... namespace 'https://sys.sagliknet.saglik.gov.tr/SYS/'.
        //      Found ... namespace 'http://ns.sagliknet.saglik.gov.tr'"
        //   Kilavuzun ornek XML'inde `SYSSendMessage` ad alanSIZ gorunuyor ve
        //   xsd0'daki hedef ad alani (ns.sagliknet...) YANILTICI - istegin
        //   govdesinde gecerli olan budur.
        XNamespace uss = "https://sys.sagliknet.saglik.gov.tr/SYS/";

        var zarf = new XElement(s + "Envelope",
            new XAttribute(XNamespace.Xmlns + "soap", s.NamespaceName),
            new XAttribute(XNamespace.Xmlns + "wsse", WsseAd),
            new XAttribute(XNamespace.Xmlns + "wsu", WsuAd),
            new XElement(s + "Header",
                new XElement(wsse + "Security",
                    new XElement(wsse + "UsernameToken",
                        new XAttribute(wsu + "Id", "SecurityToken-" + Guid.NewGuid()),
                        new XElement(wsse + "Username", hesap.Kullanici),
                        new XElement(wsse + "Password",
                            new XAttribute("Type", SifreTipi), hesap.Sifre)))),
            new XElement(s + "Body",
                new XElement(uss + "SYSSendMessage",
                    // Paket METIN olarak gecer: XElement'e string verince
                    //   XDocument.ToString() `<` ve `&` kacislamasini kendisi
                    //   yapar - elle Escape cagirmak cift kacislama uretirdi.
                    new XElement(uss + "input", paketXml))));

        return new XDocument(new XDeclaration("1.0", "utf-8", null), zarf).ToString();
    }

    /// <summary>
    /// SOAP yanitindan is sonucunu cikarir: `SYSSendMessageResult` icerigini.
    /// Fault gelirse faultstring dondurulur - hata mesaji kayda gecsin.
    /// Zarf cozulemezse ham govde aynen doner.
    /// </summary>
    private static string SoapCoz(string zarf)
    {
        if (string.IsNullOrWhiteSpace(zarf)) return "";
        try
        {
            var kok = XDocument.Parse(zarf).Root;
            var sonuc = kok?.Descendants().FirstOrDefault(
                x => x.Name.LocalName == "SYSSendMessageResult");
            // Sonuc ELEMAN tasiyabilir (SYSMessage cevabi) ya da metin olabilir.
            if (sonuc is not null)
                return sonuc.HasElements
                    ? string.Concat(sonuc.Elements().Select(e => e.ToString()))
                    : sonuc.Value;

            var fault = kok?.Descendants().FirstOrDefault(
                x => x.Name.LocalName is "faultstring" or "Reason");
            return fault?.Value ?? zarf;
        }
        catch { return zarf; }
    }

    private async Task<(bool Basarili, int HttpKod, string Kod, string Mesaj, string Yanit,
                        int SureMs)>
        GonderAsync(Hesap hesap, string xml, CancellationToken iptal)
    {
        var kronometre = Stopwatch.StartNew();
        try
        {
            var istemci = _http.CreateClient("enabiz");
            istemci.Timeout = TimeSpan.FromSeconds(60);

            // SOAP 1.1 ZARFI (602): USS servisi WCF `BasicHttpBinding_ISYSWS` -
            //   duz XML POST'u kabul etmez. WSDL'den dogrulanan sozlesme TEK
            //   metotludur:
            //
            //       SYSSendMessage(input: string) -> string
            //
            //   Paket XML'i `input` icine METIN olarak gomulur (bu yuzden
            //   kacislanir); gonderim de silme de ayni metottan gecer, hangisi
            //   oldugunu PAKET KODU soyler (100 serisi kayit, 300 serisi silme).
            using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Url)
            {
                Content = new StringContent(SoapZarfla(xml, hesap), Encoding.UTF8, "text/xml"),
            };
            // WCF SOAP 1.1: eylem HTTP basliginda, tirnak icinde.
            istek.Headers.TryAddWithoutValidation("SOAPAction", $"\"{SoapEylemi}\"");
            // Basic auth EKLENMEZ (602): USS onu yok sayiyor, kimlik zarfin
            //   WS-Security basliginda gidiyor. Eklemek, kimligi gereksiz yere
            //   ikinci bir yerde tasimak olurdu.

            using var yanit = await istemci.SendAsync(istek, iptal);
            var zarf = await yanit.Content.ReadAsStringAsync(iptal);
            kronometre.Stop();

            // Yanit da zarflidir: is sonucu `SYSSendMessageResult` icinde METIN
            //   olarak doner. Cozulemezse ham zarf kullanilir - tani icin o da
            //   islevsiz degil.
            var govde = SoapCoz(zarf);
            var kod = UssKimlikCoz(govde);

            // HTTP 200 BASARI DEMEK DEGIL (602): USS is hatasini da 200 ile
            //   dondurur, cevabin icinde:
            //     <sonucKodu value="E1004"/>
            //     <sonucMesaji value="SYSTakipNo bos olamaz"/>
            //   Yalniz HTTP koduna bakmak, USS'ye HIC KAYDEDILMEMIS paketi
            //   "gonderildi" (durum 3) isaretliyordu - gercek vaka, paket 132.
            //   Basari olcusu SONUC KODUDUR: 'S' ile baslar (S0000), hata 'E'.
            var (sonucKodu, sonucMesaji) = SonucCoz(govde);

            // E2033 HATA DEGIL, "BU KAYIT ZATEN BENDE"DIR.
            //
            // USS ayni HASTANE_REFERANS_NUMARASI ile ikinci kez kayit
            //   istendiginde reddediyor ama mevcut numarayi CEVABIN ICINDE
            //   veriyor: "Kullanabileceginiz SYSTakipNo=2BUH919XCOI0CS9XWQVTU".
            //   Basvuru USS'de vardir - istedigimiz durum zaten budur.
            //   Hata sayarsak paket sonsuza kadar "hatali" kalir, takip
            //   numarasi yazilmaz ve 301 ile SILINEMEZ; oysa numara elimizde.
            //
            // Gercek vaka: paket 364'un ilk gonderimi USS'ye ulasti, donen
            //   numara 21 karakterdi ve 20'lik gunluk kolonuna sigmadi (620);
            //   numara kaybolmustu. Ikinci gonderim E2033 ile onu geri verdi.
            var kimlikVar = kod.Length > 0;
            var basariliMi = yanit.IsSuccessStatusCode
                          && (!sonucKodu.StartsWith('E') || (sonucKodu == "E2033" && kimlikVar));

            return (basariliMi, (int)yanit.StatusCode,
                    // Kimlik cozulemezse sonuc kodu kayda gecsin: kuyruk
                    //   ekraninda "neden gitmedi" sorusunun cevabi odur.
                    kod.Length > 0 ? kod : sonucKodu,
                    basariliMi ? ""
                        : (sonucMesaji.Length > 0 ? Kirp(sonucMesaji, 400)
                                                  : Kirp(govde, 400)),
                    Kirp(govde, 4000), (int)kronometre.ElapsedMilliseconds);
        }
        catch (Exception h)
        {
            kronometre.Stop();
            // Baglanti hatasi SERVIS hatasidir (http 0): otomatik tekrarlanir.
            return (false, 0, "BAGLANTI", Kirp(h.Message, 400), "",
                    (int)kronometre.ElapsedMilliseconds);
        }
    }

    /// <summary>
    /// USS cevap govdesini ayristirir (602).
    ///
    /// GOVDE XML BILDIRIMIYLE BASLAR: `&lt;?xml version="1.0"…?&gt;`. Onu bir
    /// sarmalayicinin ICINE koyup ayristirmak XmlException atar - bildirim
    /// yalniz belgenin basinda durabilir. Hata catch'e dusup BOS sonuc
    /// donduruyor, bos sonuc da "hata yok" sayilip USS'nin REDDETTIGI paketi
    /// "gonderildi" isaretliyordu (gercek vaka: E0009 "Kurum kodu hatalı!"
    /// basarili kaydedildi). Bildirim kirpilir, sonra sarilir: govde tek kok
    /// tasimayabilir (SoapCoz birden fazla eleman dondurebilir).
    /// </summary>
    private static XElement? GovdeAyristir(string govde)
    {
        if (string.IsNullOrWhiteSpace(govde)) return null;
        var metin = govde.TrimStart();
        if (metin.StartsWith("<?xml", StringComparison.OrdinalIgnoreCase))
        {
            var son = metin.IndexOf("?>", StringComparison.Ordinal);
            if (son > 0) metin = metin[(son + 2)..].TrimStart();
        }
        try { return XElement.Parse("<k>" + metin + "</k>"); }
        catch { return null; }
    }

    /// <summary>
    /// Cevaptaki is sonucunu okur: (sonucKodu, sonucMesaji).
    ///
    /// USS her iki durumda da HTTP 200 doner; ayrimi `KayitCevabi` icindeki
    /// sonuc kodu yapar - 'S' basari (S0000), 'E' hata (E1004). Kod yoksa
    /// bos donulur ve karar HTTP koduna kalir.
    /// </summary>
    private static (string Kod, string Mesaj) SonucCoz(string govde)
    {
        var kok = GovdeAyristir(govde);
        if (kok is null) return ("", "");
        try
        {
            string Al(string ad) => kok.Descendants()
                .FirstOrDefault(x => x.Name.LocalName.Equals(ad, StringComparison.OrdinalIgnoreCase))
                ?.Attribute("value")?.Value ?? "";
            return (Al("sonucKodu").Trim(), Al("sonucMesaji").Trim());
        }
        catch { return ("", ""); }
    }

    /// <summary>
    /// Yanittan SYS TAKIP NUMARASINI cikarir (602).
    ///
    /// Kilavuzdaki cevap sablonu (dokuman/09_ENABIZ_USS_SEMASI.md):
    ///
    ///     &lt;recordData&gt;&lt;KayitCevabi&gt;
    ///       &lt;sonucKodu value="S0000"/&gt;
    ///       &lt;sonucMesaji value="Islem Basari ile Sonuclandi."/&gt;
    ///       &lt;SYSTakipNo value="..."/&gt;
    ///     &lt;/KayitCevabi&gt;&lt;/recordData&gt;
    ///
    /// Deger ELEMAN METNINDE DEGIL `value` OZNITELIGINDE durur - USS'nin her
    /// yerdeki kurali bu. Takip numarasi basvuruyla saklanmali: sonraki
    /// paketler ve 301 SILME onu kullanir.
    ///
    /// Bulunamazsa bos doner - kimligi cozememek gonderimi basarisiz saymak
    /// icin sebep degil.
    /// </summary>
    private static string UssKimlikCoz(string govde)
    {
        var kok = GovdeAyristir(govde);
        if (kok is null) return "";
        try
        {
            var dugum = kok.Descendants().FirstOrDefault(
                x => x.Name.LocalName.Equals("SYSTakipNo", StringComparison.OrdinalIgnoreCase));
            var deger = dugum?.Attribute("value")?.Value ?? dugum?.Value ?? "";
            if (deger.Trim().Length > 0) return Kirp(deger.Trim(), 64);

            // YEDEK YOL: E2033'te numara kendi elemaninda degil, sonuc
            //   mesajinin METNINDE geliyor - "... Kullanabileceginiz
            //   SYSTakipNo=2BUH919XCOI0CS9XWQVTU". Kayit USS'de var ve
            //   numarasi burada; okumamak, elimizdeki tek kimligi atmaktir.
            var esles = System.Text.RegularExpressions.Regex.Match(
                govde, @"SYSTakipNo\s*=\s*([A-Za-z0-9]+)");
            return esles.Success ? Kirp(esles.Groups[1].Value, 64) : "";
        }
        catch { return ""; }
    }

    /// <summary>
    /// BASARILI gönderimin kayda geçmesi.
    ///
    /// Dört iş, hepsi USS "aldım" dedikten sonra: paketi gönderildi işaretle,
    /// takip numarasını başvuruya yaz, silme paketiyse izleri temizle, 101 ise
    /// işlem paketini doğur. `CalistirAsync` içinde tek gövdedeydi ve gönderim
    /// döngüsünü okunmaz yapıyordu.
    /// </summary>
    private async Task BasariIsleAsync(PaketOzet p, string kod, string xml,
                                       int? kullaniciId, CancellationToken iptal)
    {

            await _veri.CalistirAsync("""
                update public.enabiz_paket
                   set durum = 3, uss_paket_id = @p1, ham_xml = @p2,
                       -- SYS TAKIP NUMARASI (605): 101'in yanitinda doner ve
                       --   basvurunun USS'deki kimligidir. Sonraki paketler
                       --   (103 muayene, 106 cikis) ve 301 SILME onu tasimak
                       --   ZORUNDA - yazilmazsa o paketler uretilemez.
                       --   Bos cevapta eski deger korunur: ikinci bir
                       --   gonderim takip numarasini silmesin.
                       sys_takip_no = case when @p1 <> '' then @p1
                                           else sys_takip_no end,
                       hata_kodu = '', hata_mesaj = '', hata_sinifi = 0
                 where id = @p0
                """, [p.Id, kod, xml], iptal);

            // TAKIP NUMARASI BASVURUYA DA YAZILIR (608). Kilavuz: "alinan
            //   SYSTakipNo degeri ilgili BASVURUYLA ILISKILI olarak HBYS
            //   sisteminde tutulmalidir." Numara paketin degil basvurunun
            //   ozelligi: basvuru USS'de onunla yasar, sonraki paketler
            //   (103/106/301) onu tasir. Pakettekini de birakiyoruz - o,
            //   "bu gonderim hangi numarayi dondurdu" izidir.
            //
            //   YALNIZ 101 ve BASVURU KAYNAKLI pakette: muayene kaynakli
            //   paketin kaynak_id'si basvuru degil MUAYENE kimligidir,
            //   oraya yazmak baska bir basvurunun numarasini bozardi.
            if (kod.Length > 0)
                await _veri.CalistirAsync("""
                    update public.belge_basvuru bb
                       set sys_takip_no = @p1
                      from public.enabiz_paket p
                      join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                     where p.id = @p0 and p.kaynak_tur = 1
                       and p.kaynak_id = bb.id and t.uss_paket_kodu = '101'
                    """, [p.Id, kod], iptal);

            // SILME GITTIYSE KAYIT ARTIK USS'DE YOK (620).
            //
            // 301 basariyla gonderildiginde iki iz geride kaliyordu:
            //   basvuru silinmis kaydin takip numarasini tasimayi
            //   surduruyor, kaynak 101 paketi de "gonderildi" gorunuyordu.
            //   Ikisi de yanlis: numara USS'de karsiligi olmayan bir
            //   kimlik, sonraki 103/106 paketleri onunla gitse reddedilir;
            //   "gonderildi" ise iptal edilmis bir paket icin yanlis durum.
            //
            // Kaynak paket 5'e (iptal) cekilir - iptalin USS'ye ULASTIGI
            //   an burasidir; iptal ucu bilerek beklemisti.
            await _veri.CalistirAsync("""
                update public.belge_basvuru bb
                   set sys_takip_no = ''
                  from public.enabiz_paket p
                  join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                 where p.id = @p0 and t.uss_paket_kodu = '301'
                   and p.kaynak_tur = 1 and p.kaynak_id = bb.id
                """, [p.Id], iptal);

            await _veri.CalistirAsync("""
                update public.enabiz_paket k
                   set durum = 5, degistirme_tarihi = now()
                  from public.enabiz_paket s
                  join public.enabiz_paket_turu st on st.id = s.paket_turu_id
                  join public.enabiz_paket_turu kt on kt.uss_paket_kodu = '101'
                 where s.id = @p0 and st.uss_paket_kodu = '301'
                   and k.paket_turu_id = kt.id
                   and k.kaynak_tur = s.kaynak_tur and k.kaynak_id = s.kaynak_id
                   and k.durum = 3
                """, [p.Id], iptal);

            // 101 GIDINCE ISLEM PAKETI HEMEN DOGAR (623).
            //
            // 102'nin ilk zorunlu alani SYSTakipNo; numara da tam BURADA,
            //   101'in yanitinda geliyor. Uretim belgenin bir sonraki
            //   KAYDEDILMESINE birakilmisti ve pratikte hic olmuyordu:
            //   kullanici kalemi girip kaydediyor (numara henuz yok),
            //   101'i gonderiyor (numara geliyor) ve bir daha kaydetmek
            //   icin sebebi kalmiyor - islem bildirimi dogmuyordu.
            //
            // SESSIZ: uretim gonderimi DUSURMEZ. 101 USS'ye ulasmistir;
            //   102 uretilemezse bu, basarili gonderimi basarisiz
            //   gostermek icin sebep degil.
            await IslemPaketiUretAsync(p.Id, kullaniciId ?? 0, iptal);

    }

    /// <summary>
    /// BAŞARISIZ gönderimin kayda geçmesi: durum, hata sınıfı ve geri çekilme.
    /// </summary>
    private async Task HataIsleAsync(PaketOzet p, string kod, string mesaj, string xml,
                                     int httpKod, CancellationToken iptal)
    {

            // HATA SINIFI: servis hatasi (5xx / zaman asimi) tekrarlanir,
            //   veri hatasi tekrarlanmaz - ayni veriyi bes kez gondermek
            //   ayni cevabi bes kez almaktir.
            var sinif = (short)(httpKod is 0 or >= 500 ? 2 : httpKod is 401 or 403 ? 3 : 1);
            var geriDon = sinif == 2 ? Math.Min(60, (int)Math.Pow(3, p.Durum + 1)) : 0;
            await _veri.CalistirAsync("""
                update public.enabiz_paket
                   set durum = 4, hata_kodu = @p1, hata_mesaj = @p2, hata_sinifi = @p3,
                       ham_xml = @p4,
                       planlanan = case when @p3 = 2
                                        then now() + (@p5 || ' minutes')::interval
                                        else planlanan end
                 where id = @p0
                """, [p.Id, kod, mesaj, sinif, xml, geriDon], iptal);

    }

    /// <summary>
    /// Gonderilen paket 101 ise, ayni basvurunun ISLEM (102) paketini uretir.
    ///
    /// Kalem yoksa uretici zaten paket acmaz. "Ayni icerik -> ayni paket"
    /// kurali mukerrer satir dogurmaz: kalem eklendikce icerik degisir ve
    /// yeni paket uretilir.
    /// </summary>
    private async Task IslemPaketiUretAsync(long paketId, int kullaniciId,
                                            CancellationToken iptal)
    {
        try
        {
            var kaynak = await _veri.TekDegerAsync<int>("""
                select coalesce(p.kaynak_id, 0)
                  from public.enabiz_paket p
                  join public.enabiz_paket_turu t on t.id = p.paket_turu_id
                 where p.id = @p0 and t.uss_paket_kodu = '101' and p.kaynak_tur = 1
                """, [paketId], iptal);
            if (kaynak == 0) return;

            await _uretici.UretAsync("HASTA_ISLEM", kaynak, kullaniciId, iptal);
        }
        catch (Exception h)
        {
            _gunluk.LogError(h, "e-Nabiz islem paketi uretilemedi (101 paket {Id})",
                             paketId);
        }
    }

    private static string Kirp(string metin, int en)
        => string.IsNullOrEmpty(metin) ? "" : metin.Length <= en ? metin : metin[..en];
}
