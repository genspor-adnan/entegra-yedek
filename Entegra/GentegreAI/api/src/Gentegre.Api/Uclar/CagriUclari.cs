using System.Security.Cryptography;
using System.Text.Json;
using System.Text.Json.Nodes;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Veri;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇAĞRI MERKEZİ (839) — liste/kart dışı uçlar. Mockuplar Ekranlar/CagriMerkezi.
///
///   /api/cagri/pano            operatör panosu: agent durumu, kuyruk, bugünkü çağrılar, aktif çağrı
///   /api/cagri/arayan          arayan tanıma: numara → taraf adayları + seçili kişinin özeti
///   /api/cagri/baslat|{id}/ustlen|{id}/kapat|{id}/ilgili|{id}/not|{id}/mesaj   çağrı akışı
///   /api/cagri/{id}            çağrı kartı (olaylar, ilgili kayıtlar, kalite, kişinin geçmişi)
///   /api/cagri/{id}/kalite|ozet   kalite değerlendirme, kural tabanlı özet (model bağlı değil)
///   /api/cagri/geri-arama      geri arama listesi: söz + kaçan + kampanya adımı
///   /api/cagri/kampanya/{id}/uret|calistir|durdur, /kampanya-kisi/{id}/sonuc
///   /api/cagri/supervizor      canlı KPI, agentlar, kuyruklar, saatlik, konu dağılımı, kalite
///   /api/cagri/santral         şubenin santral / kanal ayarı
///   /api/acik/cagri/olay/{saglayici}?anahtar=   ANONİM santral webhook'u (ringing/answered/hold/
///                              unhold/transfer/hangup); anahtar cagri_santral.webhook_anahtar.
///
/// Dosyalar: <c>.Akis</c> (pano, arayan, çağrı akışı, kart, kalite, özet),
/// <c>.Giden</c> (geri arama listesi, kampanya), <c>.Supervizor</c> (canlı pano,
/// santral ayarı), <c>.Webhook</c> (anonim santral olayı). Bu dosya: sabitler,
/// istek kayıtları, ortak yardımcılar.
///
/// Softphone yok: masaüstü telefon çalar, santral olayı ekranı açar. Şikayet =
/// GÖREV (tur 1); geri arama = GÖREV (tur 2) + cagri.geri_arama.
/// </summary>
public static partial class CagriUclari
{
    private const int LogCagri = 1330;
    private const int LogKampanya = 1336;
    private const int LogKalite = 1338;

    /// <summary>bildirim.kaynak_tur: çağrı / kampanya kişisi.</summary>
    private const int KaynakTurCagri = 41;
    private const int KaynakTurKampanyaKisi = 42;

    /// <summary>Yeni satırlarda görünen kişi adı ve telefonu (taraf takma adı <c>t</c>).</summary>
    private const string TarafAdi = "coalesce(nullif(trim(coalesce(t.ad,'')||' '||coalesce(t.soyad,'')),''), t.unvan, '')";
    private const string TarafTel = "coalesce(nullif(t.cep_tel,''), t.telefon, '')";

    /// <summary>cagri_agent.durum</summary>
    private const short AgentHazir = 1, AgentCagrida = 2, AgentIslemSonrasi = 3, AgentMola = 4, AgentCikis = 5;

