using Gentegre.Cekirdek;
using System.Globalization;
using System.Text.Json;
using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// KALİTE / SKS İCMALİ (mockup Ekranlar/İcmal/kalite_sks_icmali.html,
/// kullanıcı 12.10.2026: "icmalleri yap").
///
/// <para>ISO kalite modülü (denetim, DÖF, eğitim, sapma, toplantı) henüz YOK: icmal
/// YALNIZ mevcut kayıtlardan kurulur, kaynağı olmayan gösterge "kaynak yok" döner
/// (uydurulmaz, yeni tablo açılmaz).</para>
///
/// <para><b>Kaynaklar:</b>
/// <list type="bullet">
/// <item>Klinik göstergeler: klinik_gosterge_donem aynen (dönem, başlangıç tarihini
///   kapsayan periyot; trend = bir önceki periyot). Yalnız paydası olan (ölçülen) satırlar.</item>
/// <item>Kritik / panik bildirim: lab_panik_bildirim (süre = sonuç onayı → bildirim) +
///   radyoloji_kritik_bulgu (rapor onayı → bildirim). Hedef: referans
///   <c>kalite.panik_hedef_dk</c> (30), <c>kalite.kritik_hedef_dk</c> (60).</item>
/// <item>GRS olayları, el hijyeni, memnuniyet, İtaki, Braden: form motoru (form_istek.cevap,
///   şablon kodu; kurum kopyaları da aynı kodla). Bölüm = formun yatışı / başvurusu,
///   yoksa hastanın o anki yatışı.</item>
/// <item>Düşme = GRS türü "düşme" / yatan hasta-gün × 1000 (hasta-gün Yatan Hasta İcmali
///   kuralı: giriş günü sayılır, çıkış günü sayılmaz). Bası yarası = Braden ≤ 12 riskli
///   hastada ilk formda yok, sonraki formda "var".</item>
/// <item>Güvenli cerrahi = biten ameliyatta DSÖ listesinin tüm maddeleri işaretli.</item>
/// </list></para>
///
/// <para>Hasta kimliği dönmez: bildirimler Protokol No ile, GRS olayı form no ile.</para>
/// </summary>
public static class KaliteIcmalUclari
{
    /// <summary>Ekran kodu (1045) - haklarını klinik_kalite.donem'den kopyalar.</summary>
    private const string Kod = "kalite.icmal";

    private static readonly CultureInfo Tr = new("tr-TR");

    private static readonly Dictionary<short, string> LabKanal = new() { [1] = "Telefon", [2] = "SMS", [3] = "Mesaj", [4] = "Portal" };
    private static readonly Dictionary<short, string> RadKanal = new() { [1] = "Telefon", [2] = "SMS", [3] = "Yüz yüze", [4] = "E-posta" };

    /// <summary>GRS "Hastaya etkisi" seçenekleri → zarar düzeyi sütunu (0 ramak kala ... 4 ölüm, 5 belirtilmemiş).</summary>
    private static readonly string[] ZararAdlari = ["Ramak kala", "Zarar yok", "Hafif", "Ciddi", "Ölüm", "Belirtilmemiş"];
    private static int ZararDuzeyi(string s) => s switch
    {
        "Ulaşmadı" => 0, "Ulaştı, zarar yok" => 1, "Hafif zarar" => 2, "Ciddi zarar" => 3, "Ölüm" => 4, _ => 5,
    };

    private static readonly (string kod, string ad)[] MemnuniyetSorulari =
    [
        ("kayit", "Kayıt / karşılama"), ("bekleme", "Bekleme süresi"), ("hekim", "Hekimin ilgisi ve bilgilendirmesi"),
        ("hemsire", "Hemşire / personel"), ("temizlik", "Temizlik ve tesis"), ("tavsiye", "Kurumu tavsiye eder misiniz"),
    ];

    private sealed record Bildirim(char Kaynak, int Id, DateTime Zaman, DateTime? Cikis, string Protokol, string Tetkik, string Deger,
        string Bolum, string Bildirilen, short Kanal, bool Teyit, bool Yukseltme);
    private sealed record Form(int Id, string Kod, bool Tamam, DateTime Zaman, JsonElement Cevap, decimal? Skor, int Hasta,
        int YatisId, int DepId, string DepAd, bool Adli);
    private sealed record Yatis(int Id, int DepId, string DepAd, DateTime Giris, DateTime? Cikis);
    private sealed record Kirilim(string Ad, decimal Pay, decimal Payda, string Birim, decimal? Sonuc);
    private sealed record ServisSatiri(string Servis, int Yatan, int HastaGun, int ItakiYuksek, int Dusme, decimal? DusmeBinde,
        int BradenRiskli, int Gelisen, decimal? BasiOran);
    /// <summary>Durum: hedefte · disi · hedefsiz · veriyok (payda 0) · kaynakyok (kayıt kaynağı yok).</summary>
    private sealed record GostergeSatiri(string Kod, string Ad, string Kaynak, string Yon, decimal? Hedef, string Birim, decimal Pay,
        decimal Payda, decimal? Sonuc, decimal? Onceki, string Durum, List<Kirilim> Kirilim, string Not, bool Kesin);

