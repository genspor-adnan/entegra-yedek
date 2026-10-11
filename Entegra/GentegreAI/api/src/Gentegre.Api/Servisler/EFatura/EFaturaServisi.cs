using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.Xsl;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Servisler.EFatura;

/// <summary>
/// GİDEN e-FATURA / e-ARŞİV - Delphi <c>TEBelgeOlusturucu</c> (UEBelgeOlusturucu.pas)
/// menü adımlarının karşılığı: Hazırla · Önizle · Gönder · PDF/HTML/XML Kaydet ·
/// Seri Değiştir · Hazırı Geri Al · Mesaj Geçmişi.
///
/// Akış Delphi'deki gibi:
///   HAZIRLA  doğrula (numara tüketilmeden) → alıcı GİB kullanıcısı mı (e-Fatura /
///            e-Arşiv) → seri + numara → e_belge kaydı (durum 1 / 11).
///   GÖNDER   sıra kuralı → giriş → izibiz JSON (o anki veriden) → POST →
///            durum 2 / 12, efatura_sonuc 9; hata: efatura_sonuc 3, belge hazır kalır.
///   GÖRÜNÜM  UBL + belge türünün XSLT'si sunucuda dönüştürülür; gönderilmemiş
///            belgede PDF / HTML'e "TASLAK" filigranı.
/// Her adım e_belge_mesaj'a (Delphi EBELGEMESAJ) ve islem_log'a (LogEBelgeIslem) yazar.
/// </summary>
public sealed class EFaturaServisi(VeriKaynagi veri, IHttpClientFactory istemciUretici)
{
    private const int LogTabloBelge = 30;
    private const string TestAlias = "urn:mail:defaultpk@izibiz.com.tr";
    private static readonly JsonSerializerOptions Duz = new() { WriteIndented = false };

    /// <summary>Hazırla isteği. Boş alanlar sunucunun sorusuna verilen cevaplardır.</summary>
    public sealed record HazirlaIstegi(string? Tur = null, string? Eposta = null, string? Alias = null, bool IkinciSeri = false,
                                       long? BaslangicNo = null);

    /// <summary>
    /// Hazırla sonucu. <c>Soru</c> doluysa HİÇBİR ŞEY yazılmadı: arayüz soruyu
    /// sorar ve cevabıyla yeniden çağırır (Delphi'de aynı yerde açılan diyaloglar:
    /// test ortamı e-Fatura/e-Arşiv, MailOnayAl, AliasSec).
    /// </summary>
    public sealed record HazirlaSonucu(string? Soru, string Mesaj, string BelgeNo = "", string TurAdi = "",
                                       string Varsayilan = "", IReadOnlyList<string>? Secenekler = null);

    public sealed record MesajSatiri(DateTime Tarih, string Islem, string Tip, string Mesaj, int HttpKodu, string Servis, string Kullanici);

    // ================================================================ durum ==
    public async Task<object> DurumAsync(int belgeId, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var v = await EFaturaVerisi.OkuAsync(b, null, belgeId, iptal);
        var kullanimda = await b.TekDegerAsync<bool?>("select public.fn_ebelge_acik(@p0)", null, [v.SubeId], iptal) ?? false;
        bool testMi = false;
        try { testMi = (await EBelgeIstemcisi.HesapAsync(b, v.SubeId, "e-Fatura", iptal)).TestMi; } catch (GentegreHatasi) { }
        string[] kodlar = ["ebelge.hazirla", "ebelge.onizle", "ebelge.gonder", "ebelge.pdf", "ebelge.html", "ebelge.xml",
                           "ebelge.seri", "ebelge.sifirla", "ebelge.mesajlar"];
        return new
        {
            belgeId, v.Tur, v.EfaturaDurum, v.EfaturaSonuc, kullanimda, testMi,
            turAdi = v.EfaturaDurum == 0 ? "e-Fatura" : EFaturaKodlari.TurAdi(v.EfaturaDurum),
            durumAdi = EFaturaKodlari.DurumAdi(v.EfaturaDurum, v.EfaturaSonuc),
            belgeNo = v.EBelgeNo.Length > 0 ? v.EBelgeNo : v.BelgeNo, ettn = v.Uuid, aliciAlias = v.AliciAlias,
            dosyaAdi = DosyaAdi(v),
            engeller = kodlar.ToDictionary(k => k, k => kullanimda
                ? EFaturaKodlari.Engel(k, v.Tur, v.Durum, v.EfaturaDurum)
                : "Şube e-Fatura mükellefi değil (Yönetim › Firma Bilgileri › e-Belge)."),
        };
    }

