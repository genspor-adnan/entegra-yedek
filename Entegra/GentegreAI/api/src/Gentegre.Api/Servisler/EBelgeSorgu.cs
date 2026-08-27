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
                                         string Il, string Ilce, string Adres, string Durum);

    public sealed record DurumBilgisi(string BelgeNo, string Kod, string Aciklama, bool Degisti);

    private sealed record Hesap(string Entegrator, string Kullanici, string Sifre,
                                bool TestMi, string Url);

    // ------------------------------------------------------------- hesap ----
    private static async Task<Hesap> HesapOkuAsync(NpgsqlConnection baglanti, int? subeId,
                                                   CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "select entegrator, kullanici, sifre, test_mi, url from public.fn_ebelge_hesap(@p0)",
            baglanti);
        komut.Parameters.AddWithValue("p0", (object?)subeId ?? DBNull.Value);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali("Şubenin e-Belge hesabı çözülemedi.");

        var h = new Hesap(
            o.IsDBNull(0) ? "" : o.GetString(0), o.IsDBNull(1) ? "" : o.GetString(1),
            o.IsDBNull(2) ? "" : o.GetString(2), !o.IsDBNull(3) && o.GetBoolean(3),
            o.IsDBNull(4) ? "" : o.GetString(4));

        if (string.IsNullOrWhiteSpace(h.Entegrator) || string.IsNullOrWhiteSpace(h.Url))
            throw GentegreHatasi.IsKurali(
                "Entegratör ayarları eksik. Yönetim › Firma Bilgileri › e-Belge.");
        if (h.Entegrator != "izibiz")
            throw GentegreHatasi.IsKurali(
                $"\"{h.Entegrator}\" için sorgulama henüz desteklenmiyor.");
        return h;
    }

    /// <summary>Gonderimdeki ile ayni login (JSON govdeli /v1/auth/token).</summary>
    private static async Task<string> JetonAlAsync(HttpClient istemci, Hesap hesap,
                                                   CancellationToken iptal)
    {
        using var istek = new HttpRequestMessage(HttpMethod.Post,
            hesap.Url.TrimEnd('/') + "/v1/auth/token")
        {
            Content = new StringContent(
                JsonSerializer.Serialize(new { username = hesap.Kullanici, password = hesap.Sifre }),
                System.Text.Encoding.UTF8, "application/json"),
        };
        using var yanit = await istemci.SendAsync(istek, iptal);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali("Entegratöre giriş yapılamadı.");

        using var belge = JsonDocument.Parse(await yanit.Content.ReadAsStringAsync(iptal));
        var kok = belge.RootElement;
        foreach (var kaynak in new[] { kok, kok.TryGetProperty("data", out var d) ? d : default })
        {
            if (kaynak.ValueKind != JsonValueKind.Object) continue;
            foreach (var ad in new[] { "accessToken", "access_token", "token" })
                if (kaynak.TryGetProperty(ad, out var t) && t.ValueKind == JsonValueKind.String)
                    return t.GetString()!;
        }
        throw GentegreHatasi.IsKurali("Entegratör jetonu alınamadı.");
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
            throw GentegreHatasi.Dogrulama("VKN 10, TCKN 11 hane olmalı.");

        await using var baglanti = await veri.AcAsync(iptal);
        var hesap = await HesapOkuAsync(baglanti, subeId, iptal);

        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await JetonAlAsync(istemci, hesap, iptal);

        using var istek = new HttpRequestMessage(HttpMethod.Get,
            $"{hesap.Url.TrimEnd('/')}/v2/taxpayers/{temiz}");
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
        using var yanit = await istemci.SendAsync(istek, iptal);

        if (yanit.StatusCode == System.Net.HttpStatusCode.NotFound)
            return new MukellefBilgisi(false, "", "", "", "", "", "Kayıtlı değil");
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali(
                $"Mükellef sorgusu başarısız (HTTP {(int)yanit.StatusCode}).");

        using var belge = JsonDocument.Parse(await yanit.Content.ReadAsStringAsync(iptal));
        if (!belge.RootElement.TryGetProperty("data", out var d) || d.ValueKind != JsonValueKind.Object)
            return new MukellefBilgisi(false, "", "", "", "", "", "Kayıtlı değil");

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
        // FAAL kaydi olan mukellef e-Fatura kullanicisidir; kapanmis mukellefe
        //   (status <> FAAL) e-Fatura kesilmez.
        var aktif = durum.Equals("FAAL", StringComparison.OrdinalIgnoreCase)
                    || (d.TryGetProperty("active", out var ak) && ak.ValueKind == JsonValueKind.True);

        return new MukellefBilgisi(aktif, Metin(d, "commercialName"), Metin(d, "taxoffice"),
                                   il, ilce, adres, string.IsNullOrWhiteSpace(durum) ? "-" : durum);
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

        await using var oku = new NpgsqlCommand("""
            select e.id, coalesce(e.belge_no, ''), e.belge_turu, e.durum,
                   to_char(bl.belge_tarihi, 'YYYY-MM-DD'),
                   coalesce(nullif(bl.sube_id, 0), (select s.id from public.sube s
                        where s.varsayilan = 1 and s.aktif = 1 order by s.id limit 1))
              from public.belge bl
              join public.e_belge e on e.belge_id = bl.id
             where bl.id = @p0 order by e.id desc limit 1
            """, baglanti);
        oku.Parameters.AddWithValue("p0", belgeId);
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

        var hesap = await HesapOkuAsync(baglanti, subeId, iptal);
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await JetonAlAsync(istemci, hesap, iptal);

        var yol = belgeTuru switch
        {
            2 => "/v1/earchives",
            7 => "/v2/edespatches",
            _ => "/v1/einvoices/outbox",
        };
        using var istek = new HttpRequestMessage(HttpMethod.Get,
            $"{hesap.Url.TrimEnd('/')}{yol}?startDate={tarih}&endDate={tarih}&page=0&pageSize=100");
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);
        using var yanit = await istemci.SendAsync(istek, iptal);
        var govde = await yanit.Content.ReadAsStringAsync(iptal);
        if (!yanit.IsSuccessStatusCode)
            throw GentegreHatasi.IsKurali(
                $"Durum sorgusu başarısız (HTTP {(int)yanit.StatusCode}).");

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

        await using var yaz = new NpgsqlCommand("""
            update public.e_belge
               set gib_durum_kodu = left(@p1, 40), gib_durum_aciklama = left(@p2, 200),
                   degistiren = @p3, degistirme_tarihi = now()::timestamp
             where id = @p0
               and (coalesce(gib_durum_kodu, '') <> @p1
                 or coalesce(gib_durum_aciklama, '') <> @p2)
            """, baglanti);
        yaz.Parameters.AddWithValue("p0", eBelgeId);
        yaz.Parameters.AddWithValue("p1", kod);
        yaz.Parameters.AddWithValue("p2", aciklama);
        yaz.Parameters.AddWithValue("p3", kullaniciId);
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

        bool mukellef;
        try
        {
            mukellef = (await MukellefSorgulaAsync(vkno, subeId, iptal)).Mukellef;
        }
        catch
        {
            return false;                                    // ag/servis hatasi: sessiz gec
        }

        await using var yaz = new NpgsqlCommand("""
            update public.taraf
               set efatura = @p1, efatura_sorgu_tarihi = now()::timestamp,
                   degistiren = @p2, degistirme_tarihi = now()::timestamp
             where id = @p0
            """, baglanti);
        yaz.Parameters.AddWithValue("p0", tarafId);
        yaz.Parameters.AddWithValue("p1", (short)(mukellef ? 1 : 0));
        yaz.Parameters.AddWithValue("p2", kullaniciId);
        await yaz.ExecuteNonQueryAsync(iptal);
        return true;
    }
}