    public static void KaliteIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/kalite-icmal").WithTags("Kalite / SKS İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(Saat.Bugun.Year, Saat.Bugun.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            // Önceki dönem (trend): tam ay(lar)sa önceki ay(lar), değilse aynı uzunlukta önceki aralık.
            var aySayisi = (bitis.Year - baslangic.Year) * 12 + bitis.Month - baslangic.Month;
            var oncBas = baslangic.Day == 1 && bitis.Day == 1 && aySayisi > 0
                ? baslangic.AddMonths(-aySayisi) : baslangic.AddDays(-(bitis - baslangic).Days);
            var bugun = Saat.Bugun;
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);

            var ayar = (await b.ListeAsync("""
                select anahtar, nullif(deger, '')::int from public.referans
                 where anahtar in ('kalite.panik_hedef_dk', 'kalite.kritik_hedef_dk')
                """, null, [], o => (k: o.GetString(0), v: o.IsDBNull(1) ? 0 : o.GetInt32(1)), iptal)).ToDictionary(x => x.k, x => x.v);
            var panikHedef = ayar.GetValueOrDefault("kalite.panik_hedef_dk") is > 0 and var ph ? ph : 30;
            var kritikHedef = ayar.GetValueOrDefault("kalite.kritik_hedef_dk") is > 0 and var kh ? kh : 60;

            // ------------------------------------------------ kritik / panik bildirimleri --
            var bildirimler = await b.ListeAsync("""
                select 'L', p.id, p.bildirim_zamani, coalesce(r.onay_zamani, r.olcum_zamani, r.ekleme_tarihi),
                       coalesce(be.belge_no, ''), coalesce(t.ad, ''),
                       coalesce(nullif(r.deger_metin, ''), trim(to_char(r.deger_sayisal, 'FM999999990.###')), '')
                         || coalesce(' ' || nullif(r.birim, ''), ''),
                       coalesce(d.ad, ''), coalesce(p.bildirilen_ad, ''), coalesce(p.kanal, 1)::smallint,
                       p.teyit_zamani is not null, coalesce(p.yukseltme, 0) > 0
                  from public.lab_panik_bildirim p
                  join public.lab_sonuc r on r.id = p.sonuc_id
                  join public.lab_istem_satir s on s.id = r.istem_satir_id
                  join public.lab_istem i on i.id = s.istem_id
                  left join public.lab_tetkik t on t.id = r.tetkik_id
                  left join public.belge be on be.id = i.belge_id
                  left join public.belge_basvuru bb on bb.id = i.belge_id
                  left join public.departman d on d.id = bb.bolum_id
                 where p.bildirim_zamani >= @p0 and p.bildirim_zamani < @p1 and (@p2 = 0 or coalesce(r.sube_id, 0) in (0, @p2))
                union all
                select 'R', k.id, k.bildirim_zamani, coalesce(rp.onay_tarihi, rp.yazma_tarihi, ri.cekim_tarihi, ri.ekleme_tarihi),
                       coalesce(be.belge_no, ''), coalesce(nullif(k.bulgu, ''), h.ad, ''), '',
                       coalesce(d.ad, ''), coalesce(k.bildirilen_ad, ''), coalesce(k.yol, 1)::smallint,
                       coalesce(k.teyit_alindi, 0) = 1, false
                  from public.radyoloji_kritik_bulgu k
                  join public.radyoloji_istem ri on ri.id = k.istem_id
                  left join public.radyoloji_rapor rp on rp.id = k.rapor_id
                  left join public.hizmet h on h.id = ri.hizmet_id
                  left join public.belge be on be.id = ri.belge_id
                  left join public.belge_basvuru bb on bb.id = ri.belge_id
                  left join public.departman d on d.id = bb.bolum_id
                 where k.bildirim_zamani >= @p0 and k.bildirim_zamani < @p1 and (@p2 = 0 or coalesce(ri.sube_id, 0) in (0, @p2))
                """, null, [oncBas, bitis, sube], o => new Bildirim(o.GetString(0)[0], o.GetInt32(1), o.GetDateTime(2).ToLocalTime(),
                    o.IsDBNull(3) ? null : o.GetDateTime(3).ToLocalTime(), o.GetString(4), o.GetString(5), o.GetString(6), o.GetString(7),
                    o.GetString(8), o.GetInt16(9), o.GetBoolean(10), o.GetBoolean(11)), iptal);

