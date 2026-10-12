using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İSG / OSGB İCMALİ (mockup Ekranlar/İcmal/isg_osgb_icmali.html,
/// kullanıcı 12.10.2026: "icmalleri yap").
///
/// <para><b>Hizmet süresi:</b> plan = fn_isg_aylik_dk (sözleşme dakikası, yoksa
/// çalışan × tehlike katsayısı) × dönemin ay oranı (gün / ayın günü, ay ay);
/// gerçekleşen = dönemdeki ziyaret süresi (isg_ziyaret.sure_dk) + tamamlanmış
/// Ek-2 muayene süresi (isg_muayene.sure_dk, durum 2). Karşılama &lt; %100 = mevzuat açığı.</para>
///
/// <para><b>Geciken periyodik</b> = aktif çalışanın vadesi (v_isg_calisan.vade:
/// hekim sonraki tarihi, yoksa son muayene + fn_isg_periyot_ay) bugünden önce.
/// Dönemden bağımsız, BUGÜN itibarıyla.</para>
///
/// <para><b>Olay:</b> iş kazası ve meslek hastalığı şüphesinde SGK bildirimi
/// olaydan sonra 3 iş günü içinde (hafta sonu atlanır; resmî tatil tablosu
/// yok); bildirilmemiş ve süresi geçmiş olan da geç sayılır. Ramak kala
/// bildirim gerektirmez.</para>
///
/// <para><b>Hizmet bedeli:</b> aylık bedel firma kartından (1044 isg_firma.aylik_ucret);
/// devreden / faturalanan / tahsil / bakiye firmanın CARİSİNDEN (v_cari_ekstre,
/// yerel tutar): devreden = dönem öncesi bakiye, faturalanan = dönemdeki
/// belge hareketleri (net), tahsil = dönemdeki tahsilatlar (net), bakiye =
/// dönem sonu bakiyesi. Firma ↔ fatura bağı yok; cari üzerinden bulunur.</para>
///
/// <para>Çalışan adı yalnız ekrandaki geciken muayene ve olay listelerinde;
/// TC hiçbir yerde yok, A4'te çalışan bilgisi basılmaz.</para>
/// </summary>
public static class IsgIcmalUclari
{
    /// <summary>Ekran kodu (1044) - haklarını isg.pano'dan kopyalar.</summary>
    private const string Kod = "isg.icmal";

    private static readonly Dictionary<short, string> Tehlikeler = new()
    {
        [1] = "Az tehlikeli", [2] = "Tehlikeli", [3] = "Çok tehlikeli",
    };
    private static readonly Dictionary<short, string> ZiyaretTurleri = new()
    {
        [1] = "Saha ziyareti", [2] = "İSG kurulu", [3] = "Eğitim", [4] = "Aşı kampanyası", [5] = "Saha muayene günü",
    };
    private static readonly Dictionary<short, string> OlayTurleri = new()
    {
        [1] = "İş kazası", [2] = "Meslek hastalığı şüphesi", [3] = "Ramak kala",
    };

    /// <summary>Olaydan sonra n iş günü (Cumartesi / Pazar atlanır).</summary>
    internal static DateTime IsGunuEkle(DateTime gun, int n)
    {
        var d = gun.Date;
        while (n > 0)
        {
            d = d.AddDays(1);
            if (d.DayOfWeek is not (DayOfWeek.Saturday or DayOfWeek.Sunday)) n--;
        }
        return d;
    }

    /// <summary>Dönemin ay oranı: her ayın kapsanan gün / o ayın gün sayısı toplamı.</summary>
    internal static decimal AyOrani(DateTime bas, DateTime sonGun)
    {
        decimal t = 0;
        for (var ay = new DateTime(bas.Year, bas.Month, 1); ay <= sonGun; ay = ay.AddMonths(1))
        {
            var ayBit = ay.AddMonths(1).AddDays(-1);
            var b = bas > ay ? bas : ay;
            var s = sonGun < ayBit ? sonGun : ayBit;
            if (s >= b) t += (decimal)((s - b).TotalDays + 1) / DateTime.DaysInMonth(ay.Year, ay.Month);
        }
        return t;
    }

    public static void IsgIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/isg-icmal").WithTags("İSG / OSGB İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, int? hekim, short? tehlike, string? firmalar,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var bugun = DateTime.Today;
            var sube = baglam.SubeId ?? 0;
            var secim = (firmalar ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(x => int.TryParse(x, out var i) ? i : 0).Where(i => i > 0).ToHashSet();
            var ayOrani = AyOrani(baslangic, sonGun);
            await using var b = await veri.AcAsync(iptal);

            // ------------------------------------------------------------ firmalar --
            var tumFirmalar = await b.ListeAsync("""
                select f.id, f.taraf_id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''),
                       coalesce(f.nace, ''), coalesce(f.nace_ad, ''), coalesce(f.tehlike, 2)::smallint, coalesce(f.hekim_id, 0),
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''),
                       greatest(f.calisan_sayisi, (select count(*) from public.isg_calisan c where c.firma_id = f.id and c.durum = 1))::int,
                       coalesce(public.fn_isg_aylik_dk(f.id), 0), f.sozlesme_bit, coalesce(f.aylik_ucret, 0)
                  from public.isg_firma f
                  join public.taraf t on t.id = f.taraf_id
                  left join public.taraf h on h.id = f.hekim_id
                 where f.durum = 1 and (@p0 = 0 or coalesce(f.sube_id, 0) in (0, @p0))
                 order by 3
                """, null, [sube], o => (id: o.GetInt32(0), taraf: o.GetInt32(1), ad: o.GetString(2), nace: o.GetString(3), naceAd: o.GetString(4),
                    tehlike: o.GetInt16(5), hekimId: o.GetInt32(6), hekim: o.GetString(7), calisan: o.GetInt32(8), aylikDk: o.GetInt32(9),
                    sozlesmeBit: o.IsDBNull(10) ? (DateTime?)null : o.GetDateTime(10), aylikUcret: o.GetDecimal(11)), iptal);
            var hekimAdlari = tumFirmalar.Where(f => f.hekimId > 0).GroupBy(f => f.hekimId)
                .Select(g => new { id = g.Key, ad = g.First().hekim }).OrderBy(x => x.ad).ToList();
            var kume = tumFirmalar.Where(f => (hekim is not > 0 || f.hekimId == hekim) && (tehlike is not > 0 || f.tehlike == tehlike)
                                              && (secim.Count == 0 || secim.Contains(f.id))).ToList();
            var idler = kume.Select(f => f.id).ToArray();

            var bolumler = await b.ListeAsync("""
                select fb.id, fb.firma_id, coalesce(fb.ad, ''),
                       coalesce((select string_agg(kd.ad, ' · ' order by kd.sira)
                                   from jsonb_array_elements_text(coalesce(nullif(fb.maruziyet, '')::jsonb, '[]'::jsonb)) x(v)
                                   join public.kod_liste kl on kl.kod = 'isg.maruziyet'
                                   join public.kod_deger kd on kd.liste_id = kl.id and kd.deger::text = x.v), ''),
                       (select count(*) from public.isg_calisan c where c.bolum_id = fb.id and c.durum = 1)::int,
                       coalesce(nullif(fb.periyot_ay, 0), case f.tehlike when 1 then 60 when 2 then 36 else 12 end)::int
                  from public.isg_firma_bolum fb
                  join public.isg_firma f on f.id = fb.firma_id
                 where fb.firma_id = any(@p0)
                 order by fb.firma_id, fb.ad
                """, null, [idler], o => (id: o.GetInt32(0), firma: o.GetInt32(1), ad: o.GetString(2), maruziyet: o.GetString(3),
                    calisan: o.GetInt32(4), periyotAy: o.GetInt32(5)), iptal);

            // ----------------------------------------------- muayene / ziyaret / olay --
            var muayeneler = await b.ListeAsync("""
                select m.firma_id, coalesce(m.tur, 2)::smallint, coalesce(m.kanaat, 0)::smallint, coalesce(m.durum, 1)::smallint, coalesce(m.sure_dk, 0)::int
                  from public.isg_muayene m
                 where m.firma_id = any(@p0) and m.tarih >= @p1::date and m.tarih < @p2::date and coalesce(m.durum, 1) <> 3
                """, null, [idler, baslangic, bitis], o => (firma: o.GetInt32(0), tur: o.GetInt16(1), kanaat: o.GetInt16(2),
                    durum: o.GetInt16(3), sure: o.GetInt32(4)), iptal);
            var geciken = await b.ListeAsync("""
                select c.id, coalesce(c.calisan_adi, ''), c.firma_id, coalesce(c.bolum_id, 0), coalesce(c.bolum_adi, ''),
                       coalesce(c.tehlike_adi, ''), c.son_muayene, c.vade
                  from public.v_isg_calisan c
                 where c.durum = 1 and c.firma_id = any(@p0) and c.vade < @p1::date
                 order by c.vade, c.id
                """, null, [idler, bugun], o => (id: o.GetInt32(0), ad: o.GetString(1), firma: o.GetInt32(2), bolumId: o.GetInt32(3),
                    bolum: o.GetString(4), tehlike: o.GetString(5), son: o.IsDBNull(6) ? (DateTime?)null : o.GetDateTime(6),
                    vade: o.GetDateTime(7)), iptal);
            var ziyaretler = await b.ListeAsync("""
                select z.id, z.tarih, z.firma_id, coalesce(z.tur, 1)::smallint,
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''), coalesce(z.sure_dk, 0),
                       coalesce(z.imza_hekim, 0) = 1 and coalesce(z.imza_isveren, 0) = 1, coalesce(z.defter_sayfa, '')
                  from public.isg_ziyaret z
                  left join public.taraf h on h.id = z.hekim_id
                 where z.firma_id = any(@p0) and z.tarih >= @p1::date and z.tarih < @p2::date
                 order by z.tarih, z.id
                """, null, [idler, baslangic, bitis], o => (id: o.GetInt32(0), tarih: o.GetDateTime(1), firma: o.GetInt32(2), tur: o.GetInt16(3),
                    hekim: o.GetString(4), sure: o.GetInt32(5), imzali: o.GetBoolean(6), sayfa: o.GetString(7)), iptal);
            var olaylar = await b.ListeAsync("""
                select o.id, o.tarih, coalesce(o.tur, 1)::smallint, o.firma_id,
                       coalesce(nullif(c.bolum_adi, ''), nullif(o.yer, ''), ''), coalesce(c.calisan_adi, ''),
                       coalesce(o.yaralanma, ''), coalesce(o.gun_kaybi, 0), o.sgk_bildirim, coalesce(o.durum, 1)::smallint
                  from public.isg_olay o
                  left join public.v_isg_calisan c on c.id = o.calisan_id
                 where o.firma_id = any(@p0) and o.tarih >= @p1 and o.tarih < @p2
                 order by o.tarih, o.id
                """, null, [idler, baslangic, bitis], o => (id: o.GetInt32(0), tarih: o.GetDateTime(1), tur: o.GetInt16(2), firma: o.GetInt32(3),
                    bolum: o.GetString(4), calisan: o.GetString(5), yaralanma: o.GetString(6), gunKaybi: o.GetInt32(7),
                    sgk: o.IsDBNull(8) ? (DateTime?)null : o.GetDateTime(8), durum: o.GetInt16(9)), iptal);

            // ------------------------------------------------------------- cari --
            var cariler = await b.ListeAsync("""
                select e.taraf_id,
                       coalesce(sum(case when e.islem_tarihi < @p1 then coalesce(e.yerel_borc, 0) - coalesce(e.yerel_alacak, 0) end), 0),
                       coalesce(sum(case when e.islem_tarihi >= @p1 and e.tur_grup = 'belge'
                                         then coalesce(e.yerel_borc, 0) - coalesce(e.yerel_alacak, 0) end), 0),
                       coalesce(sum(case when e.islem_tarihi >= @p1 and e.tur_grup = 'tahsilat'
                                         then coalesce(e.yerel_alacak, 0) - coalesce(e.yerel_borc, 0) end), 0),
                       coalesce(sum(coalesce(e.yerel_borc, 0) - coalesce(e.yerel_alacak, 0)), 0)
                  from public.v_cari_ekstre e
                 where e.taraf_id = any(@p0) and e.bakiye_dahil = 1 and e.islem_tarihi < @p2
                   and (@p3 = 0 or coalesce(e.sube_id, 0) in (0, @p3))
                 group by e.taraf_id
                """, null, [kume.Select(f => f.taraf).Distinct().ToArray(), baslangic, bitis, sube], o => (taraf: o.GetInt32(0),
                    devreden: o.GetDecimal(1), fatura: o.GetDecimal(2), tahsil: o.GetDecimal(3), bakiye: o.GetDecimal(4)), iptal);
            var cari = cariler.ToDictionary(c => c.taraf);

            // ------------------------------------------------------------ hesaplar --
            static decimal? Oran(decimal pay, decimal payda) => payda > 0 ? Math.Round(100m * pay / payda, 1) : null;
            bool SgkGec(short tur, DateTime tarih, DateTime? sgk)
            {
                if (tur == 3) return false;
                var son = IsGunuEkle(tarih, 3);
                return sgk is { } s ? s.Date > son : bugun > son;
            }
            var firmaAd = kume.ToDictionary(f => f.id, f => f.ad);

            var firmaListe = kume.Select(f =>
            {
                var m = muayeneler.Where(x => x.firma == f.id).ToList();
                var z = ziyaretler.Where(x => x.firma == f.id).ToList();
                var ziyaretDk = z.Sum(x => x.sure);
                var muayeneDk = m.Where(x => x.durum == 2).Sum(x => x.sure);
                var plan = (int)Math.Round(f.aylikDk * ayOrani);
                var gercek = ziyaretDk + muayeneDk;
                var g = geciken.Where(x => x.firma == f.id).ToList();
                return new
                {
                    f.id, f.ad, f.nace, f.naceAd, f.tehlike, tehlikeAdi = Tehlikeler.GetValueOrDefault(f.tehlike, ""), f.calisan, f.hekim,
                    planDk = plan, gercekDk = gercek, ziyaret = z.Count, ziyaretDk, muayeneDk, karsilama = Oran(gercek, plan),
                    sureEksik = plan > gercek ? plan - gercek : 0,
                    muayene = m.Count, geciken = g.Count, kaza = olaylar.Count(o => o.firma == f.id && o.tur == 1),
                    bolumler = bolumler.Where(x => x.firma == f.id).Select(x => new
                    {
                        x.ad, x.maruziyet, x.calisan, x.periyotAy, geciken = g.Count(c => c.bolumId == x.id),
                    }).ToList(),
                };
            }).ToList();

            var muayeneListe = kume.Select(f =>
            {
                var m = muayeneler.Where(x => x.firma == f.id).ToList();
                return new
                {
                    f.id, f.ad,
                    iseGiris = m.Count(x => x.tur == 1), periyodik = m.Count(x => x.tur == 2), iseDonus = m.Count(x => x.tur == 3),
                    erkenKontrol = m.Count(x => x.tur == 4), isDegisikligi = m.Count(x => x.tur == 5), toplam = m.Count,
                    calisir = m.Count(x => x.kanaat == 1), kosullu = m.Count(x => x.kanaat == 2), calisamaz = m.Count(x => x.kanaat == 3),
                    bekliyor = m.Count(x => x.kanaat == 0), sureDk = m.Where(x => x.durum == 2).Sum(x => x.sure),
                };
            }).Where(x => x.toplam > 0).ToList();
            var muayeneToplam = new
            {
                iseGiris = muayeneListe.Sum(x => x.iseGiris), periyodik = muayeneListe.Sum(x => x.periyodik), iseDonus = muayeneListe.Sum(x => x.iseDonus),
                erkenKontrol = muayeneListe.Sum(x => x.erkenKontrol), isDegisikligi = muayeneListe.Sum(x => x.isDegisikligi),
                toplam = muayeneListe.Sum(x => x.toplam), calisir = muayeneListe.Sum(x => x.calisir), kosullu = muayeneListe.Sum(x => x.kosullu),
                calisamaz = muayeneListe.Sum(x => x.calisamaz), bekliyor = muayeneListe.Sum(x => x.bekliyor), sureDk = muayeneListe.Sum(x => x.sureDk),
            };

            var gecikenListe = geciken.Select(c => new
            {
                c.id, c.ad, firma = firmaAd.GetValueOrDefault(c.firma, ""), c.bolum, c.tehlike, sonMuayene = c.son, c.vade,
                gecikmeGun = (int)(bugun - c.vade.Date).TotalDays,
            }).OrderByDescending(x => x.gecikmeGun).ToList();

            var ziyaretListe = ziyaretler.Select(z => new
            {
                z.id, z.tarih, firma = firmaAd.GetValueOrDefault(z.firma, ""), tur = ZiyaretTurleri.GetValueOrDefault(z.tur, "Diğer"),
                z.hekim, sureDk = z.sure, z.imzali, defterSayfa = z.sayfa,
            }).ToList();
            var sureListe = firmaListe.Where(f => f.ziyaret > 0 || f.muayeneDk > 0 || f.planDk > 0).Select(f => new
            {
                f.id, f.ad, f.ziyaret, f.ziyaretDk, f.muayeneDk, toplamDk = f.gercekDk, f.planDk, eksikDk = f.sureEksik,
            }).ToList();

            var olayListe = olaylar.Select(o => new
            {
                o.id, o.tarih, o.tur, turAdi = OlayTurleri.GetValueOrDefault(o.tur, "Diğer"), firma = firmaAd.GetValueOrDefault(o.firma, ""),
                o.bolum, o.calisan, o.yaralanma, o.gunKaybi, sgkBildirim = o.sgk, bildirimGerekir = o.tur != 3,
                sgkSon = o.tur != 3 ? IsGunuEkle(o.tarih, 3) : (DateTime?)null, sgkGec = SgkGec(o.tur, o.tarih, o.sgk), acik = o.durum == 1,
            }).ToList();

            var hizmetListe = kume.Select(f =>
            {
                cari.TryGetValue(f.taraf, out var c);
                var kalan = f.sozlesmeBit is { } sb ? (int)(sb.Date - bugun).TotalDays : (int?)null;
                return new
                {
                    f.id, f.ad, aylikUcret = f.aylikUcret, devreden = c.devreden, faturalanan = c.fatura, tahsil = c.tahsil, bakiye = c.bakiye,
                    tahsilDurumu = c.fatura <= 0 && c.devreden <= 0 ? "Fatura yok" : c.bakiye <= 0 ? "Tahsil edildi" : c.tahsil > 0 ? "Kısmi" : "Bekliyor",
                    sozlesmeBit = f.sozlesmeBit, kalanGun = kalan,
                };
            }).OrderBy(x => x.kalanGun ?? int.MaxValue).ToList();
            var hizmetToplam = new
            {
                aylikUcret = hizmetListe.Sum(x => x.aylikUcret), devreden = hizmetListe.Sum(x => x.devreden),
                faturalanan = hizmetListe.Sum(x => x.faturalanan), tahsil = hizmetListe.Sum(x => x.tahsil), bakiye = hizmetListe.Sum(x => x.bakiye),
            };

            var planT = firmaListe.Sum(f => f.planDk);
            var gercekT = firmaListe.Sum(f => f.gercekDk);
            var ozet = new
            {
                firma = firmaListe.Count, calisan = firmaListe.Sum(f => f.calisan), cokTehlikeli = firmaListe.Count(f => f.tehlike == 3),
                hekim = kume.Where(f => f.hekimId > 0).Select(f => f.hekimId).Distinct().Count(),
                planDk = planT, gercekDk = gercekT, karsilama = Oran(gercekT, planT), sureEksikFirma = firmaListe.Count(f => f.sureEksik > 0),
                sureEksikDk = firmaListe.Sum(f => f.sureEksik),
                muayene = muayeneToplam.toplam, iseGiris = muayeneToplam.iseGiris, periyodik = muayeneToplam.periyodik,
                muayeneDk = muayeneToplam.sureDk,
                geciken = gecikenListe.Count, geciken90 = gecikenListe.Count(g => g.gecikmeGun >= 90),
                ziyaret = ziyaretListe.Count, ziyaretDk = ziyaretListe.Sum(z => z.sureDk), imzaEksik = ziyaretListe.Count(z => !z.imzali),
                kaza = olayListe.Count(o => o.tur == 1), meslekHastaligi = olayListe.Count(o => o.tur == 2), ramakKala = olayListe.Count(o => o.tur == 3),
                gunKaybi = olayListe.Sum(o => o.gunKaybi), sgkGec = olayListe.Count(o => o.sgkGec), acikOlay = olayListe.Count(o => o.acik),
                faturalanan = hizmetToplam.faturalanan, tahsil = hizmetToplam.tahsil, bakiye = hizmetToplam.bakiye,
                sozlesme60 = hizmetListe.Count(h => h.kalanGun is >= 0 and <= 60),
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun }, bugun, ozet, firmalar = firmaListe,
                muayeneler = muayeneListe, muayeneToplam, geciken = gecikenListe,
                ziyaretler = ziyaretListe, sureler = sureListe, olaylar = olayListe,
                hizmet = hizmetListe, hizmetToplam,
                hekimAdlari, secimli = secim.Count > 0,
            });
        });
    }
}
