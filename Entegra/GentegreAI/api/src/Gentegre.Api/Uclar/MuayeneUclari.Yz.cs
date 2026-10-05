using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// MUAYENEDE YAPAY ZEKÂ ÖNERİLERİ — bkz. <c>MuayeneUclari</c>.
///
/// <para>Tanı / tetkik / ilaç önerisi. <b>Öneridir, karar hekimindir:</b> bağlam
/// anonim gider, katalog doğrulaması ve alerji elemesi sunucuda yapılır, doz
/// yazılmaz. Kontör yoksa model hiç çağrılmaz; çağrı başarısızsa kontör
/// düşülmez.</para>
/// </summary>
public static partial class MuayeneUclari
{
    private static void YzUclariniEkle(RouteGroupBuilder grup)
    {
        // POST /api/muayene/{id}/tani/{icdKod} - listeden seçilen tanıyı ekle
        //   Ana tanı ZATEN VARSA yeni satır EK tanı olur: ana tanıyı sessizce
        //   değiştirmek, tamamlama ve e-Nabız 103 paketinin dayandığı kaydı
        //   hekime sormadan oynatmak demekti.
        // TANI ARAMA SEÇENEKLERİ (kullanıcı: "tür ve taraf arama edit üzerinde
        //   olsun"): ICD penceresindeki iki seçici. Taraf kartın taraf
        //   kodlarından - iki yerde ayrı liste tutulmasın.
        // YZ ÖNERİLERİ (tanı · tetkik · ilaç) - hekime; karar hekimin.
        //   Bağlam SUNUCUDA toplanır ve anonimleştirilir (YzTaniOnerisi: ad/soyad/
        //   kimlik no gitmez); her öneri katalogla doğrulanır. Kontör rehberle
        //   ortak; başarısız çağrı ücretlendirilmez. Model yoksa / kontör bittiyse
        //   iş kuralı hatası - ekranda mesaj olur, öneri uydurulmaz.

        // POST /api/muayene/{id}/yz-tani-onerisi
        grup.MapPost("/{id:int}/yz-tani-onerisi", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, Servisler.IModelSaglayici model,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var (bag, yanit, ucret, sure) = await YzCagirAsync(baglam, b, model, id, "tani",
                _ => Servisler.YzTaniOnerisi.SistemYonergesi, iptal);

            // KATALOG DOĞRULAMASI: metindeki her ICD biçimli kod tek sorguyla aranır;
            //   noktasız yazılmışsa ("J069") noktalı biçimi de denenir.
            var adaylar = System.Text.RegularExpressions.Regex.Matches(yanit.Metin.ToUpperInvariant(), @"\b[A-Z]\d{2}(?:\.?\d{1,2})?\b")
                .Select(x => x.Value).SelectMany(k => k.Contains('.') || k.Length <= 3 ? new[] { k } : new[] { k, k[..3] + "." + k[3..] })
                .Distinct().ToArray();
            var katalog = (await b.ListeAsync(
                "select kod, ad from public.icd where aktif = 1 and kod = any(@p0)", null, [adaylar],
                o => (Kod: o.GetString(0), Ad: o.GetString(1)), iptal)).ToDictionary(x => x.Kod, x => x.Ad);
            var mevcut = bag.Tanilar.Select(t => t.Split(' ')[0]).ToHashSet();
            var (oneriler, kirmizi, eksik, atilan) = Servisler.YzTaniOnerisi.Coz(yanit.Metin,
                k => katalog.GetValueOrDefault(k)
                     ?? (k.Length > 3 && !k.Contains('.') ? katalog.GetValueOrDefault(k[..3] + "." + k[3..]) : null),
                mevcut);
            // Noktasız gelen kod katalog biçimine çevrilir (ekleme ucu katalog kodunu ister).
            oneriler = oneriler.Select(o => katalog.ContainsKey(o.Kod) || o.Kod.Contains('.') || o.Kod.Length <= 3
                ? o : o with { Kod = o.Kod[..3] + "." + o.Kod[3..] }).ToList();

            await YzKontorDusAsync(b, baglam, ucret, yanit, "tani",
                $"tanı: {oneriler.Count} öneri{(kirmizi.Length > 0 ? " · kırmızı bayrak" : "")}", id, sure, iptal);
            return Results.Ok(new
            {
                oneriler = oneriler.Select(o => new { kod = o.Kod, ad = o.Ad, olasilik = o.Olasilik, gerekce = o.Gerekce }),
                kirmiziBayrak = kirmizi, eksikBilgi = eksik, atilanKod = atilan, model = yanit.Model,
                uyari = "YZ önerisidir; tanı kararı hekimindir.", izlemeNo = baglam.IzlemeNo,
            });
        });