            // ----------------------------------------------------------- form motoru --
            //  Bölüm: formun yatışı (4) / başvurusu (2, 3); yoksa hastanın o anki yatışı.
            var formlar = await b.ListeAsync("""
                select i.id, s.kod, i.durum = 4, coalesce(i.tamamlanma, i.gonderim, i.ekleme_tarihi), i.cevap::text, i.skor,
                       coalesce(i.hasta_id, 0), coalesce(y.id, ya.id, 0),
                       coalesce(dy.id, db.id, dya.id, 0), coalesce(dy.ad, db.ad, dya.ad, ''), i.dolduran_id is not null
                  from public.form_istek i
                  join public.form_sablon s on s.id = i.sablon_id
                  left join public.yatis y on i.kaynak_tur = 4 and y.id = i.kaynak_id
                  left join public.departman dy on dy.id = y.departman_id
                  left join public.belge_basvuru bb on i.kaynak_tur in (2, 3) and bb.id = i.kaynak_id
                  left join public.departman db on db.id = bb.bolum_id
                  left join lateral (
                        select y2.id, y2.departman_id from public.yatis y2
                         where y.id is null and i.hasta_id is not null and y2.hasta_id = i.hasta_id and coalesce(y2.durum, 1) <> 0
                           and y2.giris_tarihi <= coalesce(i.tamamlanma, i.gonderim, i.ekleme_tarihi)
                           and (y2.cikis_tarihi is null or y2.cikis_tarihi >= coalesce(i.tamamlanma, i.gonderim, i.ekleme_tarihi))
                         order by y2.giris_tarihi desc limit 1) ya on true
                  left join public.departman dya on dya.id = ya.departman_id
                 where s.kod in ('grs_olay', 'el_hijyeni', 'memnuniyet', 'braden', 'itaki') and i.durum <> 8
                   and coalesce(i.tamamlanma, i.gonderim, i.ekleme_tarihi) >= @p0
                   and coalesce(i.tamamlanma, i.gonderim, i.ekleme_tarihi) < @p1
                   and (@p2 = 0 or coalesce(i.sube_id, 0) in (0, @p2))
                """, null, [oncBas, bitis, sube], o =>
                {
                    JsonElement cevap;
                    try { using var d = JsonDocument.Parse(o.IsDBNull(4) ? "{}" : o.GetString(4)); cevap = d.RootElement.Clone(); }
                    catch (JsonException) { using var d = JsonDocument.Parse("{}"); cevap = d.RootElement.Clone(); }
                    return new Form(o.GetInt32(0), o.GetString(1), o.GetBoolean(2), o.GetDateTime(3), cevap,
                        o.IsDBNull(5) ? null : o.GetDecimal(5), o.GetInt32(6), o.GetInt32(7), o.GetInt32(8), o.GetString(9), o.GetBoolean(10));
                }, iptal);

            var yatislar = await b.ListeAsync("""
                select y.id, coalesce(y.departman_id, 0), coalesce(d.ad, 'Servis belirsiz'), y.giris_tarihi, y.cikis_tarihi
                  from public.yatis y left join public.departman d on d.id = y.departman_id
                 where coalesce(y.durum, 1) <> 0 and y.giris_tarihi < @p1 and (y.cikis_tarihi is null or y.cikis_tarihi >= @p0)
                   and (@p2 = 0 or coalesce(y.sube_id, 0) in (0, @p2))
                """, null, [oncBas, bitis, sube], o => new Yatis(o.GetInt32(0), o.GetInt32(1), o.GetString(2),
                    o.GetDateTime(3).ToLocalTime(), o.IsDBNull(4) ? null : o.GetDateTime(4).ToLocalTime()), iptal);

            var ameliyatlar = await b.ListeAsync("""
                select coalesce(a.salondan_cikis, a.bitis_zamani),
                       (select count(*) from public.ameliyat_kontrol k where k.ameliyat_id = a.id)::int,
                       (select count(*) from public.ameliyat_kontrol k where k.ameliyat_id = a.id and coalesce(k.isaretli, 0) = 0)::int
                  from public.ameliyat a
                 where a.durum = 4 and coalesce(a.salondan_cikis, a.bitis_zamani) >= @p0 and coalesce(a.salondan_cikis, a.bitis_zamani) < @p1
                   and (@p2 = 0 or coalesce(a.sube_id, 0) in (0, @p2))
                """, null, [oncBas, bitis, sube], o => (zaman: o.GetDateTime(0).ToLocalTime(), madde: o.GetInt32(1), eksik: o.GetInt32(2)), iptal);

