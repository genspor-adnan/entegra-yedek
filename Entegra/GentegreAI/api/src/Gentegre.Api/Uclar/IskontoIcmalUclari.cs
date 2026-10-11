using Gentegre.Api.AraKatman;
using Gentegre.Cekirdek.Sozlesme;
using Gentegre.Cekirdek.Yetki;
using Gentegre.Veri;

namespace Gentegre.Api.Uclar;

/// <summary>
/// İSKONTO VE ÜCRETSİZ HİZMET İCMALİ (mockup Ekranlar/İcmal/iskonto_icmali.html,
/// kullanıcı 10.10.2026: "iskonto İcmali ayrı olsun", "iskonto icmalini kodla").
///
/// Dönemde VERİLEN BÜTÜN iskontolar - yalnız onaylanan talepler değil:
///   talep    : satırda onaylı iskonto talebi var (iskonto_talep durum 1)
///   kampanya : satır bir kampanyadan (kampanya_satir_id)
///   banko    : ikisi de değil - bankonun onay eşiği içinde kendi verdiği
/// İskonto tutarı = satırın adet x birim fiyatı - tutarı (Doktor Performans
/// İcmali ile AYNI formül; iki ekran aynı dönem için aynı rakamı söyler).
/// Ücretsiz hizmet = liste tutarı olup tutarı sıfırlanan satır.
///
/// DENETİM: talepsiz (banko) iskontonun oranı onay eşiğini
/// (basvuru.iskonto_onay_esik) aşıyorsa işaretlenir - onay akışı atlanmış
/// olabilir. Reddedilen talepler toplamlara girmez, ayrı sayılır.
/// Yalnız gerçek başvuru (tür 19), iptal (6) hariç. Yalnız OKUR.
/// </summary>
public static class IskontoIcmalUclari
{
    /// <summary>Ekran kodu (1023) - haklarını iskonto_onay'dan kopyalar.</summary>
    private const string Kod = "iskonto.icmal";

    private sealed record Satir(int BelgeId, string ProtokolNo, DateTime Tarih, int HastaId, string Hasta,
        string Bolum, string Hekim, string Hizmet, decimal Liste, decimal Iskonto, decimal Tutar, string Kaynak,
        int? TalepId, string Gerekce, string Isteyen, string Onaylayan, string Banko);