    // ============================================================== hazırla ==
    public async Task<HazirlaSonucu> HazirlaAsync(int belgeId, HazirlaIstegi istek, YazmaBaglami bg, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var v = await EFaturaVerisi.OkuAsync(b, null, belgeId, iptal);
        if (EFaturaKodlari.Engel("ebelge.hazirla", v.Tur, v.Durum, v.EfaturaDurum) is { } engel)
            throw GentegreHatasi.IsKurali(engel);
        if (!(await b.TekDegerAsync<bool?>("select public.fn_ebelge_acik(@p0)", null, [v.SubeId], iptal) ?? false))
            throw GentegreHatasi.IsKurali("Şube e-Fatura mükellefi değil (Yönetim › Firma Bilgileri › e-Belge).");

        // 1) DOĞRULAMA - numara tüketilmeden.
        var eksik = v.Eksikler();
        if (eksik.Count > 0)
            throw GentegreHatasi.IsKurali("e-Fatura hazırlanamadı:\n• " + string.Join("\n• ", eksik));

        // 2) ALICI: e-Fatura mı e-Arşiv mi (Delphi AliasIslemiYap).
        var hesap = await EBelgeIstemcisi.HesapAsync(b, v.SubeId, "e-Fatura", iptal);
        short eTur; string alias;
        var taraf = await b.TekAsync("""
            select coalesce(efatura, 0) efatura, coalesce(alias_eposta, '') alias, efatura_sorgu_tarihi,
                   coalesce(eposta, '') eposta
              from public.taraf where id = @p0
            """, null, [v.TarafId], o => new Tuple<int, string, DateTime?, string>(
                o.Sayi("efatura"), o.Metin("alias").Trim(), o.Tarih("efatura_sorgu_tarihi"), o.Metin("eposta").Trim()), iptal)
            ?? new Tuple<int, string, DateTime?, string>(0, "", null, "");

        if (v.Senaryo == 3)
        {
            // İHRACAT: alıcı Gümrük; alias sorgusu yok (Delphi MenuHazirla :4401).
            eTur = EFaturaKodlari.TurEFatura; alias = "";
        }
        else if (hesap.TestMi)
        {
            // TEST: GİB kullanıcı listesi gerçek değil - Delphi Evet/Hayır sorar.
            if (istek.Tur is null)
                return new HazirlaSonucu("tur", "TEST ortamı: belge e-Fatura (test posta kutusu) olarak mı, e-Arşiv olarak mı hazırlansın?");
            eTur = istek.Tur == "efatura" ? EFaturaKodlari.TurEFatura : EFaturaKodlari.TurEArsiv;
            alias = eTur == EFaturaKodlari.TurEFatura ? TestAlias : "";
        }
        else
        {
            var taze = taraf.Item1 == 1 && taraf.Item2.Length > 0 && taraf.Item3 is { } t && t > DateTime.UtcNow.AddDays(-30);
            List<string> kutular;
            if (taze) kutular = [taraf.Item2];
            else
            {
                try { kutular = await GibKutulariAsync(hesap, v.Alici.Vkno, iptal); }
                catch (GentegreHatasi) when (taraf.Item2.Length > 0 && taraf.Item1 == 1) { kutular = [taraf.Item2]; }
                await b.CalistirAsync("""
                    update public.taraf set efatura = @p1, alias_eposta = case when @p1 = 1 and @p2 <> '' then @p2 else alias_eposta end,
                           efatura_sorgu_tarihi = now(), degistiren = @p3, degistirme_tarihi = now()
                     where id = @p0
                    """, null, [v.TarafId, (short)(kutular.Count > 0 ? 1 : 0), kutular.Count == 1 ? kutular[0] : "", bg.KullaniciId], iptal);
            }
            if (kutular.Count == 0) { eTur = EFaturaKodlari.TurEArsiv; alias = ""; }
            else if (kutular.Count == 1) { eTur = EFaturaKodlari.TurEFatura; alias = kutular[0]; }
            else if (istek.Alias is { } secilen && kutular.Contains(secilen)) { eTur = EFaturaKodlari.TurEFatura; alias = secilen; }
            else if (kutular.Contains(taraf.Item2)) { eTur = EFaturaKodlari.TurEFatura; alias = taraf.Item2; }
            else return new HazirlaSonucu("alias", $"{v.Alici.Unvan} birden çok e-Fatura posta kutusu kullanıyor; hangisine gönderilsin?",
                                          Secenekler: kutular);
        }

        // e-ARŞİV: alıcı e-postası (Delphi MailOnayAl). Boş = kâğıt belge.
        if (eTur == EFaturaKodlari.TurEArsiv)
        {
            if (istek.Eposta is null)
                return new HazirlaSonucu("eposta",
                    $"{v.Alici.Unvan} e-Fatura kullanıcısı değil; belge e-Arşiv olarak hazırlanacak.\nBelge alıcıya e-postayla iletilir; boş bırakılırsa kâğıt belge olarak işaretlenir.",
                    Varsayilan: v.Alici.Eposta.Length > 0 ? v.Alici.Eposta : taraf.Item4);
            alias = string.Join(";", IzibizGovde.Mailler(istek.Eposta));
        }

        if (!(await b.TekDegerAsync<bool?>("select public.fn_ebelge_mukellef_mi(@p0, @p1)", null, [v.SubeId, eTur], iptal) ?? false))
            throw GentegreHatasi.IsKurali($"Şube {(eTur == EFaturaKodlari.TurEArsiv ? "e-Arşiv" : "e-Fatura")} mükellefi değil (Yönetim › Firma Bilgileri › e-Belge).");

        // 3) SERİ + NUMARA + KAYIT (tek işlem).
        var seri = await SeriBulAsync(b, null, eTur, v.Senaryo, bg.KullaniciId, istek.IkinciSeri, null, iptal);

        // SERİNİN İLK BELGESİ (Delphi SonrakiSiraNo): bu seri + yılda kayıt yoksa başlangıç
        //   numarası sorulur - entegratör hesabı daha önce (başka programla) kullanılmış
        //   olabilir; 1'den başlamak "10009 mükerrer belge" ile reddedilir.
        if (istek.BaslangicNo is null && await EnBuyukNoAsync(b, null, seri + v.Tarih.Year, iptal) == 0)
            return new HazirlaSonucu("numara",
                $"{seri} serisinde {v.Tarih.Year} yılının ilk belgesi. Başlangıç sıra numarası?\n(Entegratörde bu seriyle daha önce belge kesildiyse sonrakini girin.)",
                Varsayilan: "1");

        await using var tx = await b.BeginTransactionAsync(iptal);
        var no = await NumaraUretAsync(b, tx, seri, v.Tarih.Year, iptal, istek.BaslangicNo ?? 1);
        var uuid = Guid.NewGuid().ToString();
        var durum = EFaturaKodlari.HazirDurum(eTur);

        var eId = await b.TekDegerAsync<long>("""
            insert into public.e_belge (belge_id, taraf_id, belge_turu, yon, uuid, belge_no, gonderici_alias, alici_alias,
                                        durum, sube_id, gonderici_vkno, gonderici_unvan, belge_tarihi, tutar, vergi_tutar,
                                        para_birimi, profil, entegrator, ekleyen)
            values (@p0, @p1, @p2, 1, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11::date, @p12, @p13, @p14, @p15, @p16, @p17)
            returning id
            """, tx, [belgeId, v.TarafId == 0 ? null : v.TarafId, eTur, uuid, no, v.GondericiAlias, alias, durum, v.SubeId,
                      EFaturaKodlari.Rakam(v.Gonderici.Vkno), Kirp(v.Gonderici.Unvan, 200), v.Tarih.Date, v.Odenecek, v.Kdv,
                      v.ParaKodu, eTur == EFaturaKodlari.TurEArsiv ? "EARSIVFATURA" : EFaturaKodlari.Profil(false, v.Senaryo),
                      hesap.Entegrator, bg.KullaniciId], iptal);
        await b.CalistirAsync("""
            update public.belge set efatura_durum = @p1, efatura_sonuc = 0, belge_no = @p2, belge_seri = @p3,
                   degistiren = @p4, degistirme_tarihi = now()
             where id = @p0
            """, tx, [belgeId, durum, no, seri, bg.KullaniciId], iptal);
        var turAdi = EFaturaKodlari.TurAdi(durum);
        var mesaj = $"{turAdi} hazırlandı: {no}" + (alias.Length > 0 ? $" · alıcı {alias}" : eTur == EFaturaKodlari.TurEArsiv ? " · kâğıt" : "");
        await MesajYazAsync(b, tx, belgeId, eId, 1, 1, mesaj, 0, hesap.TestMi, bg.KullaniciId, iptal);
        await LogAsync(b, tx, belgeId, v.TarafId, "Hazırla", bg, iptal);
        await tx.CommitAsync(iptal);
        return new HazirlaSonucu(null, mesaj, no, turAdi);
    }

