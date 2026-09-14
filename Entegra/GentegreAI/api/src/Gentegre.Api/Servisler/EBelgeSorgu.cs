using System.Net.Http.Headers;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Servisler;

/// <summary>
/// e-BELGE SORGULARI - entegratore SORULAN, gonderim disi isler:
///   1. MUKELLEF SORGUSU: alici GIB e-Fatura kullanicisi mi? Bu bilgi belgenin
///      e-Fatura mi e-Arsiv mi kesilecegini belirler. Elle isaretlenen bayrak
///      yanlissa belge yanlis turde gider ve GIB reddeder.
///   2. DURUM SORGUSU: gonderilen belge GIB'de ne oldu (raporlandi / kabul /
///      red)? Gonderimden sonra durum kendiliginden degismiyordu.
///
/// Gonderimle AYNI hesabi kullanir (fn_ebelge_hesap) - ayri kimlik yonetimi yok.
/// </summary>
public sealed class EBelgeSorgu(VeriKaynagi veri, IHttpClientFactory istemciUretici)
{
    public sealed record MukellefBilgisi(bool Mukellef, string Unvan, string VergiDairesi,
                                         string Il, string Ilce, string Adres, string Durum,
                                         string Alias = "", string IrsaliyeAlias = "",
                                         bool IrsaliyeKullanicisi = false);

    /// <summary>GIB kullanici listesi sonucu: posta kutulari + kullanici mi.</summary>
    private sealed record GibKullanici(bool EFatura, bool EIrsaliye,
                                       string Alias, string IrsaliyeAlias);

    public sealed record DurumBilgisi(string BelgeNo, string Kod, string Aciklama, bool Degisti);

    // Hesap okuma / jeton alma ORTAK: EBelgeIstemcisi. Uc serviste ayri ayri
    //   yaziliyordu ve kopyalar ayrismisti (jeton yedek yolu yalniz gonderimde
    //   vardi) - ayni hesapla gonderim calisirken sorgu "giris yapilamadi"
    //   diyebiliyordu.

    /// <summary>
    /// GIB e-FATURA KULLANICI LISTESI (186): GET /v1/resources/gib-users.
    /// Donen her kayit bir POSTA KUTUSU (alias) + belge turu (INVOICE /
    /// DESPATCHADVICE). Liste bossa alici e-Fatura kullanicisi DEGILDIR.
    ///
    /// Mukellefiyetin TEK dogru kaynagi burasi: /v2/taxpayers vergi dairesi
    /// kaydini doner, faal her firmaya "aktif" der. Onunla karar verilince
    /// e-Arsivlik alicilara e-Fatura hazirlaniyor, gonderimde entegrator
    /// RECEIVER_COULD_NOT_FOUND_IN_GIB_USER_LIST ile reddediyordu.
    /// </summary>
    private static async Task<GibKullanici> GibKullaniciAsync(HttpClient istemci, EBelgeHesabi hesap,
        string jeton, string vkno, CancellationToken iptal)
    {
        using var istek = new HttpRequestMessage(HttpMethod.Get,
            $"{hesap.Taban}/v1/resources/gib-users?identifier={vkno}");
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
        using var yanit = await istemci.SendAsync(istek, iptal);

        // 404 = listede yok; hata degil, gecerli bir cevap (e-Arsiv kesilecek).
        if (yanit.StatusCode == System.Net.HttpStatusCode.NotFound)
            return new GibKullanici(false, false, "", "");
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali(
                $"GİB kullanıcı sorgusu başarısız (HTTP {(int)yanit.StatusCode}).");

        using var belge = JsonDocument.Parse(await yanit.Content.ReadAsStringAsync(iptal));
        if (!belge.RootElement.TryGetProperty("data", out var dizi)
            || dizi.ValueKind != JsonValueKind.Array)
            return new GibKullanici(false, false, "", "");

        string fatura = "", irsaliye = "";
        foreach (var k in dizi.EnumerateArray())
        {
            if (k.ValueKind != JsonValueKind.Object) continue;
            // Kapatilmis posta kutusu ATLANIR - eskimis alias'a gonderim GIB'de reddedilir.
            if (k.TryGetProperty("active", out var ak) && ak.ValueKind == JsonValueKind.False)
                continue;

            var alias = k.TryGetProperty("alias", out var a) && a.ValueKind == JsonValueKind.String
                        ? (a.GetString() ?? "").Trim() : "";
            if (alias.Length == 0) continue;

            var tur = k.TryGetProperty("documentType", out var t) && t.ValueKind == JsonValueKind.String
                      ? (t.GetString() ?? "").ToUpperInvariant() : "";
            // Delphi ile ayni kural: tur DESPATCHADVICE ya da alias'ta "IRSALIYE".
            if (tur == "DESPATCHADVICE" || alias.ToUpperInvariant().Contains("IRSALIYE"))
            {
                if (irsaliye.Length == 0) irsaliye = alias;
            }
            else if (fatura.Length == 0) fatura = alias;
        }

        // Fatura kutusu yoksa ama irsaliye kutusu varsa alici yine GIB
        //   kullanicisidir; fatura icin o alias kullanilir.
        var eFatura = fatura.Length > 0 || irsaliye.Length > 0;
        return new GibKullanici(eFatura, irsaliye.Length > 0,
                                fatura.Length > 0 ? fatura : irsaliye, irsaliye);
    }