    public static void IskontoIcmalUclariniEkle(this IEndpointRouteBuilder yol)
    {
        var grup = yol.MapGroup("/api/iskonto-icmal").WithTags("İskonto İcmali").RequireAuthorization();

        grup.MapGet("/", async (DateTime? bas, DateTime? bit, string? kaynak, int? bolum,
                                VeriKaynagi veri, BaglamCozucu cozucu, HttpContext ctx, CancellationToken iptal) =>
        {
            var baglam = await cozucu.CozAsync(ctx, iptal);
            baglam.YetkiIste(Kod, Islem.Gor);
            var buAy = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            var baslangic = (bas ?? buAy.AddMonths(-1)).Date;
            var sonGun = (bit ?? buAy.AddDays(-1)).Date;
            if (sonGun < baslangic) sonGun = baslangic;
            var bitis = sonGun.AddDays(1);
            var sube = baglam.SubeId ?? 0;
            await using var b = await veri.AcAsync(iptal);
            var esik = await b.TekDegerAsync<decimal?>(
                "select nullif(deger, '')::numeric from public.referans where anahtar = 'basvuru.iskonto_onay_esik'",
                null, [], iptal) ?? 10m;

            var tum = await b.ListeAsync("""
                select be.id, coalesce(be.belge_no, ''), be.belge_tarihi, coalesce(bb.hasta_id, be.taraf_id, 0),
                       coalesce(public.fn_taraf_ad(h.unvan, h.ad, h.soyad)::varchar(120), ''),
                       coalesce(d.ad, ''), coalesce(public.fn_taraf_ad(hk.unvan, hk.ad, hk.soyad)::varchar(120), ''),
                       coalesce(hz.ad, sk.ad, st.aciklama, ''),
                       round(st.adet * st.birim_fiyat, 2), round(greatest(st.adet * st.birim_fiyat - st.tutar, 0), 2), st.tutar,
                       case when t.id is not null then 'talep' when st.kampanya_satir_id is not null then 'kampanya' else 'banko' end,
                       t.id, coalesce(t.gerekce, ''),
                       coalesce(public.fn_taraf_ad(ti.unvan, ti.ad, ti.soyad)::varchar(120), ''),
                       coalesce(public.fn_taraf_ad(tn.unvan, tn.ad, tn.soyad)::varchar(120), ''),
                       -- Banko görevlisi = başvuruyu açan kullanıcı.
                       coalesce(public.fn_taraf_ad(bk.unvan, bk.ad, bk.soyad)::varchar(120), '')
                  from public.belge be
                  join public.belge_basvuru bb on bb.id = be.id
                  join public.belge_satir st on st.belge_id = be.id
                  left join public.taraf h  on h.id  = coalesce(bb.hasta_id, be.taraf_id)
                  left join public.taraf hk on hk.id = bb.personel_id
                  left join public.taraf bk on bk.id = be.ekleyen
                  left join public.departman d on d.id = bb.bolum_id
                  left join public.hizmet hz on hz.id = st.hizmet_id
                  left join public.stok sk on sk.id = st.stok_id
                  -- Satırın ONAYLI talebi (en son karar).
                  left join lateral (
                      select it.id, it.gerekce, it.isteyen_id, it.onay_id
                        from public.iskonto_talep_satir its
                        join public.iskonto_talep it on it.id = its.talep_id
                       where its.belge_satir_id = st.id and it.durum = 1
                       order by it.onay_ts desc nulls last, it.id desc limit 1) t on true
                  left join public.taraf ti on ti.id = t.isteyen_id
                  left join public.taraf tn on tn.id = t.onay_id
                 where be.tipi = 30 and be.tur = 19 and be.durum <> 6
                   and be.belge_tarihi >= @p0 and be.belge_tarihi < @p1
                   and (@p2 = 0 or coalesce(be.sube_id, 0) in (0, @p2))
                   and (@p3 = 0 or bb.bolum_id = @p3)
                   and st.adet * st.birim_fiyat - st.tutar > 0.005
                 order by be.belge_tarihi, be.id, st.id
                """, null, [baslangic, bitis, sube, bolum ?? 0], o => new Satir(
                    o.GetInt32(0), o.GetString(1), o.GetDateTime(2), o.GetInt32(3), o.GetString(4), o.GetString(5),
                    o.GetString(6), o.GetString(7), o.GetDecimal(8), o.GetDecimal(9), o.GetDecimal(10), o.GetString(11),
                    o.IsDBNull(12) ? null : o.GetInt32(12), o.GetString(13), o.GetString(14), o.GetString(15),
                    o.GetString(16)), iptal);
            var satirlar = tum.Where(x => kaynak is null or "" or "hepsi" || x.Kaynak == kaynak).ToList();

            // Reddedilen talepler: toplamlara girmez, istenen tutarla ayrı sayılır.
            var redler = await b.ListeAsync("""
                select it.id, coalesce(be.belge_no, ''), it.istek_ts, coalesce(it.gerekce, ''),
                       coalesce(public.fn_taraf_ad(ti.unvan, ti.ad, ti.soyad)::varchar(120), ''),
                       coalesce(public.fn_taraf_ad(tn.unvan, tn.ad, tn.soyad)::varchar(120), ''),
                       it.oran,
                       coalesce((select sum(round(st.adet * its.birim_fiyat * its.oran / 100, 2))
                                   from public.iskonto_talep_satir its
                                   join public.belge_satir st on st.id = its.belge_satir_id
                                  where its.talep_id = it.id), 0),
                       coalesce(it.karar_notu, '')
                  from public.iskonto_talep it
                  join public.belge be on be.id = it.belge_id
                  left join public.taraf ti on ti.id = it.isteyen_id
                  left join public.taraf tn on tn.id = it.onay_id
                 where it.durum = 2 and be.belge_tarihi >= @p0 and be.belge_tarihi < @p1
                   and (@p2 = 0 or coalesce(be.sube_id, 0) in (0, @p2))
                 order by it.istek_ts
                """, null, [baslangic, bitis, sube], o => new
            {
                id = o.GetInt32(0), protokolNo = o.GetString(1), tarih = o.IsDBNull(2) ? (DateTime?)null : o.GetDateTime(2),
                gerekce = o.GetString(3), isteyen = o.GetString(4), reddeden = o.GetString(5), oran = o.GetDecimal(6),
                istenen = o.GetDecimal(7), not = o.GetString(8),
            }, iptal);

            // Dönem cirosu (ciroya oranı için) - Doktor Performans İcmali ile aynı küme.
            var ciro = await b.TekDegerAsync<decimal?>("""
                select coalesce(sum(be.genel_toplam), 0) from public.belge be
                  join public.belge_basvuru bb on bb.id = be.id
                 where be.tipi = 30 and be.tur = 19 and be.durum <> 6
                   and be.belge_tarihi >= @p0 and be.belge_tarihi < @p1
                   and (@p2 = 0 or coalesce(be.sube_id, 0) in (0, @p2))
                   and (@p3 = 0 or bb.bolum_id = @p3)
                """, null, [baslangic, bitis, sube, bolum ?? 0], iptal) ?? 0m;

            static string Kategori(string g) => (g.Split('—')[0] is { Length: > 0 } a ? a : "(belirtilmemiş)").Trim();
            var ucretsiz = satirlar.Where(x => x.Tutar <= 0.005m && x.Liste > 0).ToList();
            var iskontolu = satirlar.Where(x => !(x.Tutar <= 0.005m && x.Liste > 0)).ToList();

            // Başvuru başına (İskontolar sekmesi): kaynak satırların ağırlığına göre.
            var basvurular = iskontolu.GroupBy(x => x.BelgeId).Select(g =>
            {
                var f = g.First();
                var liste = g.Sum(x => x.Liste); var isk = g.Sum(x => x.Iskonto);
                var oran = liste > 0 ? Math.Round(100 * isk / liste, 1) : 0m;
                var kaynaklar = g.Select(x => x.Kaynak).Distinct().ToList();
                var talepli = g.FirstOrDefault(x => x.Kaynak == "talep");
                var esikUstu = g.Any(x => x.Kaynak == "banko" && x.Liste > 0 && 100 * x.Iskonto / x.Liste > esik + 0.05m);
                return new
                {
                    belgeId = g.Key, f.ProtokolNo, tarih = f.Tarih, f.HastaId, f.Hasta, f.Bolum, f.Hekim,
                    kaynak = kaynaklar.Count == 1 ? kaynaklar[0] : "karma",
                    isteyen = talepli?.Isteyen is { Length: > 0 } i ? i : f.Banko,
                    onaylayan = talepli?.Onaylayan ?? "",
                    gerekce = talepli?.Gerekce is { Length: > 0 } gr ? gr
                            : kaynaklar.Contains("kampanya") ? "Kampanya" : "Banko (talepsiz)",
                    liste, iskonto = isk, oran, esikUstu,
                    kalemler = g.Select(x => new { x.Hizmet, x.Liste, x.Iskonto, x.Kaynak }),
                };
            }).OrderBy(x => x.tarih).ToList();

            object Gruplu(IEnumerable<IGrouping<string, Satir>> gr) => gr.Select(g => new
            {
                ad = g.Key, basvuru = g.Select(x => x.BelgeId).Distinct().Count(), kalem = g.Count(),
                liste = g.Sum(x => x.Liste), iskonto = g.Sum(x => x.Iskonto),
                oran = g.Sum(x => x.Liste) > 0 ? Math.Round(100 * g.Sum(x => x.Iskonto) / g.Sum(x => x.Liste), 1) : 0m,
            }).OrderByDescending(x => x.iskonto).ToList();

            var toplamIskonto = iskontolu.Sum(x => x.Iskonto);
            var ucretsizTutar = ucretsiz.Sum(x => x.Liste);
            var ozet = new
            {
                basvuru = basvurular.Count,
                iskonto = toplamIskonto,
                talepli = iskontolu.Where(x => x.Kaynak == "talep").Sum(x => x.Iskonto),
                kampanya = iskontolu.Where(x => x.Kaynak == "kampanya").Sum(x => x.Iskonto),
                banko = iskontolu.Where(x => x.Kaynak == "banko").Sum(x => x.Iskonto),
                ucretsiz = ucretsizTutar, ucretsizKalem = ucretsiz.Count,
                ortOran = iskontolu.Sum(x => x.Liste) > 0 ? Math.Round(100 * toplamIskonto / iskontolu.Sum(x => x.Liste), 1) : 0m,
                esik, esikUstu = basvurular.Count(x => x.esikUstu),
                red = redler.Count, redTutar = redler.Sum(x => x.istenen),
                personel = iskontolu.Where(x => Kategori(x.Gerekce).Contains("Personel", StringComparison.OrdinalIgnoreCase)).Sum(x => x.Iskonto),
                ciro, ciroOrani = ciro > 0 ? Math.Round(100 * (toplamIskonto + ucretsizTutar) / ciro, 2) : 0m,
            };

            return Results.Ok(new
            {
                donem = new { bas = baslangic, bit = sonGun },
                ozet, basvurular,
                onaylayanaGore = Gruplu(iskontolu.Where(x => x.Kaynak == "talep").GroupBy(x => x.Onaylayan is { Length: > 0 } a ? a : "(bilinmiyor)")),
                // Talep edene / bankoya göre: talepte isteyen, talepsizde başvuruyu açan görevli.
                verenGore = Gruplu(iskontolu.GroupBy(x => x.Kaynak == "talep" && x.Isteyen.Length > 0 ? x.Isteyen : x.Banko is { Length: > 0 } bn ? bn : "(bilinmiyor)")),
                gerekceGore = Gruplu(iskontolu.GroupBy(x => x.Kaynak == "talep" ? Kategori(x.Gerekce)
                                                          : x.Kaynak == "kampanya" ? "Kampanya" : "Banko (talepsiz)")),
                ucretsizler = ucretsiz.Select(x => new { x.BelgeId, x.ProtokolNo, tarih = x.Tarih, x.Hasta, x.Bolum, x.Hekim, x.Hizmet, x.Liste, x.Kaynak, x.Gerekce, x.Onaylayan }),
                redler,
            });
        });
    }
}