    /// <summary>
    /// GİB e-Fatura kullanıcı listesi (GET /v1/resources/gib-users): alıcının
    /// AKTİF fatura posta kutuları. Boş = GİB kullanıcısı değil (e-Arşiv).
    /// </summary>
    private async Task<List<string>> GibKutulariAsync(EBelgeHesabi hesap, string vkno, CancellationToken iptal)
    {
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal);
        using var istek = new HttpRequestMessage(HttpMethod.Get,
            $"{hesap.Taban}/v1/resources/gib-users?identifier={EFaturaKodlari.Rakam(vkno)}");
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
        using var yanit = await istemci.SendAsync(istek, iptal);
        if (yanit.StatusCode == System.Net.HttpStatusCode.NotFound) return [];
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali($"GİB kullanıcı sorgusu başarısız (HTTP {(int)yanit.StatusCode}).");
        using var belge = JsonDocument.Parse(await yanit.Content.ReadAsStringAsync(iptal));
        var kok = belge.RootElement;
        var dizi = kok.ValueKind == JsonValueKind.Array ? kok
                 : kok.TryGetProperty("data", out var d) && d.ValueKind == JsonValueKind.Array ? d : default;
        var liste = new List<string>();
        if (dizi.ValueKind != JsonValueKind.Array) return liste;
        foreach (var k in dizi.EnumerateArray())
        {
            if (k.ValueKind != JsonValueKind.Object) continue;
            if (k.TryGetProperty("active", out var ak) && ak.ValueKind == JsonValueKind.False) continue;
            var a = k.TryGetProperty("alias", out var al) && al.ValueKind == JsonValueKind.String ? (al.GetString() ?? "").Trim() : "";
            var tur = k.TryGetProperty("documentType", out var dt) && dt.ValueKind == JsonValueKind.String ? (dt.GetString() ?? "").ToUpperInvariant() : "";
            if (a.Length == 0 || tur == "DESPATCHADVICE" || a.ToUpperInvariant().Contains("IRSALIYE")) continue;
            if (!liste.Contains(a)) liste.Add(a);
        }
        return liste;
    }

    // ================================================================ gönder ==
    public async Task<string> GonderAsync(int belgeId, YazmaBaglami bg, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var v = await EFaturaVerisi.OkuAsync(b, null, belgeId, iptal);
        if (EFaturaKodlari.Engel("ebelge.gonder", v.Tur, v.Durum, v.EfaturaDurum) is { } engel)
            throw GentegreHatasi.IsKurali(engel);
        v.ETur = EFaturaKodlari.ETur(v.EfaturaDurum);
        v.Hesapla();

        // Veri hazırlamadan sonra değişmiş olabilir: aynı doğrulama yeniden.
        var eksik = v.Eksikler();
        if (eksik.Count > 0)
            throw GentegreHatasi.IsKurali("Gönderilemedi:\n• " + string.Join("\n• ", eksik));

        // SIRA KURALI (Delphi MenuGonder): aynı seride daha küçük numaralı belge hâlâ
        //   hazır bekliyorsa bu belge gönderilmez - GİB'de numara sırası bozulur.
        var once = await b.TekDegerAsync<string>("""
            select e.belge_no from public.e_belge e
             where e.yon = 1 and e.durum in (1, 11) and e.belge_id <> @p0
               and left(e.belge_no, 7) = left(@p1, 7) and e.belge_no < @p1
             order by e.belge_no limit 1
            """, null, [belgeId, v.EBelgeNo], iptal);
        if (!string.IsNullOrEmpty(once))
            throw GentegreHatasi.IsKurali($"Aynı seride önce {once} gönderilmeli (numara sırası).");

        var hesap = await EBelgeIstemcisi.HesapAsync(b, v.SubeId, "e-Fatura gönderimi", iptal);
        if (string.IsNullOrWhiteSpace(hesap.Kullanici) || string.IsNullOrWhiteSpace(hesap.Sifre))
            throw GentegreHatasi.IsKurali("Entegratör kullanıcı adı / şifresi girilmemiş (Ayarlar › Genel › Entegrasyon).");

        var xslt = await XsltAsync(b, v.ETur, iptal);
        var notlar = await NotlarAsync(b, v, iptal);
        var govde = IzibizGovde.Uret(v, notlar, xslt).ToJsonString(Duz);
        var ubl = UblUretici.Uret(v, notlar, xslt);
        if (hesap.TestMi)
            await MesajYazAsync(b, null, belgeId, v.EBelgeId, 2, 3, govde, 0, true, bg.KullaniciId, iptal);

        var istemci = istemciUretici.CreateClient("ebelge");
        string jeton;
        try { jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal); }
        catch (GentegreHatasi h)
        {
            await HataYazAsync(b, v, h.Message, 0, hesap.TestMi, bg, iptal);
            throw;
        }

        var yol = v.Arsiv ? "/v1/earchives" : "/v1/einvoices";
        using var istek = new HttpRequestMessage(HttpMethod.Post, hesap.Taban + yol)
        { Content = new StringContent(govde, Encoding.UTF8, "application/json") };
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
        HttpResponseMessage yanit;
        try { yanit = await istemci.SendAsync(istek, iptal); }
        catch (Exception h) when (h is HttpRequestException or TaskCanceledException)
        {
            await HataYazAsync(b, v, "Entegratöre ulaşılamadı: " + h.Message, 0, hesap.TestMi, bg, iptal);
            throw GentegreHatasi.IsKurali("Entegratöre ulaşılamadı; belge hazır bekliyor, yeniden gönderilebilir.");
        }
        using (yanit)
        {
            var metin = await yanit.Content.ReadAsStringAsync(iptal);
            var kod = (int)yanit.StatusCode;
            if (!yanit.IsSuccessStatusCode)
            {
                var hata = EBelgeIstemcisi.HataMetni(metin, yanit.StatusCode);
                await HataYazAsync(b, v, $"HTTP {kod}: {Kirp(metin, 700)}", kod, hesap.TestMi, bg, iptal);
                if (!v.Arsiv && metin.Contains("RECEIVER_COULD_NOT_FOUND", StringComparison.OrdinalIgnoreCase))
                {
                    await b.CalistirAsync("update public.taraf set efatura = 0, efatura_sorgu_tarihi = now() where id = @p0",
                                          null, [v.TarafId], iptal);
                    throw GentegreHatasi.IsKurali("Alıcı GİB e-Fatura kullanıcı listesinde yok. \"Hazırı Geri Al\" ve " +
                                                  "\"Hazırla\" ile belgeyi e-Arşiv olarak yeniden hazırlayın.");
                }
                if (metin.Contains("10009", StringComparison.Ordinal) || metin.Contains("DUPLICATE", StringComparison.OrdinalIgnoreCase))
                    throw GentegreHatasi.IsKurali($"{v.EBelgeNo} numarası entegratörde daha önce kullanılmış (mükerrer belge, 10009). " +
                        "\"Hazırı Geri Al\" ve \"Hazırla\" ile daha büyük bir başlangıç numarası verin ya da \"Seri Değiştir\" kullanın.");
                throw GentegreHatasi.IsKurali($"Gönderilemedi (HTTP {kod}): {hata}");
            }

            var uuid = YanitUuid(metin);
            var durum = EFaturaKodlari.GonderildiDurum(v.ETur);
            await using var tx = await b.BeginTransactionAsync(iptal);
            await b.CalistirAsync("""
                update public.e_belge set durum = @p1, api_json = @p2, ubl_xml = @p3, servis_durum_kodu = @p4,
                       servis_durum_adi = 'Gönderildi', uuid = coalesce(nullif(@p5, ''), uuid), entegrator = @p6,
                       tutar = @p7, vergi_tutar = @p8, degistiren = @p9, degistirme_tarihi = now()
                 where id = @p0
                """, tx, [v.EBelgeId, durum, govde, ubl, kod.ToString(), uuid, hesap.Entegrator, v.Odenecek, v.Kdv, bg.KullaniciId], iptal);
            await b.CalistirAsync("""
                update public.belge set efatura_durum = @p1, efatura_sonuc = @p2, degistiren = @p3, degistirme_tarihi = now()
                 where id = @p0
                """, tx, [belgeId, durum, EFaturaKodlari.SonucGonderildi, bg.KullaniciId], iptal);
            await MesajYazAsync(b, tx, belgeId, v.EBelgeId, 2, 2, Kirp(metin, 4000), kod, hesap.TestMi, bg.KullaniciId, iptal);
            await LogAsync(b, tx, belgeId, v.TarafId, "Gönder", bg, iptal);
            await tx.CommitAsync(iptal);
        }
        return $"{EFaturaKodlari.TurAdi(v.EfaturaDurum)} {v.EBelgeNo} GİB'e gönderildi.";
    }

    private static async Task HataYazAsync(NpgsqlConnection b, EFaturaVerisi v, string mesaj, int kod, bool test,
                                           YazmaBaglami bg, CancellationToken iptal)
    {
        await MesajYazAsync(b, null, v.Id, v.EBelgeId, 2, 9, mesaj, kod, test, bg.KullaniciId, iptal);
        await b.CalistirAsync("update public.belge set efatura_sonuc = @p1 where id = @p0", null,
                              [v.Id, EFaturaKodlari.SonucHata], iptal);
    }

    private static string YanitUuid(string metin)
    {
        try
        {
            using var d = JsonDocument.Parse(metin);
            var k = d.RootElement;
            if (k.ValueKind == JsonValueKind.Object && k.TryGetProperty("data", out var dd) && dd.ValueKind == JsonValueKind.Object) k = dd;
            foreach (var ad in new[] { "uuid", "UUID", "documentUUID" })
                if (k.ValueKind == JsonValueKind.Object && k.TryGetProperty(ad, out var u) && u.ValueKind == JsonValueKind.String)
                    return u.GetString() ?? "";
        }
        catch (JsonException) { }
        return "";
    }

    // ============================================================ geri al ==
    public async Task<string> SifirlaAsync(int belgeId, YazmaBaglami bg, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var v = await EFaturaVerisi.OkuAsync(b, null, belgeId, iptal);
        if (EFaturaKodlari.Engel("ebelge.sifirla", v.Tur, v.Durum, v.EfaturaDurum) is { } engel)
            throw GentegreHatasi.IsKurali(engel);
        await using var tx = await b.BeginTransactionAsync(iptal);
        await b.CalistirAsync("delete from public.e_belge where belge_id = @p0 and yon = 1 and durum in (1, 11)", tx, [belgeId], iptal);
        await b.CalistirAsync("""
            update public.belge set efatura_durum = 0, efatura_sonuc = 0, belge_no = '0', belge_seri = '',
                   degistiren = @p1, degistirme_tarihi = now()
             where id = @p0
            """, tx, [belgeId, bg.KullaniciId], iptal);
        var mesaj = $"Hazırlık geri alındı ({v.EBelgeNo}); numara boşa düştü.";
        await MesajYazAsync(b, tx, belgeId, null, 3, 1, mesaj, 0, false, bg.KullaniciId, iptal);
        await LogAsync(b, tx, belgeId, v.TarafId, "Hazırı Geri Al", bg, iptal);
        await tx.CommitAsync(iptal);
        return mesaj;
    }

    // ========================================================= seri değiştir ==
    public async Task<object> SerilerAsync(int belgeId, YazmaBaglami bg, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var v = await EFaturaVerisi.OkuAsync(b, null, belgeId, iptal);
        var eTur = EFaturaKodlari.ETur(v.EfaturaDurum);
        var simdiki = v.EBelgeNo.Length >= 3 ? v.EBelgeNo[..3] : "";
        var liste = await SeriListesiAsync(b, null, eTur, v.Senaryo, bg.KullaniciId, iptal);
        return new { hazir = EFaturaKodlari.Hazir(v.EfaturaDurum), simdiki, seriler = liste.Where(s => s != simdiki).ToList() };
    }

    /// <summary>
    /// Delphi MenuSeriDegistir: hazırlanmamış belgede İKİNCİ uygun seriyle hazırlar;
    /// hazırda seçilen seriden yeni numara verir (ETTN değişmez).
    /// </summary>
    public async Task<string> SeriDegistirAsync(int belgeId, string seri, YazmaBaglami bg, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var v = await EFaturaVerisi.OkuAsync(b, null, belgeId, iptal);
        if (EFaturaKodlari.Engel("ebelge.seri", v.Tur, v.Durum, v.EfaturaDurum) is { } engel)
            throw GentegreHatasi.IsKurali(engel);
        if (!EFaturaKodlari.Hazir(v.EfaturaDurum))
            throw GentegreHatasi.IsKurali("Belge hazırlanmamış; önce hazırlayın.");
        var eTur = EFaturaKodlari.ETur(v.EfaturaDurum);
        seri = (seri ?? "").Trim().ToUpperInvariant();
        var liste = await SeriListesiAsync(b, null, eTur, v.Senaryo, bg.KullaniciId, iptal);
        if (!liste.Contains(seri)) throw GentegreHatasi.Dogrulama("Seçilen seri bu belge türü için tanımlı değil.");
        if (v.EBelgeNo.StartsWith(seri, StringComparison.Ordinal)) throw GentegreHatasi.Dogrulama("Belge zaten bu seride.");

        await using var tx = await b.BeginTransactionAsync(iptal);
        var no = await NumaraUretAsync(b, tx, seri, v.Tarih.Year, iptal);
        await b.CalistirAsync("update public.e_belge set belge_no = @p1, degistiren = @p2, degistirme_tarihi = now() where id = @p0",
                              tx, [v.EBelgeId, no, bg.KullaniciId], iptal);
        await b.CalistirAsync("""
            update public.belge set belge_no = @p1, belge_seri = @p2, efatura_sonuc = 0, degistiren = @p3, degistirme_tarihi = now()
             where id = @p0
            """, tx, [belgeId, no, seri, bg.KullaniciId], iptal);
        var mesaj = $"Seri değişti: {v.EBelgeNo} → {no}";
        await MesajYazAsync(b, tx, belgeId, v.EBelgeId, 4, 1, mesaj, 0, false, bg.KullaniciId, iptal);
        await LogAsync(b, tx, belgeId, v.TarafId, "Seri Değiştir", bg, iptal);
        await tx.CommitAsync(iptal);
        return mesaj;
    }

    private static async Task<List<string>> SeriListesiAsync(NpgsqlConnection b, NpgsqlTransaction? tx, short eTur,
                                                             int senaryo, int kullanici, CancellationToken iptal)
        // Delphi UEBelgeSeri.UygunSeriler önceliği: senaryo+kullanıcı, kullanıcı, senaryo, genel.
        => await b.ListeAsync("""
            select s.seri from public.ebelge_seri s
             where s.belge_turu = @p0 and s.durum = 1 and length(btrim(s.seri)) = 3
               and s.kullanici_id in (@p2, 0) and s.senaryo in (@p1, 0)
             order by (s.kullanici_id = @p2 and s.senaryo = @p1 and @p1 <> 0 and @p2 <> 0) desc,
                      (s.kullanici_id = @p2 and @p2 <> 0) desc, (s.senaryo = @p1 and @p1 <> 0) desc, s.sira, s.id
            """, tx, [eTur, senaryo, kullanici], o => o.GetString(0).Trim().ToUpperInvariant(), iptal)
            is var l ? l.Distinct().ToList() : [];

    private static async Task<string> SeriBulAsync(NpgsqlConnection b, NpgsqlTransaction tx, short eTur, int senaryo,
                                                   int kullanici, bool ikinci, string? haric, CancellationToken iptal)
    {
        var liste = (await SeriListesiAsync(b, tx, eTur, senaryo, kullanici, iptal)).Where(s => s != haric).ToList();
        if (liste.Count == 0)
            throw GentegreHatasi.IsKurali($"{(eTur == EFaturaKodlari.TurEArsiv ? "e-Arşiv" : "e-Fatura")} için seri tanımı yok: Firma Bilgileri › e-Belge › Seri.");
        if (ikinci && liste.Count < 2)
            throw GentegreHatasi.IsKurali("İkinci bir seri tanımlı değil.");
        return ikinci ? liste[1] : liste[0];
    }

    /// <summary>
    /// SERİ(3) + YIL(4) + SIRA(9) = 16 hane (Delphi BelgeNoUret / SonrakiSiraNo):
    /// aynı seri+yılda en büyük + 1. Seri+yıl kilidiyle - eşzamanlı iki hazırlama
    /// aynı numarayı alamaz.
    /// </summary>
    private static async Task<string> NumaraUretAsync(NpgsqlConnection b, NpgsqlTransaction tx, string seri, int yil,
                                                      CancellationToken iptal, long baslangic = 1)
    {
        var onek = seri + yil.ToString(System.Globalization.CultureInfo.InvariantCulture);
        await b.CalistirAsync("select pg_advisory_xact_lock(hashtext('efatura_no|' || @p0))", tx, [onek], iptal);
        var enBuyuk = Math.Max(await EnBuyukNoAsync(b, tx, onek, iptal), baslangic - 1);
        if (enBuyuk >= 999_999_999 || baslangic < 1) throw GentegreHatasi.IsKurali($"{seri} serisinde {yil} için geçersiz / dolmuş numara.");
        return onek + (enBuyuk + 1).ToString("D9", System.Globalization.CultureInfo.InvariantCulture);
    }

    private static async Task<long> EnBuyukNoAsync(NpgsqlConnection b, NpgsqlTransaction? tx, string onek, CancellationToken iptal)
        => await b.TekDegerAsync<long?>("""
            select max(substring(x.no from 8)::bigint) from (
                select belge_no no from public.e_belge where yon = 1 and belge_no ~ ('^' || @p0 || '[0-9]{9}$')
                union all
                select belge_no from public.belge where belge_no ~ ('^' || @p0 || '[0-9]{9}$')) x
            """, tx, [onek], iptal) ?? 0;

    // ============================================================= görünüm ==
    /// <summary>
    /// GİB GÖRÜNTÜSÜ: UBL + belge türünün XSLT'si (Delphi XSLTOnizlemeUret, MSXML yerine
    /// XslCompiledTransform - script / document() kapalı). Şablon yoksa ya da dönüşüm
    /// patlarsa sade tabloya düşer. <paramref name="filigran"/>: gönderilmemişse TASLAK.
    /// </summary>
    public async Task<(string Html, string DosyaAdi)> HtmlAsync(int belgeId, bool filigran, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var v = await GorunumVerisiAsync(b, belgeId, iptal);
        var xslt = await XsltAsync(b, v.ETur, iptal, zorunlu: false);
        var ubl = UblUretici.Uret(v, await NotlarAsync(b, v, iptal), xslt);
        string html;
        try { html = xslt.Length > 0 ? Donustur(ubl, xslt) : SadeHtml(v); }
        catch (Exception h) when (h is XsltException or XmlException) { html = SadeHtml(v); }
        if (filigran && !EFaturaKodlari.Gonderildi(v.EfaturaDurum)) html = FiligranEkle(html);
        return (html, DosyaAdi(v));
    }

    public async Task<(string Xml, string DosyaAdi)> XmlAsync(int belgeId, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        var v = await GorunumVerisiAsync(b, belgeId, iptal);
        var xslt = await XsltAsync(b, v.ETur, iptal, zorunlu: false);
        return (UblUretici.Uret(v, await NotlarAsync(b, v, iptal), xslt), DosyaAdi(v));
    }

    private static async Task<EFaturaVerisi> GorunumVerisiAsync(NpgsqlConnection b, int belgeId, CancellationToken iptal)
    {
        var v = await EFaturaVerisi.OkuAsync(b, null, belgeId, iptal);
        if (v.EfaturaDurum == 0 || v.EBelgeId == 0)
            throw GentegreHatasi.IsKurali("Önce \"Hazırla\" ile e-Fatura oluşturun.");
        v.ETur = EFaturaKodlari.ETur(v.EfaturaDurum);
        v.Hesapla();
        return v;
    }

    private static string Donustur(string ubl, string xslt)
    {
        var donusum = new XslCompiledTransform();
        using (var xr = XmlReader.Create(new StringReader(xslt), new XmlReaderSettings { DtdProcessing = DtdProcessing.Prohibit }))
            donusum.Load(xr, new XsltSettings(enableDocumentFunction: false, enableScript: false), null);
        using var ur = XmlReader.Create(new StringReader(ubl), new XmlReaderSettings { DtdProcessing = DtdProcessing.Prohibit });
        var sb = new StringBuilder();
        using (var w = XmlWriter.Create(sb, donusum.OutputSettings)) donusum.Transform(ur, w);
        return sb.ToString();
    }

    private static string FiligranEkle(string html)
    {
        const string f = """
            <div style="position:fixed;inset:0;display:flex;align-items:center;justify-content:center;pointer-events:none;z-index:9999">
              <div style="transform:rotate(-35deg);font:bold 110px Arial,sans-serif;color:rgba(200,0,0,.13);letter-spacing:8px;white-space:nowrap">TASLAK FATURA</div>
            </div>
            """;
        var i = html.LastIndexOf("</body>", StringComparison.OrdinalIgnoreCase);
        return i >= 0 ? html.Insert(i, f) : html + f;
    }

    private static string SadeHtml(EFaturaVerisi v)
    {
        string E(string s) => System.Net.WebUtility.HtmlEncode(s);
        string P(decimal d) => d.ToString("N2", new System.Globalization.CultureInfo("tr-TR")) + " " + v.ParaKodu;
        var sb = new StringBuilder("<!doctype html><html><head><meta charset=\"utf-8\"><style>body{font:12px Arial;margin:24px}table{border-collapse:collapse;width:100%}td,th{border:1px solid #999;padding:4px}th{background:#eee}.s{text-align:right}</style></head><body>");
        sb.Append($"<h2>{E(EFaturaKodlari.TurAdi(v.EfaturaDurum))} {E(v.EBelgeNo)}</h2>");
        sb.Append($"<p><b>{E(v.Gonderici.Unvan)}</b> (VKN {E(v.Gonderici.Vkno)})<br>Sayın <b>{E(v.Alici.Unvan)}</b> ({E(v.Alici.Vkno)})<br>{E(v.Alici.Adres)} {E(v.Alici.Ilce)} / {E(v.Alici.Il)}</p>");
        sb.Append($"<p>Tarih: {v.Tarih:dd.MM.yyyy} · ETTN: {E(v.Uuid)} · Senaryo: {v.Profil} · Tip: {v.FaturaTipi}</p>");
        sb.Append("<table><tr><th>#</th><th>Mal / Hizmet</th><th class=s>Miktar</th><th class=s>Birim Fiyat</th><th class=s>İskonto</th><th class=s>KDV %</th><th class=s>Tutar</th></tr>");
        foreach (var s in v.Satirlar)
            sb.Append($"<tr><td>{s.No}</td><td>{E(s.Ad)}</td><td class=s>{s.Miktar:0.##}</td><td class=s>{P(s.Fiyat)}</td><td class=s>{P(s.Iskonto)}</td><td class=s>{s.KdvOran}</td><td class=s>{P(s.Net)}</td></tr>");
        sb.Append("</table><table style=\"width:320px;margin:12px 0 0 auto\">");
        sb.Append($"<tr><td>Mal Hizmet Toplam</td><td class=s>{P(v.Brut)}</td></tr><tr><td>Toplam İskonto</td><td class=s>{P(v.Iskonto)}</td></tr>");
        foreach (var g in v.VergiGruplari) sb.Append($"<tr><td>KDV %{g.Oran}</td><td class=s>{P(g.Vergi)}</td></tr>");
        if (v.Tevkifat > 0) sb.Append($"<tr><td>KDV Tevkifatı</td><td class=s>{P(v.Tevkifat)}</td></tr>");
        sb.Append($"<tr><th>Ödenecek Tutar</th><th class=s>{P(v.Odenecek)}</th></tr></table></body></html>");
        return sb.ToString();
    }

    /// <summary>Delphi MenuDosyaKaydet: "&lt;E-Fatura|E-ArsivFatura&gt; &lt;no&gt; &lt;carinin ilk 2 kelimesi&gt;".</summary>
    private static string DosyaAdi(EFaturaVerisi v)
    {
        var tur = EFaturaKodlari.ETur(v.EfaturaDurum) == EFaturaKodlari.TurEArsiv ? "E-ArsivFatura" : "E-Fatura";
        var cari = string.Join(' ', v.Alici.Unvan.Split(' ', StringSplitOptions.RemoveEmptyEntries).Take(2));
        var ad = $"{tur} {(v.EBelgeNo.Length > 0 ? v.EBelgeNo : v.BelgeNo)} {cari}";
        return Regex.Replace(ad, @"[\\/:*?""<>|]", " ").Trim();
    }

    // ============================================================= mesajlar ==
    public async Task<IReadOnlyList<MesajSatiri>> MesajlarAsync(int belgeId, CancellationToken iptal)
    {
        await using var b = await veri.AcAsync(iptal);
        return await b.ListeAsync("""
            select m.ekleme_tarihi, m.islem, m.tip, m.mesaj, m.http_kodu, m.servis,
                   coalesce(k.ad, '') kullanici
              from public.e_belge_mesaj m
              left join public.v_kullanici_lookup k on k.id = m.ekleyen
             where m.belge_id = @p0
             order by m.id desc
            """, null, [belgeId], o => new MesajSatiri(
                o.GetDateTime(0),
                o.GetInt16(1) switch { 1 => "Hazırla", 2 => "Gönder", 3 => "Hazırı Geri Al", 4 => "Seri Değiştir", _ => "" },
                o.GetInt16(2) switch { 1 => "Bilgi", 2 => "Başarılı yanıt", 3 => "İstek gövdesi", 9 => "Hata", _ => "" },
                o.GetString(3), o.GetInt32(4), o.GetString(5), o.GetString(6)), iptal);
    }

    // ============================================================ yardımcı ==
    private static async Task MesajYazAsync(NpgsqlConnection b, NpgsqlTransaction? tx, int belgeId, long? eBelgeId,
        short islem, short tip, string mesaj, int http, bool test, int kullanici, CancellationToken iptal)
        => await b.CalistirAsync("""
            insert into public.e_belge_mesaj (belge_id, e_belge_id, islem, tip, mesaj, http_kodu, servis, ekleyen)
            values (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7)
            """, tx, [belgeId, eBelgeId is > 0 ? eBelgeId : null, islem, tip, mesaj, http,
                      islem == 2 ? (test ? "TEST" : "URETIM") : "", kullanici], iptal);

    /// <summary>Delphi ULog.LogEBelgeIslem: belge kaydına "E-Belge İşlemi" satırı.</summary>
    private static async Task LogAsync(NpgsqlConnection b, NpgsqlTransaction tx, int belgeId, int tarafId, string islem,
                                       YazmaBaglami bg, CancellationToken iptal)
        => await new LogDeposu().YazAsync(b, tx, LogIslemi.Degistir, LogTabloBelge, belgeId, bg.KullaniciId, bg.SubeId, bg.Ip,
            new Dictionary<string, string> { ["E-Belge İşlemi"] = islem }, tarafId: tarafId == 0 ? null : tarafId, iptal: iptal);

    /// <summary>Belge türünün GİDEN XSLT'si (varsayılan önce). Gönderimde zorunlu (Delphi).</summary>
    private static async Task<string> XsltAsync(NpgsqlConnection b, short eTur, CancellationToken iptal, bool zorunlu = true)
    {
        var x = await b.TekDegerAsync<string>("""
            select convert_from(di.icerik, 'UTF8')
              from public.dokuman d join public.dokuman_icerik di on di.hash = d.hash
             where d.kaynak = 'ebelge-xslt' and d.kaynak_id = @p0 and coalesce(d.yon, 0) in (0, 2)
             order by d.varsayilan desc, d.id limit 1
            """, null, [eTur], iptal) ?? "";
        if (zorunlu && x.Trim().Length == 0)
            throw GentegreHatasi.IsKurali($"{(eTur == EFaturaKodlari.TurEArsiv ? "e-Arşiv" : "e-Fatura")} için XSLT şablonu yok: Ayarlar › Satış Belgeleri › e-Belge › XSLT.");
        return x;
    }

    /// <summary>
    /// NOTLAR (Delphi SabitNotlariGetir + KDVIstisnaNotu + TevkifatNotu): türün sabit
    /// not şablonu, {ALAN} yer tutucuları doldurulur; boş kalan satır atılır.
    /// </summary>
    private static async Task<List<string>> NotlarAsync(NpgsqlConnection b, EFaturaVerisi v, CancellationToken iptal)
    {
        var sablon = await b.TekDegerAsync<string>("select deger from public.referans where anahtar = @p0", null,
                                                    [v.Arsiv ? "earsiv.sabit_notlar" : "efatura.sabit_notlar"], iptal) ?? "{ACIKLAMA}";
        var alanlar = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["ACIKLAMA"] = v.Aciklama, ["ACIKLAMA2"] = "", ["BELGENO"] = v.EBelgeNo,
            ["TARIH"] = v.Tarih.ToString("dd.MM.yyyy"), ["UNVAN"] = v.Alici.Unvan,
            ["PaymentTotalAsText"] = TutarYazi.Yaz(v.Odenecek, v.ParaKodu),
        };
        var notlar = new List<string>();
        foreach (var satir in sablon.Replace("\r", "").Split('\n'))
        {
            var bos = true;
            var dolu = Regex.Replace(satir, @"\{([A-Za-z0-9_]+)\}", m =>
            {
                var d = alanlar.TryGetValue(m.Groups[1].Value, out var x) ? x : "";
                if (d.Length > 0) bos = false;
                return d;
            }).Trim();
            // Yer tutucusu olan satır, hepsi boş kaldıysa atılır ("{ACIKLAMA}" tek başına).
            if (dolu.Length > 0 && (!bos || !Regex.IsMatch(satir, @"\{[A-Za-z0-9_]+\}")))
                notlar.Add(dolu);
        }
        foreach (var g in v.VergiGruplari.Where(g => g.IstisnaKodu > 0).Select(g => g.IstisnaAdi).Distinct())
            notlar.Add("KDV İstisna Nedeni: " + g);
        foreach (var g in v.TevkifatGruplari)
            notlar.Add($"KDV Tevkifatı: {g.Ad} - Tevkifat tutarı {g.Tevkifat:N2} {v.ParaKodu}");
        return notlar;
    }

    private static string Kirp(string s, int n) => s.Length <= n ? s : s[..n];
}