            var klinikHam = await b.ListeAsync("""
                select g.id, g.kod, g.ad, d.periyot, d.donem_yil, d.donem_no, d.pay, d.payda, d.sonuc,
                       coalesce(d.hedef_yon, g.kurum_hedef_yon, g.hedef_yon, ''), coalesce(d.hedef_deger, g.kurum_hedef_deger, g.hedef_deger),
                       coalesce(g.hedef_birim, ''), d.durum, d.sube_id
                  from public.klinik_gosterge_donem d
                  join public.klinik_gosterge g on g.id = d.gosterge_id
                 where coalesce(g.aktif, 1) = 1 and d.periyot > 0 and d.donem_yil between @p0 and @p1
                   and (@p2 = 0 or d.sube_id in (0, @p2))
                """, null, [(short)(oncBas.Year - 1), (short)baslangic.Year, sube], o => (gid: o.GetInt32(0), kod: o.GetString(1), ad: o.GetString(2),
                    periyot: o.GetInt16(3), yil: o.GetInt16(4), no: o.GetInt16(5), pay: o.GetDecimal(6), payda: o.GetDecimal(7),
                    sonuc: o.GetDecimal(8), yon: o.GetString(9), hedef: o.IsDBNull(10) ? (decimal?)null : o.GetDecimal(10),
                    birim: o.GetString(11), kesin: o.GetInt16(12) == 1, subeId: o.GetInt32(13)), iptal);

            // ---------------------------------------------------------------- yardımcılar --
            bool Donemde(DateTime t) => t >= baslangic && t < bitis;
            bool Oncede(DateTime t) => t >= oncBas && t < baslangic;
            static decimal? Oran(decimal pay, decimal payda, int carpan = 100) => payda > 0 ? Math.Round(carpan * pay / payda, carpan == 1000 ? 2 : 1) : null;
            static int? Ort(IEnumerable<int> v) { var l = v.ToList(); return l.Count > 0 ? (int)Math.Round(l.Average()) : null; }
            int Gece(Yatis y, DateTime a, DateTime son)
            {
                var g = y.Giris.Date; var c = y.Cikis?.Date ?? bugun.AddDays(1);
                var ilk = g > a ? g : a; var sonr = c < son ? c : son;
                return Math.Max(0, (sonr - ilk).Days);
            }
            string Kucuk(string s) => s.Trim().ToLower(Tr);

            // -------------------------------------------------------------- bildirimler --
            int Hedef(Bildirim x) => x.Kaynak == 'L' ? panikHedef : kritikHedef;
            int? Sure(Bildirim x) => x.Cikis is { } c ? Math.Max(0, (int)Math.Round((x.Zaman - c).TotalMinutes)) : null;
            bool HedefteMi(Bildirim x) => Sure(x) is { } s && s <= Hedef(x);
            var bildBu = bildirimler.Where(x => Donemde(x.Zaman)).ToList();
            var bildOnc = bildirimler.Where(x => Oncede(x.Zaman)).ToList();
            object KaynakSatiri(string ad, int hedef, List<Bildirim> l) => new
            {
                kaynak = ad, hedefDk = hedef, bildirim = l.Count, hedefte = l.Count(HedefteMi), asan = l.Count(x => !HedefteMi(x)),
                oran = Oran(l.Count(HedefteMi), l.Count), ortSure = Ort(l.Select(Sure).OfType<int>()),
                enUzun = l.Select(Sure).OfType<int>().Select(x => (int?)x).Max(),
                teyit = l.Count(x => x.Teyit), yukseltme = l.Count(x => x.Yukseltme),
            };
            var bildirimKaynaklari = new[]
            {
                KaynakSatiri("Laboratuvar panik değer", panikHedef, bildBu.Where(x => x.Kaynak == 'L').ToList()),
                KaynakSatiri("Radyoloji kritik bulgu", kritikHedef, bildBu.Where(x => x.Kaynak == 'R').ToList()),
            };
            var bildirimListe = bildBu.Select(x => new
            {
                zaman = x.Zaman, protokolNo = x.Protokol, kaynak = x.Kaynak == 'L' ? "Lab" : "Rad", tetkik = x.Tetkik, deger = x.Deger,
                bolum = x.Bolum, bildirilen = x.Bildirilen,
                kanal = (x.Kaynak == 'L' ? LabKanal : RadKanal).GetValueOrDefault(x.Kanal, ""), sureDk = Sure(x), hedefDk = Hedef(x),
                asti = !HedefteMi(x), teyit = x.Teyit, yukseltme = x.Yukseltme,
            }).OrderByDescending(x => (x.sureDk ?? 100000) - x.hedefDk).ToList();

