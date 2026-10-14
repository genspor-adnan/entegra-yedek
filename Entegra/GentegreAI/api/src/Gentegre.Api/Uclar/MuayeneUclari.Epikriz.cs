using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENE EPİKRİZİ (1100, mockup muayene_karti_v7) — bkz. <c>MuayeneUclari</c>.
///
/// <para><b>Ayrı kayıt:</b> epikriz muayenenin alanlarından TASLAK olarak
/// derlenir ama kaydedilen metin hekimin metnidir; imzadan sonra muayene
/// değişse de epikriz değişmez (hastaya / sevk kurumuna giden budur).</para>
///
/// <para><b>Taslak ücretsiz ve kuralla:</b> model çağrılmaz. Taslak kayda
/// yazılmaz; ekran "Karttan derle" ile alanlara koyar, hekim düzeltip kaydeder.</para>
///
/// <para><b>İmza kilitler:</b> imzalı epikriz yeniden yazılamaz (yatış
/// epikriziyle aynı kural - iki farklı metin, hangisinin verildiğini belirsizleştirir).</para>
/// </summary>
public static partial class MuayeneUclari
{
    private static void EpikrizUclariniEkle(RouteGroupBuilder grup)
    {
        // GET /api/muayene/{id}/epikriz - kayıt (yoksa null) + karttan derlenmiş taslak
        grup.MapGet("/{id:int}/epikriz", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Gor);
            await using var b = await veri.AcAsync(iptal);

            var kayit = (await b.ListeAsync("""
                select e.id, e.sikayet, e.hikaye, e.bulgular, e.tani, e.tetkik_ozet as "tetkikOzet",
                       e.tedavi, e.oneriler, e.imza_durum as "imzaDurum", e.imza_zamani as "imzaZamani",
                       coalesce(e.degistirme_tarihi, e.ekleme_tarihi) as "kayitZamani"
                  from public.epikriz e where e.muayene_id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)).FirstOrDefault();

            var taslak = (await b.ListeAsync("""
                select coalesce(m.sikayet, '') as sikayet, coalesce(m.hikaye, '') as hikaye,
                       coalesce(m.bulgu_ozet, '') as bulgular,
                       coalesce((select string_agg(t.icd_kod || ' ' || coalesce(i.ad, '')
                                       || case when t.tur = 1 then ' (ana)' else '' end, ' · '
                                       order by t.tur, t.sira, t.id)
                                   from public.tani t left join public.icd i on i.kod = t.icd_kod
                                  where t.muayene_id = m.id), '') as tani,
                       -- TETKİK: yalnız ONAYLI sonuç (muayene sonuçlarındaki kural).
                       coalesce((select string_agg(lt.ad || ' ' || ls.deger_metin
                                       || coalesce(' ' || nullif(ls.birim, ''), '')
                                       || case when coalesce(ls.bayrak, '') <> '' then ' (' || ls.bayrak || ')' else '' end,
                                       ' · ' order by lt.ad)
                                   from public.lab_istem li
                                   join public.lab_istem_satir s on s.istem_id = li.id
                                   join public.lab_tetkik lt on lt.id = s.tetkik_id
                                   join public.lab_sonuc ls on ls.istem_satir_id = s.id and ls.durum = 3
                                  where li.durum <> 9
                                    and (li.belge_id = m.belge_id
                                         or exists (select 1 from public.muayene_istem mi
                                                     where mi.muayene_id = m.id and mi.hedef_tablo = 'lab_istem'
                                                       and mi.hedef_id = li.id))), '') as "tetkikOzet",
                       coalesce((select string_agg(rs.ilac_ad || coalesce(' ' || nullif(rs.doz, ''), '')
                                       || coalesce(' ' || nullif(rs.periyot, ''), ''), ' · ' order by rs.recete_id, rs.sira, rs.id)
                                   from public.recete_satir rs join public.recete r on r.id = rs.recete_id
                                  where r.muayene_id = m.id), '') as tedavi,
                       coalesce(m.karar, '')
                         || case when coalesce(m.kontrol_onerisi_gun, 0) > 0
                                 then E'\n' || 'Kontrol: ' || m.kontrol_onerisi_gun || ' gün sonra.' else '' end as oneriler
                  from public.muayene m where m.id = @p0
                """, null, [id], OkuyucuGenisletmeleri.Sozluk, iptal)).FirstOrDefault()
                ?? throw GentegreHatasi.Bulunamadi();

            return Results.Ok(new { kayit, taslak });
        });

        // POST /api/muayene/{id}/epikriz - kaydet (muayene başına tek satır; imzalıysa reddedilir)
        grup.MapPost("/{id:int}/epikriz", async (
            int id, MuayeneEpikrizIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);

            var imzali = await b.TekDegerAsync<int?>(
                "select imza_durum from public.epikriz where muayene_id = @p0", null, [id], iptal);
            if (imzali == 1)
                throw GentegreHatasi.IsKurali("Epikriz imzalı; imzalı metin değiştirilemez.");

            var kayitId = await b.TekDegerAsync<int>("""
                insert into public.epikriz
                    (sube_id, muayene_id, sikayet, hikaye, bulgular, tani, tetkik_ozet, tedavi, oneriler, ekleyen)
                values (@p1, @p0, coalesce(@p2, ''), coalesce(@p3, ''), coalesce(@p4, ''), coalesce(@p5, ''),
                        coalesce(@p6, ''), coalesce(@p7, ''), coalesce(@p8, ''), @p9)
                on conflict (muayene_id) where muayene_id is not null do update
                   set sikayet = excluded.sikayet, hikaye = excluded.hikaye, bulgular = excluded.bulgular,
                       tani = excluded.tani, tetkik_ozet = excluded.tetkik_ozet, tedavi = excluded.tedavi,
                       oneriler = excluded.oneriler, degistiren = @p9, degistirme_tarihi = now()
                returning id
                """, null,
                [id, baglam.SubeId ?? 0, istek.Sikayet, istek.Hikaye, istek.Bulgular, istek.Tani,
                 istek.TetkikOzet, istek.Tedavi, istek.Oneriler, baglam.KullaniciId], iptal);

            return Results.Ok(new { id = kayitId, izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/epikriz/yz-duzenle - ekrandaki metni modele akıcı hâle getirtir.
        //   KONTÖRLÜ (1101 oz_epikriz). Sonuç KAYDEDİLMEZ: hekime öneri olarak döner, hekim
        //   kontrol edip kaydeder. Hasta adı ve kimlik / numara gönderilmeden MASKELENİR.
        grup.MapPost("/{id:int}/epikriz/yz-duzenle", async (
            int id, MuayeneEpikrizIstegi istek, BaglamCozucu cozucu, VeriKaynagi veri,
            Servisler.IModelSaglayici model, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            if (!model.Hazir)
                throw GentegreHatasi.IsKurali("YZ modeli bu kurulumda yapılandırılmamış (API anahtarı yok); yöneticiye bildirin.");
            await using var b = await veri.AcAsync(iptal);

            if (await b.TekDegerAsync<int?>("select imza_durum from public.epikriz where muayene_id = @p0", null, [id], iptal) == 1)
                throw GentegreHatasi.IsKurali("Epikriz imzalı; imzalı metin değiştirilemez.");

            var kontor = await Servisler.RehberServisi.KontorDurumAsync(b, iptal, "epikriz", baglam.KullaniciId);
            if (!kontor.Izin)
                throw GentegreHatasi.IsKurali(kontor.Sebep.Length > 0
                    ? kontor.Sebep.Replace("cevaplar şimdilik katalog ve yardım belgelerinden üretiliyor", "YZ ile düzenleme kullanılamıyor")
                                  .Replace("cevaplar katalogdan üretiliyor", "YZ ile düzenleme kullanılamıyor")
                    : "YZ kullanımı bu kurulumda kapalı.");

            // MASKE: hastanın ad / soyadı ve uzun sayılar (TCKN, protokol...) modele gitmez.
            var adlar = (await b.ListeAsync(
                "select coalesce(t.ad, '') as ad, coalesce(t.soyad, '') as soyad from public.muayene m " +
                "join public.taraf t on t.id = m.taraf_id where m.id = @p0", null, [id], OkuyucuGenisletmeleri.Sozluk, iptal))
                .SelectMany(r => new[] { Convert.ToString(r["ad"]) ?? "", Convert.ToString(r["soyad"]) ?? "" })
                .SelectMany(a => a.Split(' ', StringSplitOptions.RemoveEmptyEntries)).Where(a => a.Length >= 2).ToArray();
            string Maskele(string? metin)
            {
                var x = Servisler.Yardim.PiiMaske.Uygula(metin);
                foreach (var a in adlar)
                    x = System.Text.RegularExpressions.Regex.Replace(x, $@"(?<!\w){System.Text.RegularExpressions.Regex.Escape(a)}(?!\w)",
                        "[HASTA]", System.Text.RegularExpressions.RegexOptions.IgnoreCase | System.Text.RegularExpressions.RegexOptions.CultureInvariant);
                return x;
            }
            var giden = new Dictionary<string, string>
            {
                ["sikayet"] = Maskele(istek.Sikayet), ["hikaye"] = Maskele(istek.Hikaye), ["bulgular"] = Maskele(istek.Bulgular),
                ["tani"] = Maskele(istek.Tani), ["tetkikOzet"] = Maskele(istek.TetkikOzet), ["tedavi"] = Maskele(istek.Tedavi),
                ["oneriler"] = Maskele(istek.Oneriler),
            };
            if (giden.Values.All(string.IsNullOrWhiteSpace))
                throw GentegreHatasi.Dogrulama("Düzenlenecek metin yok.", []);

            var kronometre = System.Diagnostics.Stopwatch.StartNew();
            var yanit = await model.IsteAsync(new Servisler.ModelIstegi(EpikrizYzYonergesi,
                JsonSerializer.Serialize(giden)), iptal);
            var sure = (int)kronometre.ElapsedMilliseconds;
            Dictionary<string, string>? duzen = null;
            if (yanit is not null)
            {
                var ham = yanit.Metin.Trim();
                var bas = ham.IndexOf('{'); var son = ham.LastIndexOf('}');
                try { if (bas >= 0 && son > bas) duzen = JsonSerializer.Deserialize<Dictionary<string, string>>(ham[bas..(son + 1)]); }
                catch (JsonException) { duzen = null; }
            }
            if (yanit is null || duzen is null)
            {
                // BAŞARISIZ ÇAĞRI ücretlendirilmez; izi kalır (934 deseni).
                await Servisler.RehberServisi.BasarisizYazAsync(b, baglam, "epikriz", id, sure,
                    yanit is null ? "Modele ulaşılamadı / zaman aşımı - ücretlendirilmedi"
                                  : "Model yanıtı okunamadı - ücretlendirilmedi", iptal);
                throw GentegreHatasi.IsKurali("YZ düzenlemesi alınamadı; biraz sonra tekrar deneyin (kontör düşülmedi).");
            }

            await Servisler.RehberServisi.KontorDusAsync(b, baglam, kontor.Ucret, yanit.GirisJeton + yanit.CikisJeton, null,
                yanit.Model, iptal, "YZ önerisi - epikriz düzenleme", "epikriz", id, sure);

            // Boş bölüm boş kalır; modelin uydurduğu anahtar alınmaz.
            string Al(string k) => string.IsNullOrWhiteSpace(giden[k]) ? "" : (duzen.GetValueOrDefault(k) ?? giden[k]).Trim();
            return Results.Ok(new
            {
                sikayet = Al("sikayet"), hikaye = Al("hikaye"), bulgular = Al("bulgular"), tani = Al("tani"),
                tetkikOzet = Al("tetkikOzet"), tedavi = Al("tedavi"), oneriler = Al("oneriler"),
                ucret = kontor.Ucret, model = yanit.Model,
                uyari = "YZ yalnız dili düzenler; hasta adı [HASTA] olarak maskelendi - kontrol edip kaydedin.",
                izlemeNo = baglam.IzlemeNo,
            });
        });

        // POST /api/muayene/{id}/epikriz/imzala - kilitler. Ayrı adım: her kaydetme imza sayılmasın.
        grup.MapPost("/{id:int}/epikriz/imzala", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste("muayene", Islem.Degistir);
            await using var b = await veri.AcAsync(iptal);
            var n = await b.CalistirAsync("""
                update public.epikriz
                   set imza_durum = 1, imza_zamani = now(), degistiren = @p1, degistirme_tarihi = now()
                 where muayene_id = @p0 and imza_durum = 0
                """, null, [id, baglam.KullaniciId], iptal);
            if (n == 0) throw GentegreHatasi.IsKurali("Epikriz yok ya da zaten imzalı. Önce kaydedin.");
            return Results.Ok(new { id, imzali = true, izlemeNo = baglam.IzlemeNo });
        });
    }

    /// <summary>YZ düzenleme yönergesi: yalnız dil; bilgi eklenmez / çıkarılmaz / değiştirilmez.</summary>
    private const string EpikrizYzYonergesi = """
        Sen Türkçe tıbbi metin editörüsün. Sana bir poliklinik epikrizinin bölümleri JSON olarak verilir.
        Görevin YALNIZ dili düzeltmek: yazım, noktalama, cümle akışı, tıbbi terimlerin standart yazımı.
        KURALLAR:
        - Yeni bilgi EKLEME; tanı, ilaç, doz, tetkik değeri, tarih, sayı DEĞİŞTİRME; hiçbir bilgiyi ÇIKARMA.
        - Kısaltmaları ve ICD kodlarını olduğu gibi bırak. [HASTA], [kimlik], [numara] gibi yer tutucuları aynen koru.
        - Boş bölümü boş bırak. Yorum, öneri, açıklama yazma.
        - Cevap YALNIZ aynı anahtarlarla bir JSON nesnesi olsun:
          {"sikayet":"","hikaye":"","bulgular":"","tani":"","tetkikOzet":"","tedavi":"","oneriler":""}
        """;

    public sealed record MuayeneEpikrizIstegi(string? Sikayet, string? Hikaye, string? Bulgular, string? Tani,
        string? TetkikOzet, string? Tedavi, string? Oneriler);
}
