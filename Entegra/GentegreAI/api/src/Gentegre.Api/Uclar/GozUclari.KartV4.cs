using System.Text;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;
using Gentegre.Veri.Depolar;
using Npgsql;

namespace Gentegre.Api.Uclar;

/// <summary>
/// GÖZ MUAYENE KARTI v4 (mockup Ekranlar/Goz/goz_muayene_karti_v4.html).
///
/// <para><b>Kontrol</b> tek tanımdır: sol gezintideki bölüm durumları, Özet'in tamamlama
/// kontrolü, alttaki kural çubuğu ve Tamamla'nın kendisi aynı listeyi okur - ekranda "tamam"
/// görünen bir koşulun sunucuda eksik sayılması olmasın.</para>
///
/// <para><b>Özet metni</b> bölümlerden derlenir, yazılmaz. <b>Göz öyküsü</b> hastanındır
/// (goz_hasta_oyku, 971); sistemik hastalık / göze etkili ilaç kronik tanı ve reçete
/// geçmişinden türetilir.</para>
/// </summary>
public static partial class GozUclari
{
    private const int LogTabloGozOyku = 957;

    public sealed record KontrolSatiri(string Kod, string Ad, string Durum, bool Zorunlu, string Mesaj, string Bolum);

    /// <summary>Bölüm durumu: ok · bos · uy (uyarı). Anahtar sol gezintideki sekme başlığıdır.</summary>
    internal static async Task<(Dictionary<string, (string Durum, string Ipucu)> Bolumler, List<KontrolSatiri> Kontrol)>
        GozKontrolAsync(NpgsqlConnection b, NpgsqlTransaction? islem, int id, CancellationToken iptal)
    {
        var o = await b.TekAsync("""
            select coalesce(m.sikayet, '') <> '' as sikayet,
                   (select count(distinct x.goz) from public.goz_gorme x where x.goz_muayene_id = gm.id and x.goz in (1, 2)
                      and (x.deger_ondalik is not null or coalesce(x.deger_metin, '') <> ''))::int as va_goz,
                   (select count(*) from public.goz_gorme x where x.goz_muayene_id = gm.id)::int
                 + (select count(*) from public.goz_refraksiyon x where x.goz_muayene_id = gm.id)::int as gorme,
                   (select count(distinct x.goz) from public.goz_tonometri x where x.goz_muayene_id = gm.id and x.goz in (1, 2)
                      and x.gib is not null)::int as gib_goz,
                   (select count(*) from public.goz_tonometri x where x.goz_muayene_id = gm.id)::int as tono,
                   coalesce(v.gib_yuksek, 0) as gib_yuksek, coalesce(v.gorme_dusus, 0) as gorme_dusus,
                   (select count(*) from public.goz_on_segment x where x.goz_muayene_id = gm.id)::int as onseg,
                   (select count(*) from public.goz_fundus x where x.goz_muayene_id = gm.id)::int as fundus,
                   (select count(*) from public.goz_motilite x where x.goz_muayene_id = gm.id)::int as motilite,
                   (select count(*) from public.goz_ek_test x where x.goz_muayene_id = gm.id)::int as ektest,
                   (select count(*) from public.tani t where t.muayene_id = m.id)::int as tani,
                   (select count(*) from public.tani t where t.muayene_id = m.id and coalesce(t.taraf, 0) = 0)::int as tani_tarafsiz,
                   (coalesce(gm.degerlendirme, '') <> '' or coalesce(gm.plan, '') <> '') as plan,
                   (select count(*) from public.recete r where r.muayene_id = m.id
                      and exists (select 1 from public.recete_satir s where s.recete_id = r.id))::int as recete,
                   (select count(*) from public.recete r where r.muayene_id = m.id and r.imza_zamani is null
                      and exists (select 1 from public.recete_satir s where s.recete_id = r.id))::int as recete_imzasiz,
                   (select count(*) from public.muayene_istem i where i.muayene_id = m.id)::int as istem,
                   (gm.kontrol_gun > 0) as kontrol_var, (m.kontrol_randevu_id is not null) as randevu_var,
                   (select count(*) - 1 from public.goz_muayene g2 where g2.hasta_id = gm.hasta_id)::int as onceki,
                   (select count(*) from public.goz_goruntuleme g where g.hasta_id = gm.hasta_id)::int
                 + (select count(*) from public.goz_cizim z where z.goz_muayene_id = gm.id)::int as goruntu
              from public.goz_muayene gm
              join public.muayene m on m.id = gm.muayene_id
              left join public.v_goz_muayene_ozet v on v.goz_muayene_id = gm.id
             where gm.id = @p0
            """, islem, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Göz muayenesi bulunamadı.");

        int S(string k) => Convert.ToInt32(o[k]);
        bool B(string k) => o[k] is bool x && x;
        string D(int n) => n > 0 ? "ok" : "bos";

        var bol = new Dictionary<string, (string, string)>
        {
            ["Şikâyet & Öykü"] = (B("sikayet") ? "ok" : "bos", ""),
            ["Görme & Refraksiyon"] = (S("gorme") == 0 ? "bos" : S("gorme_dusus") > 0 ? "uy" : "ok", S("gorme_dusus") > 0 ? "düşüş ↓" : S("va_goz") == 2 ? "OD·OS" : ""),
            ["Tonometri & Pakimetri"] = (S("tono") == 0 ? "bos" : S("gib_yuksek") > 0 ? "uy" : "ok", S("gib_yuksek") > 0 ? "hedef ↑" : ""),
            ["Ön Segment"] = (D(S("onseg")), ""),
            ["Fundus"] = (D(S("fundus")), ""),
            ["Motilite · Pupil · Alan"] = (D(S("motilite")), ""),
            ["Gonyoskopi & Ek Testler"] = (D(S("ektest")), ""),
            ["Tanılar"] = (S("tani") == 0 ? "bos" : S("tani_tarafsiz") > 0 ? "uy" : "ok", S("tani") > 0 ? S("tani").ToString() : ""),
            ["Tanı & Plan"] = (B("plan") ? "ok" : "bos", ""),
            ["e-Reçete"] = (S("recete") == 0 ? "bos" : S("recete_imzasiz") > 0 ? "uy" : "ok", S("recete_imzasiz") > 0 ? "taslak" : ""),
            ["İstem & Sonuç"] = (D(S("istem")), S("istem") > 0 ? S("istem").ToString() : ""),
            ["Karşılaştırma"] = ("", S("onceki") > 0 ? S("onceki").ToString() : ""),
            ["Görüntüler"] = ("", S("goruntu") > 0 ? S("goruntu").ToString() : ""),
        };

        var k = new List<KontrolSatiri>
        {
            new("sikayet", "Şikâyet", B("sikayet") ? "ok" : "yok", true, "", "Şikâyet & Öykü"),
            new("gorme", "Görme · iki göz", S("va_goz") >= 2 ? "ok" : "yok", true, S("va_goz") == 1 ? "tek göz girildi" : "", "Görme & Refraksiyon"),
            new("gib", "GİB · iki göz", S("gib_goz") >= 2 ? "ok" : "yok", true, S("gib_goz") == 1 ? "tek göz girildi" : "", "Tonometri & Pakimetri"),
            new("tani", "Tanı · göz tarafı", S("tani") == 0 ? "yok" : S("tani_tarafsiz") > 0 ? "yok" : "ok", true,
                S("tani_tarafsiz") > 0 ? $"{S("tani_tarafsiz")} tanıda taraf yok" : "", "Tanılar"),
            new("plan", "Değerlendirme & plan", B("plan") ? "ok" : "yok", true, "", "Tanı & Plan"),
        };
        if (S("recete_imzasiz") > 0)
            k.Add(new("recete", "e-Reçete imzalanmadı", "uyari", false, "tamamlamayı engellemez", "e-Reçete"));
        if (B("kontrol_var") && !B("randevu_var"))
            k.Add(new("randevu", "Kontrol randevusu verilmedi", "uyari", false, "Tamamla'da önerilir", ""));
        return (bol, k);
    }

    private static void KartV4UclariniEkle(RouteGroupBuilder grup)
    {
        grup.MapGet("/muayene/{id:int}/kontrol", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var (bol, kontrol) = await GozKontrolAsync(b, null, id, iptal);
            return Results.Ok(new
            {
                bolumler = bol.Select(x => new { baslik = x.Key, durum = x.Value.Durum, ipucu = x.Value.Ipucu }),
                kontrol = kontrol.Select(x => new { kod = x.Kod, ad = x.Ad, durum = x.Durum, zorunlu = x.Zorunlu, mesaj = x.Mesaj, bolum = x.Bolum }),
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // ÖZET METNİ: bölümlerden derlenir (başlık + metin), yazılmaz.
        grup.MapGet("/muayene/{id:int}/ozet-metin", async (int id, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await b.TekAsync("""
                select coalesce(m.sikayet, '') as sikayet, coalesce(m.hikaye, '') as hikaye, gm.hasta_id as "hastaId",
                       coalesce(gm.degerlendirme, '') as degerlendirme, coalesce(gm.plan, '') as plan, m.id as "muayeneId",
                       v.bcva_od as "bcvaOd", v.bcva_os as "bcvaOs", v.onceki_bcva_od as "oncekiOd", v.onceki_bcva_os as "oncekiOs",
                       v.gib_od as "gibOd", v.gib_os as "gibOs", v.tani
                  from public.goz_muayene gm join public.muayene m on m.id = gm.muayene_id
                  left join public.v_goz_muayene_ozet v on v.goz_muayene_id = gm.id
                 where gm.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal) ?? throw GentegreHatasi.Bulunamadi("Göz muayenesi bulunamadı.");
            var muayeneId = Convert.ToInt32(o["muayeneId"]);
            static string Y(object? v) => v is null ? "—" : Convert.ToDecimal(v).ToString("0.##", new System.Globalization.CultureInfo("tr-TR"));
            var bolumler = new List<object>();
            void Ekle(string baslik, string metin) { if (!string.IsNullOrWhiteSpace(metin)) bolumler.Add(new { baslik, metin = metin.Trim() }); }

            Ekle("Şikâyet", string.Join(" · ", new[] { (string)o["sikayet"]!, (string)o["hikaye"]! }.Where(x => x != "")));

            var oyku = await b.TekDegerAsync<string?>("select veri::text from public.goz_hasta_oyku where hasta_id = @p0", null,
                [Convert.ToInt32(o["hastaId"])], iptal);
            Ekle("Göz öyküsü", OykuMetni(oyku));

            var sb = new StringBuilder();
            if (o["bcvaOd"] is not null || o["bcvaOs"] is not null)
                sb.Append($"Görme (düz.) OD {Y(o["bcvaOd"])} · OS {Y(o["bcvaOs"])}"
                    + (o["oncekiOd"] is not null || o["oncekiOs"] is not null ? $" (önceki {Y(o["oncekiOd"])} / {Y(o["oncekiOs"])})" : "") + ". ");
            var refr = await b.ListeAsync("""
                select r.goz, concat_ws(' ', to_char(r.sph, 'SG990D00'), case when r.cyl is not null then to_char(r.cyl, 'SG990D00') || '×' || coalesce(r.aks::text, '') end,
                       case when r.add_yakin is not null then 'add ' || to_char(r.add_yakin, 'SG990D00') end)
                  from public.goz_refraksiyon r where r.goz_muayene_id = @p0 and r.tur = 2 and r.goz in (1, 2) order by r.goz
                """, null, [id], x => (Goz: (int)x.GetInt16(0), Metin: x.GetString(1)), iptal);
            if (refr.Count > 0) sb.Append("Refraksiyon " + string.Join(" · ", refr.Select(r => (r.Goz == 1 ? "OD " : "OS ") + r.Metin.Replace('.', ','))) + ". ");
            if (o["gibOd"] is not null || o["gibOs"] is not null)
            {
                var cct = await b.TekDegerAsync<string?>("""
                    select string_agg(t.cct_um::text, ' / ' order by t.goz) from (select distinct on (goz) goz, cct_um from public.goz_tonometri
                     where goz_muayene_id = @p0 and cct_um is not null and goz in (1, 2) order by goz, zaman desc) t
                    """, null, [id], iptal);
                sb.Append($"GİB OD {Y(o["gibOd"])} · OS {Y(o["gibOs"])} mmHg" + (cct is null ? "" : $" (CCT {cct})") + ". ");
            }
            var onseg = await b.TekDegerAsync<string?>("""
                select string_agg((case s.goz when 1 then 'OD ' when 2 then 'OS ' else '' end) || s.alan || ' ' || s.deger_metin, ', ' order by s.goz, s.alan)
                  from public.goz_on_segment s
                 where s.goz_muayene_id = @p0 and coalesce(s.normal, 0) = 0 and coalesce(s.deger_metin, '') <> ''
                   and lower(s.deger_metin) not in ('normal', 'saydam', 'doğal', 'olağan')
                """, null, [id], iptal);
            if (!string.IsNullOrEmpty(onseg)) sb.Append($"Ön segment: {onseg}. ");
            var fundus = await b.TekDegerAsync<string?>("""
                select string_agg((case f.goz when 1 then 'OD ' else 'OS ' end)
                       || concat_ws(', ', case when f.cd_dikey is not null then 'C/D ' || f.cd_dikey end,
                                    nullif(f.disk_metin, ''), nullif(f.makula_metin, '')), ' · ' order by f.goz)
                  from public.goz_fundus f where f.goz_muayene_id = @p0 and f.goz in (1, 2)
                """, null, [id], iptal);
            if (!string.IsNullOrEmpty(fundus)) sb.Append($"Fundus: {fundus}.");
            Ekle("Bulgular", sb.ToString());

            var tanilar = await b.TekDegerAsync<string?>("""
                select string_agg(t.icd_kod || coalesce(' ' || i.ad, '')
                       || case t.taraf when 1 then ' (sağ)' when 2 then ' (sol)' when 3 then ' (bilateral)' else '' end, ' · ' order by t.tur, t.sira, t.id)
                  from public.tani t left join public.icd i on i.kod = t.icd_kod where t.muayene_id = @p0
                """, null, [muayeneId], iptal);
            Ekle("Tanı", tanilar ?? "");
            Ekle("Değerlendirme & plan", string.Join(" · ", new[] { (string)o["degerlendirme"]!, (string)o["plan"]! }.Where(x => x != "")));
            var gor = await b.TekDegerAsync<string?>("""
                select string_agg(case g.tetkik when 1 then 'OCT maküla' when 2 then 'OCT RNFL' when 3 then 'OCT ön segment' when 4 then 'OCT-A'
                       when 7 then 'Fundus foto' when 8 then 'Görme alanı' when 11 then 'Biyometri' else 'Görüntüleme' end
                       || ' ' || case g.goz when 1 then 'OD' when 2 then 'OS' else 'OU' end
                       || case g.durum when 1 then ' istendi' when 2 then ' çekildi' when 3 then ' değerlendirildi' else '' end, ' · ')
                  from public.goz_goruntuleme g where g.muayene_id = @p0
                """, null, [muayeneId], iptal);
            Ekle("Görüntüleme", gor ?? "");
            var rec = await b.TekDegerAsync<string?>("""
                select string_agg(s.ilac_ad || coalesce(' ' || nullif(s.periyot, ''), '') || case when r.imza_zamani is null then ' (taslak)' else '' end, ' · ')
                  from public.recete r join public.recete_satir s on s.recete_id = r.id where r.muayene_id = @p0
                """, null, [muayeneId], iptal);
            Ekle("Reçete", rec ?? "");
            return Results.Ok(new { bolumler, izlemeNo = baglam.IzlemeNo });
        });

        // GÖZ ÖYKÜSÜ (hastanın): oku / yaz + sistemik hastalık ve göze etkili ilaçlar (türetilmiş).
        grup.MapGet("/hasta/{hastaId:int}/oyku", async (int hastaId, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);
            var o = await b.TekAsync("""
                select veri::text as veri, degistirme_tarihi as zaman,
                       coalesce((select k.ad from public.v_kullanici_lookup k where k.id = coalesce(degistiren, ekleyen)), '') as kim
                  from public.goz_hasta_oyku where hasta_id = @p0
                """, null, [hastaId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var kronik = await b.ListeAsync("""
                select k.icd_kod as kod, coalesce(nullif(k.tani_ad, ''), i.ad, '') as ad, k.baslangic
                  from public.hasta_kronik_tani k left join public.icd i on i.kod = k.icd_kod
                 where k.hasta_id = @p0 and coalesce(k.durum, 1) = 1 order by k.baslangic nulls last
                """, null, [hastaId], OkuyucuGenisletmeleri.Sozluk, iptal);
            var ilaclar = await b.ListeAsync("""
                select s.ilac_ad as ad, max(r.ekleme_tarihi) as son
                  from public.recete r join public.recete_satir s on s.recete_id = r.id
                 where r.hasta_id = @p0 and r.ekleme_tarihi >= now() - interval '12 months'
                 group by s.ilac_ad order by max(r.ekleme_tarihi) desc limit 30
                """, null, [hastaId], OkuyucuGenisletmeleri.Sozluk, iptal);
            // GÖZE ETKİLİ İLAÇLAR (risk): katarakt cerrahisi / retina / basınç açısından bilinen.
            var riskler = ilaclar.Select(i => (Ad: (string)i["ad"]!, Risk: IlacGozRiski((string)i["ad"]!)))
                .Where(x => x.Risk != null).Select(x => new { ilac = x.Ad, risk = x.Risk }).ToList();
            return Results.Ok(new
            {
                veri = o?["veri"] is string v ? JsonDocument.Parse(v).RootElement : JsonDocument.Parse("{}").RootElement,
                zaman = o?["zaman"], kim = o?["kim"] ?? "",
                kronik, ilaclar = ilaclar.Select(i => i["ad"]), riskler, izlemeNo = baglam.IzlemeNo,
            });
        });
        grup.MapPost("/hasta/{hastaId:int}/oyku", async (int hastaId, JsonElement veri, BaglamCozucu cozucu, VeriKaynagi veri2,
            LogDeposu log, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("goz.muayene", Islem.Degistir);
            baglam.YazmaIste();
            if (veri.ValueKind != JsonValueKind.Object) throw GentegreHatasi.Dogrulama("Öykü nesne olmalı.");
            var metin = veri.GetRawText();
            if (metin.Length > 20000) throw GentegreHatasi.Dogrulama("Öykü çok uzun.");
            await using var b = await veri2.AcAsync(iptal);
            await b.CalistirAsync("""
                insert into public.goz_hasta_oyku (hasta_id, veri, ekleyen) values (@p0, @p1::jsonb, @p2)
                on conflict (hasta_id) do update set veri = excluded.veri, degistiren = @p2, degistirme_tarihi = now()
                """, null, [hastaId, metin, baglam.KullaniciId], iptal);
            await log.YazAsync(LogIslemi.Degistir, LogTabloGozOyku, hastaId, baglam.KullaniciId, baglam.SubeId, baglam.Ip,
                veri, tarafId: hastaId, iptal: iptal);
            return Results.Ok(new { hastaId, izlemeNo = baglam.IzlemeNo });
        });
    }

    private static readonly (string Anahtar, string Risk)[] IlacRiskleri =
    [
        ("tamsulosin", "IFIS riski (katarakt cerrahisi)"), ("alfuzosin", "IFIS riski"), ("silodosin", "IFIS riski"),
        ("hidroksiklorokin", "retinal toksisite - yıllık tarama"), ("klorokin", "retinal toksisite"),
        ("amiodaron", "kornea depozitleri / optik nöropati"), ("etambutol", "optik nöropati"),
        ("prednizolon", "steroid - katarakt / GİB artışı"), ("metilprednizolon", "steroid - katarakt / GİB artışı"),
        ("deksametazon", "steroid - GİB artışı"), ("varfarin", "antikoagülan - cerrahi / enjeksiyon"),
        ("apiksaban", "antikoagülan"), ("rivaroksaban", "antikoagülan"), ("dabigatran", "antikoagülan"),
        ("topiramat", "açı kapanması riski"), ("isotretinoin", "kuru göz"),
    ];

    private static string? IlacGozRiski(string ad)
    {
        var a = ad.ToLower(new System.Globalization.CultureInfo("tr-TR"));
        foreach (var (k, r) in IlacRiskleri) if (a.Contains(k)) return r;
        return null;
    }

    /// <summary>Öykü jsonb'sinden özet cümlesi (Özet sekmesi).</summary>
    private static string OykuMetni(string? json)
    {
        if (string.IsNullOrEmpty(json)) return "";
        using var d = JsonDocument.Parse(json);
        var r = d.RootElement;
        var p = new List<string>();
        string Liste(string ad) => r.TryGetProperty(ad, out var e) && e.ValueKind == JsonValueKind.Array
            ? string.Join(", ", e.EnumerateArray().Select(x => x.GetString()).Where(x => !string.IsNullOrEmpty(x))) : "";
        string Tek(string ad) => r.TryGetProperty(ad, out var e) && e.ValueKind == JsonValueKind.String ? e.GetString() ?? "" : "";
        var ameliyat = Liste("ameliyat"); p.Add(ameliyat == "" || ameliyat == "yok" ? "Göz ameliyatı yok" : $"Ameliyat: {ameliyat}");
        var lazer = Liste("lazer"); if (lazer != "" && lazer != "yok") p.Add($"Lazer: {lazer}");
        if (Tek("travma") == "var") p.Add("Travma öyküsü var");
        var duz = Tek("duzeltme"); if (duz != "") p.Add($"Düzeltme: {duz}");
        if (Tek("ambliyopi") == "var") p.Add("Ambliyopi / şaşılık");
        if (r.TryGetProperty("damlalar", out var dm) && dm.ValueKind == JsonValueKind.Array)
        {
            var ds = dm.EnumerateArray().Select(x =>
                $"{(x.TryGetProperty("ad", out var a) ? a.GetString() : "")} {(x.TryGetProperty("goz", out var g) ? g.GetString() : "")}"
                + (x.TryGetProperty("uyum", out var u) && u.GetString() is { Length: > 0 } us ? $" (uyum: {us})" : "")).ToList();
            if (ds.Count > 0) p.Add("Damlalar: " + string.Join(", ", ds.Select(x => x.Trim())));
        }
        var aile = string.Join(", ", new[] { ("glokom", "glokom"), ("amd", "AMD"), ("keratokonus", "keratokonus"), ("retina", "kalıtsal retina") }
            .Select(x => (Ad: x.Item2, Kim: Liste("aile_" + x.Item1))).Where(x => x.Kim != "" && x.Kim != "yok").Select(x => $"{x.Ad} ({x.Kim})"));
        if (aile != "") p.Add($"Aile: {aile}");
        return string.Join(". ", p) + (p.Count > 0 ? "." : "");
    }
}
