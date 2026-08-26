using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;
using NpgsqlTypes;

namespace Gentegre.Api.Servisler;

/// <summary>
/// e-BELGE GONDERIMI - entegrator baglantisi.
///
/// KAYNAK: Delphi `TEBelgeOlusturucu.Gonder` + `TIzibizRest` (UIzibizRest.pas).
/// Akis: hesabi coz -> login -> govdeyi uret (fn_ebelge_gonderim_govdesi) ->
/// POST -> yaniti e_belge'ye yaz.
///
/// ENTEGRATORDEN BAGIMSIZ KISIM burada: hangi hesap, hangi govde, sonuc nereye
/// yazilir. Entegratore ozel olan yalniz UC NOKTA YOLU ve LOGIN BICIMI - ikisi
/// de asagida tek yerde (`YolBul`, `JetonAl`). Ikinci entegrator eklenirken bu
/// iki yer dallanir, gerisi aynen calisir.
///
/// GONDERILMIS BELGEYE DOKUNULMAZ: durum 2/12/52 ise istek reddedilir - ayni
/// belgeyi iki kez gondermek GIB'de mukerrer fatura demektir.
/// </summary>
public sealed class EBelgeGonderimi(VeriKaynagi veri, IHttpClientFactory istemciUretici)
{
    /// <summary>e-Belge turu -> gonderilmis durum kodu (Delphi ile ayni).</summary>
    private static short GonderilmisDurum(short belgeTuru) => belgeTuru switch
    {
        1 => 2,     // e-Fatura
        2 => 12,    // e-Arsiv
        7 => 52,    // e-Irsaliye
        _ => 2,
    };

    /// <summary>izibiz uc noktalari (Delphi: irsaliye v2 ve /send sonekli).</summary>
    private static string YolBul(string entegrator, short belgeTuru) => entegrator switch
    {
        "izibiz" => belgeTuru switch
        {
            7 => "/v2/edespatches/send",
            2 => "/v1/earchives",
            _ => "/v1/einvoices",
        },
        _ => throw GentegreHatasi.IsKurali(
            $"\"{entegrator}\" için gönderim uç noktası tanımlı değil."),
    };

    public sealed record Sonuc(bool Basarili, string Mesaj, string Uuid,
                               int HttpKodu, string BelgeNo, string Entegrator);

    public async Task<Sonuc> GonderAsync(int belgeId, int kullaniciId,
                                         CancellationToken iptal = default)
    {
        await using var baglanti = await veri.AcAsync(iptal);

        // 1) Belgenin e-Belge kaydi + durumu.
        var (eBelgeId, belgeTuru, belgeNo, durum, subeId) =
            await EBelgeOkuAsync(baglanti, belgeId, iptal);

        if (durum is 2 or 12 or 52)
            throw GentegreHatasi.IsKurali("Bu belge zaten gönderilmiş.");
        if (durum == 0)
            throw GentegreHatasi.IsKurali("Önce \"e-Fatura Hazırla\" ile belge hazırlanmalı.");

        // 2) Mukellef hesabi (171): kimlik hangi subedeyse hesap da onun.
        var hesap = await HesapOkuAsync(baglanti, subeId, iptal);
        if (string.IsNullOrWhiteSpace(hesap.Entegrator))
            throw GentegreHatasi.IsKurali(
                "Bu şube için entegratör seçilmemiş. Yönetim › Firma Bilgileri › e-Belge.");
        if (string.IsNullOrWhiteSpace(hesap.Kullanici) || string.IsNullOrWhiteSpace(hesap.Sifre))
            throw GentegreHatasi.IsKurali(
                hesap.TestMi
                    ? "Test kullanıcı adı / şifresi girilmemiş (Firma Bilgileri › e-Belge)."
                    : "Entegratör kullanıcı adı / şifresi girilmemiş (Firma Bilgileri › e-Belge).");
        if (string.IsNullOrWhiteSpace(hesap.Url))
            throw GentegreHatasi.IsKurali("Entegratör servis adresi boş.");

        // 3) Gonderim govdesi - adaptor secimi veritabaninda (167/171).
        var (entegrator, _, govde) = await GovdeUretAsync(baglanti, belgeId, iptal);

        // 4) Login + gonder.
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await JetonAlAsync(istemci, hesap, iptal);
        var yol = YolBul(entegrator, belgeTuru);

        using var istek = new HttpRequestMessage(HttpMethod.Post,
            hesap.Url.TrimEnd('/') + yol)
        {
            Content = new StringContent(govde, Encoding.UTF8, "application/json"),
        };
        istek.Headers.Authorization = new AuthenticationHeaderValue("Bearer", jeton);

        using var yanit = await istemci.SendAsync(istek, iptal);
        var govdeYanit = await yanit.Content.ReadAsStringAsync(iptal);
        var httpKodu = (int)yanit.StatusCode;

        if (!yanit.IsSuccessStatusCode)
        {
            // Yanit AYNEN saklanir: entegrator hata metni tek teshis kaynagi.
            await SonucYazAsync(baglanti, eBelgeId, belgeId, durum, entegrator,
                                httpKodu, Kisalt(govdeYanit), "", false, kullaniciId, iptal);
            throw GentegreHatasi.IsKurali($"Gönderilemedi (HTTP {httpKodu}): {Kisalt(govdeYanit, 500)}");
        }

        var (uuid, mesaj) = YanitCoz(govdeYanit);
        await SonucYazAsync(baglanti, eBelgeId, belgeId, GonderilmisDurum(belgeTuru),
                            entegrator, httpKodu, Kisalt(govdeYanit), uuid, true,
                            kullaniciId, iptal);

        return new Sonuc(true, mesaj, uuid, httpKodu, belgeNo, entegrator);
    }