    // --------------------------------------------------------- mukellef ----
    /// <summary>
    /// GIB e-Fatura kullanicisi mi? 404 = kayitli DEGIL (e-Arsiv kesilecek) -
    /// hata degil, gecerli bir cevaptir.
    /// </summary>
    public async Task<MukellefBilgisi> MukellefSorgulaAsync(string vkno, int? subeId,
                                                            CancellationToken iptal = default)
    {
        var temiz = new string((vkno ?? "").Where(char.IsDigit).ToArray());
        if (temiz.Length is not (10 or 11))
            throw GentegreHatasi.Dogrulama("VKN 10, kimlik no 11 hane olmalı.");

        await using var baglanti = await veri.AcAsync(iptal);
        var hesap = await EBelgeIstemcisi.HesapAsync(baglanti, subeId, "sorgulama", iptal);

        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal);

        // MUKELLEFIYET + ALIAS: GIB kullanici listesi (tek dogru kaynak).
        var gib = await GibKullaniciAsync(istemci, hesap, jeton, temiz, iptal);

        // UNVAN / VERGI DAIRESI / ADRES: vergi dairesi kaydi - kart doldurmak icin.
        using var istek = new HttpRequestMessage(HttpMethod.Get,
            $"{hesap.Taban}/v2/taxpayers/{temiz}");
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
        using var yanit = await istemci.SendAsync(istek, iptal);

        if (yanit.StatusCode == System.Net.HttpStatusCode.NotFound)
            return new MukellefBilgisi(gib.EFatura, "", "", "", "", "",
                                       gib.EFatura ? "Kayıtlı" : "Kayıtlı değil",
                                       gib.Alias, gib.IrsaliyeAlias, gib.EIrsaliye);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali(
                $"Mükellef sorgusu başarısız (HTTP {(int)yanit.StatusCode}).");

        using var belge = JsonDocument.Parse(await yanit.Content.ReadAsStringAsync(iptal));
        if (!belge.RootElement.TryGetProperty("data", out var d) || d.ValueKind != JsonValueKind.Object)
            return new MukellefBilgisi(gib.EFatura, "", "", "", "", "",
                                       gib.EFatura ? "Kayıtlı" : "Kayıtlı değil",
                                       gib.Alias, gib.IrsaliyeAlias, gib.EIrsaliye);

        string Metin(JsonElement e, string ad)
            => e.TryGetProperty(ad, out var v) && v.ValueKind == JsonValueKind.String
               ? v.GetString() ?? "" : "";

        // Ilk adres yeterli: kart doldururken kullanicidan onay alinacak.
        var il = ""; var ilce = ""; var adres = "";
        if (d.TryGetProperty("addresses", out var adresler)
            && adresler.ValueKind == JsonValueKind.Array && adresler.GetArrayLength() > 0)
        {
            var a = adresler[0];
            il = Metin(a, "city");
            ilce = Metin(a, "subCity");
            adres = string.Join(' ', new[] { Metin(a, "district"), Metin(a, "streetName"),
                                             Metin(a, "buildingNumber") }
                                     .Where(x => !string.IsNullOrWhiteSpace(x)));
        }