        // POST /api/muayene/{id}/yz-tetkik-onerisi - lab (katalog listesinden kod) +
        //   görüntüleme (modalite + bölge -> radyoloji hizmet kataloğunda eşleşme).
        grup.MapPost("/{id:int}/yz-tetkik-onerisi", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, Servisler.IModelSaglayici model,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            // Aktif lab tetkikleri + panelleri: modelin seçebileceği TEK liste.
            var lab = await b.ListeAsync("""
                select 'tetkik', id, kod, ad from public.lab_tetkik where durum = 0
                union all
                select 'panel', id, kod, ad from public.lab_panel where durum = 0
                order by 1 desc, 3
                """, null, [], o => (Tur: o.GetString(0), Id: o.GetInt32(1), Kod: o.GetString(2), Ad: o.GetString(3)), iptal);
            var liste = string.Join("\n", lab.Select(x => $"{x.Kod} | {x.Ad}{(x.Tur == "panel" ? " (panel)" : "")}"));
            var (_, yanit, ucret, sure) = await YzCagirAsync(baglam, b, model, id, "tetkik",
                _ => Servisler.YzIstemReceteOnerisi.TetkikYonergesi(liste), iptal);

            var labKodlari = lab.Select(x => x.Kod).ToHashSet(StringComparer.OrdinalIgnoreCase);
            var (labOneri, gorOneri, not, atilan) = Servisler.YzIstemReceteOnerisi.CozTetkik(yanit.Metin, labKodlari);
            var oneriler = new List<object>();
            var radyolojiIdleri = new HashSet<int>();
            foreach (var o in labOneri)
            {
                var k = lab.First(x => string.Equals(x.Kod, o.Kod, StringComparison.OrdinalIgnoreCase));
                oneriler.Add(new { tur = k.Tur, id = k.Id, kod = k.Kod, ad = k.Ad, gerekce = o.Gerekce });
            }
            foreach (var o in gorOneri)
            {
                var kosullar = Servisler.YzIstemReceteOnerisi.BolgeKosullari(o.Bolge);
                if (kosullar.Count == 0) { atilan++; continue; }
                // Her bölge sözcüğü (ya da eş anlamlısı) adda geçsin; en kısa (en genel) ad önce.
                var sozcukler = kosullar.SelectMany(x => x).ToList();
                var n = 1;
                var kosul = string.Join(" and ", kosullar.Select(es =>
                    "(" + string.Join(" or ", es.Select(_ => $"lower(h.ad) like '%' || @p{n++} || '%'")) + ")"));
                var h = await b.TekAsync($"""
                    select h.id, h.kod, h.ad from public.hizmet h
                     where h.modalite = @p0 and h.durum = 1 and {kosul}
                     order by length(h.ad), h.id limit 1
                    """, null, [o.Modalite, .. sozcukler.Cast<object?>()],
                    r => new YzHizmet(r.GetInt32(0), r.GetString(1), r.GetString(2)), iptal);
                if (h is null) { atilan++; continue; }
                if (!radyolojiIdleri.Add(h.Id)) continue;
                oneriler.Add(new { tur = "radyoloji", id = h.Id, kod = h.Kod, ad = h.Ad, gerekce = o.Gerekce });
            }

            await YzKontorDusAsync(b, baglam, ucret, yanit, "tetkik",
                $"tetkik: {labOneri.Count} lab · {oneriler.Count - labOneri.Count} görüntüleme", id, sure, iptal);
            return Results.Ok(new { oneriler, not, atilan, model = yanit.Model,
                                    uyari = "YZ önerisidir; istem kararı hekimindir.", izlemeNo = baglam.IzlemeNo });
        });

        // POST /api/muayene/{id}/yz-ilac-onerisi - etken madde önerisi -> katalog ürünleri
        //   (en çok 3); alerjiyle çakışan etken madde ELENİR. Doz önerilmez.
        grup.MapPost("/{id:int}/yz-ilac-onerisi", async (
            int id, BaglamCozucu cozucu, VeriKaynagi veri, Servisler.IModelSaglayici model,
            HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            await using var b = await veri.AcAsync(iptal);
            var (bag, yanit, ucret, sure) = await YzCagirAsync(baglam, b, model, id, "ilac",
                _ => Servisler.YzIstemReceteOnerisi.IlacYonergesi, iptal);

            var (etkenler, not) = Servisler.YzIstemReceteOnerisi.CozIlac(yanit.Metin);
            var notlar = new List<string>();
            if (not.Length > 0) notlar.Add(not);
            var oneriler = new List<object>();
            var bulunamayan = 0;
            foreach (var e in etkenler)
            {
                if (Servisler.YzIstemReceteOnerisi.AlerjiCakisir(e.Etken, bag.Alerji))
                {
                    notlar.Add($"⚠ {e.Etken} önerildi ama hastanın alerji kaydıyla çakıştığı için gösterilmedi.");
                    continue;
                }
                const string urunSql = """
                    select i.barkod, i.ad, i.etken_madde from public.ilac i
                     where i.aktif = 1 and lower(i.etken_madde) like '%' || @p0 || '%'
                     order by (lower(i.etken_madde) = @p0) desc,
                              -- AĞIZDAN FORM ÖNCE: jel / krem / gargara ilk sırada hekimi yanıltıyordu.
                              (lower(i.ad) similar to '%(tablet|kapsül|kapsul|şurup|surup|süspansiyon|suspansiyon|saşe|efervesan)%') desc,
                              length(i.etken_madde), length(i.ad), i.ad
                     limit 3
                    """;
                var urunler = await b.ListeAsync(urunSql, null, [e.Etken],
                    o => (Barkod: o.GetString(0), Ad: o.GetString(1), Etken: o.GetString(2)), iptal);
                // Yedek: İngilizce yazımla gelmişse Türkçe yazımla bir kez daha.
                var tr = Servisler.YzIstemReceteOnerisi.TurkceYazim(e.Etken);
                if (urunler.Count == 0 && tr != e.Etken)
                    urunler = await b.ListeAsync(urunSql, null, [tr],
                        o => (Barkod: o.GetString(0), Ad: o.GetString(1), Etken: o.GetString(2)), iptal);
                if (urunler.Count == 0) { bulunamayan++; continue; }
                foreach (var u in urunler)
                    oneriler.Add(new { barkod = u.Barkod, ad = u.Ad, etken = u.Etken, gerekce = $"{e.Etken}: {e.Gerekce}" });
            }
            if (bulunamayan > 0) notlar.Add($"{bulunamayan} etken madde ilaç kataloğunda bulunamadığı için gösterilmedi.");

            var elenen = notlar.Count(n => n.Contains("alerji"));
            await YzKontorDusAsync(b, baglam, ucret, yanit, "ilac",
                $"ilaç: {etkenler.Count - elenen} öneri{(elenen > 0 ? $" · {elenen} alerjiyle elendi" : "")}", id, sure, iptal);
            return Results.Ok(new { oneriler, notlar, model = yanit.Model,
                                    uyari = "YZ önerisidir; ilaç, doz ve süre kararı hekimindir.", izlemeNo = baglam.IzlemeNo });
        });
    }
}