    // --------------------------------------------------------------- okuma ----
    private static async Task<(long EBelgeId, short BelgeTuru, string BelgeNo, short Durum, int SubeId)>
        EBelgeOkuAsync(NpgsqlConnection baglanti, int belgeId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand("""
            select e.id, e.belge_turu, coalesce(e.belge_no, ''), e.durum,
                   coalesce(nullif(bl.sube_id, 0),
                            (select s.id from public.sube s
                              where s.varsayilan = 1 and s.aktif = 1 order by s.id limit 1))
              from public.belge bl
              join public.e_belge e on e.belge_id = bl.id
             where bl.id = @p0
             order by e.id desc
             limit 1
            """, baglanti);
        komut.Parameters.AddWithValue("p0", belgeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali(
                "Belge için hazırlanmış e-Belge yok. Önce \"e-Fatura Hazırla\" çalıştırın.");
        return (o.GetInt64(0), o.GetInt16(1), o.GetString(2), o.GetInt16(3), o.GetInt32(4));
    }

    private sealed record Hesap(string Entegrator, string Kullanici, string Sifre,
                                bool TestMi, string Url);

    private static async Task<Hesap> HesapOkuAsync(NpgsqlConnection baglanti, int subeId,
                                                   CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "select entegrator, kullanici, sifre, test_mi, url from public.fn_ebelge_hesap(@p0)",
            baglanti);
        komut.Parameters.AddWithValue("p0", subeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali("Şubenin e-Belge hesabı çözülemedi.");
        return new Hesap(
            o.IsDBNull(0) ? "" : o.GetString(0),
            o.IsDBNull(1) ? "" : o.GetString(1),
            o.IsDBNull(2) ? "" : o.GetString(2),
            !o.IsDBNull(3) && o.GetBoolean(3),
            o.IsDBNull(4) ? "" : o.GetString(4));
    }

    private static async Task<(string Entegrator, short Bicim, string Govde)>
        GovdeUretAsync(NpgsqlConnection baglanti, int belgeId, CancellationToken iptal)
    {
        await using var komut = new NpgsqlCommand(
            "select entegrator, bicim, govde::text from public.fn_ebelge_gonderim_govdesi(@p0)",
            baglanti);
        komut.Parameters.AddWithValue("p0", belgeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali("Gönderim gövdesi üretilemedi.");
        return (o.GetString(0), o.GetInt16(1), o.GetString(2));
    }

    // --------------------------------------------------------------- login ----
    /// <summary>
    /// izibiz jeton alma. Delphi uc varyant deniyor; calisani JSON govdeli
    /// `/v1/auth/token` (dogrulandi) - once o denenir, olmazsa form-encoded.
    /// </summary>
    private static async Task<string> JetonAlAsync(HttpClient istemci, Hesap hesap,
                                                   CancellationToken iptal)
    {
        var taban = hesap.Url.TrimEnd('/');

        var jeton = await DeneAsync(new StringContent(
            JsonSerializer.Serialize(new { username = hesap.Kullanici, password = hesap.Sifre }),
            Encoding.UTF8, "application/json"));
        if (jeton is not null) return jeton;

        jeton = await DeneAsync(new FormUrlEncodedContent(new Dictionary<string, string>
        {
            ["grant_type"] = "password",
            ["username"] = hesap.Kullanici,
            ["password"] = hesap.Sifre,
        }));
        if (jeton is not null) return jeton;

        throw GentegreHatasi.IsKurali(
            "Entegratöre giriş yapılamadı; kullanıcı adı / şifre ve ortam (test/üretim) doğru mu?");

        async Task<string?> DeneAsync(HttpContent govde)
        {
            using var istek = new HttpRequestMessage(HttpMethod.Post, taban + "/v1/auth/token")
            { Content = govde };
            using var yanit = await istemci.SendAsync(istek, iptal);
            if (!yanit.IsSuccessStatusCode) return null;
            var metin = await yanit.Content.ReadAsStringAsync(iptal);
            return JetonAyikla(metin);
        }
    }

    /// <summary>Jeton anahtari entegratore gore degisir; bilinen adlar denenir.</summary>
    private static string? JetonAyikla(string yanit)
    {
        try
        {
            using var belge = JsonDocument.Parse(yanit);
            var kok = belge.RootElement;
            if (Bul(kok) is { } t) return t;
            // izibiz jetonu `data` altinda dondurur.
            if (kok.TryGetProperty("data", out var veri) && Bul(veri) is { } t2) return t2;
            return null;
        }
        catch (JsonException) { return null; }

        static string? Bul(JsonElement e)
        {
            foreach (var ad in new[] { "accessToken", "access_token", "token", "ACCESS_TOKEN" })
                if (e.ValueKind == JsonValueKind.Object && e.TryGetProperty(ad, out var d)
                    && d.ValueKind == JsonValueKind.String)
                    return d.GetString();
            return null;
        }
    }

    private static (string Uuid, string Mesaj) YanitCoz(string yanit)
    {
        try
        {
            using var belge = JsonDocument.Parse(yanit);
            var kok = belge.RootElement;
            var uuid = "";
            foreach (var ad in new[] { "uuid", "UUID", "documentUUID", "id" })
                if (kok.ValueKind == JsonValueKind.Object && kok.TryGetProperty(ad, out var d))
                { uuid = d.ToString(); break; }
            var mesaj = "Gönderim başarılı";
            foreach (var ad in new[] { "message", "description" })
                if (kok.ValueKind == JsonValueKind.Object && kok.TryGetProperty(ad, out var d)
                    && d.ValueKind == JsonValueKind.String)
                { mesaj = d.GetString() ?? mesaj; break; }
            return (uuid, mesaj);
        }
        catch (JsonException) { return ("", "Gönderim başarılı"); }
    }

    private static string Kisalt(string metin, int sinir = 4000)
        => metin.Length <= sinir ? metin : metin[..sinir];

    // ---------------------------------------------------------------- yazma ---
    /// <summary>
    /// Sonuc HER DURUMDA yazilir - basarisiz denemenin de izi kalir, yoksa
    /// "gonderdim ama olmadi" durumu tesbit edilemez. Basarisizda DURUM
    /// DEGISMEZ: belge hazir kalir ve yeniden gonderilebilir.
    /// </summary>
    private static async Task SonucYazAsync(NpgsqlConnection baglanti, long eBelgeId,
        int belgeId, short durum, string entegrator, int httpKodu, string yanit,
        string uuid, bool basarili, int kullaniciId, CancellationToken iptal)
    {
        await using var islem = await baglanti.BeginTransactionAsync(iptal);

        await using (var komut = new NpgsqlCommand("""
            update public.e_belge
               set durum = @p1,
                   entegrator = @p2,
                   servis_durum_kodu = @p3,
                   servis_durum_adi = left(@p4, 200),
                   api_json = @p5,
                   uuid = case when coalesce(nullif(btrim(@p6), ''), '') <> ''
                               then @p6 else uuid end,
                   degistiren = @p7,
                   degistirme_tarihi = now()::timestamp
             where id = @p0
            """, baglanti, islem))
        {
            komut.Parameters.AddWithValue("p0", eBelgeId);
            komut.Parameters.AddWithValue("p1", durum);
            komut.Parameters.AddWithValue("p2", entegrator);
            komut.Parameters.AddWithValue("p3", httpKodu);
            komut.Parameters.AddWithValue("p4", basarili ? "Gönderildi" : $"HTTP {httpKodu}");
            komut.Parameters.Add("p5", NpgsqlDbType.Text).Value = yanit;
            komut.Parameters.AddWithValue("p6", uuid);
            komut.Parameters.AddWithValue("p7", kullaniciId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        if (basarili)
        {
            await using var komut = new NpgsqlCommand("""
                update public.belge
                   set efatura_durum = @p1, degistiren = @p2,
                       degistirme_tarihi = now()::timestamp
                 where id = @p0
                """, baglanti, islem);
            komut.Parameters.AddWithValue("p0", belgeId);
            komut.Parameters.AddWithValue("p1", durum);
            komut.Parameters.AddWithValue("p2", kullaniciId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
    }
}