        var durum = Metin(d, "status");
        // MUKELLEFIYET gib-users'tan; ama vergi dairesi kaydi KAPANMISSA (status
        //   <> FAAL) e-Fatura kesilmez - iki kaynak da olumlu olmali.
        var faal = durum.Length == 0
                   || durum.Equals("FAAL", StringComparison.OrdinalIgnoreCase)
                   || (d.TryGetProperty("active", out var ak) && ak.ValueKind == JsonValueKind.True);

        return new MukellefBilgisi(gib.EFatura && faal, Metin(d, "commercialName"),
                                   Metin(d, "taxoffice"), il, ilce, adres,
                                   string.IsNullOrWhiteSpace(durum) ? "-" : durum,
                                   gib.Alias, gib.IrsaliyeAlias, gib.EIrsaliye);
    }

    // ------------------------------------------------------------ durum ----
    /// <summary>
    /// Gonderilen belgenin entegratordeki durumu. Entegrator listesi TARIH
    /// araligiyla calisiyor (tek belge ucu yok), o yuzden belgenin kendi
    /// tarihinin gunu sorgulanip numarasi eslesen satir alinir.
    /// </summary>
    public async Task<DurumBilgisi> DurumSorgulaAsync(int belgeId, int kullaniciId,
                                                      CancellationToken iptal = default)
    {
        await using var baglanti = await veri.AcAsync(iptal);

        await using var oku = baglanti.Komut("""
            select e.id, coalesce(e.belge_no, ''), e.belge_turu, e.durum,
                   to_char(bl.belge_tarihi, 'YYYY-MM-DD'),
                   coalesce(nullif(bl.sube_id, 0), (select s.id from public.sube s
                        where s.varsayilan = 1 and s.aktif = 1 order by s.id limit 1))
              from public.belge bl
              join public.e_belge e on e.belge_id = bl.id
             where bl.id = @p0 order by e.id desc limit 1
            """, null,
            belgeId);
        long eBelgeId; string belgeNo, tarih; short belgeTuru, durum; int subeId;
        await using (var o = await oku.ExecuteReaderAsync(iptal))
        {
            if (!await o.ReadAsync(iptal))
                throw GentegreHatasi.IsKurali("Belge için e-Belge kaydı yok.");
            eBelgeId = o.GetInt64(0); belgeNo = o.GetString(1); belgeTuru = o.GetInt16(2);
            durum = o.GetInt16(3); tarih = o.GetString(4); subeId = o.GetInt32(5);
        }

        if (durum is not (2 or 12 or 52))
            throw GentegreHatasi.IsKurali("Belge henüz gönderilmemiş; sorgulanacak durum yok.");

        var hesap = await EBelgeIstemcisi.HesapAsync(baglanti, subeId, "sorgulama", iptal);
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal);

        var yol = belgeTuru switch
        {
            2 => "/v1/earchives",
            7 => "/v2/edespatches",
            _ => "/v1/einvoices/outbox",
        };
        var govde = await EBelgeIstemcisi.IsteAsync(istemci, hesap, jeton, HttpMethod.Get,
            $"{yol}?startDate={tarih}&endDate={tarih}&page=0&pageSize=100", null,
            "Durum sorgusu", iptal);

        string kod = "", aciklama = "";
        using (var belge = JsonDocument.Parse(govde))
        {
            var kokVeri = belge.RootElement.TryGetProperty("data", out var d) ? d : belge.RootElement;
            var liste = kokVeri.TryGetProperty("contents", out var c) ? c : kokVeri;
            if (liste.ValueKind == JsonValueKind.Array)
            {
                foreach (var s in liste.EnumerateArray())
                {
                    if (!s.TryGetProperty("documentNo", out var no)
                        || !string.Equals(no.GetString(), belgeNo, StringComparison.OrdinalIgnoreCase))
                        continue;
                    if (s.TryGetProperty("documentStatus", out var ds)
                        && ds.ValueKind == JsonValueKind.Object)
                    {
                        kod = ds.TryGetProperty("value", out var v) ? v.GetString() ?? "" : "";
                        aciklama = ds.TryGetProperty("label", out var l) ? l.GetString() ?? "" : "";
                    }
                    if (kod == "" && s.TryGetProperty("statusCode", out var sk))
                        kod = sk.ToString();
                    if (aciklama == "" && s.TryGetProperty("statusCodeDesc", out var sd))
                        aciklama = sd.GetString() ?? "";
                    break;
                }
            }
        }

        if (kod == "")
            return new DurumBilgisi(belgeNo, "", "Entegratörde bu numarayla belge bulunamadı.", false);

        await using var yaz = baglanti.Komut("""
            update public.e_belge
               set gib_durum_kodu = left(@p1, 40), gib_durum_aciklama = left(@p2, 200),
                   degistiren = @p3, degistirme_tarihi = now()::timestamp
             where id = @p0
               and (coalesce(gib_durum_kodu, '') <> @p1
                 or coalesce(gib_durum_aciklama, '') <> @p2)
            """, null,
            eBelgeId, kod, aciklama, kullaniciId);
        var degisti = await yaz.ExecuteNonQueryAsync(iptal) > 0;

        return new DurumBilgisi(belgeNo, kod, aciklama, degisti);
    }

    /// <summary>
    /// Hazirlamadan ONCE mukellefiyeti TAZELE (185). Kural veritabaninda
    /// (fn_mukellef_sorgu_gerekli): mukellef bilinen cari sorgu taze ise
    /// sorulmaz, mukellef olmayan HER SEFERINDE sorulur - yeni mukellefiyet
    /// her an baslayabilir ve e-Arsiv kesilen aliciya artik e-Fatura gitmelidir.
    ///
    /// SESSIZ BASARISIZLIK: entegratore ulasilamazsa hazirlama DURMAZ, elde
    /// olan bayrakla devam eder. Ag arizasi yuzunden fatura kesilememesi,
    /// yanlis turde kesilmesinden daha kotu bir sonuc.
    /// </summary>
    public async Task<bool> MukellefiyetTazeleAsync(int belgeId, int kullaniciId,
                                                    CancellationToken iptal = default)
    {
        await using var baglanti = await veri.AcAsync(iptal);

        int tarafId; string vkno; int? subeId;
        await using (var oku = new NpgsqlCommand("""
            select bl.taraf_id, coalesce(t.vkno, ''), nullif(bl.sube_id, 0)
              from public.belge bl
              left join public.taraf t on t.id = bl.taraf_id
             where bl.id = @p0 and public.fn_mukellef_sorgu_gerekli(bl.taraf_id)
            """, baglanti))
        {
            oku.Parameters.AddWithValue("p0", belgeId);
            await using var o = await oku.ExecuteReaderAsync(iptal);
            if (!await o.ReadAsync(iptal)) return false;     // sorgu gerekmiyor
            tarafId = o.GetInt32(0); vkno = o.GetString(1);
            subeId = o.IsDBNull(2) ? null : o.GetInt32(2);
        }

        MukellefBilgisi bilgi;
        try
        {
            bilgi = await MukellefSorgulaAsync(vkno, subeId, iptal);
        }
        catch
        {
            return false;                                    // ag/servis hatasi: sessiz gec
        }

        // ALIAS da yazilir (186): e-Fatura gonderiminde posta kutusu ZORUNLU.
        //   Sorgu alias dondurmediyse elle girilmis alias EZILMEZ.
        await using var yaz = baglanti.Komut("""
            update public.taraf
               set efatura = @p1, eirsaliye = @p3,
                   alias_eposta = case when @p4 <> '' then @p4 else alias_eposta end,
                   alias_irsaliye = case when @p5 <> '' then @p5 else alias_irsaliye end,
                   efatura_sorgu_tarihi = now()::timestamp,
                   degistiren = @p2, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, null,
            tarafId, (short)(bilgi.Mukellef ? 1 : 0), kullaniciId, (short)(bilgi.IrsaliyeKullanicisi ? 1 : 0), bilgi.Alias ?? "", bilgi.IrsaliyeAlias ?? "");
        await yaz.ExecuteNonQueryAsync(iptal);
        return true;
    }
}