    public sealed record AgentDurumIstegi(short Durum, short? MolaSebep);
    public sealed record BaslatIstegi(short? Kanal, short? Yon, string? ArayanNo, int? TarafId, int? KuyrukId, int? KampanyaKisiId);
    public sealed record KapatIstegi(int? KonuId, int? AltKonuId, short? Sonuc, string? Notu, short? Oncelik, int? TarafId,
                                     DateTime? GeriArama, string? GorevKonu, short? Memnuniyet);
    public sealed record IlgiliIstegi(string KaynakTur, int KaynakId, string? Aciklama);
    public sealed record NotIstegi(string Metin);
    public sealed record MesajIstegi(string Sablon, string? Telefon, string? Tutar, string? Baglanti, string? Saat);
    public sealed record KaliteIstegi(short Puan, JsonNode? Olcutler, string? Notu);
    public sealed record KisiSonucIstegi(short Durum, string? Sonuc, int? CagriId);
    public sealed record SantralIstegi(string? Saglayici, string? ApiAdres, string? Kimlik, string? Gizli, string? KayitKaynak, short? KvkkAnons,
                                       int? KayitSaklamaAy, JsonNode? Ivr, JsonNode? Calisma, string? MesaiDisiMesaj, string? WhatsappNo,
                                       string? WhatsappToken, string? BotIlkYanit, string? EpostaAdres, int? IslemSonrasiSn);
    public sealed record OlayIstegi(string Olay, string? Ref, string? Arayan, string? Aranan, string? Kuyruk, string? Dahili, int? SureSn, string? KayitUrl, string? Hedef);

