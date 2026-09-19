using System.Text.Json;
using System.Text.Json.Nodes;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// STERİLİZASYON (868) — liste/kart dışı uçlar. Mockuplar Ekranlar/Dis Klinigi/dis_steril_*.html.
///
///   /api/steril/pano                    cihazlar, günün döngüleri, hazırlanan birimler, uyarılar, SKT
///   /api/steril/kurallar                kurum kuralları (GET / POST; referans steril.kurallar)
///   /api/steril/dongu/baslat            yükleme + program → döngü (paketler, indikatörler, Bowie-Dick kuralı)
///   /api/steril/dongu/{id}/bitir|indikator|serbest|iptal · /dongu/{id} kart
///   /api/steril/birim/olay              kirli / yıkama / sayım / paketle / yağlama / arıza / depo
///   /api/steril/paket/okut              seansta kullanım (hasta / seans / hekim / ünite)
///   /api/steril/paket/{barkod}          izlenebilirlik zinciri
///   /api/steril/izleme?tarafId=         hasta bazlı kullanım
///   /api/steril/geri-cagirma            biyolojik pozitif → etkilenen döngü / paket / hasta; bloke; kapat; bildir
///   /api/steril/kayit-defteri?ay=       SKS sterilizasyon kayıt defteri (serbest bırakılmış döngüler)
///   /api/steril/ayar                    cihazlar, programlar, test uyumu, bakım takvimi
///
/// Dosyalar: bu dosya (sabitler, istekler, yardımcılar, pano, kurallar, ayar),
/// <c>.Islem</c> (döngü / birim / paket / izleme / geri çağırma).
/// </summary>
public static partial class SterilUclari
{
    private const int LogDongu = 1345, LogPaket = 1346, LogKullanim = 1347, LogGeriCagirma = 1349, LogCihaz = 1340;

    // steril.dongu_durum
    private const short DonguCalisiyor = 2, DonguIndikator = 3, DonguSerbest = 4, DonguKarantina = 5, DonguBasarisiz = 6, DonguIptal = 7, DonguTest = 8;
    // steril.birim_durum
    private const short BirimKirli = 1, BirimYikamada = 2, BirimSayim = 3, BirimPaketlendi = 4, BirimSterilde = 5, BirimKarantina = 6, BirimDepoda = 7, BirimKullanimda = 8, BirimArizali = 9, BirimYenidenIsle = 10;
    // steril.paket_durum
    private const short PaketSterilde = 1, PaketKarantina = 2, PaketSteril = 3, PaketKullanildi = 4, PaketIptal = 5, PaketSuresiDoldu = 6, PaketBloke = 7;
    // steril.indikator_tur / sonuc
    private const short IndBowieDick = 1, IndHelix = 2, IndSinif4 = 3, IndSinif5 = 4, IndSinif6 = 5, IndBiyolojik = 6, IndVakum = 7;
    private const short SonucBekliyor = 0, SonucGecti = 1, SonucKaldi = 2, SonucInkubasyon = 3;
    // steril.olay_tur
    private const short OlayKirli = 1, OlayYikama = 2, OlaySayim = 3, OlayPaketle = 4, OlayYukle = 5, OlayBitti = 6, OlayIndikator = 7, OlaySerbest = 8, OlayKarantina = 9, OlayBasarisiz = 10, OlayKullanim = 11, OlayYaglama = 12, OlayAriza = 13, OlayBloke = 14, OlayNot = 15;

    public sealed record YukBirimi(int? BirimId, string? Barkod, short? PaketTur, string? Raf);
    public sealed record DonguBaslatIstegi(int CihazId, int? ProgramId, YukBirimi[]? Birimler, string? KimyasalLot, string? BioLot, string? BdOnayNotu, string? Notu);
    public sealed record DonguBitirIstegi(decimal? TepeSicaklik, decimal? PlatoDk, decimal? TepeBasinc, decimal? KurutmaDk, string? HataKodu);
    public sealed record IndikatorIstegi(short Tur, string? Lot, string? Konum, short Sonuc, string? Notu, int? InkubasyonSaat);
    public sealed record SerbestIstegi(string Karar, string? Notu, string? BdOnayNotu);
    public sealed record BirimOlayIstegi(int? BirimId, string? Barkod, string Islem, short? Sayilan, short? Toplam, string? Eksik, string? Notu, int? TarafId, int? BelgeId);
    public sealed record OkutIstegi(string Barkod, int? TarafId, int? BelgeId, int? HekimId, string? Unite, bool? Zorla, string? Notu);
    public sealed record GeriCagirmaIstegi(int DonguId, string? Aciklama);
    public sealed record AciklamaIstegi(string? Aciklama);