            // --------------------------------------------------------------- GRS olayları --
            var grsHepsi = formlar.Where(f => f.Kod == "grs_olay" && f.Tamam).Select(f =>
            {
                var tarihMetin = Metin(Bul(f.Cevap, "tarih"));
                var t = DateTime.TryParse(tarihMetin, CultureInfo.InvariantCulture, DateTimeStyles.None, out var tt) ? tt.Date : f.Zaman.Date;
                var birim = Metin(Bul(f.Cevap, "birim"));
                return (f.Id, tarih: t, kayit: f.Zaman, tur: Metin(Bul(f.Cevap, "tur")) is { Length: > 0 } tr ? tr : "Diğer",
                    birim: birim.Length > 0 ? birim : f.DepAd, zarar: ZararDuzeyi(Metin(Bul(f.Cevap, "sonuc"))),
                    anonim: Evet(Bul(f.Cevap, "anonim")) || !f.Adli);
            }).ToList();
            var grsBu = grsHepsi.Where(g => Donemde(g.tarih)).ToList();
            var grsOnc = grsHepsi.Where(g => Oncede(g.tarih)).ToList();
            var grsMatris = grsBu.GroupBy(g => g.tur).Select(g => new
            {
                tur = g.Key, duzey = Enumerable.Range(0, ZararAdlari.Length).Select(z => g.Count(x => x.zarar == z)).ToArray(), toplam = g.Count(),
            }).OrderByDescending(x => x.toplam).ToList();
            var grsListe = grsBu.OrderBy(g => g.tarih).Select(g => new
            {
                no = $"GRS-{g.kayit.Year}-{g.Id:0000}", tarih = g.tarih, g.tur, g.birim, zarar = ZararAdlari[g.zarar], duzey = g.zarar, g.anonim,
            }).ToList();
            bool DusmeMi(string tur) => Kucuk(tur).Contains("düşme");

            // ------------------------------------------- servis: düşme / bası yarası --
            var depAdlari = yatislar.Where(y => y.DepId > 0).GroupBy(y => y.DepId).ToDictionary(g => g.Key, g => g.First().DepAd);
            int DepBul(string metin) => depAdlari.FirstOrDefault(d => Kucuk(d.Value) == Kucuk(metin)).Key;
            (List<ServisSatiri> satirlar, int dusme, int hastaGun, int riskli, int gelisen) Servisler(DateTime a, DateTime son, bool liste)
            {
                bool Ic(DateTime t) => t >= a && t < son;
                var dus = grsHepsi.Where(g => Ic(g.tarih) && DusmeMi(g.tur)).Select(g => DepBul(g.birim)).ToList();
                var itaki = formlar.Where(f => f.Kod == "itaki" && f.Tamam && Ic(f.Zaman)).ToList();
                var braden = formlar.Where(f => f.Kod == "braden" && f.Tamam && Ic(f.Zaman)).ToList();
                var bradenRiskli = braden.Where(f => f.Skor is { } s && s <= 12).GroupBy(f => f.Hasta).ToDictionary(g => g.Key, g => g.First().DepId);
                // Gelişen: hastanın dönemdeki ilk Braden formunda yara yok, sonrakinde var.
                var gelisen = braden.GroupBy(f => f.Hasta).Where(g =>
                {
                    var s = g.OrderBy(f => f.Zaman).ToList();
                    return !Evet(Bul(s[0].Cevap, "yara")) && s.Skip(1).Any(f => Evet(Bul(f.Cevap, "yara")));
                }).ToDictionary(g => g.Key, g => g.OrderBy(f => f.Zaman).Last().DepId);
                var depler = yatislar.Where(y => Gece(y, a, son) > 0).Select(y => y.DepId)
                    .Concat(dus.Where(d => d > 0)).Concat(bradenRiskli.Values).Concat(itaki.Select(f => f.DepId)).Where(d => d > 0).Distinct();
                var satirlar = liste ? depler.Select(d =>
                {
                    var ys = yatislar.Where(y => y.DepId == d && Gece(y, a, son) > 0).ToList();
                    var hg = ys.Sum(y => Gece(y, a, son)); var du = dus.Count(x => x == d);
                    var rk = bradenRiskli.Count(x => x.Value == d); var ge = gelisen.Count(x => x.Value == d && bradenRiskli.ContainsKey(x.Key));
                    return new ServisSatiri(depAdlari.GetValueOrDefault(d, formlar.FirstOrDefault(f => f.DepId == d)?.DepAd ?? "Servis belirsiz"),
                        ys.Count, hg, itaki.Where(f => f.DepId == d && f.Skor is >= 5).Select(f => f.Hasta).Distinct().Count(),
                        du, Oran(du, hg, 1000), rk, ge, Oran(ge, rk));
                }).OrderByDescending(x => x.HastaGun).ToList() : [];
                var hastaGun = yatislar.Sum(y => Gece(y, a, son));
                return (satirlar, dus.Count, hastaGun, bradenRiskli.Count, gelisen.Count(x => bradenRiskli.ContainsKey(x.Key)));
            }
            var servisBu = Servisler(baslangic, bitis, true);
            var servisOnc = Servisler(oncBas, baslangic, false);
            var eslesmeyenDusme = grsBu.Count(g => DusmeMi(g.tur) && DepBul(g.birim) == 0);