    public static void CagriUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var yetkili = yol.MapGroup("/api/cagri").WithTags("Çağrı Merkezi").RequireAuthorization();
        AkisUclari(yetkili);
        GidenUclari(yetkili);
        SupervizorUclari(yetkili);
        SantralUclari(yetkili);
        WebhookUclari(yol.MapGroup("/api/acik/cagri").WithTags("Çağrı Merkezi (santral)").AllowAnonymous());
    }

    // ============================================================ yardımcı ====
    private static IResult Json(object o) => Results.Content(JsonSerializer.Serialize(o), "application/json");
    private static JsonNode? Parse(string? s) => s is null ? null : JsonNode.Parse(s);
    private static JsonNode?[] ParseList(IReadOnlyList<string> s) => s.Select(x => JsonNode.Parse(x)).ToArray();

    /// <summary><c>row_to_json(..)::text</c> / <c>json_build_object(..)::text</c> tek satır → JSON düğümü.</summary>
    private static async Task<JsonNode?> JsonTekAsync(NpgsqlConnection b, string sql, object?[] par, CancellationToken iptal)
        => Parse(await b.TekAsync(sql, null, par, o => o.GetString(0), iptal));

    /// <summary>Aynı kalıbın liste hali.</summary>
    private static async Task<JsonNode?[]> JsonListeAsync(NpgsqlConnection b, string sql, object?[] par, CancellationToken iptal)
        => ParseList(await b.ListeAsync(sql, null, par, o => o.GetString(0), iptal));

    private static int? SayiN(NpgsqlDataReader o, int i) => o.IsDBNull(i) ? null : o.GetInt32(i);
    private static string Kirp(string? m, int n) => (m ?? "").Length <= n ? m ?? "" : m![..n];

    private static string TelAnahtar(string? tel)
    {
        var d = new string((tel ?? "").Where(char.IsDigit).ToArray());
        return d.Length > 10 ? d[^10..] : d;
    }

    private static string AnahtarUret() => Convert.ToHexString(RandomNumberGenerator.GetBytes(12)).ToLowerInvariant();

    private static string KurumAdi(IstekBaglami baglam) => baglam.AktifSube?.Ad ?? "GenoTIP";

    /// <summary>Numaradan ilk taraf adayı (fn_cagri_arayan_bul); numara boşsa null.</summary>
    private static async Task<int?> TarafBulAsync(NpgsqlConnection b, string tel, CancellationToken iptal)
        => tel == "" ? null : await b.TekDegerAsync<int?>("select taraf_id from public.fn_cagri_arayan_bul(@p0) limit 1", null, [tel], iptal);

    /// <summary>Santral kuyruk kodu ya da adından kuyruk.</summary>
    private static async Task<int?> KuyrukBulAsync(NpgsqlConnection b, string? kod, CancellationToken iptal)
        => string.IsNullOrWhiteSpace(kod) ? null :
           await b.TekDegerAsync<int?>("select id from public.cagri_kuyruk where santral_kodu = @p0 or lower(ad) = lower(@p0) limit 1", null, [kod.Trim()], iptal);

    /// <summary>Dahili numaradan aktif agent.</summary>
    private static async Task<int?> AgentBulAsync(NpgsqlConnection b, string? dahili, CancellationToken iptal)
        => string.IsNullOrWhiteSpace(dahili) ? null :
           await b.TekDegerAsync<int?>("select kullanici_id from public.cagri_agent where dahili = @p0 and aktif = 1 limit 1", null, [dahili.Trim()], iptal);

    private static async Task OlayYazAsync(NpgsqlConnection b, int cagriId, short tur, int? agentId, string aciklama, string veri, CancellationToken iptal)
        => await b.CalistirAsync("insert into public.cagri_olay (cagri_id, tur, zaman, agent_id, aciklama, veri) values (@p0, @p1, now(), @p2, @p3, @p4)", null,
            [cagriId, tur, agentId, Kirp(aciklama, 300), Kirp(veri, 1000)], iptal);

    private static async Task<int> IlgiliEkleAsync(NpgsqlConnection b, int cagriId, string kaynakTur, int kaynakId, string aciklama, int kullaniciId, CancellationToken iptal)
    {
        var id = await b.TekDegerAsync<int>("insert into public.cagri_ilgili (cagri_id, kaynak_tur, kaynak_id, aciklama, ekleyen) values (@p0, @p1, @p2, @p3, @p4) returning id", null,
            [cagriId, Kirp(kaynakTur, 30), kaynakId, Kirp(aciklama, 200), kullaniciId], iptal);
        await OlayYazAsync(b, cagriId, 9, kullaniciId, $"{kaynakTur} #{kaynakId} {aciklama}", "", iptal);
        return id;
    }

    /// <summary>Kullanıcının agent satırı yoksa açar (dahili boş; ayarlardan doldurulur).</summary>
    private static async Task AgentSaglaAsync(NpgsqlConnection b, IstekBaglami baglam, CancellationToken iptal)
        => await b.CalistirAsync("""
            insert into public.cagri_agent (kullanici_id, dahili, durum, durum_zaman, sube_id, ekleyen)
            values (@p0, '', 1, now(), @p1, @p0) on conflict (kullanici_id) do nothing
            """, null, [baglam.KullaniciId, baglam.SubeId ?? 0], iptal);

    /// <summary>Agent durumunu sistem koyar (çağrıya girdi / çağrı bitti).</summary>
    private static async Task AgentDurumAsync(NpgsqlConnection b, int? kullaniciId, short durum, CancellationToken iptal)
    {
        if (kullaniciId is null) return;
        await b.CalistirAsync("update public.cagri_agent set durum = @p1, durum_zaman = now() where kullanici_id = @p0", null, [kullaniciId, durum], iptal);
    }

    /// <summary>Çağrı bitince: çağrıdaki agent işlem sonrasına geçer (başka durumda ise dokunulmaz).</summary>
    private static async Task AgentIslemSonrasinaAlAsync(NpgsqlConnection b, int? kullaniciId, CancellationToken iptal)
    {
        if (kullaniciId is null) return;
        await b.CalistirAsync("update public.cagri_agent set durum = @p1, durum_zaman = now() where kullanici_id = @p0 and durum = @p2", null,
            [kullaniciId, AgentIslemSonrasi, AgentCagrida], iptal);
    }

    /// <summary>İşlem sonrası süresi dolan agent kendiliğinden hazır olur (santral ayarı, vars. 45 sn).</summary>
    private static async Task IslemSonrasiKapatAsync(NpgsqlConnection b, int kullaniciId, CancellationToken iptal)
        => await b.CalistirAsync("""
            update public.cagri_agent a set durum = 1, durum_zaman = now()
             where a.kullanici_id = @p0 and a.durum = 3
               and a.durum_zaman < now() - make_interval(secs => coalesce((select s.islem_sonrasi_sn from public.cagri_santral s where s.sube_id = a.sube_id), 45))
               and not exists (select 1 from public.cagri c where c.agent_id = a.kullanici_id and c.durum in (2, 3, 4))
            """, null, [kullaniciId], iptal);

    /// <summary>Şubenin santral satırı yoksa açar (sağlayıcı "yok", rastgele webhook anahtarı).</summary>
    private static async Task SantralSaglaAsync(NpgsqlConnection b, int subeId, CancellationToken iptal)
        => await b.CalistirAsync("insert into public.cagri_santral (sube_id, saglayici, webhook_anahtar) values (@p0, 'yok', @p1) on conflict do nothing", null,
            [subeId, AnahtarUret()], iptal);

    /// <summary>Arayan kişinin özeti: kimlik, son ziyaret, yaklaşan randevu, bekleyen/hazır sonuç, bakiye.</summary>
    private static async Task<object?> KisiOzetiAsync(NpgsqlConnection b, int tarafId, CancellationToken iptal)
        => await b.TekAsync($"""
            select t.id, {TarafAdi}, coalesce(t.kod, ''), coalesce(t.vkno, ''), coalesce(t.cep_tel, ''), coalesce(t.telefon, ''),
                   t.hasta, t.musteri, t.personel, t.kurum, h.dogum_tarihi, h.cinsiyet,
                   (select to_char(r.baslangic, 'DD.MM.YYYY') || ' · ' || coalesce(d.ad, '') || coalesce(' · ' || hk.ad, '') from public.randevu r
                      left join public.v_departman_lookup d on d.id = r.bolum left join public.v_hekim_lookup hk on hk.id = r.hekim_id
                     where r.hasta_id = t.id and r.baslangic < now() and r.durum = 2 order by r.baslangic desc limit 1),
                   (select json_build_object('id', r.id, 'metin', to_char(r.baslangic, 'DD.MM.YYYY HH24:MI') || ' · ' || coalesce(d.ad, '') || coalesce(' · ' || hk.ad, ''))::text from public.randevu r
                      left join public.v_departman_lookup d on d.id = r.bolum left join public.v_hekim_lookup hk on hk.id = r.hekim_id
                     where r.hasta_id = t.id and r.baslangic >= now() and r.durum = 1 order by r.baslangic limit 1),
                   (select count(*) from public.lab_istem li where li.taraf_id = t.id and li.sonuc_tarihi is null and li.istem_tarihi >= now() - interval '30 days'),
                   (select count(*) from public.lab_istem li where li.taraf_id = t.id and li.sonuc_tarihi >= now() - interval '7 days'),
                   (select coalesce(sum(e.yerel_borc) - sum(e.yerel_alacak), 0) from public.v_cari_ekstre e where e.taraf_id = t.id),
                   (select count(*) from public.gorev g where g.taraf_id = t.id and g.durum < 2)
              from public.taraf t left join public.taraf_hasta h on h.id = t.id
             where t.id = @p0
            """, null, [tarafId], o => new
        {
            tarafId = o.GetInt32(0), ad = o.GetString(1), kod = o.GetString(2), tckn = o.GetString(3), cepTel = o.GetString(4), telefon = o.GetString(5),
            hasta = o.GetInt16(6), musteri = o.GetInt16(7), personel = o.GetInt16(8), kurum = o.GetInt16(9),
            dogumTarihi = o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10), cinsiyet = o.IsDBNull(11) ? (int?)null : Convert.ToInt32(o.GetValue(11)),
            sonZiyaret = o.IsDBNull(12) ? "" : o.GetString(12), yaklasanRandevu = o.IsDBNull(13) ? null : JsonNode.Parse(o.GetString(13)),
            bekleyenSonuc = o.GetInt64(14), hazirSonuc = o.GetInt64(15), bakiye = o.GetDecimal(16), acikGorev = o.GetInt64(17),
        }, iptal);
}
