using Gentegre.Cekirdek;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// ÇAĞRI MERKEZİ İCMALİ (mockup Ekranlar/İcmal/cagri_merkezi_icmali.html,
/// kullanıcı 11.10.2026: "çağrı merkezi icmalini kodla").
///
/// <para><b>Kurallar (mockup notu):</b> gelen = yon 1; cevaplanan = cevap zamanı
/// dolu; terk = durum 6 (Kaçan); sesli / mesai dışı = durum 7. SLA = kuyruğun
/// sla_sn süresi içinde cevaplanan / (cevaplanan + terk); sesli SLA'ya girmez.
/// Randevuya dönüşme = sonuç 7 / cevaplanan gelen. Giden = yon 2.</para>
///
/// <para><b>Geri arama:</b> istek = sonucu "geri aranacak" (2) olan ya da terk
/// / sesli mesaj gelen çağrı. Tamamlanma zamanı tutulmadığı için istekten
/// sonra AYNI numaraya ya da kişiye yapılan ilk giden arama esas alınır;
/// zamanında = ayar <c>cagri.geri_arama_hedef_dk</c> (varsayılan 120) içinde.
/// Giden arama bulunamayan ama elle "tamam" işaretlenen istek süresiz sayılır.</para>
///
/// <para>Telefon numarası maskelenir, arayan adı kısaltılır; A4'te arayan yok.</para>
/// </summary>
public static class CagriIcmalUclari
{
    /// <summary>Ekran kodu (1031) - haklarını cagri.supervizor'dan kopyalar.</summary>
    private const string Kod = "cagri.icmal";

    private static readonly Dictionary<short, string> Sonuclar = new()
    {
        [1] = "Çözüldü", [2] = "Geri aranacak", [3] = "Görev açıldı", [4] = "Ulaşılamadı", [5] = "Yönlendirildi",
        [6] = "Bilgi verildi", [7] = "Randevu verildi", [8] = "Vazgeçti",
    };
    private static readonly Dictionary<short, string> KampanyaTurleri = new()
    {
        [1] = "Randevu hatırlatma", [2] = "Sonuç hazır", [3] = "Memnuniyet anketi", [4] = "Tahsilat", [5] = "Serbest liste", [6] = "İSG periyodik muayene",
    };

    private sealed record Cagri(int Id, short Kanal, short Yon, string ArayanNo, string ArananNo, int TarafId, string Taraf,
        int KuyrukId, int AgentId, DateTime Baslama, DateTime? Cevap, int Bekleme, int Sure, int IslemSonrasi, short Sonuc, short Durum,
        DateTime? GeriArama, bool GeriAramaTamam, int KampanyaId, int? Kalite);

    private sealed record OzetKaydi(int gelen, int cevaplanan, int terk, int sesli, decimal? cevapOrani, decimal? sla,
        int? ortBekleme, int? enUzunBekleme, int? ortGorusme, int? ortIslemSonrasi, int randevu);