            // ------------------------------------------------------------- el hijyeni --
            var elBu = formlar.Where(f => f.Kod == "el_hijyeni" && f.Tamam && Donemde(f.Zaman)).Select(f => (
                meslek: Metin(Bul(f.Cevap, "meslek")) is { Length: > 0 } m ? m : "Belirtilmemiş",
                endikasyon: Metin(Bul(f.Cevap, "endikasyon")) is { Length: > 0 } e ? e : "Belirtilmemiş",
                birim: Metin(Bul(f.Cevap, "birim")) is { Length: > 0 } bi ? bi : f.DepAd,
                uydu: Metin(Bul(f.Cevap, "uyum")) is { Length: > 0 } u && u != "Yapılmadı")).ToList();
            var elOnc = formlar.Where(f => f.Kod == "el_hijyeni" && f.Tamam && Oncede(f.Zaman))
                .Select(f => Metin(Bul(f.Cevap, "uyum")) is { Length: > 0 } u && u != "Yapılmadı").ToList();
            object ElSatir(string ad, IEnumerable<bool> l) { var x = l.ToList(); return new { ad, firsat = x.Count, uyulan = x.Count(v => v), oran = Oran(x.Count(v => v), x.Count) }; }
            var elMeslek = elBu.GroupBy(x => x.meslek).OrderByDescending(g => g.Count()).Select(g => ElSatir(g.Key, g.Select(x => x.uydu))).ToList();
            var elEndikasyon = elBu.GroupBy(x => x.endikasyon).OrderByDescending(g => g.Count()).Select(g => ElSatir(g.Key, g.Select(x => x.uydu))).ToList();

            // ------------------------------------------------------------- memnuniyet --
            decimal? Puan(Form f)
            {
                var l = MemnuniyetSorulari.Select(s => Sayi(Bul(f.Cevap, s.kod))).OfType<decimal>().Where(v => v > 0).ToList();
                return l.Count > 0 ? l.Average() : null;
            }
            var memHepsi = formlar.Where(f => f.Kod == "memnuniyet").ToList();
            var memBu = memHepsi.Where(f => Donemde(f.Zaman)).ToList();
            var memDolan = memBu.Where(f => f.Tamam && Puan(f) != null).ToList();
            var memOncDolan = memHepsi.Where(f => Oncede(f.Zaman) && f.Tamam && Puan(f) != null).ToList();
            string Birim(Form f) => f.DepAd.Length > 0 ? (f.YatisId > 0 ? $"{f.DepAd} (yatan)" : f.DepAd) : "Birim belirsiz";
            var memBirim = memBu.GroupBy(Birim).Select(g =>
            {
                var d = g.Where(f => f.Tamam && Puan(f) != null).ToList();
                return new
                {
                    birim = g.Key, gonderilen = g.Count(), dolduran = d.Count, yanit = Oran(d.Count, g.Count()),
                    ortPuan = d.Count > 0 ? Math.Round(d.Average(f => Puan(f)!.Value), 2) : (decimal?)null,
                    memnun = d.Count(f => Puan(f) >= 4), oran = Oran(d.Count(f => Puan(f) >= 4), d.Count),
                };
            }).OrderByDescending(x => x.gonderilen).ToList();
            var memSorular = MemnuniyetSorulari.Select(s =>
            {
                var l = memDolan.Select(f => Sayi(Bul(f.Cevap, s.kod))).OfType<decimal>().Where(v => v > 0).ToList();
                return new { soru = s.ad, cevap = l.Count, ortalama = l.Count > 0 ? Math.Round(l.Average(), 2) : (decimal?)null };
            }).ToList();

            // ---------------------------------------------------------- güvenli cerrahi --
            var amBu = ameliyatlar.Where(a => Donemde(a.zaman)).ToList();
            var amOnc = ameliyatlar.Where(a => Oncede(a.zaman)).ToList();
            static int Tam(IEnumerable<(DateTime zaman, int madde, int eksik)> l) => l.Count(a => a.madde > 0 && a.eksik == 0);

            // ------------------------------------------------------------ göstergeler --
            static string? Durum(decimal? sonuc, string yon, decimal? hedef) => sonuc is not { } s || hedef is not { } h || yon == "" ? null
                : yon switch { ">=" => s >= h, "<=" => s <= h, ">" => s > h, "<" => s < h, _ => true } ? "hedefte" : "disi";
            Kirilim Kir(string ad, decimal pay, decimal payda, string birimAdi, int carpan = 100) =>
                new(ad, pay, payda, birimAdi, Oran(pay, payda, carpan));
            GostergeSatiri Gosterge(string kod, string ad, string kaynak, string yon, decimal hedef, string birim, decimal pay, decimal payda,
                decimal? onceki, List<Kirilim>? kirilim = null, string not = "", int carpan = 100)
            {
                var sonuc = Oran(pay, payda, carpan);
                return new(kod, ad, kaynak, yon, hedef, birim, pay, payda, sonuc, onceki,
                    payda > 0 ? Durum(sonuc, yon, hedef) ?? "hedefsiz" : "veriyok", kirilim ?? [], not, true);
            }
            GostergeSatiri KaynakYok(string kod, string ad, string yon, decimal hedef, string birim, string not) =>
                new(kod, ad, "SKS", yon, hedef, birim, 0, 0, null, null, "kaynakyok", [], not, true);

