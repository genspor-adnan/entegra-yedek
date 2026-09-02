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

    /// <param name="aliciAlias">
    /// e-Faturada GIB posta kutusu, e-ARSIVDE ALICI E-POSTASI (Delphi ile ayni
    /// ikili anlam). Dolu gelirse govde uretilmeden ONCE kayda yazilir - govde
    /// onu okuyup mailFlag / receiverAlias'i kurar.
    /// </param>
    public async Task<Sonuc> GonderAsync(int belgeId, int kullaniciId,
                                         string? aliciAlias = null,
                                         CancellationToken iptal = default)
    {
        await using var baglanti = await veri.AcAsync(iptal);

        if (!string.IsNullOrWhiteSpace(aliciAlias))
        {
            await using var alias = baglanti.Komut(
                "update public.e_belge set alici_alias = left(btrim(@p1), 500), "
                + "degistiren = @p2, degistirme_tarihi = now()::timestamp "
                + "where belge_id = @p0 and id = (select max(id) from public.e_belge "
                + "where belge_id = @p0)", null,
                belgeId, aliciAlias, kullaniciId);
            await alias.ExecuteNonQueryAsync(iptal);
        }

        // 1) Belgenin e-Belge kaydi + durumu.
        var (eBelgeId, belgeTuru, belgeNo, durum, subeId) =
            await EBelgeOkuAsync(baglanti, belgeId, iptal);

        if (durum is 2 or 12 or 52)
            throw GentegreHatasi.IsKurali("Bu belge zaten gönderilmiş.");
        if (durum == 0)
            throw GentegreHatasi.IsKurali("Önce \"e-Fatura Hazırla\" ile belge hazırlanmalı.");

        // 2) Mukellef hesabi (171): kimlik hangi subedeyse hesap da onun.
        var hesap = await EBelgeIstemcisi.HesapAsync(baglanti, subeId, "gönderim", iptal);
        if (string.IsNullOrWhiteSpace(hesap.Kullanici) || string.IsNullOrWhiteSpace(hesap.Sifre))
            throw GentegreHatasi.IsKurali(
                hesap.TestMi
                    ? "Test kullanıcı adı / şifresi girilmemiş (Ayarlar › Genel › Entegrasyon)."
                    : "Entegratör kullanıcı adı / şifresi girilmemiş (Ayarlar › Genel › Entegrasyon).");

        // 3) Gonderim govdesi - adaptor secimi veritabaninda (167/171).
        var (entegrator, _, govde) = await GovdeUretAsync(baglanti, belgeId, iptal);

        // 4) Login + gonder.
        var istemci = istemciUretici.CreateClient("ebelge");
        var jeton = await EBelgeIstemcisi.JetonAsync(istemci, hesap, iptal);
        var yol = YolBul(entegrator, belgeTuru);

        using var istek = new HttpRequestMessage(HttpMethod.Post,
            hesap.Taban + yol)
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

            // ALICI GIB LISTESINDE YOK: mukellef sorgusu (vergi dairesi kaydi)
            //   "FAAL" dese de alici e-Fatura KULLANICISI olmayabilir - tek kesin
            //   kanit gonderimin kendisi. Cariyi e-Arsiv'e cevirip kullaniciya ne
            //   yapacagini soyle; yoksa ayni belge her denemede ayni hatayi alir.
            if (belgeTuru == 1 && govdeYanit.Contains("RECEIVER_COULD_NOT_FOUND",
                                                      StringComparison.OrdinalIgnoreCase))
            {
                await MukellefDegilIsaretleAsync(baglanti, belgeId, kullaniciId, iptal);
                throw GentegreHatasi.IsKurali(
                    "Alıcı GİB e-Fatura kullanıcı listesinde yok; cari e-Arşiv'e çevrildi. " +
                    "\"Hazırı Geri Al\" ve ardından \"Hazırla\" ile belgeyi e-Arşiv olarak " +
                    "yeniden hazırlayın.");
            }

            throw GentegreHatasi.IsKurali($"Gönderilemedi (HTTP {httpKodu}): {Kisalt(govdeYanit, 500)}");
        }

        var (uuid, mesaj) = YanitCoz(govdeYanit);
        await SonucYazAsync(baglanti, eBelgeId, belgeId, GonderilmisDurum(belgeTuru),
                            entegrator, httpKodu, Kisalt(govdeYanit), uuid, true,
                            kullaniciId, iptal);

        return new Sonuc(true, mesaj, uuid, httpKodu, belgeNo, entegrator);
    }

    /// <summary>
    /// Belgenin carisini "e-Fatura mükellefi DEĞİL" olarak isaretle ve sorgu
    /// tarihini tazele (185) - boylece bir sonraki hazirlama e-Arsiv secer ve
    /// tazelik kurali hemen yeniden sormaz.
    /// </summary>
    private static async Task MukellefDegilIsaretleAsync(NpgsqlConnection baglanti,
        int belgeId, int kullaniciId, CancellationToken iptal)
    {
        await using var komut = baglanti.Komut("""
            update public.taraf t
               set efatura = 0, efatura_sorgu_tarihi = now()::timestamp,
                   degistiren = @p1, degistirme_tarihi = now()::timestamp
              from public.belge b
             where b.id = @p0 and t.id = b.taraf_id
            """, null,
            belgeId, kullaniciId);
        await komut.ExecuteNonQueryAsync(iptal);
    }

    // --------------------------------------------------------------- okuma ----
    private static async Task<(long EBelgeId, short BelgeTuru, string BelgeNo, short Durum, int SubeId)>
        EBelgeOkuAsync(NpgsqlConnection baglanti, int belgeId, CancellationToken iptal)
    {
        await using var komut = baglanti.Komut("""
            select e.id, e.belge_turu, coalesce(e.belge_no, ''), e.durum,
                   coalesce(nullif(bl.sube_id, 0),
                            (select s.id from public.sube s
                              where s.varsayilan = 1 and s.aktif = 1 order by s.id limit 1))
              from public.belge bl
              join public.e_belge e on e.belge_id = bl.id
             where bl.id = @p0
             order by e.id desc
             limit 1
            """, null,
            belgeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali(
                "Belge için hazırlanmış e-Belge yok. Önce \"e-Fatura Hazırla\" çalıştırın.");
        return (o.GetInt64(0), o.GetInt16(1), o.GetString(2), o.GetInt16(3), o.GetInt32(4));
    }

    // Hesap okuma / jeton alma ORTAK: EBelgeIstemcisi (uc serviste kopyaydi).

    private static async Task<(string Entegrator, short Bicim, string Govde)>
        GovdeUretAsync(NpgsqlConnection baglanti, int belgeId, CancellationToken iptal)
    {
        await using var komut = baglanti.Komut(
            "select entegrator, bicim, govde::text from public.fn_ebelge_gonderim_govdesi(@p0)", null,
            belgeId);
        await using var o = await komut.ExecuteReaderAsync(iptal);
        if (!await o.ReadAsync(iptal))
            throw GentegreHatasi.IsKurali("Gönderim gövdesi üretilemedi.");
        return (o.GetString(0), o.GetInt16(1), o.GetString(2));
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
                   -- GIB'e GIDENIN kopyasi (182): uyusmazlikta entegratore
                   --   bagimli kalmayalim. Uretilemezse (eski belge, eksik veri)
                   --   gonderim durmasin diye hata yutulur.
                   ubl_xml = coalesce(ubl_xml,
                       (select xmlserialize(document public.fn_ebelge_ubl(@p8) as text))),
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
            komut.Parameters.AddWithValue("p8", belgeId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        if (basarili)
        {
            await using var komut = baglanti.Komut("""
                update public.belge
                   set efatura_durum = @p1, degistiren = @p2,
                       degistirme_tarihi = now()::timestamp
                 where id = @p0
                """, islem,
                belgeId, durum, kullaniciId);
            await komut.ExecuteNonQueryAsync(iptal);
        }

        await islem.CommitAsync(iptal);
    }
}