    /// <summary>referans steril.kurallar (868 tohumu); eksik alanlar varsayılana düşer.</summary>
    public sealed class Kurallar
    {
        public string BdKurali { get; set; } = "onay";           // uyari · onay · engel
        public int BioGecikmeUyariGun { get; set; } = 7;
        public int BioGecikmeEngelGun { get; set; } = 10;
        public string KarantinaKullanim { get; set; } = "uyari"; // uyari · engel
        public string SeansOkutma { get; set; } = "uyari";
        public int SktUyariGun { get; set; } = 7;
        public int YaglamaZorunlu { get; set; } = 1;
        public int DonguEsigi { get; set; } = 400;
        public Dictionary<string, int> RafOmru { get; set; } = new() { ["1"] = 6, ["2"] = 12, ["3"] = 6, ["4"] = 12, ["5"] = 0 };
        public string EtiketYazici { get; set; } = "";
        public int BioSiklikGun { get; set; } = 7;
    }
    private static readonly JsonSerializerOptions JsonAyar = new(JsonSerializerDefaults.Web);

    public static void SterilUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/steril").WithTags("Sterilizasyon").RequireAuthorization();
        PanoUclari(grup);
        IslemUclari(grup);
        IzlemeUclari(grup);
    }

    // ============================================================ yardımcı ====
    // Kurallar sınıfı (PascalCase) da bu yoldan döner: web seçenekleri (camelCase) şart.
    private static IResult Json(object o) => Results.Content(JsonSerializer.Serialize(o, JsonAyar), "application/json");
    private static JsonNode? Parse(string? s) => s is null ? null : JsonNode.Parse(s);
    private static async Task<JsonNode?> JsonTekAsync(NpgsqlConnection b, string sql, object?[] par, CancellationToken iptal)
        => Parse(await b.TekAsync(sql, null, par, o => o.GetString(0), iptal));
    private static async Task<JsonNode?[]> JsonListeAsync(NpgsqlConnection b, string sql, object?[] par, CancellationToken iptal)
        => (await b.ListeAsync(sql, null, par, o => o.GetString(0), iptal)).Select(x => JsonNode.Parse(x)).ToArray();
    private static int? SayiN(NpgsqlDataReader o, int i) => o.IsDBNull(i) ? null : o.GetInt32(i);
    private static string Kirp(string? m, int n) => (m ?? "").Length <= n ? m ?? "" : m![..n];

    private static async Task<Kurallar> KurallarAsync(NpgsqlConnection b, CancellationToken iptal)
    {
        var metin = await b.TekDegerAsync<string>("select deger from public.referans where anahtar = 'steril.kurallar'", null, [], iptal);
        if (string.IsNullOrWhiteSpace(metin)) return new Kurallar();
        try { return JsonSerializer.Deserialize<Kurallar>(metin, JsonAyar) ?? new Kurallar(); } catch (JsonException) { return new Kurallar(); }
    }

    private static async Task OlayYazAsync(NpgsqlConnection b, int? birimId, int? paketId, int? donguId, short tur, int? kullaniciId, string aciklama, CancellationToken iptal, string veri = "")
        => await b.CalistirAsync("insert into public.steril_olay (birim_id, paket_id, dongu_id, tur, kullanici_id, aciklama, veri) values (@p0, @p1, @p2, @p3, @p4, @p5, @p6)", null,
            [birimId, paketId, donguId, tur, kullaniciId, Kirp(aciklama, 300), Kirp(veri, 600)], iptal);

    private static async Task BirimDurumAsync(NpgsqlConnection b, int birimId, short durum, int kullaniciId, CancellationToken iptal, string? konum = null)
        => await b.CalistirAsync("update public.steril_birim set durum = @p1, durum_zaman = now(), konum = coalesce(@p3::text, konum), degistiren = @p2, degistirme_tarihi = now() where id = @p0", null,
            [birimId, durum, kullaniciId, konum], iptal);

    private sealed record BirimSatiri(int Id, string Barkod, string Ad, short Tur, short Durum, int? SetId, short PaketTur, short RafOmruAy, short Implant, short YaglamaGerekli, DateTime? SonYaglama, DateTime? SonKullanim, string Konum);
    private static async Task<BirimSatiri?> BirimBulAsync(NpgsqlConnection b, int? id, string? barkod, CancellationToken iptal)
        => await b.TekAsync("""
            select b.id, b.barkod, b.ad, b.tur, b.durum, b.set_id, coalesce(s.paket_tur, 1), coalesce(s.raf_omru_ay, 6), coalesce(s.implant, 0), b.yaglama_gerekli, b.son_yaglama, b.son_kullanim, b.konum
              from public.steril_birim b left join public.steril_set s on s.id = b.set_id
             where b.aktif = 1 and ((@p0::int is not null and b.id = @p0) or (@p1::text <> '' and upper(b.barkod) = upper(@p1)))
            """, null, [id, (barkod ?? "").Trim()], o => new BirimSatiri(o.GetInt32(0), o.GetString(1), o.GetString(2), o.GetInt16(3), o.GetInt16(4), SayiN(o, 5), o.GetInt16(6), o.GetInt16(7), o.GetInt16(8), o.GetInt16(9),
                o.IsDBNull(10) ? null : o.GetDateTime(10), o.IsDBNull(11) ? null : o.GetDateTime(11), o.GetString(12)), iptal);

    /// <summary>Uyarı listesi: Bowie-Dick eksik, bakım gecikmiş, biyolojik inkübasyon / gecikme, SKT, eksik alet, min. stok.</summary>
    private static async Task<List<object>> UyarilarAsync(NpgsqlConnection b, Kurallar k, CancellationToken iptal)
    {
        var u = new List<object>();
        var cihazlar = await b.ListeAsync("select id, ad, bd_bugun, durum, sonraki_bakim, sonraki_validasyon, bugun_dongu from public.v_steril_cihaz where tur = 1 and durum > 0", null, [],
            o => new { id = o.GetInt32(0), ad = o.GetString(1), bd = o.GetInt16(2), durum = o.GetInt16(3), bakim = o.IsDBNull(4) ? (DateTime?)null : o.GetDateTime(4), val = o.IsDBNull(5) ? (DateTime?)null : o.GetDateTime(5), bugun = o.GetInt64(6) }, iptal);
        foreach (var c in cihazlar)
        {
            if (c.bd == 0 && c.bugun > 0) u.Add(new { tur = "bd", seviye = "kir", cihazId = c.id, mesaj = $"{c.ad}: bugün Bowie-Dick sonucu kayıtlı değil; döngüler {(k.BdKurali == "engel" ? "engellenir" : "sorumlu onayıyla açılıyor")}." });
            else if (c.bd == 0) u.Add(new { tur = "bd", seviye = "sari", cihazId = c.id, mesaj = $"{c.ad}: günün Bowie-Dick testi henüz yapılmadı (ilk döngü, boş kazan)." });
            if (c.bakim is { } bk && bk <= DateTime.Today.AddDays(30)) u.Add(new { tur = "bakim", seviye = bk < DateTime.Today ? "kir" : "sari", cihazId = c.id, mesaj = $"{c.ad}: periyodik bakım {bk:dd.MM.yyyy}{(bk < DateTime.Today ? " GECİKTİ" : "")}." });
            if (c.val is { } vl && vl <= DateTime.Today.AddDays(60)) u.Add(new { tur = "validasyon", seviye = vl < DateTime.Today ? "kir" : "sari", cihazId = c.id, mesaj = $"{c.ad}: validasyon / kalibrasyon {vl:dd.MM.yyyy}{(vl < DateTime.Today ? " GECİKTİ" : "")}." });
        }
        var bakimGerekli = await b.ListeAsync("select id, ad from public.steril_cihaz where durum = 2", null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1) }, iptal);
        foreach (var c in bakimGerekli) u.Add(new { tur = "cihaz", seviye = "kir", cihazId = c.id, mesaj = $"{c.ad}: bakım gerekli (kullanım dışı)." });
        var bio = await b.ListeAsync("""
            select d.id, d.sayac_no, c.ad, i.inkubasyon_bitis, (select count(*) from public.steril_paket p where p.dongu_id = d.id and p.durum = 2)
              from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id join public.steril_cihaz c on c.id = d.cihaz_id
             where i.tur = 6 and i.sonuc = 3
            """, null, [], o => new { id = o.GetInt32(0), no = o.GetInt32(1), cihaz = o.GetString(2), bitis = o.IsDBNull(3) ? (DateTime?)null : o.GetDateTime(3), paket = o.GetInt64(4) }, iptal);
        foreach (var x in bio) u.Add(new { tur = "bio", seviye = "sari", donguId = x.id, mesaj = $"Biyolojik indikatör inkübasyonda: {x.cihaz} #{x.no}, okuma {x.bitis:dd.MM HH:mm}; {x.paket} paket karantinada." });
        var sonBio = await b.ListeAsync("""
            select c.id, c.ad, (select max(d.baslama) from public.steril_dongu d join public.steril_dongu_indikator i on i.dongu_id = d.id where d.cihaz_id = c.id and i.tur = 6 and i.sonuc in (1, 2))
              from public.steril_cihaz c where c.tur = 1 and c.durum > 0
            """, null, [], o => new { id = o.GetInt32(0), ad = o.GetString(1), son = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2) }, iptal);
        foreach (var c in sonBio)
        {
            var gun = c.son is null ? 999 : (DateTime.Now - c.son.Value).Days;
            if (c.son is null) u.Add(new { tur = "bio_gecikme", seviye = "sari", cihazId = c.id, mesaj = $"{c.ad}: biyolojik test hiç yapılmadı; ilk döngüye biyolojik indikatör (lot) ekleyin." });
            else if (gun >= k.BioGecikmeUyariGun) u.Add(new { tur = "bio_gecikme", seviye = gun >= k.BioGecikmeEngelGun ? "kir" : "sari", cihazId = c.id, mesaj = $"{c.ad}: haftalık biyolojik test {gun} gündür yapılmadı{(gun >= k.BioGecikmeEngelGun ? " — biyolojik indikatörsüz döngü engellenir" : "")}." });
        }
        var skt = await b.TekDegerAsync<long>("select count(*) from public.steril_paket where durum = 3 and skt is not null and skt <= current_date + @p0", null, [k.SktUyariGun], iptal);
        if (skt > 0) u.Add(new { tur = "skt", seviye = "sari", mesaj = $"Raf ömrü dolmak üzere / dolmuş {skt} paket (≤ {k.SktUyariGun} gün); yeniden işleme listesi." });
        var eksik = await b.ListeAsync("select b.id, b.ad, o.aciklama from public.steril_birim b join lateral (select aciklama from public.steril_olay o where o.birim_id = b.id and o.tur = 13 order by o.id desc limit 1) o on true where b.durum in (3, 9)", null, [],
            o => new { id = o.GetInt32(0), ad = o.GetString(1), acik = o.GetString(2) }, iptal);
        foreach (var x in eksik) u.Add(new { tur = "eksik", seviye = "sari", birimId = x.id, mesaj = $"{x.ad}: {x.acik}" });
        var stok = await b.ListeAsync("select ad, min_stok, steril_depoda from public.v_steril_set where aktif = 1 and min_stok > 0 and steril_depoda < min_stok", null, [], o => new { ad = o.GetString(0), min = o.GetInt16(1), var_ = o.GetInt64(2) }, iptal);
        foreach (var s in stok) u.Add(new { tur = "stok", seviye = "sari", mesaj = $"{s.ad}: steril stok {s.var_} < minimum {s.min}." });
        return u;
    }

    // ================================================================ pano ====
    private static void PanoUclari(RouteGroupBuilder grup)
    {
        grup.MapGet("/pano", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.pano", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var k = await KurallarAsync(b, iptal);
            var cihazlar = await JsonListeAsync(b, """
                select (row_to_json(c)::jsonb || jsonb_build_object('aktifDongu', (select row_to_json(d) from public.v_steril_dongu d where d.cihaz_id = c.id and d.durum in (2, 3) order by d.baslama desc limit 1)))::text
                  from public.v_steril_cihaz c where c.durum > 0 order by c.tur, c.id
                """, [], iptal);
            var dongular = await JsonListeAsync(b, "select row_to_json(d)::text from public.v_steril_dongu d where d.baslama >= current_date or d.durum in (2, 3, 5) order by d.baslama desc limit 60", [], iptal);
            var birimler = await JsonListeAsync(b, "select row_to_json(x)::text from public.v_steril_birim x where x.aktif = 1 and x.durum in (1, 2, 3, 4, 9, 10) order by x.durum, x.durum_zaman", [], iptal);
            var depo = await JsonListeAsync(b, "select row_to_json(p)::text from public.v_steril_paket p where p.durum in (2, 3, 7, 8) order by p.skt nulls last, p.id desc limit 300", [], iptal);
            var kullanilan = await JsonListeAsync(b, "select row_to_json(k)::text from public.v_steril_paket_kullanim k where k.zaman >= current_date order by k.zaman desc limit 100", [], iptal);
            var setler = await JsonListeAsync(b, "select row_to_json(s)::text from public.v_steril_set s where s.aktif = 1 order by s.kod", [], iptal);
            var kpi = await b.TekAsync("""
                select (select count(*) from public.steril_dongu d where d.baslama >= current_date and d.durum <> 8),
                       (select count(*) from public.steril_dongu d where d.baslama >= current_date and d.durum = 4),
                       (select count(*) from public.steril_dongu d where d.durum in (2, 3)),
                       (select count(*) from public.steril_birim x where x.aktif = 1 and x.durum in (1, 2)),
                       (select count(*) from public.steril_birim x where x.aktif = 1 and x.durum in (3, 4)),
                       (select count(*) from public.steril_paket p where p.durum = 3),
                       (select count(*) from public.steril_paket p where p.durum = 3 and p.skt is not null and p.skt <= current_date + @p0),
                       (select count(*) from public.steril_paket p where p.durum = 2),
                       (select count(*) from public.steril_paket_kullanim u where u.zaman >= current_date),
                       (select count(distinct u.taraf_id) from public.steril_paket_kullanim u where u.zaman >= current_date and u.taraf_id is not null),
                       (select count(*) from public.steril_paket p where p.durum = 7)
                """, null, [k.SktUyariGun], o => new
            {
                bugunDongu = o.GetInt64(0), bugunSerbest = o.GetInt64(1), calisan = o.GetInt64(2), kirli = o.GetInt64(3), paketlemeBekleyen = o.GetInt64(4),
                sterilDepo = o.GetInt64(5), sktYakin = o.GetInt64(6), karantina = o.GetInt64(7), bugunKullanilan = o.GetInt64(8), bugunHasta = o.GetInt64(9), bloke = o.GetInt64(10),
            }, iptal);
            var uyarilar = await UyarilarAsync(b, k, iptal);
            var programlar = await JsonListeAsync(b, "select row_to_json(p)::text from public.v_steril_program p where p.aktif = 1 order by p.test, p.id", [], iptal);
            return Json(new { kpi, cihazlar, dongular, birimler, depo, kullanilan, setler, uyarilar, programlar, kurallar = k });
        });

        grup.MapGet("/kurallar", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.pano", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            return Results.Ok(await KurallarAsync(b, iptal));
        });

        grup.MapPost("/kurallar", async (Kurallar g, VeriKaynagi veri, LogDeposu log, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.ayar", Islem.Degistir);
            if (g.BdKurali is not ("uyari" or "onay" or "engel")) throw GentegreHatasi.IsKurali("Bowie-Dick kuralı uyari / onay / engel olmalı.");
            if (g.KarantinaKullanim is not ("uyari" or "engel")) throw GentegreHatasi.IsKurali("Karantina kullanımı uyari / engel olmalı.");
            await using var b = await veri.AcAsync(iptal);
            var metin = JsonSerializer.Serialize(g, JsonAyar);
            var n = await b.CalistirAsync("update public.referans set deger = @p0, degistiren = @p1, degistirme_tarihi = now() where anahtar = 'steril.kurallar'", null, [metin, baglam.KullaniciId], iptal);
            if (n == 0) await b.CalistirAsync("insert into public.referans (anahtar, deger, tip, kapsam, aciklama, ekleyen) values ('steril.kurallar', @p0, 'json', 'kurum', 'Sterilizasyon kuralları', @p1)", null, [metin, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogCihaz, 0, baglam.KullaniciId, baglam.SubeId, baglam.Ip, new { kurallar = true, g.BdKurali, g.KarantinaKullanim }, iptal: iptal);
            return Results.Ok(g);
        });

        // Ayar sayfası: cihazlar, programlar, günlük/haftalık test uyumu, bakım takvimi.
        grup.MapGet("/ayar", async (VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("steril.ayar", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var k = await KurallarAsync(b, iptal);
            var cihazlar = await JsonListeAsync(b, "select row_to_json(c)::text from public.v_steril_cihaz c order by c.tur, c.id", [], iptal);
            var programlar = await JsonListeAsync(b, "select row_to_json(p)::text from public.v_steril_program p order by p.test, p.id", [], iptal);
            var bakimlar = await JsonListeAsync(b, "select row_to_json(m)::text from public.v_steril_bakim m order by m.tarih desc, m.id desc limit 50", [], iptal);
            var testler = await JsonListeAsync(b, """
                select json_build_object('cihazId', c.id, 'cihazAdi', c.ad,
                        'bdBugun', c.bd_bugun,
                        'helixBugun', (select count(*) from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id where d.cihaz_id = c.id and i.tur = 2 and i.sonuc = 1 and d.baslama::date = current_date),
                        'vakumBugun', (select count(*) from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id where d.cihaz_id = c.id and i.tur = 7 and i.sonuc = 1 and d.baslama::date = current_date),
                        'sonBio', (select max(d.baslama) from public.steril_dongu d join public.steril_dongu_indikator i on i.dongu_id = d.id where d.cihaz_id = c.id and i.tur = 6 and i.sonuc in (1, 2)),
                        'sonBioSonuc', (select i.sonuc from public.steril_dongu d join public.steril_dongu_indikator i on i.dongu_id = d.id where d.cihaz_id = c.id and i.tur = 6 and i.sonuc in (1, 2) order by d.baslama desc limit 1),
                        'bioBekleyen', (select count(*) from public.steril_dongu d join public.steril_dongu_indikator i on i.dongu_id = d.id where d.cihaz_id = c.id and i.tur = 6 and i.sonuc = 3),
                        'sonrakiBakim', c.sonraki_bakim, 'sonrakiValidasyon', c.sonraki_validasyon,
                        'son7gunBd', (select count(distinct d.baslama::date) from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id where d.cihaz_id = c.id and i.tur = 1 and i.sonuc = 1 and d.baslama >= current_date - 6),
                        'son7gunDonguGun', (select count(distinct d.baslama::date) from public.steril_dongu d where d.cihaz_id = c.id and d.durum <> 8 and d.baslama >= current_date - 6))::text
                  from public.v_steril_cihaz c where c.tur = 1 and c.durum > 0 order by c.id
                """, [], iptal);
            var takvim = await JsonListeAsync(b, """
                select json_build_object('gun', g::date, 'bd', (select count(*) from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id where i.tur = 1 and i.sonuc = 1 and d.baslama::date = g::date),
                        'bdKaldi', (select count(*) from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id where i.tur = 1 and i.sonuc = 2 and d.baslama::date = g::date),
                        'helix', (select count(*) from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id where i.tur = 2 and i.sonuc = 1 and d.baslama::date = g::date),
                        'bio', (select count(*) from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id where i.tur = 6 and i.sonuc in (1, 2) and d.baslama::date = g::date),
                        'bioBekleyen', (select count(*) from public.steril_dongu_indikator i join public.steril_dongu d on d.id = i.dongu_id where i.tur = 6 and i.sonuc = 3 and d.baslama::date = g::date),
                        'dongu', (select count(*) from public.steril_dongu d where d.durum <> 8 and d.baslama::date = g::date))::text
                  from generate_series(current_date - 13, current_date + 1, interval '1 day') g
                """, [], iptal);
            return Json(new { kurallar = k, cihazlar, programlar, bakimlar, testler, takvim });
        });
    }
}