            var labBu = bildBu.Where(x => x.Kaynak == 'L').ToList(); var radBu = bildBu.Where(x => x.Kaynak == 'R').ToList();
            var elToplam = elBu.Count; var elUyulan = elBu.Count(x => x.uydu);
            var gostergeler = new List<GostergeSatiri>
            {
                Gosterge("SKS.KB1", "Kritik / panik değerin hedef sürede bildirilme oranı", "SKS", ">=", 90, "%",
                    bildBu.Count(HedefteMi), bildBu.Count, Oran(bildOnc.Count(HedefteMi), bildOnc.Count),
                    [Kir("Lab", labBu.Count(HedefteMi), labBu.Count, "bildirim"), Kir("Rad", radBu.Count(HedefteMi), radBu.Count, "bildirim")]),
                Gosterge("SKS.HG1", "Yatan hastada düşme oranı (‰ hasta-gün)", "SKS", "<=", 2.5m, "‰",
                    servisBu.dusme, servisBu.hastaGun, Oran(servisOnc.dusme, servisOnc.hastaGun, 1000),
                    servisBu.satirlar.Select(s => Kir(s.Servis, s.Dusme, s.HastaGun, "düşme / hasta-gün", 1000)).ToList(),
                    "düşme = GRS bildirimi (tür düşme)", 1000),
                Gosterge("SKS.HG2", "Hastanede gelişen bası yarası oranı (Braden riskli)", "SKS", "<=", 5, "%",
                    servisBu.gelisen, servisBu.riskli, Oran(servisOnc.gelisen, servisOnc.riskli),
                    servisBu.satirlar.Select(s => Kir(s.Servis, s.Gelisen, s.BradenRiskli, "riskli")).ToList()),
                Gosterge("SKS.EH1", "El hijyeni uyum oranı (5 endikasyon)", "SKS", ">=", 85, "%", elUyulan, elToplam,
                    Oran(elOnc.Count(v => v), elOnc.Count),
                    elBu.GroupBy(x => x.meslek).Select(g => Kir(g.Key, g.Count(x => x.uydu), g.Count(), "fırsat")).ToList()),
                Gosterge("SKS.HM1", "Hasta memnuniyet oranı (4-5 puan)", "SKS", ">=", 85, "%",
                    memDolan.Count(f => Puan(f) >= 4), memDolan.Count, Oran(memOncDolan.Count(f => Puan(f) >= 4), memOncDolan.Count),
                    memDolan.GroupBy(Birim).Select(g => Kir(g.Key, g.Count(f => Puan(f) >= 4), g.Count(), "anket")).ToList()),
                KaynakYok("SKS.GR1", "Orta / ciddi GRS olayında kök neden analizi tamamlanma", ">=", 100, "%",
                    "olay takip / kök neden analizi kaydı yok - kalite modülü kurulunca dolar"),
                Gosterge("SKS.CG1", "Güvenli cerrahi kontrol listesi doldurulma oranı", "SKS", ">=", 100, "%",
                    Tam(amBu), amBu.Count, Oran(Tam(amOnc), amOnc.Count), null, "biten ameliyatta DSÖ listesinin bütün maddeleri işaretli"),
                KaynakYok("SKS.HK1", "Kimlik bilekliği takılı yatan hasta oranı (gözlem)", ">=", 100, "%", "bileklik gözlem kaydı yok"),
                KaynakYok("SKS.IU1", "Yatışta ilaç uzlaştırması yapılan hasta oranı", ">=", 90, "%", "ilaç uzlaştırma kaydı yok"),
            };

            // Klinik göstergeler: başlangıç tarihini kapsayan periyot; trend = önceki periyot.
            static DateTime PerBas(short yil, short no, short per) => new DateTime(yil, 1, 1).AddMonths((no - 1) * per);
            var ilkSube = klinikHam.GroupBy(k => (k.gid, k.periyot, k.yil, k.no)).Select(g => g.OrderByDescending(x => x.subeId).First()).ToList();
            var klinikOlculmeyen = 0;
            foreach (var g in ilkSube.GroupBy(k => k.gid))
            {
                var bu = g.Where(k => PerBas(k.yil, k.no, k.periyot) <= baslangic && baslangic < PerBas(k.yil, k.no, k.periyot).AddMonths(k.periyot))
                          .OrderBy(k => k.periyot).FirstOrDefault();
                if (bu.kod is null) continue;
                if (bu.payda <= 0) { klinikOlculmeyen++; continue; }
                var bas0 = PerBas(bu.yil, bu.no, bu.periyot);
                var onc = g.FirstOrDefault(k => k.periyot == bu.periyot && PerBas(k.yil, k.no, k.periyot).AddMonths(k.periyot) == bas0);
                var birim = bu.birim == "yuzde" ? "%" : bu.birim;
                gostergeler.Add(new(bu.kod, bu.ad, "Klinik", bu.yon, bu.hedef, birim, bu.pay, bu.payda, Math.Round(bu.sonuc, 1),
                    onc.kod is not null && onc.payda > 0 ? Math.Round(onc.sonuc, 1) : null, Durum(bu.sonuc, bu.yon, bu.hedef) ?? "hedefsiz", [],
                    $"{bu.yil} / {bu.no}. dönem ({bu.periyot} aylık){(bu.kesin ? "" : " · kesinleşmedi")}", bu.kesin));
            }