    public static void CagriIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/cagri-icmal").WithTags("Çağrı Merkezi İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? kuyruk, short? kanal,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(Saat.Bugun.Year, Saat.Bugun.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var hedefDk = await b.TekDegerAsync<int?>(
                "select nullif(deger, '')::int from public.referans where anahtar = 'cagri.geri_arama_hedef_dk'", null, [], iptal) ?? 120;

            // Dönem + geri arama eşlemesi için 7 gün sonrası (giden aramalar).
            var hepsi = await b.ListeAsync("""
                select c.id, coalesce(c.kanal, 1)::smallint, coalesce(c.yon, 1)::smallint, coalesce(c.arayan_no, ''), coalesce(c.aranan_no, ''),
                       coalesce(c.taraf_id, 0), coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       coalesce(c.kuyruk_id, 0), coalesce(c.agent_id, 0), c.baslama, c.cevap,
                       coalesce(c.bekleme_sn, 0), coalesce(c.sure_sn, 0), coalesce(c.islem_sonrasi_sn, 0),
                       coalesce(c.sonuc, 0)::smallint, coalesce(c.durum, 0)::smallint, c.geri_arama, coalesce(c.geri_arama_tamam, 0) = 1,
                       coalesce(c.kampanya_id, 0),
                       (select round(avg(k.puan))::int from public.cagri_kalite k where k.cagri_id = c.id)
                  from public.cagri c
                  left join public.taraf t on t.id = c.taraf_id
                 where c.baslama >= @p0 and c.baslama < @p1
                   and (@p2 = 0 or coalesce(c.sube_id, 0) in (0, @p2))
                """, null, [baslangic, bitis.AddDays(7), sube], o => new Cagri(
                    o.GetInt32(0), o.GetInt16(1), o.GetInt16(2), o.GetString(3), o.GetString(4), o.GetInt32(5), o.GetString(6),
                    o.GetInt32(7), o.GetInt32(8), o.GetDateTime(9), o.IsDBNull(10) ? null : o.GetDateTime(10), o.GetInt32(11),
                    o.GetInt32(12), o.GetInt32(13), o.GetInt16(14), o.GetInt16(15), o.IsDBNull(16) ? null : o.GetDateTime(16),
                    o.GetBoolean(17), o.GetInt32(18), o.IsDBNull(19) ? null : o.GetInt32(19)), iptal);

            var kuyruklarTanim = (await b.ListeAsync("""
                select id, coalesce(ad, ''), coalesce(sla_sn, 0), coalesce(sla_hedef, 0)::int, coalesce(kanal, 1)::smallint
                  from public.cagri_kuyruk where (@p0 = 0 or coalesce(sube_id, 0) in (0, @p0))
                """, null, [sube], o => (id: o.GetInt32(0), ad: o.GetString(1),
                    // SLA tanımsız (0) kuyrukta her çağrı "SLA dışı" sayılırdı: varsayılan 20 sn / %80, ekranda belirtilir.
                    slaSn: o.GetInt32(2) > 0 ? o.GetInt32(2) : 20, hedef: o.GetInt32(3) > 0 ? o.GetInt32(3) : 80,
                    tanimsiz: o.GetInt32(2) <= 0 || o.GetInt32(3) <= 0, kanal: o.GetInt16(4)), iptal))
                .ToDictionary(x => x.id);
            // cagri.agent_id KULLANICI kimliğidir (839); dahili cagri_agent'tan.
            var agentlar = (await b.ListeAsync("""
                select t.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), 'Kullanıcı ' || t.id),
                       coalesce((select a.dahili from public.cagri_agent a where a.kullanici_id = t.id order by a.id limit 1), '')
                  from public.taraf t where t.id = any(@p0)
                """, null, [hepsi.Where(c => c.AgentId > 0).Select(c => c.AgentId).Distinct().ToArray()],
                o => (id: o.GetInt32(0), ad: o.GetString(1), dahili: o.GetString(2)), iptal)).ToDictionary(x => x.id);

            bool Donemde(Cagri c) => c.Baslama >= baslangic && c.Baslama < bitis;
            var kume = hepsi.Where(c => Donemde(c) && (kuyruk is not > 0 || c.KuyrukId == kuyruk) && (kanal is not > 0 || c.Kanal == kanal)).ToList();
            var gelen = kume.Where(c => c.Yon == 1).ToList();
            var giden = kume.Where(c => c.Yon == 2).ToList();
            bool Cevapli(Cagri c) => c.Cevap != null;
            bool Terk(Cagri c) => c.Durum == 6;
            bool Sesli(Cagri c) => c.Durum == 7;
            int SlaSn(Cagri c) => kuyruklarTanim.TryGetValue(c.KuyrukId, out var k) ? k.slaSn : 20;

            // 4 saatten uzun "görüşme" kapanmamış kayıttır (açık kalıp günler sonra kapanan); süre ortalamasına girmez.
            const int EnFazlaSure = 4 * 3600;
            bool SureGecerli(Cagri c) => c.Sure <= EnFazlaSure;
            static decimal? Oran(int pay, int payda) => payda > 0 ? Math.Round(100m * pay / payda, 1) : null;
            static int? Ort(IEnumerable<int> v) { var l = v.ToList(); return l.Count > 0 ? (int)Math.Round(l.Average()) : null; }

            OzetKaydi Ozetle(List<Cagri> g)
            {
                var cev = g.Where(Cevapli).ToList(); var terk = g.Count(Terk);
                return new OzetKaydi(g.Count, cev.Count, terk, g.Count(Sesli), Oran(cev.Count, g.Count),
                    Oran(cev.Count(c => c.Bekleme <= SlaSn(c)), cev.Count + terk), Ort(cev.Select(c => c.Bekleme)),
                    cev.Count > 0 ? cev.Max(c => c.Bekleme) : null, Ort(cev.Where(SureGecerli).Select(c => c.Sure)), Ort(cev.Select(c => c.IslemSonrasi)),
                    cev.Count(c => c.Sonuc == 7));
            }

            var kuyruklar = gelen.GroupBy(c => c.KuyrukId).Select(g =>
            {
                kuyruklarTanim.TryGetValue(g.Key, out var t);
                var l = g.ToList();
                return new
                {
                    id = g.Key, ad = g.Key > 0 ? t.ad ?? $"Kuyruk {g.Key}" : "Kuyruksuz", slaSn = g.Key > 0 ? t.slaSn : 20, hedef = g.Key > 0 ? t.hedef : 80,
                    slaTanimsiz = g.Key <= 0 || t.tanimsiz,
                    ozet = Ozetle(l),
                    sonuclar = l.Where(Cevapli).GroupBy(c => c.Sonuc).Select(s => new { ad = Sonuclar.GetValueOrDefault(s.Key, "Sonuçsuz"), adet = s.Count() })
                                .OrderByDescending(s => s.adet).ToList(),
                };
            }).OrderByDescending(x => x.id > 0).ThenBy(x => x.ad).ToList();

            // ------------------------------------------------- geri aramalar --
            string Maske(string no)
            {
                var r = new string(no.Where(char.IsDigit).ToArray());
                return r.Length >= 4 ? $"0{(r.Length > 10 ? r[^10] : r[0])}** *** ** {r[^2..]}" : "—";
            }
            string KisaAd(string ad) => string.IsNullOrWhiteSpace(ad) ? "Tanınmayan numara"
                : ad.Split(' ', StringSplitOptions.RemoveEmptyEntries) is { Length: > 1 } p ? $"{p[0]} {p[^1][0]}." : ad;
            static string Rakam(string no) { var r = new string(no.Where(char.IsDigit).ToArray()); return r.Length > 10 ? r[^10..] : r; }

            var istekler = gelen.Where(c => (c.Sonuc == 2 && c.GeriArama != null) || Terk(c) || Sesli(c)).Select(c =>
            {
                var referans = c.Sonuc == 2 && c.GeriArama is { } ga ? ga : c.Baslama;
                var no = Rakam(c.ArayanNo);
                var donus = hepsi.Where(x => x.Yon == 2 && x.Baslama >= c.Baslama
                        && ((no.Length >= 7 && Rakam(x.ArananNo) == no) || (c.TarafId > 0 && x.TarafId == c.TarafId)))
                    .OrderBy(x => x.Baslama).FirstOrDefault();
                int? dk = donus is null ? null : (int)Math.Max(0, Math.Round((donus.Baslama - referans).TotalMinutes));
                var durum = donus != null ? (dk <= hedefDk ? "zamaninda" : "gec") : c.GeriAramaTamam ? "tamam" : "yapilmadi";
                return new
                {
                    c.Id, istek = c.Baslama, arayan = KisaAd(c.Taraf), telefon = Maske(c.ArayanNo),
                    kuyruk = kuyruklarTanim.TryGetValue(c.KuyrukId, out var k) ? k.ad : "—",
                    kaynak = c.Sonuc == 2 ? "Temsilci notu" : Terk(c) ? "Terk (otomatik)" : "Sesli mesaj",
                    temsilci = agentlar.TryGetValue(c.AgentId, out var a) ? a.ad : "—", agentId = c.AgentId, sure = dk, durum,
                    ulasildi = donus?.Cevap != null,
                };
            }).ToList();

            var geriAramaOzet = istekler.GroupBy(i => i.kaynak).Select(g => new
            {
                kaynak = g.Key, istek = g.Count(), zamaninda = g.Count(x => x.durum == "zamaninda"), gec = g.Count(x => x.durum == "gec"),
                yapilmadi = g.Count(x => x.durum == "yapilmadi"), tamam = g.Count(x => x.durum == "tamam"), ulasildi = g.Count(x => x.ulasildi),
                ortSure = Ort(g.Where(x => x.sure != null).Select(x => x.sure!.Value)),
                oran = Oran(g.Count(x => x.durum == "zamaninda"), g.Count()),
            }).OrderByDescending(x => x.istek).ToList();

            // --------------------------------------------------- temsilciler --
            var temsilciler = kume.Where(c => c.AgentId > 0).GroupBy(c => c.AgentId).Select(g =>
            {
                agentlar.TryGetValue(g.Key, out var a);
                var cev = g.Where(c => c.Yon == 1 && Cevapli(c)).ToList();
                var gd = g.Where(c => c.Yon == 2).ToList();
                var konusulan = g.Where(Cevapli).ToList();
                var ist = istekler.Where(i => i.agentId == g.Key).ToList();
                var kalite = g.Where(c => c.Kalite != null).Select(c => (decimal)c.Kalite!.Value).ToList();
                return new
                {
                    id = g.Key, ad = a.ad ?? $"Agent {g.Key}", dahili = a.dahili ?? "", gelen = cev.Count, giden = gd.Count,
                    konusmaSn = konusulan.Where(SureGecerli).Sum(c => c.Sure), ortGorusme = Ort(konusulan.Where(SureGecerli).Select(c => c.Sure)),
                    ortIslemSonrasi = Ort(konusulan.Select(c => c.IslemSonrasi)), randevu = cev.Count(c => c.Sonuc == 7),
                    donusum = Oran(cev.Count(c => c.Sonuc == 7), cev.Count),
                    geriZamaninda = ist.Count(i => i.durum == "zamaninda"), geriGec = ist.Count(i => i.durum == "gec"),
                    geriYok = ist.Count(i => i.durum == "yapilmadi"),
                    kalite = kalite.Count > 0 ? Math.Round(kalite.Average(), 1) : (decimal?)null,
                };
            }).OrderByDescending(x => x.gelen + x.giden).ToList();

            // --------------------------------------------- saat / gün yoğunluğu --
            var saatler = gelen.GroupBy(c => Sesli(c) ? -1 : c.Baslama.Hour).Select(g =>
            {
                var cev = g.Where(Cevapli).ToList(); var terk = g.Count(Terk);
                return new
                {
                    saat = g.Key, gelen = g.Count(), cevaplanan = cev.Count, terk, sesli = g.Count(Sesli),
                    sla = Oran(cev.Count(c => c.Bekleme <= SlaSn(c)), cev.Count + terk), ortBekleme = Ort(cev.Select(c => c.Bekleme)),
                };
            }).OrderBy(x => x.saat < 0 ? 99 : x.saat).ToList();
            var gunSayilari = Enumerable.Range(0, (bitis - baslangic).Days).Select(i => baslangic.AddDays(i).DayOfWeek)
                .GroupBy(d => d).ToDictionary(g => g.Key, g => g.Count());
            var gunler = Enum.GetValues<DayOfWeek>().OrderBy(d => ((int)d + 6) % 7).Select(d =>
            {
                var l = gelen.Where(c => c.Baslama.DayOfWeek == d).ToList(); var n = gunSayilari.GetValueOrDefault(d);
                return new
                {
                    gun = (int)d, gunSayisi = n, gelen = l.Count, gunBasina = n > 0 ? Math.Round((decimal)l.Count / n, 0) : 0m,
                    cevapOrani = Oran(l.Count(Cevapli), l.Count),
                };
            }).ToList();

            // ------------------------------------------------------ kampanyalar --
            var kampanyalar = await b.ListeAsync("""
                select k.id, coalesce(k.ad, ''), coalesce(k.tur, 5)::smallint, coalesce(k.sablon_kodu, '') <> '',
                       count(p.id)::int, coalesce(sum(p.deneme), 0)::int,
                       count(*) filter (where p.durum in (4, 5, 6))::int, count(*) filter (where p.durum = 5)::int,
                       count(*) filter (where p.durum = 6)::int, count(*) filter (where p.durum = 3)::int,
                       count(*) filter (where p.durum in (1, 2))::int
                  from public.cagri_kampanya k
                  left join public.cagri_kampanya_kisi p on p.kampanya_id = k.id
                 where coalesce(k.baslama, @p0::date) < @p1::date and coalesce(k.bitis, @p1::date) >= @p0::date
                   and (@p2 = 0 or coalesce(k.sube_id, 0) in (0, @p2))
                 group by k.id, k.ad, k.tur, k.sablon_kodu
                 order by k.ad
                """, null, [baslangic, bitis, sube], o => new
            {
                id = o.GetInt32(0), ad = o.GetString(1), tur = KampanyaTurleri.GetValueOrDefault(o.GetInt16(2), "Serbest liste"),
                kanal = o.GetBoolean(3) ? "SMS + arama" : "arama", kisi = o.GetInt32(4), arama = o.GetInt32(5), ulasilan = o.GetInt32(6),
                onay = o.GetInt32(7), iptal = o.GetInt32(8), ulasilamadi = o.GetInt32(9), bekliyor = o.GetInt32(10),
                basari = Oran(o.GetInt32(7), o.GetInt32(6)),
            }, iptal);

            var g0 = Ozetle(gelen);
            var ozet = new
            {
                gelen = gelen.Count, telefon = gelen.Count(c => c.Kanal == 1), whatsapp = gelen.Count(c => c.Kanal == 2),
                digerKanal = gelen.Count(c => c.Kanal > 2), cevaplanan = g0.cevaplanan, cevapOrani = g0.cevapOrani,
                sla = g0.sla, terk = g0.terk, sesli = g0.sesli, ortBekleme = g0.ortBekleme,
                enUzunBekleme = g0.enUzunBekleme, ortGorusme = g0.ortGorusme, ortIslemSonrasi = g0.ortIslemSonrasi,
                randevu = g0.randevu, donusum = Oran(g0.randevu, g0.cevaplanan),
                geriIstek = istekler.Count, geriZamaninda = istekler.Count(i => i.durum == "zamaninda"),
                geriGec = istekler.Count(i => i.durum == "gec"), geriYok = istekler.Count(i => i.durum == "yapilmadi"),
                geriOran = Oran(istekler.Count(i => i.durum == "zamaninda"), istekler.Count), hedefDk,
                giden = giden.Count, gidenGeriArama = giden.Count(c => c.KampanyaId == 0), gidenKampanya = giden.Count(c => c.KampanyaId > 0),
                slaHedef = kuyruklarTanim.Count > 0 ? (int)Math.Round(kuyruklarTanim.Values.Average(k => k.hedef)) : 80,
                temsilci = temsilciler.Count, asiriSure = kume.Count(c => c.Cevap != null && !SureGecerli(c)),
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, ozet, kuyruklar, temsilciler, saatler, gunler, geriAramaOzet,
                gecikenler = istekler.Where(i => i.durum is "gec" or "yapilmadi").OrderBy(i => i.durum == "gec").ThenBy(i => i.istek).Take(50).ToList(),
                kampanyalar,
                kuyrukAdlari = kuyruklarTanim.Values.OrderBy(k => k.ad).Select(k => new { k.id, k.ad }),
            });
        });
    }
}
