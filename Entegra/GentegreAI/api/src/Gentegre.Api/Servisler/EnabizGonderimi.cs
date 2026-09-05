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

    public EnabizGonderimi(VeriKaynagi veri, IHttpClientFactory http,
                           ILogger<EnabizGonderimi> gunluk)
    {
        _veri = veri;
        _http = http;
        _gunluk = gunluk;
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

            await _veri.CalistirAsync("""
                insert into public.enabiz_gonderim
                       (paket_id, ortam, http_kod, sonuc, uss_kod, uss_mesaj, yanit_ham,
                        sure_ms, kullanici_id)
                values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8)
                """,
                [p.Id, hesap.Ortam, (short)httpKod, (short)(basarili ? 1 : 2), kod, mesaj,
                 yanit, sure, kullaniciId], iptal);

            if (basarili)
            {
                gonderilen++;
                await _veri.CalistirAsync("""
                    update public.enabiz_paket
                       set durum = 3, uss_paket_id = @p1, ham_xml = @p2,
                           hata_kodu = '', hata_mesaj = '', hata_sinifi = 0
                     where id = @p0
                    """, [p.Id, kod, xml], iptal);
            }
            else
            {
                hatali++;
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

    /// <summary>
    /// Paketten XML üretir.
    ///
    /// ŞEMA GEÇİCİ: USS kılavuzunun gerçek şeması KTS tescili sonrası gelecek.
    /// Alanlar ad-değer olarak sarılıyor; şema geldiğinde değişecek TEK yer
    /// burasıdır.
    /// </summary>
    private async Task<string> XmlUretAsync(long paketId, CancellationToken iptal)
    {
        var baslik = await _veri.TekAsync("""
            select t.uss_paket_kodu, t.uss_surum, p.paket_no,
                   to_char(p.olay_tarihi, 'YYYY-MM-DD"T"HH24:MI:SS')
              from public.enabiz_paket p
              join public.enabiz_paket_turu t on t.id = p.paket_turu_id
             where p.id = @p0
            """, [paketId],
            o => new { Kod = o.GetString(0), Surum = o.GetString(1), No = o.GetString(2),
                       Olay = o.IsDBNull(3) ? "" : o.GetString(3) }, iptal);
        if (baslik is null) return "";

        var alanlar = await _veri.ListeAsync("""
            select uss_alan, deger from public.enabiz_paket_alan
             where paket_id = @p0 and deger <> '' order by sira
            """, [paketId], o => (Ad: o.GetString(0), Deger: o.GetString(1)), iptal);

        var kok = new XElement("GonderimPaketi",
            new XAttribute("paketKodu", baslik.Kod),
            new XAttribute("surum", baslik.Surum),
            new XElement("PaketNo", baslik.No),
            new XElement("OlayZamani", baslik.Olay),
            new XElement("Alanlar", alanlar.Select(a => new XElement(a.Ad, a.Deger))));

        return new XDocument(new XDeclaration("1.0", "utf-8", null), kok).ToString();
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

            using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Url)
            {
                Content = new StringContent(xml, Encoding.UTF8, "application/xml"),
            };
            if (hesap.Kullanici.Length > 0)
                istek.Headers.Authorization = new("Basic", Convert.ToBase64String(
                    Encoding.UTF8.GetBytes($"{hesap.Kullanici}:{hesap.Sifre}")));

            using var yanit = await istemci.SendAsync(istek, iptal);
            var govde = await yanit.Content.ReadAsStringAsync(iptal);
            kronometre.Stop();

            var kod = UssKimlikCoz(govde);
            return (yanit.IsSuccessStatusCode, (int)yanit.StatusCode, kod,
                    yanit.IsSuccessStatusCode ? "" : Kirp(govde, 400),
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
    /// Yanıttan USS paket kimliğini çıkarır (silme/güncelleme bununla yapılır).
    ///
    /// Gerçek yanıt şeması gelene kadar toleranslı: XML içinde kimlik benzeri
    /// bir eleman aranır, bulunamazsa boş döner - kimliği bulamamak gönderimi
    /// başarısız saymak için sebep değil.
    /// </summary>
    private static string UssKimlikCoz(string govde)
    {
        try
        {
            var kok = XDocument.Parse(govde).Root;
            var kimlik = kok?.Descendants()
                .FirstOrDefault(x => x.Name.LocalName.Contains("PaketId",
                                        StringComparison.OrdinalIgnoreCase)
                                  || x.Name.LocalName.Contains("Kimlik",
                                        StringComparison.OrdinalIgnoreCase));
            return Kirp(kimlik?.Value ?? "", 64);
        }
        catch { return ""; }
    }

    private static string Kirp(string metin, int en)
        => string.IsNullOrEmpty(metin) ? "" : metin.Length <= en ? metin : metin[..en];
}