            var gDurumlar = gostergeler.Select(x => x.Durum).ToList();
            var bildSure = bildBu.Select(Sure).OfType<int>().ToList();
            var ozet = new
            {
                gosterge = gDurumlar.Count(d => d is "hedefte" or "disi"), hedefte = gDurumlar.Count(d => d == "hedefte"),
                hedefDisi = gDurumlar.Count(d => d == "disi"), kaynakYok = gDurumlar.Count(d => d == "kaynakyok"),
                veriYok = gDurumlar.Count(d => d == "veriyok"), klinikOlculmeyen,
                bildirim = bildBu.Count, bildirimHedefte = bildBu.Count(HedefteMi), bildirimOran = Oran(bildBu.Count(HedefteMi), bildBu.Count),
                bildirimAsan = bildBu.Count(x => !HedefteMi(x)), ortSure = Ort(bildSure),
                labOrt = Ort(labBu.Select(Sure).OfType<int>()), radOrt = Ort(radBu.Select(Sure).OfType<int>()), panikHedef, kritikHedef,
                grs = grsBu.Count, grsCiddi = grsBu.Count(g => g.zarar is 3 or 4), grsOnceki = grsOnc.Count,
                dusme = servisBu.dusme, dusmeBinde = Oran(servisBu.dusme, servisBu.hastaGun, 1000), hastaGun = servisBu.hastaGun, eslesmeyenDusme,
                basi = servisBu.gelisen, bradenRiskli = servisBu.riskli, basiOran = Oran(servisBu.gelisen, servisBu.riskli),
                elFirsat = elToplam, elUyulan, elOran = Oran(elUyulan, elToplam),
                anketGonderilen = memBu.Count, anket = memDolan.Count, memnun = memDolan.Count(f => Puan(f) >= 4),
                memnuniyetOran = Oran(memDolan.Count(f => Puan(f) >= 4), memDolan.Count),
                ortPuan = memDolan.Count > 0 ? Math.Round(memDolan.Average(f => Puan(f)!.Value), 2) : (decimal?)null,
                ameliyat = amBu.Count, cerrahiTam = Tam(amBu),
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun, oncekiBas = oncBas, oncekiBit = baslangic.AddDays(-1) }, ozet, gostergeler,
                bildirimKaynaklari, bildirimler = bildirimListe, zararAdlari = ZararAdlari, grsMatris, grsOlaylar = grsListe,
                servisler = servisBu.satirlar, elMeslek, elEndikasyon, memnuniyetBirim = memBirim, memnuniyetSorular = memSorular,
            });
        });
    }

    // ------------------------------------------------------------ form cevabı okuma --
    //  Cevap bölüm koduna göre iç içe olabilir ({"olay": {"tur": ...}}) ya da düz;
    //  alan kodu ağaçta ilk bulunduğu yerden okunur.
    private static JsonElement? Bul(JsonElement e, string anahtar)
    {
        if (e.ValueKind != JsonValueKind.Object) return null;
        foreach (var p in e.EnumerateObject()) if (p.Name == anahtar) return p.Value;
        foreach (var p in e.EnumerateObject()) if (Bul(p.Value, anahtar) is { } x) return x;
        return null;
    }

    private static string Metin(JsonElement? e) => e is not { } x ? "" : x.ValueKind switch
    {
        JsonValueKind.String => (x.GetString() ?? "").Trim(), JsonValueKind.Number => x.GetRawText(),
        JsonValueKind.True => "Evet", JsonValueKind.False => "Hayır", _ => "",
    };

    private static decimal? Sayi(JsonElement? e) => e is not { } x ? null
        : x.ValueKind == JsonValueKind.Number && x.TryGetDecimal(out var d) ? d
        : x.ValueKind == JsonValueKind.String && decimal.TryParse(x.GetString(), NumberStyles.Number, CultureInfo.InvariantCulture, out var s) ? s : null;

    private static bool Evet(JsonElement? e) => Metin(e).ToLowerInvariant() is "evet" or "true" or "1" or "var";
}
